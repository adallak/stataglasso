{smcl}
{* *! version 1.0.0  jun2020}{...}
{vieweralsosee "[GLASSO] graphical lasso" "help glasso"}{...}
{vieweralsosee "[NWCOMMAND] nwcommand" search nwcommand "}{...}
{viewerjumpto "Syntax" "PLOTPrecision##syntax"}{...}
{viewerjumpto "Options for plotglasso" "PLOTP##options"}{...}
{viewerjumpto "Examples of plotglasso"PLOTP##examples_plotp"}{...}
{viewerjumpto "Stored results" "PLOTP##results"}{...}


{p2colset 1 16 18 2}{...}
{p2col:{bf: plotglasso} {hline 2}} Visualizes the estimated inverse covariance matrix. {p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{pstd}
Visualizes the inverse covariance matrix as an {bf:undirected graph} or {bf:matrix}.

{p 8 15 2}
{cmdab:plotglasso} {it:matname} 
[{cmd:,}
{it:{help PLOTP##options:*}}]


{phang}
{it:matname} Estimated inverse covariance matrix, which is a p by p Stata matrix with p >= 2. 

{synoptset 20 tabbed}{...}

{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt type(str)}} Type of the graph: {it: graph} or {it: matrix}. The default is {it: graph}. {p_end}
{synopt:{opt *}} Options borrowed from {helpb NWCOMMAND}{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd: plotglasso} Visualizes the inverse covariance matrix as an undirected graph or matrix. 
The command heavily relies on {helpb NWCOMMAND}

{marker examples_plotp}{...}
{title:Examples of plotglasso}
{phang2}{cmd:. set seed 2}{p_end}

{pstd}Setup by simulating data from {helpb randomgraph}{p_end}
{phang2}{cmd:. randomgraph, n(100) p(150)}{p_end}

{pstd} Extract data and true precision matrix{p_end}
{phang2}{cmd:. mat data = r(data}} {p_end}
{phang2} {cmd:. omega_true = r(Omega)} {p_end}

{pstd} Estimating inverse covariance matrix using data input as variable names and 
lambda = 0.4 and extract estimated precision matrix. {p_end}
{phang2}{cmd:. glasso data, lambda(0.2)}{p_end}
{phang2} {cmd:. omega_est = r(Omega)} {p_end}

{pstd} Visualize the result {p_end}
{phang2}{cmd:. plotglasso omega_est, type(matrix)}{p_end}
{phang2}{cmd:. plotglasso omega_est, type(graph) lab layout(circle)}{p_end}
