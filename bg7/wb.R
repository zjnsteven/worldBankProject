library("rpart",lib.loc="/home/scratch/jzhao/wbproject/wb/R_libs/")
library("rpart.plot",lib.loc="/home/scratch/jzhao/wbproject/wb/R_libs/")
library("Rcpp",lib.loc="/home/scratch/jzhao/wbproject/wb/R_libs/")
Sys.setenv("PKG_CXXFLAGS"="-fopenmp")
Sys.setenv("PKG_LIBS"="-fopenmp")
sourceCpp("/home/scratch/jzhao/wbproject/wb/splitc.cpp")
test <- read.csv("/home/scratch/jzhao/wbproject/wb/test.csv")
test = test[,2:306]
### user defined split function

ctev <- function(y, wt,parms) {
  out = node_evaluate(y)
  list(label= out[1], deviance=out[2])
}

ctsplit <- function(y, wt, x, parms, continuous) {
  if (continuous) {
    n = nrow(y)
    res = splitc(y)
    list(goodness=res[1:(n-1)], direction=res[n:(2*(n-1))])
  }
  else{
    res = splitnc(y,x)
    n=(length(res)+1)/2
    list(goodness=res[1:(n-1)], direction=res[n:(2*n-1)])
  }
}


ctinit <- function(y, offset, parms, wt) {
  sfun <- function(yval, dev, wt, ylevel, digits ) {
    print(yval)
    paste("events=", round(yval[,1]),
          ", coef= ", format(signif(yval[,2], digits)),
          ", deviance=" , format(signif(dev, digits)),
          sep = '')}
  environment(sfun) <- .GlobalEnv
  list(y =y, parms = 0, numresp = 1, numy = 4,
       summary = sfun)
}


alist <- list(eval=ctev, split=ctsplit, init=ctinit)
# y : outcome, treatment(W), "pscore", tansformaed outcome

#fit1 = rpart(cbind(outcome,TrtBin,pscore,trans_outcome) ~ .,test,control=rpart.control(minsplit=2,cp = 0.001), method=alist)

fit1 <- rpart(cbind(outcome,TrtBin,pscore,trans_outcome) ~ . ,
              test,
              control = rpart.control(cp = 0.001,
              minsplit = 20),
              method = alist)


#printcp(fit1) # display the results 
prp(fit1)
print(fit1)

