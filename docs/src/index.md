# VPopMIP.jl

`VPopMIP.jl` is a Julia package for selecting virtual populations (VPops) from plausible QSP simulation outputs using mixed-integer optimization.

## Problem addressed

The goal of generating a Virtual Population (VPop) is to support drug development by predicting the variability in patient responses observed in clinical trials. Several VPop generation methods were proposed [1], [2]. Nevertheless, their practical application in realworld QSP projects is often limited by project-specific challenges, including:

- Endpoints specificity. Clinical efficacy endpoints often involve time-to-event outcomes, or survival data, which are not directly represented by the mechanistic model states and therefore require additional mapping or transformation.
- Limited availability of individual patient data. Clinical results are frequently reported as aggregate statistics (e.g., response rates, survival probabilities), while individual-level data may be limited or unavailable.
- Computational complexity. The problem becomes increasingly demanding as the number of endpoints and therapies grows.

`VPopMIP.jl` provides a unified optimization formulation to handle these constraints.

## Method

**The method implemented in VPopMIP addresses step 2 (cohort selection)** of the two-step framework described in [2], while step 1 (plausible population generation) is outside the scope of this package. The general outline of the framework is as follows:

1. **Generation of a plausible population**
The researcher defines ranges and distributions for model parameters and performs simulations using sampled parameter values. Each simulation, together with its corresponding parameter set, is accepted if all model outputs fall within predefined biologically plausible ranges; otherwise, it is rejected. The goal of this step is to generate a large and diverse set of plausible patients.

2. **Selection of a VPop from the plausible population**
Although the plausible population satisfies biological constraints, it does not necessarily reproduce clinical trial outcomes. The goal of this step is therefore to select a subset of patients that matches reported clinical endpoints.
This subset selection problem is formulated as a mixed-integer programming (MIP) problem. Binary variables 𝑥𝑖 ∈ {0,1} indicate whether a plausible patient is included in the VPop, subject to a constraint on the desired VPop size. The objective function minimizes the mismatch between simulated and experimental data across multiple clinical endpoints.
Since individual patient data are often unavailable, the method focuses on endpoints reported as cohort-level statistics, such as means, std, quantiles, and survival data.

Details on the mathematical formulation of the objective function terms, corresponding to different types of clinical data, can be found in DigiPopData package documentation:
https://hetalang.github.io/DigiPopData.jl/dev/

## Citation

1. G. Kolesova, A. Stepanov, G. Lebedeva, and O. Demin, “Application of different approaches to
generate virtual patient populations for the quantitative systems pharmacology model of
erythropoiesis,” J Pharmacokinet Pharmacodyn, vol. 49, no. 5, pp. 511–524, Oct. 2022, doi:
10.1007/s10928-022-09814-y.
2. N. Braniff et al., “An integrated quantitative systems pharmacology virtual population approach for
calibration with oncology efficacy endpoints,” CPT Pharmacom & Syst Pharma, p. psp4.13270, Nov.
2024, doi: 10.1002/psp4.13270.