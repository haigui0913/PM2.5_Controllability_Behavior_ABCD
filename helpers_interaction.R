fit_group_interaction <- function(outcome,predictor,group,reference_level=NULL){
  dat <- data.frame(outcome=outcome,predictor=predictor,group=factor(group))
  if(!is.null(reference_level)) dat$group <- stats::relevel(dat$group,ref=reference_level)
  fit <- stats::lm(outcome ~ predictor*group,data=dat)
  list(fit=fit,coefficients=summary(fit)$coefficients,r2=summary(fit)$r.squared,adj_r2=summary(fit)$adj.r.squared)
}
