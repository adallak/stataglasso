//////////////////////////Function for simulation
program define SIMglasso
version 16
	syntax ,n(integer) p(integer) prob(real) criteria(string)

	randomgraph ,n(`n') p(`p') prob(`prob') 

	matrix TOmega =  r(Omega)

	// Extract the data and true Precision matrix
	mat data = r(data)
	if "`criteria'" == "CV"{
	/// Choosing tuning parameter through 5-fold cross-validation  
		cvglasso data, nlam(40) nfold(5)
		mat CVOmega = r(Omega)
			/// Now let compare the result 
		compareGraph CVOmega, true(TOmega)
	}
	else if "`criteria'" == "BIC"{
		/// Choosing tuning parameter through pure BIC 
		ebicglasso data, nlam(40) gamma(0)
		mat BICOmega = r(Omega)
		mat lambda   = r(lambda)
		compareGraph BICOmega, true(TOmega)
	}
	else if "`criteria'" == "eBIC"{
		//Choosing tuning parameter through eBIC using gamma = 0.5
		ebicglasso data, nlam(40) gamma(0.1)
		mat eBICOmega = r(Omega)
		mat lambda   = r(lambda)
		compareGraph eBICOmega, true(TOmega)
	}
	else{
	    di as error "Wrong criteria specified"
	}
	
end