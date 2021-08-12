clear all

//do glasso.ado

import delimited protain, clear

// Standardize data
standardize praf-pjnk
matrix X = r(X)

numlist "0.01 0.1  0.25 0.5 0.75"



foreach lbd in `r(numlist)'{
	import delimited protain, clear
	glasso X, lam(`lbd')
    local filename = "lambda" + "`lbd'"
	plotglasso r(Omega), type(graph) layout(circle) newlabs("Raf" "Mek"  "Plcg"  "PIP2"  "PIP3"  "Erk"  "Akt"  "PKA"  "PKC"  "P38"  "Jnk") lab title("{&lambda}  = `lbd'") saving("`filename'", replace)
}


gr combine "lambda.5" "lambda.25" "lambda.1"  "lambda.01"  

graph export "protaincombined.png", replace



import delimited protain, clear

//standardize data
standardize praf-pjnk
matrix X = r(X)

// Run glasso with eBIC
cvglasso X,  gamma(0.5) nlam(20) crit(eBIC) 

mat eBICOmega = r(Omega) 
local bic = round(r(lambda), 0.0001)


// Run glasso with CV
cvglasso X,  nlam(20) crit(loglik)

mat cvOmega = r(Omega) 
local cv = round(r(lambda), 0.0001)



mat lambda = `cv',`bic'

//plotglasso eBICOmega, type(matrix) saving(bicprotain,replace) 

// Plot the results 
plotglasso cvOmega, type(graph) saving(cvprotaingraph,replace) layout(circle) newlabs("Raf" "Mek"  "Plcg"  "PIP2"  "PIP3"  "Erk"  "Akt"  "PKA"  "PKC"  "P38"  "Jnk") lab title("CV, {&lambda} = `cv'") 
plotglasso eBICOmega, type(graph) saving(bicprotaingraph,replace) layout(circle) newlabs("Raf" "Mek"  "Plcg"  "PIP2"  "PIP3"  "Erk"  "Akt"  "PKA"  "PKC"  "P38"  "Jnk") lab title("eBIC, {&lambda} = `bic'")
plotglasso cvOmega, type(matrix) saving(cvprotainmat,replace)
plotglasso cvOmega, type(matrix) saving(bicprotainmat,replace)

gr combine "cvprotaingraph" "bicprotaingraph" "cvprotainmat"  "bicprotainmat"  

graph export "protaincvbic.png", replace

mat list lambda

//gr combine "bicprotain" "cvprotain"
