{smcl}
{* *! version 1.0.0  jun2020}{...}
{vieweralsosee "[GLASSO] graphical lasso" "help glasso"}{...}
{viewerjumpto "Syntax" "compareGraph##syntax"}{...}
{viewerjumpto "Options for compareGraph" "compareGraph##options"}{...}
{viewerjumpto "Examples of compareGraph"compareGraph##examples_compg"}{...}
{viewerjumpto "Stored results" "compareGraph##results"}{...}


{p2colset 1 16 18 2}{...}
{p2col:{bf: compareGraph} {hline 2}} Compares the estimated and true  inverse covariance matrices. {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}
Compares the estimated and true inverse covariance matrix based on True Positive, 
False Positive and True Discovery rates.

{p 8 15 2}
{cmdab:compareGraph} {it:matname1} {it: true(matname2)}


{phang}
{it:matname1} Estimated matrix, which is a p by p Stata matrix with p >= 2. 

{phang}
{it: type(matname2)} True matrix, which is a p by p Stata matrix with p >= 2. 

{synoptset 20 tabbed}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:compareGraph} Compares two matrices, from which one is estimated 
and the other is the true one and estimates true positive, false positive, and true discovery rates. 

{marker examples_compg}{...}
{title:Examples of compareGraph}

{phang2}{cmd:. set seed 2}{p_end}

{pstd}Setup by simulating data from {helpb randomgraph}{p_end}
{phang2}{cmd:. randomgraph ,n(100) p(150)}{p_end}

{pstd} Extract data and true precision matrix{p_end}
{phang2}{cmd:. mat data = r(data}} {p_end}
{phang2} {cmd:. omega_true = r(Omega)} {p_end}

{pstd} Estimating inverse covariance matrix using data input as variable names with {bf: lambda = 0.4}. {p_end}
{phang2}{cmd:. glasso data, lambda(0.2)}{p_end}
{phang2}{cmd:. omega_est = r(Omega)} {p_end}

{pstd} Compare the results {p_end}
{phang2}{cmd:. compareGraph omega_est, true(omega_true)}{p_end}
{phang2}{cmd:. return list}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:compareGraph} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(tpr)}}True Positive Rate{p_end}
{synopt:{cmd:r(fpr)}}False Positive Rate{p_end}
{synopt:{cmd:r(tdr)}}True Discovery Rate{p_end}
{p2colreset}{...}

