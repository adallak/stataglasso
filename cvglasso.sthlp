{smcl}
{* *! version 1.0.0  jun2020}{...}
{vieweralsosee "[plotglasso] plot glasso" "help plotglasso"}{...}
{vieweralsosee "[glasso] graphical lasso" "help glasso"}{...}
{viewerjumpto "Syntax" "cvglasso##syntax"}{...}
{viewerjumpto "Options for cv glasso" "cvglasso##options"}{...}
{viewerjumpto "Examples of cv glasso" "cvglasso##examples_cvg"}{...}
{viewerjumpto "Stored results" "cvglasso##results"}{...}
{viewerjumpto "Reference" "cvglasso##reference"}{...}


{p2colset 1 16 18 2}{...}
{p2col:{bf: cvglasso} {hline 2}} Selects the tuning parameter lambda for {helpb glasso}.{p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{pstd}
Sparse inverse covariance matrix estimation through Cross Validation using 
list of variables as an input.

{p 8 15 2}
{cmdab:cvglasso} {varlist} {ifin}
[{cmd:,}
{it:{help cvglasso##options_table:options}}]

{pstd}
Sparse covariance matrix estimation through Cross Validation using 
Stata matrix as an input.


{p 8 18 2}
{cmd:cvglasso} {it:matname}
[{cmd:,}
{it:{help cvglasso##options_table:options}}]

{phang}
{it:matname} is a n by b Stata matrix with p >= 2. 


{synoptset 20 tabbed}{...}


{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt lam_list(#)}} List of positive penalty parameters.{p_end}
{synopt:{opt nlam(#)}} If {it: lam_list} is not provided, create a {it: lam_list} with length {it: nlam}.
Default is 40. {p_end}
{synopt:{opt max_iter(#)}} Maximum number of iterations of outer loop. Default 1,000.{p_end}
{synopt:{opt tolerance(#)}} Threshold for outer loop convergence. Default value is 1e-5.{p_end}
{synopt:{opt nfold(#)}} Number of folds for K-fold cross-validation{p_end}
{synopt:{opt diag}} Should diagonal be penalized. Default is FALSE.{p_end}
{synopt:{opt crit(string)}} Cross validation criterion ({it: loglik}, {it: extended BIC}, and {it: AIC}). Default is {it: loglik} {p_end}
{synopt:{opt start(string)}} Type of initial values. The default is {it: cold}. The {it: warm} start uses the solution of the previous tuning parameter as an initial value. {p_end}
{synopt: {opt gamma(#)}} Parameter for extended BIC criterion. gamma = 0 case corresponds to BIC ({help ebic_glasso##FD2010:Foygen and Drton (2010)}) . Default is 0.5 {p_end} 
{synopt:{opt verbose}} Show the table of selected information criterion.{p_end}
{marker description}{...}
{title:Description}

{pstd}
{cmd:cvglasso} Implements K-fold cross-validation ({help cvglasso##HTF2009:Hastie et. al (2009)}) .

{marker examples_cvg}{...}
{title:Examples of cvglasso}
{phang2}{cmd:. set seed 2}{p_end}
{pstd}Simulating data with n = 100 and p = 150{p_end}
{phang2}{cmd:. randomgraph ,n(100) p(150)}{p_end}

{pstd} Extract the data{p_end}
{phang2}{cmd:. mat data = r(data)}{p_end}

{pstd} Estimate sparse inverse covariance matrix based on CV.{p_end}
{phang2}{cmd:. cvglasso data1-data150, nfold(5) nlam(40) crit(loglik)}{p_end}

{pstd} Save the estimated matrix{p_end}
{phang2}{cmd:. matrix omega_cv = r(Omega)}{p_end}

{pstd} Save the tuned regularization paramater{p_end}
{phang2}{cmd:. scalar lambda = r(lambda)}{p_end}

{pstd} Estimate sparse inverse covariance matrix based on extended BIC using matrix as an input.{p_end}
{phang2}{cmd:. cvglasso data, nfold(5) nlam(40) crit(eBIC) gamma(0.2)}{p_end}

{pstd} Save the estimated matrix{p_end}
{phang2}{cmd:. matrix omega_ebic = r(Omega)}{p_end}

{pstd} Save the tuned regularization paramater{p_end}
{phang2}{cmd:. scalar lambda_ebic = r(lambda)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:CVglasso} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalar}{p_end}
{synopt:{cmd:e(lambda)}}Selected regularization parameter.{p_end}
{p2colreset}{...}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(Omega)}}Sparse inverse covariance matrix{p_end}
{synopt:{cmd:e(Sigma)}}Covariance matrix{p_end}
{synopt:{cmd:e(lamlist)}}List of regularization parameters{p_end}
{p2colreset}{...}

{marker reference}{...}
{title:Reference}

{marker HTF}{...}
{phang} 
Hastie, Trevor, Tibshirani, Robert and Friedman, Jerome. The Elements of Statistical Learning. New York, NY, USA: Springer New York Inc., 2001.
{p_end}

{marker FD2010}{...}
{phang}
Foygel, R. and Drton, M. (2010). Extended Bayesian Information Criteria for Gaussian Graphical Models. 
{it Advances in Neural Information Processing Systems 23}. pp. 604–612. {p_end}