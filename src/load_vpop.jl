
"""
    VirtualPopulation{D,SC,S}

A struct representing a Virtual Population.

### Fields
- `df::D`: A DataFrame containing the virtual population data.
- `scenarios::SC`: A collection of scenarios associated with the virtual population.
- `npop::Int64`: The number of individuals in the virtual population. 
- `preselected::S`: Pre-selected individuals in the virtual population.

Use `load_vpop(pop::DataFrame)` to create an instance of `VirtualPopulation` from DataFrame.
"""
struct VirtualPopulation{D,E,SC,S}
  df::D
  endpoints::E
  scenarios::SC
  npop::Int64
  preselected::S
end

Base.show(io::IO, mime::MIME"text/plain", vpop::VirtualPopulation) =
  println(io, "Virtual Population." * "\n" *
              "Number of Virtual Patients: $(length(vpop))." * "\n" * 
              "Number of pre-selected candidates: $(has_preselected(vpop) ? sum(vpop.preselected) : 0).")

Base.length(vpop::VirtualPopulation) = vpop.npop
DataFrames.DataFrame(vpop::VirtualPopulation) = vpop.df
endpoints(vpop::VirtualPopulation) = vpop.endpoints
scenarios(vpop::VirtualPopulation) = vpop.scenarios
has_endpoint(vpop::VirtualPopulation, ep) = ep in endpoints(vpop)
has_scenario(vpop::VirtualPopulation, scn) = scn in scenarios(vpop)
has_preselected(vpop::VirtualPopulation) = !isnothing(vpop.preselected)

"""
    load_vpop(pop::DataFrame) -> VirtualPopulation

Load Virtual Population from a DataFrame.
"""
function load_vpop(pop::DataFrame; endpoints=nothing)
  !hasproperty(pop, VPID_COL) &&  throw(ArgumentError("$VPID_COL column not found in the Virtual Population table."))
  !hasproperty(pop, SCENARIO_COL) &&  throw(ArgumentError("$SCENARIO_COL column not found in the Virtual Population table."))
  
  if isnothing(endpoints) 
    epts = names(pop, Not([VPID_COL, SCENARIO_COL]))
  else
    for ept in endpoints
      !hasproperty(pop, ept) && throw(ArgumentError("Endpoint column '$ept' not found in the Virtual Population table."))
    end
  end

  @info "Loading Virtual Population."
  npop = length(unique(pop[!,VPID_COL]))
  scenarios = unique(pop[!,SCENARIO_COL])
  preselected = nothing # no pre-selection by default

  return VirtualPopulation(pop, epts, scenarios, npop, preselected)
end
