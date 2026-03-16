module VPopMIP

using Reexport
@reexport using DigiPopData
using DataFrames
using JuMP, MathOptInterface, SCIP

const VPID_COL = "id"
const SCENARIO_COL = "scenario"
const PRESELECTED_COL = "preselected"
const VPINCLUDE_COL = "include"

include("load_vpop.jl")
include("select_cohort.jl")
include("stats.jl")
include("plotting.jl")


export load_vpop, select_cohort, scenarios, endpoints, objective_value, statistics_summary, compute_statistics

end
