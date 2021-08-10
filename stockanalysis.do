clear all

do glasso.ado

import delimited stocksm, clear

standardize hsbaln - x8418to
matrix X = r(X)


cvglasso X, gamma(0.5)  nlam(40) crit(eBIC)

//cvglasso hsbaln -  x8418to,  nlam(40) 
//cvglasso hsbaln - usb,  nlam(20) 
mat eBICOmega = r(Omega) 
di r(lambda)
mat list r(Omega)



mata K = st_matrix("r(Omega)")

nwset, mat(K) undirected 



input str16 cnt
"gb" 
"jp" 
"us" 
"gb" 
"us" 
"us" 
"jp" 
"gb" 
"jp" 
"us" 
"gb" 
"it" 
"us" 
"it" 
"us" 
"ca"
"ca" 
"au" 
"ca" 
"au" 
"gb" 
"cn" 
"au" 
"au" 
"cn" 
"cn" 
"ca" 
"jp" 
"jp" 
"jp" 
"ca" 
"us"
"us" 
"us" 
"cn"
"us"
"cn"
"it"
"us" 
"us" 
"ca"
"us" 
"it"
"au" 
"jp"
"jp"
"us"
"us"
"jp" 
"it" 
"jp" 
"jp"
"it"
"jp" 
end


set seed 250

nwplot, color(cnt) iterations(1000) 

