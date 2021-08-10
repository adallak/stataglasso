# stataglasso

Stata command for the sparse inverse covariance matrix estimation through
Graphical lasso algorithm.

The toy example below illustrates the use of the command.

We start by generating data from Erdos-Renyi graph.

. randomgraph ,n(100) p(150)
. mat data = r(data}
. svmat data

Now, we estimate the inverse covariance matrix using data input as variable names and lambda = 0.2.

. glasso data1-data50, lambda(0.2)

Next, we illustrate the glasso with K-fold cross-validation.

. cvglasso data1-data50, nfold(5) nlam(40) crit(loglik)
