# TODO

## ISSUES from Metelkin

- We need code in tutorial to be automatically tested. Previous code does not working because of changes in the API and not normailized data! Or you must always check manually.

- Tutorial run must be less than 5 minutes. Simplier task or force limit for optimization.

- Tutorial is too complicated.

- We need very simple "Quick start" example in README.md. Should we share files to run the example?

- Not clear why endpoints, scenarios, preselected don't have particular types. Internal normalization required.

- Need to have clear sytematics of terms: create clear glossary!!!
    - individuals vs patients vs candidates
    - cohort vs population
    - plausible population vs virtual population - we don't need "plausible population" term at all
    - selected cohort vs selected subset vs subpopulation

- solve_mip_prob: mixed level of abstraction, should not return VirtualPopulation

- statistics_summary vs compute_statistics - why we need both? Unclear names and goal of both functions.

- Mixture of meanings in the structure of VirtualPopulation: Same object means whole set and result of optimization.

- Refactoring: We should introduce an object that stores the intermediate optimization state, so we can support rerunning the solver with a warm start. It is also worth reconsidering how the result is returned, since instead of materializing a filtered population immediately, we may want to store the selection state and derive the final population from it.
