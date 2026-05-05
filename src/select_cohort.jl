
"""
    select_cohort(pop::VirtualPopulation, data::Vector{M}, vpnum::Int; kwargs...) where {M<:DigiPopData.MetricBinding}

Select a cohort of virtual patients from a `VirtualPopulation` that best matches the provided data. The selection is performed by solving a Mixed-Integer Programming (MIP) optimization problem.
# Arguments
- `pop::VirtualPopulation`: The DataFrame with plausiblel population from which to select the cohort. 
- `data::Vector{M}`: A vector of metric bindings that define the data to match. See DigiPopData.jl for details on how to create metric bindings.
- `vpnum::Int`: The desired size of the virtual population cohort to be selected.
- `kwargs...`: Additional keyword arguments for the optimization solver (e.g., optimizer choice, time limits, etc.).
"""
function select_cohort(pop::VirtualPopulation, data::Vector{M}, vpnum::Int; kwargs...) where {M<:DigiPopData.MetricBinding}

  @assert (0 < vpnum <= length(pop)) "Virtual Population size `vpnum` should be in the interval vpnum ∈ (0, $(length(pop))]." 

  has_preselected(pop) && (@assert sum(pop.preselected) < vpnum "Number of pre-selected VP must be less than `vpnum`.")
  @info "Generating optimization problem."
  prob = build_mip_prob(pop, data, vpnum)

  @info "Solving optimization problem."
  vpop = solve_mip_prob(prob, pop; kwargs...)
  
  return vpop
end

function solve_mip_prob(prob, pop; 
  optimizer = SCIP.Optimizer, multialg = nothing, scip_limits_gap = 0.0, time_limit = 1e20)

  if isnothing(multialg)
    JuMP.set_optimizer(prob, optimizer)
  else
    JuMP.set_optimizer(prob, () -> MOA.Optimizer(optimizer))
    JuMP.set_attribute(prob, MOA.Algorithm(), multialg)
  end

  if optimizer == SCIP.Optimizer 
    JuMP.set_attribute(prob, "limits/gap", scip_limits_gap)
    JuMP.set_attribute(prob, "limits/time", time_limit)
  end

  JuMP.optimize!(prob)

  if JuMP.termination_status(prob) == MathOptInterface.OPTIMAL
    idxs = round.(Int, JuMP.value.(prob[:x]))

    grdf = groupby(DataFrame(pop), SCENARIO_COL)
    df_cohort = combine(grdf) do g
      g[Bool.(idxs), :]
    end
    return VirtualPopulation(df_cohort, endpoints(pop), scenarios(pop), sum(idxs), pop.preselected, JuMP.objective_value(prob))
  else 
    println("No solution found. Check your setup or choose a different Virtual Population size `vpnum`.")
    return nothing
  end
end


function build_mip_prob(pop, data, vpnum)
  
  popnum = length(pop)
  datanum = length(data)

  grpop = groupby(DataFrame(pop), SCENARIO_COL)

  prob = JuMP.Model()
  JuMP.@variable(prob, x[i=1:popnum], Bin)

  # constaints on vpop size
  @constraint(prob, sum(x[i] for i in 1:popnum) == vpnum)

  # preselected VPs
  if has_preselected(pop)
    !(0 < sum(pop.preselected) <= vpnum) && throw(ArgumentError("Number of pre-selected VP must be in the interval (0, $(vpnum)]."))
    preselected_ids = findall(pop.preselected)
    @constraint(prob, [i = preselected_ids], x[i] == 1)
  end

  @variable(prob, z_ept[i=1:datanum])
  for (j, mb) in enumerate(data)
    ept = mb.endpoint
    scn = mb.scenario
    metric = mb.metric
    has_scenario(pop, scn) || throw(ArgumentError("Scenario '$scn' not found in the Virtual Population."))
    has_endpoint(pop, ept) || throw(ArgumentError("Endpoint '$ept' not found in the Virtual Population."))

    if has_vp_include(pop) 
      include_vp = Bool.(Vector(grpop[(scn,)][!, VPINCLUDE_COL]))
      sim = Vector(grpop[(scn,)][include_vp, ept])    
      X = x[include_vp]
      metric.size > vpnum && throw(ArgumentError("Metric size should be less than or equal to `vpnum`."))
      obj_exp = DigiPopData.add_mismatch_expression!(prob, sim, metric, X, metric.size)
    else
      sim = float.(Vector(grpop[(scn,)][!, ept]))
      X = x 
      obj_exp = DigiPopData.add_mismatch_expression!(prob, sim, metric, X, vpnum)
    end
    

    @constraint(prob, z_ept[j] == obj_exp)
  end

  @objective(prob, Min, sum(z_ept[i] for i in 1:datanum))

  return prob
end
