{smcl}
{* *! version 1.0.0  jun2020}{...}
{vieweralsosee "[LASSO] Lasso intro" "help lasso intro"}{...}
{vieweralsosee "[RG] Random Graph" "help randomgraph"}{...}
{viewerjumpto "Syntax" "glasso##syntax"}{...}
{viewerjumpto "Options for glasso" "glasso##options"}{...}
{viewerjumpto "Examples of glasso"glasso##examples_glasso"}{...}
{viewerjumpto "Stored results" "glasso##results"}{...}
{viewerjumpto "Reference" "glasso##reference"}{...}


{p2colset 1 16 18 2}{...}
{p2col:{bf: glasso} {hline 2}}Graphical Lasso{p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{pstd}
Sparse inverse covariance matrix estimation through Graphical lasso algorithm using 
list of variables as an input.

{p 8 15 2}
{cmdab:glasso} {varlist} {ifin}
[{cmd:,}
{it:{help glasso##options_table:options}}]

{pstd}
Sparse covariance matrix estimation through Graphical lasso algorithm using 
Stata matrix as an input.


{p 8 18 2}
{cmd:glasso} {it:matname}
[{cmd:,}
{it:{help glasso##options_table:options}}]

{phang}
{it:matname} is a n by b Stata matrix with p >= 2. 

{synoptset 20 tabbed}{...}

{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt lam:bda(#)}} (Non-negative) penalty parameter. Default value is 0.1. {p_end}
{synopt:{opt max_iter(#)}} Maximum number of iterations of outer loop. Default 100.{p_end}
{synopt:{opt tol:erance(#)}} Tolerance for convergence. Default value is 1e-5.{p_end}
{synopt:{opt diag}} Shoud diagonal be penalized? Default is FALSE.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:glasso} Estimates a sparse inverse covariance matrix using a lasso (L1) penalty, using framework developed in
({help glasso##FHT2007:Friedman and et.al 2007}). 

{pstd}
{cmd:glasso} allows data in both the form of variable and Stata matrix.

{marker examples_glasso}{...}
{title:Examples of glasso}
{phang2}{cmd:. set seed 2}{p_end}

{pstd}Setup by simulating data from {helpb randomgraph}{p_end}
{phang2}{cmd:. randomgraph, n(100) p(150)}{p_end}

{pstd} Save data as matrix {p_end}
{phang2}{cmd:. mat data = r(data}} {p_end}

{pstd} Estimating inverse covariance matrix using data input as variable names and lambda = 0.2. {p_end}
{phang2}{cmd:. glasso data1-data50, lambda(0.2)}{p_end}

{pstd} Estimating inverse covariance matrix using data input as Stata matrix and lambda = 0.2. {p_end}
{phang2}{cmd:. glasso data, lambda(0.2)}{p_end}
{phang2}{cmd:. return list}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:glasso} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}

{p2col 5 20 24 2: Scalar}{p_end}
{synopt:{cmd:e(lambda)}}Penalization parameter{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(Omega)}}Sparse inverse covariance matrix{p_end}
{synopt:{cmd:e(Sigma)}}Covariance matrix{p_end}
{p2colreset}{...}

{marker reference}{...}
{title:Reference}

{marker FHT2007}{...}
{phang}
Jerome Friedman, Trevor Hastie and Robert Tibshirani (2007). Sparse inverse covariance estimation
with the lasso. Biostatistics 2007. http://www-stat.stanford.edu/~tibs/ftp/graph.pdf
{p_end}
