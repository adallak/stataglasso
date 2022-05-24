# stataglasso

Stata command for the sparse inverse covariance matrix estimation through
Graphical lasso algorithm (Friedman et.al 2008). For details see `glasso.sthlp` and `cvglasso.sthlp`. 
To build Mata libraries run
```s
. do make_lglasso
```

The toy example below illustrates the use of the commands.
We start by generating data from Erdos-Renyi graph.

```s
. randomgraph, n(300) p(50)
```

Now, we estimate the inverse covariance matrix using data input as variable names and lambda = 0.2.

```s
. glasso var1-var50, lambda(0.2)
. mat list r(Omega)
```

Next, we illustrate the glasso with K-fold cross-validation.

```s
. cvglasso var1-var50, nfold(5) nlam(40) crit(loglik)
. mat list r(Omega)
```
More example can be found in `stockanalysis.do` and `protainanalysis.do` files.
