
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
  optimizer = SCIP.Optimizer, multialg = nothing, scip_limits_gap = 0.0)

  if isnothing(multialg)
    JuMP.set_optimizer(prob, optimizer)
  else
    JuMP.set_optimizer(prob, () -> MOA.Optimizer(optimizer))
    JuMP.set_attribute(prob, MOA.Algorithm(), multialg)
  end

  if optimizer == SCIP.Optimizer 
    JuMP.set_attribute(prob, "limits/gap", scip_limits_gap)
  end

  JuMP.optimize!(prob)

  if JuMP.termination_status(prob) == MathOptInterface.OPTIMAL
    idxs = round.(Int, JuMP.value.(prob[:x]))
    return VirtualPopulation(DataFrame(pop)[Bool.(idxs),:], endpoints(pop), scenarios(pop), sum(idxs), pop.preselected)
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
  if has_preselected(pop) && sum(pop.preselected) > 0
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
    
    obj_exp = DigiPopData.mismatch_expression(Vector(grpop[(scn,)][!, ept]), metric, x, vpnum)
    @constraint(prob, z_ept[j] == obj_exp)
  end

  @objective(prob, Min, sum(z_ept[i] for i in 1:datanum))

  return prob
end
