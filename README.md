# VPopMIP.jl

`VPopMIP.jl` selects a virtual population from a larger plausible population using mixed-integer optimization.

[![Build Status](https://github.com/hetalang/VPopMIP.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/hetalang/VPopMIP.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://hetalang.github.io/VPopMIP.jl/dev)

> ⚠️ This package is under development.

## Why this package?

`VPopMIP.jl` implements a cohort-selection workflow where a large plausible population is filtered into a smaller virtual population that matches reported clinical results (summary statistics and individual patients data). The approach is formulated as a mixed-integer programming (MIP) problem and is designed for practical QSP calibration workflows.

## Installation

```julia
using Pkg

Pkg.add(url="https://github.com/hetalang/DigiPopData.jl")
Pkg.add(url="https://github.com/hetalang/VPopMIP.jl")
```

## Quick start

See more details in the documentation [here](https://hetalang.github.io/VPopMIP.jl/dev).

```julia
using CSV, DataFrames
using VPopMIP

# load clinical data
metrics_df = CSV.File("metrics.csv", DataFrame)
data = parse_metric_bindings(metrics_df)

# load VP simulations
vpop_df = CSV.File("vpop.csv", DataFrame)
cohort = load_vpop(vpop_df)

# select optimal sub-cohort of size 100
sub_cohort = select_cohort(cohort, data, 100)
statistics_summary(sub_cohort, data)
```

## Citation

E. Metelkin and I. Borisov, "Mixed-Integer Optimization for Virtual Population Selection in QSP Models", 2026, doi: [10.13140/RG.2.2.31274.79049](https://doi.org/10.13140/RG.2.2.31274.79049).
