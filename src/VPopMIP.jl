module VPopMIP

using Reexport
@reexport using DigiPopData
using DataFrames
using JuMP, MathOptInterface, SCIP

const VPID_COL = "id"
const SCENARIO_COL = "scenario"

include("load_vpop.jl")
include("select_cohort.jl")
include("stats.jl")
include("plotting.jl")


export load_vpop, select_cohort, scenarios, endpoints, statistics_summary, compute_statistics

end
