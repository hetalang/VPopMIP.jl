using DataFrames

sim_df = DataFrame(
    id = 1:8,
    scenario = fill("dose_a", 8),
    response = [0.2, 0.4, 0.6, 1.8, 2.0, 2.2, 3.4, 3.8],
)

vpop0 = load_vpop(sim_df; endpoints = ["response"])

metric_df = DataFrame(
    id = ["response_mean_sd"],
    scenario = ["dose_a"],
    endpoint = ["response"],
    var"metric.type" = ["mean_sd"],
    var"metric.size" = [3],
    var"metric.mean" = [2.0],
    var"metric.sd" = [sqrt(0.08 / 3)],
)

data = parse_metric_bindings(metric_df)
vpop = subset_vpop(vpop0, data, 3; scip_limits_gap = 0.0, time_limit = 10.0, silent = true)
vpop_df = sort(DataFrame(vpop), :id)

@test vpop_df.id == [4, 5, 6]
@test vpop_df.response == [1.8, 2.0, 2.2]
@test objective_value(vpop) ≈ 0.0 atol = 1e-8

summary_df = statistics_summary(vpop, data)
summary = summary_df[1, :stats]

@test summary_df.scenario == ["dose_a"]
@test summary_df.endpoint == ["response"]
@test summary[:mean] ≈ 2.0
@test summary[:std] ≈ 0.2
