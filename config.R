# Central configuration
SEED <- 123
N_PM <- 15
N_BEHAVIOR <- 17
N_BRAIN <- 268
N_COMPONENTS <- 15
N_CV_REPEATS <- 100
N_CV_FOLDS <- 10
N_PERM <- 1000
MODAL_INPUT <- "data/residualized_pollution_behavior_modal.csv"
AVERAGE_INPUT <- "data/residualized_pollution_behavior_average.csv"
RESULT_DIR <- "results"
PM_NAMES <- c("OC","EC","NO3","SO4","NH4","Br","Ca","Si","Fe","Cu","Zn","Pb","K","Ni","V")
BEHAVIOR_NAMES <- c("Rule-breaking behavior","Conduct problems","Stress problems","Aggressive behavior","Oppositional defiant problems","Depressive problems","Anxious/depressed","Anxiety problems","Obsessive-compulsive problems","Attention problems","Attention-deficit/hyperactivity problems","Somatic complaints","Somatic problems","Social problems","Thought problems","Withdrawn/depressed","Sluggish cognitive tempo")
dir.create(RESULT_DIR, showWarnings = FALSE)
set.seed(SEED)
