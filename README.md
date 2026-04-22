# VPopMIP.jl

Virtual population (VPop) selection for Quantitative Systems Pharmacology (QSP) using mixed-integer optimization.

[![Build Status](https://github.com/hetalang/VPopMIP.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/hetalang/VPopMIP.jl/actions/workflows/CI.yml?query=branch%3Amaster)

> ⚠️ This package is under active development.

## Why this package?

`VPopMIP.jl` implements a cohort-selection workflow where a large plausible population is filtered into a smaller virtual population that matches reported clinical summary statistics. The approach is formulated as a mixed-integer programming (MIP) problem and is designed for practical QSP calibration workflows.

This draft README is based on your poster:
- “Mixed-Integer Optimization for Virtual Population Selection in QSP Models”
- Two-step process: generate plausible patients, then optimize selection against reported endpoints
- Endpoint support highlighted in the poster: mean/sd, quantiles, and progression-free/survival curves

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/hetalang/VPopMIP.jl")
```

## Core idea

Given:
- A plausible population (`DataFrame`) with one row per virtual patient per scenario
- Clinical targets represented as metric bindings (from `DigiPopData.jl`)
- Desired cohort size `vpnum`

The package solves:

- decision variable `xᵢ ∈ {0,1}` for inclusion of candidate `i`
- size constraint `Σxᵢ = vpnum`
- optional hard constraints for preselected candidates
- objective: minimize total mismatch across endpoint/metric targets

## Input table schema

At minimum, the plausible population table must include:

- `id` (patient identifier)
- `scenario` (regimen / treatment arm / simulation scenario)
- one or more endpoint columns (numeric)

Optional columns:
- `preselected` (`Bool`) to force inclusion
- `include` (`Bool`) to include/exclude rows from objective calculations

## Quick start

```julia
using VPopMIP
using DataFrames
using DigiPopData

# 1) Create/load plausible population
pop_df = DataFrame(
    id = ["p1", "p2", "p3", "p1", "p2", "p3"],
    scenario = ["drug", "drug", "drug", "placebo", "placebo", "placebo"],
    sld_baseline = [80.0, 95.0, 110.0, 82.0, 92.0, 108.0],
    best_dsld = [-35.0, -20.0, -10.0, -10.0, -5.0, 0.0],
)
vpop_plausible = load_vpop(pop_df)

# 2) Define fitting targets
mb1 = MetricBinding("drug", "sld_baseline", MeanSDMetric(90.0, 20.0))
mb2 = MetricBinding("drug", "best_dsld", QuantileMetric([-30.0, -20.0, -10.0], [0.25, 0.5, 0.75]))

# 3) Select a cohort of size 2
vpop_selected = select_cohort(vpop_plausible, [mb1, mb2], 2)

# 4) Inspect quality
summary_df = statistics_summary(vpop_selected, [mb1, mb2])
println(summary_df)
println("Objective value: ", objective_value(vpop_selected))
```

## Exported API

- `load_vpop(pop::DataFrame; endpoints=nothing)`
- `select_cohort(pop::VirtualPopulation, data::Vector{<:MetricBinding}, vpnum::Int; kwargs...)`
- `scenarios(vpop)`, `endpoints(vpop)`, `objective_value(vpop)`
- `statistics_summary(vpop, data)`
- `compute_statistics(...)`

## Current limitations

As highlighted in your poster, practical limitations include:
- Increasing MIP complexity with plausible population size and number of endpoints
- Dependence on diversity in plausible patients to make good matching feasible

## Documentation draft

A starter documentation structure is included in `docs/`:
- `docs/src/index.md` for package overview
- `docs/src/methodology.md` for MIP formulation and assumptions
- `docs/src/tutorial.md` for step-by-step usage

## Reference

If you use this package, please cite the associated methodology and poster materials from the project.
