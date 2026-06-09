# Quick Start

This example shows the complete VPopMIP workflow on a small in-memory dataset:

1. load simulated virtual patients into a `VirtualPopulation`;
2. define clinical summary data in a metric table;
3. select the subset that best matches the target data.

## Load Simulations

The simulation table must contain an `id` column, a `scenario` column, and one or more endpoint columns. Here, `response` is the endpoint we want to match.

```@example quickstart
using VPopMIP, DataFrames

sim_df = DataFrame(
    id = 1:8,
    scenario = fill("dose_a", 8),
    response = [0.2, 0.4, 0.6, 1.8, 2.0, 2.2, 3.4, 3.8],
)

vpop0 = load_vpop(sim_df; endpoints = ["response"])
```

## Define Clinical Data

Clinical data are represented as a metric table. Each row states which scenario and endpoint to match, and which summary statistic should be used as the target.

```@example quickstart
metric_df = DataFrame(
    id = ["response_mean_sd"],
    scenario = ["dose_a"],
    endpoint = ["response"],
    var"metric.type" = ["mean_sd"],
    var"metric.size" = [3],
    var"metric.mean" = [2.0],
    var"metric.sd" = [sqrt(0.08 / 3)],
)

data = parse_metric_bindings(metric_df);
```

## Subset the VPop

Use `subset_vpop` to select the requested number of virtual patients. The result is also a `VirtualPopulation`.

```@example quickstart
vpop = subset_vpop(vpop0, data, 3; scip_limits_gap = 0.0, time_limit = 10.0, silent = true)
```

The selected subset can be summarized against the same clinical data.

```@example quickstart
ss = statistics_summary(vpop, data)
ss.stats
```
