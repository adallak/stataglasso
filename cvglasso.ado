////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
////////////// Train based on cv criteria ////////////////////////

program cvglasso, rclass
version 16

////neq code
_parse comma matrix rest : 0
capture confirm matrix `matrix'

if _rc == 0 {            // syntax 2:  matrix
		local syntax 2
		syntax [anything(name=matrix)] [, lamlist(numlist) max_iter(integer 100)  TOLerance(real 1e-5) nlam(integer 40) nfold(integer 5) gamma(real 0.5) crit(string) cvmethod(string) diag] //NOSTANDardize
    }
else {                                        // syntax 1: varlist
		local syntax 1
		syntax varlist(min=2 numeric) [if] [in] ///
		[, lamlist(numlist) max_iter(integer 100) ///
		TOLerance(real 1e-5) nlam(integer 40) nfold(integer 5) gamma(real 0.5) crit(string) cvmethod(string) diag] //NOSTANDardize
		marksample touse
		markout `touse'
	}
capt mata mata which mm_srswor()
if _rc!= 0 {
         di as txt "user-written package moremata needs to be installed first;"
         di as txt "use -ssc install moremata- to do that"
         exit 498
}

mata: r = CV_GLasso(1)
if `syntax' == 1{
	mata: r.setup("`varlist'", "`touse'", "`lamlist'", `nlam', `nfold', `max_iter', `tolerance', `gamma', "`crit'", "`cvmethod'" ,"`diag'") //"`nostandardize'", 
}
else{
	mata: X = st_matrix("`matrix'")
	mata: r.setup1(X, "`lamlist'", `nlam', `nfold', `max_iter', `tolerance', `gamma', "`crit'", "`cvmethod'", "`diag'") //"`nostandardize'"
}

return add
end
//////////////


version 16
set matastrict on


version 16
set matastrict on


mata:
struct GLasso_result
{
	// Structure to store the result
	real matrix Omega
	real matrix Omega_inv
}

struct decomp_matrix
{
	// Structure used to decompose symmetric matrix 
	real matrix A11
	real colvector a12
	real scalar    a11
}


class GLasso
{
    // Public Functions
	public:
		void						setup()
		void 						setup1()
		real rowvector 				mean_X()
		real matrix             	S()      // variance matrix
		real scalar             	N()      // # obs 
		real scalar             	p()      // # X vars 
		real scalar             	ispdf()
		real matrix            		standardizeX()
		struct GLasso_result scalar GLasso_fit()
		real scalar					soft()
		real matrix 				S
		real matrix 				Omega
		real matrix 				Omega_inv
	// Private Funcitons

	private:
		struct decomp_matrix scalar block_decomp()
	
	// Input and estimated variables
	public:
		pointer(real matrix) scalar X  
		real scalar					lambda
		struct GLasso_result scalar result
		real matrix 				init			
		
	private:
		real matrix					W
		real colvector				w
		real scalar					sigma
		real matrix					standardizedX
		real scalar             	X_st
		real rowvector          	mean_X
	
}


///////////////////////NEW CODE for the syntax ////////////////////////////////
void GLasso::setup1(real matrix user_X, real scalar lbd,  real scalar max_iter, real scalar tolerance, | string scalar diag, real matrix init_O) //string scalar nostandardize,
{
	string colvector cv
//	if(nostandardize == "")
//	{
//		X      = &standardizeX(user_X)
//	}else{
	X = &user_X
//	}
	lambda = lbd
	if(lambda < 0)
	{
	    errprintf("lambda must be positive \n")
		exit(498)
	}
	if(max_iter < 0)
	{
	    errprintf("Number of iterations should be positive \n")
		exit(498)
	}
	if(tolerance < 0)
	{
	    errprintf("Threshold should be positive \n")
		exit(498)
	}
	if(cols(*X) < 2)
	{
	    errprintf("Number of variables should be >2. \n")
		exit(498)
	}
	S = S()
	if (args() == 6)
	{
		    init = init_O
	}else{
	    if(diag != "")
		{
			init = S + lambda * diag(J(1,p(),1))
		}else{
		    init = S
		}
	}
	result = GLasso_fit(max_iter, tolerance, diag) //, nostandardize
	Omega = result.Omega
	Omega_inv =  result.Omega_inv
	st_rclear()
	st_matrix("r(Omega)", Omega)
	st_matrix("r(Sigma)", Omega_inv)
	st_matrix("r(lambda)", lambda)
}




//////////////////////////////////////////////////////////////

void GLasso::setup(string scalar varlist, string scalar touse, real scalar lbd, real scalar max_iter, real scalar tolerance,| string scalar diag, real matrix init_O) //string scalar nostandardize, 
{
	real matrix user_X
	string colvector cv
	pragma unset user_X
	st_view(user_X, ., tokens(varlist), touse)
//	if(nostandardize == "")
//	{
//		X      = &standardizeX(user_X)
//	}else{
	X = &user_X
//	}
	lambda = lbd
		if(lambda < 0)
	{
	    errprintf("lambda must be positive \n")
		exit(498)
	}
	if(max_iter < 0)
	{
	    errprintf("Number of iterations should be positive \n")
		exit(498)
	}
	if(tolerance < 0)
	{
	    errprintf("Threshold should be positive")
		exit(498)
	}
	if(cols(*X) < 2)
	{
	    errprintf("Number of variables should be >2. \n")
		exit(498)
	}

	S = S()
	if (args() == 7)
	{
			init = init_O
	}else{
	    if(diag != "")
		{
			init = S + lambda * diag(J(1,p(),1)) 
		}else{
		    init = S
		}
	
	}
	cv = tokens(varlist)
	
	if (length(uniqrows(cv)) != length(cv)) 
	{
		errprintf(" repeated variables not allowed \n")
		exit(498)
	}
 //   tolerance = tolerance * mean(abs(mean(S - diag(diagonal(S)))'))
	result = GLasso_fit(max_iter, tolerance, diag) //nostandardize
	Omega = result.Omega
	Omega_inv =  result.Omega_inv
	st_rclear()
	st_matrix("r(Omega)", Omega)
	st_matrix("r(Sigma)", Omega_inv)
}


real scalar GLasso::N() return(rows(*X))
real scalar GLasso::p() return(cols(*X))


real rowvector GLasso::mean_X()
{
	// Function to return the mean of each column
        mean_X = mean(*X)
        return(mean_X)
}


real matrix GLasso::S()   
{
	// Function returns the sample covariance
		S = quadcrossdev(*X, 0, mean_X(), *X, 0, mean_X()) :/ N()
	return(S)
}


real matrix GLasso::standardizeX(real matrix X)
{
	// Standardies X to have mean 0 and variance 1
	real matrix diag_S, st_X
	real vector sqrt_diag_S
	st_X = X :- mean(X)
	S = quadcross(st_X, st_X) / rows(X)
	sqrt_diag_S = sqrt(diagonal(S))
	diag_S = diag(1 :/ sqrt_diag_S)

	standardizedX = quadcross(st_X', diag_S)
	
	return(standardizedX)
}


struct decomp_matrix scalar GLasso::block_decomp(real matrix mat,  real scalar index)
{
	// Function to decompose matrix into column vector and submatrix
	struct decomp_matrix scalar res
//	real matrix tmp
	res.a12 = select(mat[,index], (1::p()) :!= index)
	res.A11 = select(select(mat, (1..p()) :!= index), (1::p()) :!= index)
	res.a11 = mat[index,index]
	
	return(res)
}


struct GLasso_result scalar GLasso::GLasso_fit(real scalar max_iter, real scalar tolerance, string scalar diag) //string scalar nostandardize
{
	struct decomp_matrix scalar dec1, dec2, dec3
	struct GLasso_result scalar res
    real colvector beta, beta_old, s, beta_j, omega
	real rowvector sel_ind
	real scalar converge_beta, s_ii, omega_ii, converge_omega, iter, i, j
	real rowvector W_j
	real matrix Omega_inv_old, Omega, Omega_inv, Omega_old
	//Initialization of algorithm
	Omega_inv = init
	Omega =  diag(1:/diagonal(Omega_inv)) 
	iter = 0
	converge_omega = 0
			// Update diagonal
	while((converge_omega == 0) & (iter <= max_iter))
	{
		Omega_inv_old = Omega_inv
		Omega_old = Omega

		// Update nondiagonals
		for (i = 1; i <= p(); i++)
		{
			dec1 = block_decomp(Omega_inv, i)
			W = dec1.A11
			w = dec1.a12
//			sigma = dec1.a11
			dec2 = block_decomp(S, i)
			s = dec2.a12
//			s_ii = dec2.a11	

			// Initialize beta
			beta = beta_old = J((p() - 1), 1, 0)
			converge_beta = 0
			while (converge_beta == 0)
			{
				beta_old = beta
				for (j = 1; j <= (p() - 1); j++)
				{
					beta_j = select(beta,(1::(p()-1)) :!= j)
					W_j = select(W[,j], (1::(p()-1)) :!= j)
					beta[j] = (soft((s[j] - quadcross(W_j, beta_j)), lambda))/ (W[j,j])               
				}
				if (sum(abs(beta - beta_old):^2) < tolerance) 
				{
					converge_beta = 1
				}
			}
			// Update  W, w, and sigma
			w = W * beta //quadcross(W', beta)
			sel_ind = select((1..(p())) , (1..(p())) :!= i)
			Omega_inv[i, sel_ind] = w' 
			Omega_inv[sel_ind', i] = w
			omega_ii    = 1 / (Omega_inv[i,i] - quadcross(w, beta))
			omega = -beta :* omega_ii
			Omega[i, sel_ind] = omega' 
			Omega[sel_ind', i] = omega
			Omega[i,i] = omega_ii	
			if (sum(abs(Omega_inv - Omega_inv_old):^2) < tolerance)
			{
				converge_omega = 1
			}else{
				iter = iter + 1
			}
		}
	}
	
	// return the results
	res.Omega = Omega
	res.Omega_inv = Omega_inv
	return(res)
}


real scalar GLasso::soft(real colvector a, real scalar b)
{
	// Function to implement soft-thresholding
	return( sign(a) :* max((abs(a) :- b)\0))
}

real scalar GLasso::ispdf(real matrix A)
{
        real matrix N, M
        if(issymmetric(X) == 0)
	{
		errprintf(" Matrix is not symmetric")
		exit(3498)
	}
	N = .
	M = .
	eigensystem(A, N, M)
	if (length(selectindex(Re(M) :< 0)) > 0)
	{
	        return(0)
	}else{
	        return(1)
	}
	
}

end



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



mata:

struct GLassoCV_result
{
	real matrix Omega
	real matrix Omega_inv
	real scalar lambda
}

class CV_GLasso
{
	public:
		void		       setup()
		void 		       setup1()
		void	       	   CVglasso()
		void		       CVglasso_fit()
		real scalar            N
		real scalar            p
		real scalar             gam
	// Private Funcitons

	// Input and estimated variables
	public:
		real matrix   	       X 
		real matrix            Omega
		real matrix 	       Omega_inv
		real scalar	           lambda
		real scalar            nfold
		real colvector	       lamlist
		pointer(real vector) scalar 		result
	private:
		class GLasso scalar    gl
		real scalar            nonzero()
		real matrix            S_train
		real matrix 		   scale()

}
	
/// Setup when input is Stata matrix type
void CV_GLasso::setup1(real matrix user_X, string colvector lbd_list, real scalar nlam, real scalar K, real scalar max_iter, real scalar tolerance, real scalar gama, string scalar crit, string scalar cvmethod, string scalar diag) // string scalar nostandardize, 
{
    real matrix S, diag_S, st_X 
	real scalar lammin, lammax
	real colvector sqrt_diag_S
//	if (nostandardize == "")
//	{
//		X      = gl.standardizeX(user_X)
//	}else{
	X = user_X
//	}
	if (crit == "")
	{
		crit = "loglik"
	}
	if (crit != "loglik" & crit != "eBIC")
	{
	    errprintf("Available criteria are CV and eBIC \n")
		exit(498)	
	}
	if (cvmethod == "")
	{
	    cvmethod = "shuffle"
	}
	if (cvmethod != "mod" & cvmethod != "shuffle")
	{
	    errprintf("Available cv methods are mod and shuffle \n")
		exit(498)
	}
	if (gama < 0 | gama > 1 )
	{
		errprintf("Gamma should be between 0 and 1 \n")
		exit(498)
	}
	if( K < 1)
	{
		errprintf("K should be positive. \n")
		exit(498)
	}
	if (lbd_list == "")
	{
		if (nlam < 0)
		{
			errprintf("nlam should be positive. \n")
			exit(498)
		}
	    S = quadcrossdev(X, 0, mean(X), X, 0, mean(X)) :/ rows(X)
		st_X = X :- mean(X)
		sqrt_diag_S = sqrt(diagonal(S))
		diag_S = diag(1 :/ sqrt_diag_S)
		st_X = quadcross(st_X', diag_S)
	    S = quadcross(st_X, st_X) :/ rows(X)
		lammax = max(abs(S - diag(diagonal(S))))
		lammin = 0.01 * lammax
		lamlist = 10:^rangen(log10(lammax), log10(lammin), nlam)
	}else{
		lamlist = st_matrix(lbd_list)
		if (length(select(lamlist, lamlist :< 0)))
		{
			errprintf("lamlist should contain only positive values. \n")
			exit(498)
		}
		lamlist = sort(lamlist,-1)
	}
	nfold     = K
	gam = gama
	CVglasso(max_iter, tolerance, crit, cvmethod, diag) //string scalar nostandardize, 
	st_rclear()
	st_matrix("r(Omega)", Omega)
	st_matrix("r(Sigma)", Omega_inv)
	st_numscalar("r(lambda)", lambda)
}

/// Setup when input is Stata variables type
void CV_GLasso::setup(string scalar varlist, string scalar touse, string colvector lbd_list, real scalar nlam, real scalar K, real scalar max_iter, real scalar tolerance, real scalar gama, string scalar crit, string scalar cvmethod, string scalar diag) //string scalar nostandardize,
{
	real matrix user_X, S, st_X, diag_S
	real scalar lammin, lammax
	real colvector sqrt_diag_S
	string colvector cv
//	pragma unset X
	st_view(X, ., tokens(varlist), touse)
	cv = tokens(varlist)
//		if (nostandardize == "")
//	{
//	X      = gl.standardizeX(X)
//	}
	if (length(uniqrows(cv)) != length(cv)) 
	{
		errprintf(" repeated variables not allowed \n")
		exit(498)
	}
	if (crit == "")
	{
		crit = "loglik"
	}
	if (crit != "loglik" & crit != "eBIC")
	{
	    errprintf("Available criteria are CV and eBIC \n")
		exit(498)	
	}
	if (cvmethod == "")
	{
	    cvmethod = "shuffle"
	}
	if (cvmethod != "mod" & cvmethod != "shuffle")
	{
	    errprintf("Available cv methods are mod and shuffle \n")
		exit(498)
	}
	if (lbd_list == "")
	{
	    S = quadcrossdev(X, 0, mean(X), X, 0, mean(X)) :/ rows(X)
		st_X = X :- mean(X)
		sqrt_diag_S = sqrt(diagonal(S))
		diag_S = diag(1 :/ sqrt_diag_S)
		st_X = quadcross(st_X', diag_S)
	    S = quadcross(st_X, st_X) :/ rows(X)
		lammax = max(abs(S - diag(diagonal(S))))
		lammin = 0.01 * log10(lammax)
		lamlist = 10:^rangen(log10(lammax), log10(lammin), nlam)
	}else{
		lamlist = st_matrix(lbd_list)
	}
	nfold     = K
	gam = gama
	CVglasso(max_iter, tolerance, crit, cvmethod, diag) //nostandardize,
	st_rclear()
	st_matrix("r(Omega)", Omega)
	st_matrix("r(Sigma)", Omega_inv)
	st_numscalar("r(lambda)", lambda)
}

void CV_GLasso::CVglasso(real scalar max_iter, real scalar tolerance,  string scalar crit, string scalar cvmethod, string scalar diag) //, string scalar nostandardize
{
    real scalar nlam, fold, j, se_fit, i_best_fit, ise_fit, nz
	real colvector fold_ids, cvm, cvse, index_te, index_tr, xbar
	real rowvector m_fit, ind_te, ind_tr
	real matrix cv_folds, errs_fit, xtrain, xtest, S_test, tmp
	N = rows(X)
	p = cols(X)
	nlam = length(lamlist)
	if (cvmethod == "mod")
	{
	fold_ids = mod(mm_srswor(N, N), nfold) :+ 1 
	}else{
	    fold_ids = mm_srswor(N,N)
	}
	cvm = J(nlam, 1, .)
	cvse = J(nlam, 1, .)
	cv_folds = J(nfold, nlam, 0)
	errs_fit = J(nlam, nfold, 0)

	for (fold = 1; fold <= nfold; fold++)
	{
	    if (cvmethod == "mod")
		{
			index_tr = selectindex(fold_ids :!= fold)
			index_te = selectindex(fold_ids :== fold)
		}else{
		    ind_tr = ((1 + floor((fold - 1) * N / nfold) ) .. floor(fold * N / nfold))
			index_tr = fold_ids[ind_tr]
			ind_te = J(1, N, 1)
			ind_te[ind_tr] = J(1,length(ind_tr), 0)
			index_te = select(fold_ids, ind_te')
		}
		xtrain = X[index_tr, ]
		xbar   = mean(xtrain)
		xtrain = xtrain :- xbar //scale(xtrain)	
		xtest = X[index_te,]
		xtest = xtest :- xbar
		S_test = quadcross(xtest,xtest) :/ rows(xtest)
		S_train = quadcross(xtrain,xtrain) :/ rows(xtrain)
		CVglasso_fit(xtrain, max_iter, tolerance, diag) //nostandardize,
		for(j = 1; j <= nlam; j++)
		{
		    if (crit == "loglik")
			{
		        errs_fit[j,fold] =  rows(xtest)  * (sum((*result[j]) :* S_test) -  log(det((*result[j]))))
			}else{
			    nz = sum((*result[j]) :!= 0)
			    errs_fit[j,fold] =  rows(xtest)  * (trace((*result[j]),S_test) -  log(det((*result[j]))))  + nz * log(rows(xtest)) + 4 * nz * gam * log(cols(xtest))
			}
				
		}
	}
	m_fit = mean(errs_fit')
	se_fit = sqrt(diag(variance(errs_fit))) :/ sqrt(nfold)
	i_best_fit = selectindex(m_fit :== min(m_fit))[1]
	lambda = lamlist[i_best_fit]
	gl.setup1(X, lambda, max_iter, tolerance, diag) //nostandardize, 
	Omega = gl.Omega
	Omega_inv = gl.Omega_inv
}


void CV_GLasso::CVglasso_fit(real matrix xtrain, real scalar max_iter, real scalar tolerance, string scalar diag) //string scalar nostandardize,
{
	real scalar lbd, i
	real matrix init
	result = J(length(lamlist),1, NULL)
	for(i = 1; i <= length(lamlist); i++)
	{
	       result[i] = &(J(p, p, 0)) 
	}
	if (diag != "")
	{
		init = diag(diagonal(S_train)) // + diag(J(p,1,max(lamlist)))
	}else{
		init = S_train + diag(J(p,1,max(lamlist)))
		}
	for(i = 1; i <= length(lamlist); i++)
	{
		lbd = lamlist[i]
		gl.setup1(xtrain, lbd, max_iter,tolerance, diag, init) //nostandardize,
		(*result[i]) = gl.Omega
	//	init = gl.Omega_inv 
	}

}

real matrix CV_GLasso::scale(real matrix x ,| real scalar center, real scalar scl)
{
    real scalar p, N
	real matrix S, diag_S
	real colvector sqrt_diag_S
	real colvector cnt
        if(args() == 1)
	{
	    center = 1
		scl  = 0
	}
	p = cols(x)
	N = rows(x)
	if(center == 1)
	{
		x = x :- mean(x)
	}
	if(scl == 1)
	{
		S = quadcrossdev(x, 0, mean(x), x, 0, mean(x)) :/ N
	    sqrt_diag_S = sqrt(diagonal(S))
		diag_S = diag(1 :/ sqrt_diag_S)
		x = quadcross(x', diag_S)
	}
	return(x)
}
end	

//////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
////////////// Train based on ebic criteria ////////////////////////

program ebicglasso, rclass
version 16

////neq code
_parse comma matrix rest : 0
capture confirm matrix `matrix'

if _rc == 0 {            // syntax 2:  matrix
		local syntax 2
		syntax [anything(name=matrix)] [, lamlist(numlist)  NOSTANDardize max_iter(integer 100)  tolerance(real 1e-5) nlam(integer 40) gamma(real 0) diag]
    }
else {                                        // syntax 1: varlist
		local syntax 1
		syntax varlist(min=2 numeric) [if] [in] ///
		[,  lamlist(numlist)  NOSTANDardize max_iter(integer 100) ///
		tolerance(real 1e-5) nlam(integer 40) gamma(real 0) diag]
		marksample touse
		markout `touse'
	}
/*
if "`lamlist'" != ""{
	local lamlist: subinstr local lamlist " " ", ", all
	mata lamlist=sort(`lamlist', -1)'
}
  else{
        mata lamlist = rangen(1, 0.01, `nlam'')
  }
  
*/

mata: r = ebic_GLasso(1)
if `syntax' == 1{
	mata: r.setup("`varlist'", "`touse'", "`lamlist'",`nlam', `gamma', "`nostandardize'", `max_iter', `tolerance', "`diag'")
}
else{
	mata: X = st_matrix("`matrix'")
	mata: r.setup1(X, "`lamlist'",`nlam', `gamma', "`nostandardize'", `max_iter', `tolerance', "`diag'")
}

return add
end
//////////////


version 16
set matastrict on

mata:

struct GLassoebic_result
{
	real matrix Omega
	real matrix Omega_inv
	real scalar lambda
}

class ebic_GLasso
{
	public:
		void			setup()
		void 			setup1()
		void			GLasso_ebic_fit()
		real scalar             N
		real scalar             p
	// Private Funcitons

	// Input and estimated variables
	public:
		real matrix   			X 
		real matrix             Omega
		real matrix 		Omega_inv
		real scalar			lambda
		real scalar             gam
		real colvector		lamlist
		struct GLassoebic_result scalar result
		
	private:
		class GLasso scalar     gl
		real scalar             nonzero()

}
	
/// Setup when input is Stata matrix type
void ebic_GLasso::setup1(real matrix user_X, string colvector lbd_list, real scalar nlam, real scalar gama, string scalar nostandardize, real scalar max_iter, real scalar tolerance, string scalar diag)
{
    real scalar lammin, lammax
	real colvector sqrt_diag_S
	real matrix S, diag_S, st_X
	if (nostandardize == "")
	{
	    X = gl.standardizeX(user_X)
	}
	if (lbd_list == "")
	{
	    S = quadcrossdev(X, 0, mean(X), X, 0, mean(X)) :/ rows(X)
		st_X = X :- mean(X)
		sqrt_diag_S = sqrt(diagonal(S))
		diag_S = diag(1 :/ sqrt_diag_S)
		st_X = quadcross(st_X', diag_S)
	    S = quadcross(st_X, st_X) :/ rows(X)
		lammax = max(abs(S - diag(diagonal(S))))
		lammin = 0.01 * log10(lammax)
		lamlist = 10:^rangen(log10(lammax), log10(lammin), nlam)
	}else{
		lamlist = st_matrix(lbd_list)
		lamlist = sort(lamlist, -1)
	}
	gam     = gama
	GLasso_ebic_fit(max_iter, tolerance, nostandardize, diag)
	st_rclear()
	st_matrix("r(Omega)", Omega)
	st_matrix("r(Sigma)", Omega_inv)
	st_numscalar("r(lambda)", lambda)
}

/// Setup when input is Stata variables type
void ebic_GLasso::setup(string scalar varlist, string scalar touse, string colvector lbd_list, real scalar nlam, real scalar gama, string scalar nostandardize, real scalar max_iter, real scalar tolerance, string scalar diag)
{
	real matrix user_X, S, diag_S,st_X
	real scalar lammin, lammax
	real colvector sqrt_diag_S
	string colvector cv
//	pragma unset X
	st_view(X, ., tokens(varlist), touse)
	cv = tokens(varlist)
	if (nostandardize == "")
	{
	    X = gl.standardizeX(X)
	}
	if (length(uniqrows(cv)) != length(cv)) 
	{
		errprintf(" repeated variables not allowed")
		exit(498)
	}

	if (lbd_list == "")
	{
	    S = quadcrossdev(X, 0, mean(X), X, 0, mean(X)) :/ rows(X)
		st_X = X :- mean(X)
		sqrt_diag_S = sqrt(diagonal(S))
		diag_S = diag(1 :/ sqrt_diag_S)
		st_X = quadcross(st_X', diag_S)
	    S = quadcross(st_X, st_X) :/ rows(X)
		lammax = max(abs(S - diag(diagonal(S))))
		lammin = 0.01 * lammax
		lamlist = 10:^rangen(log10(lammax), log10(lammin), nlam)
	}else{
		lamlist = st_matrix(lbd_list)
	}

	gam     = gama
	GLasso_ebic_fit(max_iter, tolerance, nostandardize, diag)
	st_rclear()
	st_matrix("r(Omega)", Omega)
	st_matrix("r(Sigma)", Omega_inv)
	st_numscalar("r(lambda)", lambda)
}



void ebic_GLasso::GLasso_ebic_fit(real scalar max_iter, real scalar tolerance, string scalar nostandardize, string scalar diag)
{
    real matrix init, result
	real colvector ebic_fit
	real scalar lbd, i, nz, i_bic
	ebic_fit = J(length(lamlist),1, .)
	init = diag(diagonal(quadcrossdev(X, 0, mean(X), X, 0, mean(X)) :/ rows(X))) //I(cols(X))
	for(i = 1; i <= length(lamlist) ; i++)
	{
		lbd = lamlist[i]
		gl.setup1(X, lbd, nostandardize, max_iter, tolerance, diag, init)
		nz = sum(gl.Omega :!= 0)  // nonzero(gl.Omega)
		ebic_fit[i] = gl.N() * (trace(gl.S, gl.Omega) -  log(det(gl.Omega))) + nz * log(gl.N()) + 4 * nz * gam *log(gl.p())
		init = gl.Omega_inv // +  diag(J(gl.p(),1,max(lamlist)))
	}
	i_bic = selectindex(ebic_fit :== min(ebic_fit))[1]
	lambda = lamlist[i_bic] 
	gl.setup1(X, lambda, nostandardize, max_iter, tolerance, diag)
	Omega = gl.Omega
	Omega_inv = gl.Omega_inv 
}
	
end


