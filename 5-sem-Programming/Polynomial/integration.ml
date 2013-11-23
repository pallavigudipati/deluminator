(*Integration of a polynomial*)

use "arithmetic.ml";

(*Integrates given the coefficient and power.*)
fun integrate_part (coeff:real, power) = 
	make_poly(coeff / real(power + 1), power + 1);

(*Itegrates each term of a polynomial.*)
fun integrate_iter ([], power) = []
| 	integrate_iter (a::y, power) = add_poly(integrate_part((a:real),
								   							power),
									integrate_iter(y, power - 1));

(*Integrates a polynomial. Constant of integration is ignored.*)
fun integrate ([]) = []
| 	integrate (a::y) = integrate_iter(rev(y)@((a:real)::[]),
									  length(y));
