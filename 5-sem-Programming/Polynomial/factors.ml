(*Factorization of polynomials and few basic functions for polynomials.*)

use "arithmetic.ml";

(*Finds if a particular value is a zero of the given polynomial.*)
fun is_zero (y, x) = let
		val remainder = clean_poly(nth(div_poly(y, x), 1));
	in
		if ((length(remainder) = 1) andalso
			((hd(remainder) - 0.0 < epsilon) andalso
			 hd(remainder) -0.0 > ~epsilon)) then true
		else false
	end;

(*Finds a zero of the given polynomial out of a set of values.*)
fun find_zero (y, []) = make_real(y)
| 	find_zero (y, a::x) = 
		if (is_zero(make_real(y), make_zero(a))) then make_zero(a)
		else find_zero(y, x);

(*Finds all the linear factors of the give polynomial.*)
fun find_linear_factors ([]) = []
| 	find_linear_factors (a::y) = 
		if (null(y)) then (real(a)::[])::[]
		else let
			val fac_constant = find_factors(modulus(a), 1);
			val fac_coeff = find_factors(modulus(nth(y, length(y) - 1)), 1);
			val possible_zeroes = remove_duplicates(make_rationals(fac_constant,
															   fac_coeff));
			val factor = find_zero(a::y, possible_zeroes);
			val next = make_int(nth(div_poly(make_real(a::y), factor), 0), 0);
		in
			factor::find_linear_factors(next)
		end;

(*Finds a polynomial in a list of polynomials.*)
fun find_poly (a, []) = false
| 	find_poly (a, b::y) =
		if (equal_poly(a, b)) then true
		else find_poly(a, y);

(*Deletes a polynomial in a list of polynomials.*)
fun delete_poly (a, []) = []
| 	delete_poly (a, b::y) =
		if (equal_poly(a, b)) then y
		else b::delete_poly(a, y);

(*Finds common polynomials in two lists of polynomials.*)
fun find_common ([], y) = []
| 	find_common (a::x, y) =
		if (find_poly(a, y)) then a::find_common(x, delete_poly(a, y))
		else find_common(x, y);

(*Finds common factors of two polynomials.*)
fun find_common_factors (x, []) = []
| 	find_common_factors ([], y) = []
| 	find_common_factors (a::x, b::y) = let
		val factors_x = find_linear_factors(a::x);
		val factors_y = find_linear_factors(b::y);
		val common = find_common(factors_x, factors_y);
	in
		common
	end;
