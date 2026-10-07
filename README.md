# PM2.5–Brain Controllability–Behavior Analysis in the ABCD Study

This repository contains reproducible R code for multivariate analyses of residential PM2.5 chemical constituents, brain network controllability, and behavioral traits in early adolescence.

## Study domains
- **Environmental exposure:** 15 PM2.5 chemical constituents
- **Brain:** regional controllability measures from the 268-node Shen atlas
- **Behavior:** 17 Child Behavior Checklist (CBCL) domains

Modal controllability is the primary analysis; average controllability is a sensitivity analysis.

## Repository structure
```text
R/config.R
R/helpers_smcca.R
R/helpers_interaction.R
code/01_prepare_inputs.R
code/02_modal_smcca_main.R
code/03_modal_loadings_and_tables.R
code/04_modal_cross_validation.R
code/05_modal_permutation_test.R
code/06_sex_sensitivity.R
code/07_rural_urban_sensitivity.R
code/08_average_controllability_sensitivity.R
code/09_session_info.R
```

## Key analysis definitions
Canonical loadings are Pearson correlations between each standardized observed variable and its corresponding domain-specific canonical variate.

For brain results, loadings are calculated for all 268 regions, while the 10 largest positive and 10 most negative loadings are selected for visualization.

Repeated cross-validation uses 100 repetitions of 10-fold CV. Within each repetition, the 10 held-out fold sum-of-r values are averaged. Reported `mean ± SD` therefore refers to the mean and SD across the 100 repetition-specific averages.

Permutation testing uses the same held-out sum-of-r statistic for observed and null data. The provided implementation independently permutes Pollution and Behavior relative to Brain, preserving within-block covariance while breaking cross-domain subject correspondence. If the final manuscript uses a different null scheme, update `run_cv_permutation()` accordingly.

## Data availability
Individual-level ABCD Study data are restricted and are not included in this repository. Do not commit participant-level data, identifiers, or restricted metadata.

## Reproducibility
All local absolute file paths have been removed. Update file locations in `R/config.R`, then run scripts in numerical order.

## Required R packages
`PMA`, `cvTools`, `dplyr`, `tidyr`, `ggplot2`, `purrr`, `readr`

## Citation
Please cite the associated manuscript once published.
