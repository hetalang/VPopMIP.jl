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
include("subset_vpop.jl")
include("stats.jl")
include("plotting.jl")


export load_vpop, subset_vpop, scenarios, endpoints, objective_value, statistics_summary

end
