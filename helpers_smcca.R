make_xlist <- function(dat_scaled, n_pm=15, n_behavior=17, n_brain=268){
  expected <- n_pm+n_behavior+n_brain
  stopifnot(ncol(dat_scaled)>=expected)
  list(Pollution=as.matrix(dat_scaled[,1:n_pm,drop=FALSE]),
       Behavior=as.matrix(dat_scaled[,(n_pm+1):(n_pm+n_behavior),drop=FALSE]),
       Brain=as.matrix(dat_scaled[,(n_pm+n_behavior+1):expected,drop=FALSE]))
}

fit_smcca <- function(xlist, penalties, ws_init, ncomponents=15){
  PMA::MultiCCA(xlist,type=c("standard","standard","standard"),penalty=penalties,ncomponents=ncomponents,ws=ws_init,trace=FALSE)
}

get_variates <- function(xlist, fit){
  list(Pollution=xlist[[1]]%*%fit$ws[[1]], Behavior=xlist[[2]]%*%fit$ws[[2]], Brain=xlist[[3]]%*%fit$ws[[3]])
}

calc_loadings <- function(X, scores){
  out <- sapply(seq_len(ncol(scores)), function(k) apply(X,2,stats::cor,y=scores[,k],use="pairwise.complete.obs"))
  if(is.null(dim(out))) out <- matrix(out,ncol=1)
  out
}

pairwise_sum_r <- function(a,b,c){
  rmat <- stats::cor(cbind(a,b,c),use="pairwise.complete.obs")
  sum(rmat[upper.tri(rmat)])
}

pairwise_cor_table <- function(variates,ncomponents){
  dplyr::bind_rows(lapply(seq_len(ncomponents),function(k){
    rmat <- stats::cor(cbind(Pollution=variates$Pollution[,k],Behavior=variates$Behavior[,k],Brain=variates$Brain[,k]),use="pairwise.complete.obs")
    data.frame(Mode=paste0("M",k),Pollution_Brain=rmat["Pollution","Brain"],Pollution_Behavior=rmat["Pollution","Behavior"],Brain_Behavior=rmat["Brain","Behavior"],Sum_of_r=sum(rmat[upper.tri(rmat)]))
  }))
}

top_brain_loadings <- function(load_vec,top_n=10){
  pos <- order(load_vec,decreasing=TRUE)[seq_len(top_n)]
  neg <- order(load_vec,decreasing=FALSE)[seq_len(top_n)]
  rbind(data.frame(Brain_region=pos,Loading=load_vec[pos],Direction="Positive"),data.frame(Brain_region=neg,Loading=load_vec[neg],Direction="Negative"))
}

run_repeated_cv <- function(xlist,penalties,ws_init,ncomponents=15,n_repeats=100,n_folds=10,seed=123){
  set.seed(seed)
  folds <- cvTools::cvFolds(nrow(xlist[[1]]),K=n_folds,R=n_repeats,type="random")
  arr <- array(NA_real_,dim=c(n_repeats,n_folds,ncomponents))
  for(r in seq_len(n_repeats)){
    for(f in seq_len(n_folds)){
      train_idx <- folds$subsets[,r][folds$which != f]
      test_idx  <- folds$subsets[,r][folds$which == f]
      train <- lapply(xlist,function(x)x[train_idx,,drop=FALSE])
      test  <- lapply(xlist,function(x)x[test_idx,,drop=FALSE])
      fit <- fit_smcca(train,penalties,ws_init,ncomponents)
      sp <- test[[1]]%*%fit$ws[[1]]; sb <- test[[2]]%*%fit$ws[[2]]; sm <- test[[3]]%*%fit$ws[[3]]
      for(k in seq_len(ncomponents)) arr[r,f,k] <- pairwise_sum_r(sp[,k],sb[,k],sm[,k])
    }
  }
  repeat_means <- apply(arr,c(1,3),mean,na.rm=TRUE)
  summary <- dplyr::bind_rows(lapply(seq_len(ncomponents),function(k){x<-repeat_means[,k];data.frame(Mode=paste0("M",k),Mean_sum_of_r=mean(x,na.rm=TRUE),SD_across_repetitions=stats::sd(x,na.rm=TRUE))}))
  list(fold_statistics=arr,repeat_means=repeat_means,summary=summary)
}

run_cv_permutation <- function(xlist,penalties,ws_init,observed_repeat_means,ncomponents=15,n_perm=1000,n_folds=10,seed=123){
  set.seed(seed); n <- nrow(xlist[[1]])
  observed_stat <- colMeans(observed_repeat_means,na.rm=TRUE)
  null_stat <- matrix(NA_real_,nrow=n_perm,ncol=ncomponents)
  for(j in seq_len(n_perm)){
    idx_p <- sample.int(n,n,replace=FALSE); idx_b <- sample.int(n,n,replace=FALSE)
    xp <- list(Pollution=xlist[[1]][idx_p,,drop=FALSE],Behavior=xlist[[2]][idx_b,,drop=FALSE],Brain=xlist[[3]])
    folds <- cvTools::cvFolds(n,K=n_folds,R=1,type="random")
    fold_stat <- matrix(NA_real_,nrow=n_folds,ncol=ncomponents)
    for(f in seq_len(n_folds)){
      train_idx <- folds$subsets[,1][folds$which != f]; test_idx <- folds$subsets[,1][folds$which == f]
      train <- lapply(xp,function(x)x[train_idx,,drop=FALSE]); test <- lapply(xp,function(x)x[test_idx,,drop=FALSE])
      fit <- fit_smcca(train,penalties,ws_init,ncomponents)
      sp <- test[[1]]%*%fit$ws[[1]]; sb <- test[[2]]%*%fit$ws[[2]]; sm <- test[[3]]%*%fit$ws[[3]]
      for(k in seq_len(ncomponents)) fold_stat[f,k] <- pairwise_sum_r(sp[,k],sb[,k],sm[,k])
    }
    null_stat[j,] <- colMeans(fold_stat,na.rm=TRUE)
  }
  p <- sapply(seq_len(ncomponents),function(k)(1+sum(null_stat[,k]>=observed_stat[k],na.rm=TRUE))/(n_perm+1))
  list(observed_stat=observed_stat,null_stat=null_stat,summary=data.frame(Mode=paste0("M",seq_len(ncomponents)),Observed_mean_sum_of_r=observed_stat,Permutation_p=p))
}
