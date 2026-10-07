source("R/config.R")
source("R/helpers_smcca.R")
dat <- read.csv(MODAL_INPUT,check.names=FALSE)
expected_ncol <- N_PM+N_BEHAVIOR+N_BRAIN
stopifnot(ncol(dat)>=expected_ncol)
dat_scaled <- scale(dat[,seq_len(expected_ncol)])
xlist_modal <- make_xlist(dat_scaled,N_PM,N_BEHAVIOR,N_BRAIN)
saveRDS(xlist_modal,file.path(RESULT_DIR,"xlist_modal.rds"))
