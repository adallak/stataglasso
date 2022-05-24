clear all

//do glasso.ado 


/// Generate n =100, p =150 data from the random graph with the default value of probabilities between edges.
set seed 200
randomgraph, n(200) p(50) prob(0.1) //seed(400) 
matrix TOmega =  r(Omega)

return list


// Extract the data and true Precision matrix
mat data = r(data)

// For demonstration run GLasso for  penalty lambda = 0.2
glasso data, lam(.046700728) 
mat list r(Omega)
mat list r(Sigma)
mat FIXOmega = r(Omega)


/// Choosing tuning parameter through 5-fold cross-validation  
cvglasso data, nlam(20) nfold(5)  crit(loglik)
mat CVOmega = r(Omega) 
scalar lambda_cv = r(lambda)
mat list r(Omega)
di r(lambda)

/// Choosing tuning parameter through bic  
cvglasso data, nlam(20)  crit(eBIC) gamma(0)
mat BICOmega = r(Omega)
scalar lambda_bic = r(lambda)
di lambda_bic


/// Choosing tuning parameter through ebic  
cvglasso data, nlam(20) crit(eBIC) gamma(0.5)
mat eBICOmega = r(Omega)
scalar lambda_ebic = r(lambda)
di lambda_ebic

/// Choosing tuning parameter through aic  
cvglasso data, nlam(20)  crit(AIC)
mat AICOmega = r(Omega)
scalar lambda_aic = r(lambda)
di lambda_aic


// Let plot matrices together using wrapped function plot_precision
// True omega

plotglasso TOmega, type(graph) lab layout(circle) title(True Precision Matrix,position(12)) saving(trueomega,replace)
plotglasso CVOmega, type(graph) lab layout(circle) title(CV,position(12)) saving(cvomega,replace)

plotglasso BICOmega, type(graph) lab layout(circle) title(BIC,position(12)) saving(bicomega,replace)

plotglasso eBICOmega, type(graph) lab layout(circle) title(eBIC,position(12)) saving(ebicomega,replace)


gr combine "trueomega" "cvomega" "bicomega" "ebicomega"


plotglasso TOmega, type(matrix) title(True Precision Matrix,position(12)) saving(trueomega,replace)

plotglasso CVOmega, type(matrix)  title(CV,position(12)) saving(cvomega,replace)

plotglasso BICOmega, type(matrix) title(BIC,position(12)) saving(bicomega,replace)

plotglasso eBICOmega, type(matrix) title(eBIC,position(12)) saving(ebicomega,replace)


gr combine "trueomega" "cvomega" "bicomega" "ebicomega"

/// Now let compare the result 
comparegraph CVOmega, true(TOmega)

return list

comparegraph BICOmega, true(TOmega)

return list

comparegraph eBICOmega, true(TOmega)

return list


svmat data

export delimited data.csv, replace
