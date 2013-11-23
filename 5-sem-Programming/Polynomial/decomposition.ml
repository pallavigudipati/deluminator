(*Decomposition into partial fractions.*)

use "factors.ml";

(*Finds all the partial fractions, given all the linear factors of denominator.*)
fun linear_denom ([], y, z) = []
| 	linear_denom (a::x, y, z) = let
		val zero = ~(hd(a));
		val num_n = substitute_poly(zero, y);
		val num_d = substitute_poly(zero, hd(div_poly(z, a)));
		val numerator = num_n / num_d;
	in
		((numerator::[])::(a::[]))::linear_denom(x, y, z)
 	end;

(*Finds partial fractions. Input: [numerator, denominator]
 *Assumption: The denominator has only linear, distinct factors.
 *)
fun decompose ([], y) = []
| 	decompose (x, []) = raise div_zero
| 	decompose (a::x, b::y) =
		if (length(a::x) >= length(b::y)) then let
			val quot_rem = div_poly(a::x, b::y);
		   	val element = hd(quot_rem)::((1.0::[])::[]);
			val remainder = nth(quot_rem, 1);
		in
			element::decompose(remainder, b::y)
		end
		else let
			val factors_y = find_linear_factors(make_int(b::y, 0));
			val actual_factors = take(factors_y, length(y));
			val elements = linear_denom(actual_factors, a::x, b::y);
			val first_el = hd(elements);
			val mod_first = hd(first_el)::(mult_poly(last(factors_y),
												     last(first_el))::[]);
		in
			mod_first::tl(elements)
			
		end;			
