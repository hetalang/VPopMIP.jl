# VPopMIP.jl

Virtual population (VPop) selection for Quantitative Systems Pharmacology (QSP) using mixed-integer optimization.

[![Build Status](https://github.com/hetalang/VPopMIP.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/hetalang/VPopMIP.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://hetalang.github.io/VPopMIP.jl/dev)

> ⚠️ This package is under development.

## Why this package?

`VPopMIP.jl` implements a cohort-selection workflow where a large plausible population is filtered into a smaller virtual population that matches reported clinical results (summary statistics and individual patients data). The approach is formulated as a mixed-integer programming (MIP) problem and is designed for practical QSP calibration workflows.

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/hetalang/VPopMIP.jl")
```

## Citation

E. Metelkin and I. Borisov, “Mixed-Integer Optimization for Virtual Population Selection in QSP Models,” 2026, doi: 10.13140/RG.2.2.31274.79049.