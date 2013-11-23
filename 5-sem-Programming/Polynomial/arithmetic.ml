(*Arithmetic operations for polynomials*) 

use "utilities.ml";

(*Checks equality of two polynomials.*)
fun equal_poly ([], []) = true
| 	equal_poly (a::x, []) = false
| 	equal_poly ([], b::y) = false
|  	equal_poly (a::x, b::y) = 
		if (((a:real) - (b:real) < epsilon) andalso
			(a - b > ~epsilon)) then equal_poly(x, y)
		else false;	

(*Add two polynomials.*)
fun add_poly ([], a) = a
| 	add_poly (a, []) = a
|  	add_poly (a::p, b::q) =  ((a:real) + b)::add_poly(p, q);

(*Subtracts two polynomials.*)
fun sub_poly ([], a) = bin_map(mult, ~1.0, a)
| 	sub_poly (a, []) = a
|  	sub_poly (a::p, b::q) =  ((a:real) - b)::sub_poly(p, q);

(*Multiplies two polynomials.*)
fun mult_poly ([], a) = [] 
| 	mult_poly (a::p, q) = add_poly(bin_map(mult, a, q),
									0.0::mult_poly(p, q));

exception div_zero;

(*Divides two polynomials. Returns quotient and remainder.*)
fun div_poly (p, q) = 
	if (length(q) = 0) then raise div_zero
	else if (hd(clean_poly(p)) - 0.0 < epsilon andalso
			 hd(clean_poly(p)) - 0.0 > ~epsilon) then (0.0::[])::((0.0::[])::[])
	else if (length(p) < length(q)) then [0.0]::(p::[])
	else let
		val coeff = last(p) / last(q);
		val power = length(p) - length(q);
		val quotient = make_poly(coeff, power);
		val new_divident = sub_poly(p, mult_poly(q, quotient));
		val new_division = div_poly(clean_poly(new_divident), q);
	in
		add_poly(quotient, nth(new_division, 0))::
										(nth(new_division, 1)::[])
	end;

(*Substitutes the given value in the polynomial and returns the result.*)
fun substitute_poly (a, []) = 0.0
| 	substitute_poly (a, b::y) = b + (a * substitute_poly(a, y));
