program standardize, rclass
version 16

	////neq code
	_parse comma matrix rest : 0
	capture confirm matrix `matrix'


	if _rc == 0 {            // syntax 2:  matrix
			local syntax 2
			syntax [anything(name=mt)]  //NOSTANDardize
		}
	else {                                        // syntax 1: varlist
			local syntax 1
			syntax varlist(min=2 numeric) [if] [in] ///
			//NOSTANDardize
			marksample touse
			markout `touse'
		}

//	mata: r = GLasso(1)
	if `syntax' == 1{
		    mata:   user_X = .
		    mata: 	st_view(user_X, ., tokens("`varlist'"), "`touse'")
			mata:   X = standardizeX(user_X) //"`nostandardize'",
	}
	else{
		mata: X = st_matrix("`matrix'")
		mata: X = standardizeX( X) //"`nostandardize'",
	}
	mata: 	st_rclear()
	mata:   st_matrix("r(X)", X)

	return add


end


version 16
set matastrict on

mata:
real matrix standardizeX(real matrix X)
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

end
