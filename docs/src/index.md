# VPopMIP.jl

`VPopMIP.jl` is a Julia package for selecting virtual populations (VPops) from QSP simulation outputs using mixed-integer optimization.

## Glossary

The key concept used throughout the package is the Virtual Population.

A Virtual Population (VPop) is an ensemble of QSP model parameterizations generated to capture the observed statistics of the clinical population of interest. A member of a Virtual Population is referred to as a Virtual Patient.

The package is designed around the `VirtualPopulation` object, which stores QSP model simulation results for different drug regimens and clinical endpoints. The package exports two main functions to operate with `VirtualPopulation`:

- `load_vpop` constructs a `VirtualPopulation` object from a DataFrame.
- `subset_vpop` selects Virtual Patients from a `VirtualPopulation` that best match clinical data and returns the selected subset as another `VirtualPopulation` object.

## Problem addressed

The goal of generating a Virtual Population (VPop) is to support drug development by predicting the variability in patient responses observed in clinical trials. Several VPop generation methods were proposed [1], [2]. Nevertheless, their practical application in realworld QSP projects is often limited by project-specific challenges, including:

- Endpoints specificity. Clinical efficacy endpoints often involve time-to-event outcomes, or survival data, which are not directly represented by the mechanistic model states and therefore require additional mapping or transformation.
- Limited availability of individual patient data. Clinical results are frequently reported as aggregate statistics (e.g., response rates, survival probabilities), while individual-level data may be limited or unavailable.
- Computational complexity. The problem becomes increasingly demanding as the number of endpoints and therapies grows.

`VPopMIP.jl` provides a unified optimization formulation to handle these constraints.

## Method

**VPopMIP provides a method for selecting a subset from an existing virtual population so that the selected subset matches clinical data.** In practice, the method chooses a subset of patients from a generated population and optimizes it against reported clinical endpoints data.

The selection problem is formulated as a mixed-integer programming (MIP) problem. Binary variables x_i in {0,1} indicate whether a patient is included in the VPop, subject to a constraint on the desired VPop size. The objective function minimizes the mismatch between simulated and experimental data across multiple clinical endpoints. Since individual patient data are often unavailable, the method focuses on endpoints reported as statistics, such as means, std, quantiles, and survival data.

Details on the mathematical formulation of the objective function terms, corresponding to different types of clinical data, can be found in [DigiPopData package documentation](https://hetalang.github.io/DigiPopData.jl/dev/). 

> The approach corresponds to the selection step of the two-step VPop framework described in [2] but it can be applied to general virtual populations.

## Citation

1. G. Kolesova, A. Stepanov, G. Lebedeva, and O. Demin, "Application of different approaches to generate virtual patient populations for the quantitative systems pharmacology model of erythropoiesis," J Pharmacokinet Pharmacodyn, vol. 49, no. 5, pp. 511-524, Oct. 2022, doi:10.1007/s10928-022-09814-y.
2. N. Braniff et al., "An integrated quantitative systems pharmacology virtual population approach for calibration with oncology efficacy endpoints," CPT Pharmacom & Syst Pharma, p. psp4.13270, Nov. 2024, doi: 10.1002/psp4.13270.
