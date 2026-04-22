# Tutorial

This tutorial gives an end-to-end draft workflow.

## 1) Prepare plausible population

```julia
using VPopMIP, DataFrames, DigiPopData

pop_df = DataFrame(
    id = ["p1", "p2", "p3", "p4", "p1", "p2", "p3", "p4"],
    scenario = ["drug", "drug", "drug", "drug", "placebo", "placebo", "placebo", "placebo"],
    sld_baseline = [70.0, 80.0, 95.0, 120.0, 72.0, 79.0, 90.0, 118.0],
    best_dsld = [-40.0, -30.0, -20.0, -5.0, -15.0, -10.0, 0.0, 10.0],
)

vpop_plausible = load_vpop(pop_df)
```

## 2) Define clinical targets

```julia
targets = [
    MetricBinding("drug", "sld_baseline", MeanSDMetric(90.0, 20.0)),
    MetricBinding("drug", "best_dsld", QuantileMetric([-30.0, -20.0, -10.0], [0.25, 0.5, 0.75])),
]
```

## 3) Run cohort selection

```julia
vpop_selected = select_cohort(vpop_plausible, targets, 3)
```

Optional solver tuning:

```julia
vpop_selected = select_cohort(
    vpop_plausible,
    targets,
    3;
    scip_limits_gap = 0.01,
    time_limit = 60.0,
)
```

## 4) Evaluate selected cohort

```julia
summary_df = statistics_summary(vpop_selected, targets)
println(summary_df)
println("Objective value: ", objective_value(vpop_selected))
```

## 5) Plot comparisons

If you use `Plots.jl`, recipe methods allow plotting target-vs-selected behavior directly:

```julia
using Plots
plot(vpop_selected, targets)
```

## Data requirements checklist

- Include `id` and `scenario` columns.
- Keep endpoint names consistent with target bindings.
- Ensure scenario labels in targets exist in the VPop table.
- Use realistic plausible populations to improve match quality.
