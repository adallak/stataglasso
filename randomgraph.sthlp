{smcl}
{* *! version 1.0.0  jun2020}{...}
{vieweralsosee "[plotglasso] Plot glasso result" "help plot_precision"}{...}
{viewerjumpto "Syntax" "randomgraph##syntax"}{...}
{viewerjumpto "Options for random graph" "randomgraph##options"}{...}
{viewerjumpto "Examples of random graph"randomgraph##examples_rgraph"}{...}
{viewerjumpto "Stored results" "randomgraph##results"}{...}
{viewerjumpto "Reference" "randomgraph##reference"}{...}


{p2colset 1 16 18 2}{...}
{p2col:{bf: randomgraph} {hline 2}} Generates Data from the inverse covariance matrix given the sparsity level.{p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{pstd}
Implements the data generation from multivariate normal 
distribution with {it: random} graph structure.

{p 8 18 2}
{cmd:randomgraph} {it: n(#)} {it: p(#)}
[{cmd:,}
{it:{help randomgraph##options_table:options}}]

{phang}
{it:n(#)} The number of observations of sample size. {p_end}

{phang}
{it:p(#)} The number of variables(dimension) of sample size. {p_end}

{synoptset 20 tabbed}{...}

{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt v(#)}} The off-diagonal elements of the precision matrix, controlling the magnitude of partial correlations with u. 
The default value is 0.3.{p_end}
{synopt:{opt u(#)}} A positive number being added to the diagonal elements of the precision matrix, to control the magnitude of partial correlations. 
The default value is 0.1.{p_end}
{synopt:{opt prob(#)}} Is the probability that a pair of nodes has an edge. The default value is 3/p{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:randomgraph} Given the adjacency matrix theta, the graph patterns are generated as below: 
Each pair of off-diagonal elements are randomly set {it: theta[i,j]= theta[j,i]=1} for {it: i!=j} with probability prob, and 0 other wise. It results in about {it: p*(p-1)*prob/2} edges in the graph.
The adjacency matrix {it: theta} has all diagonal elements equal to 0. To obtain a positive definite precision matrix, the smallest eigenvalue of {it: theta*v} is computed. 
Then we set the precision matrix equal to {it: theta*v+(theta*v++0.1+u)I }. The covariance matrix is then computed to generate multivariate normal data.

{marker examples_rgraph}{...}
{title:Examples of Random Graph}
{pstd}Simulating data with {bf: n = 100} and {bf: p = 150}{p_end}
{phang2}{cmd:. randomgraph ,n(100) p(150)}{p_end}

{pstd} Extract the data and true Precision matrix {p_end}
{phang2}{cmd:. mat data = r(data)} {p_end}
{phang2}{cmd:. mat omega_true= r(Omega)} {p_end} 

{pstd} Plot true inverse covariance matrix using {helpb plotglasso} {p_end}
{phang2}{cmd:. plotglasso omega_true, type(graph) lab layout(cicle) title(True Precision Matrix, color(white) position(12)) saving("trueomega",replace)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:randomgraph} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalar}{p_end}
{synopt:{cmd:r(Sparsity)}}Sparsity level{p_end}
{p2colreset}{...}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(data)}}Generated data matrix{p_end}
{synopt:{cmd:r(Omega)}}Sparse inverse covariance matrix{p_end}
{synopt:{cmd:r(Sigma)}}Covariance matrix{p_end}
{synopt:{cmd:r(S)}}Estimated Covariance matrix from the data{p_end}
{p2colreset}{...}

{marker reference}{...}
{title:Reference}

{marker liu2012}{...}
{phang}
Tuo Zhao, Han Liu, Kathryn Roeder, John Lafferty, and Larry Wasserman. 2012. {p_end}
The huge package for high-dimensional undirected graph estimation in R. {it: J. Mach. Learn. Res. 13}, (3/1/2012), 1059–1062.{p_end}
