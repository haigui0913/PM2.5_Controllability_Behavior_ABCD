source("R/config.R")
source("R/helpers_interaction.R")
# Rural is the reference category in the manuscript analysis.
# Example: fit_group_interaction(brain_score,pollution_score,rural_urban,reference_level="Rural")
# Repeat for pollution-brain, pollution-behavior, and brain-behavior across M1-M4.
# Apply p.adjust(p_interaction, method="BH") across the 12 interaction tests.
message("Verify factor coding before interpreting the sign of the interaction coefficient.")
