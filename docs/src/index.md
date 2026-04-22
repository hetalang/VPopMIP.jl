# VPopMIP.jl

`VPopMIP.jl` is a Julia package for selecting virtual populations (VPops) from plausible QSP simulation outputs using mixed-integer optimization.

This documentation draft follows the workflow described in your poster:

1. Generate a biologically plausible population.
2. Select a VPop subset that matches reported clinical summary statistics.

## Problem addressed

Traditional VPop selection often becomes difficult when:
- endpoints are reported as aggregate statistics rather than individual data,
- endpoints differ in type (means/SD, quantiles, survival),
- and model complexity grows across scenarios and regimens.

`VPopMIP.jl` provides a unified optimization formulation to handle these constraints.

## Feature highlights

- Cohort selection via binary MIP decision variables.
- Multiple metric types through `DigiPopData.jl` metric bindings.
- Optional pre-selection constraints.
- Summary-statistics post-check functions.
- Plot recipes for visual comparison of simulation and clinical targets.

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/hetalang/VPopMIP.jl")
```

## Minimal workflow

```julia
using VPopMIP, DataFrames, DigiPopData

# plausible population table
pop = DataFrame(
    id = ["p1", "p2", "p3", "p1", "p2", "p3"],
    scenario = ["drug", "drug", "drug", "placebo", "placebo", "placebo"],
    endpoint_a = [1.0, 2.1, 2.9, 1.2, 2.0, 3.2],
)

vpop = load_vpop(pop)

target = MetricBinding("drug", "endpoint_a", MeanMetric(2.0))
selected = select_cohort(vpop, [target], 2)

statistics_summary(selected, [target])
```

See [Methodology](methodology.md) for formulation details and [Tutorial](tutorial.md) for a fuller worked example.
