(*Utilities*)

open List;

val epsilon = 0.0000000001;

(*Map for binary functions.*)
fun bin_map (f, v, []) = []
| 	bin_map (f, v, a::y) = (f(v, a))::(bin_map(f, v, y));

fun mult (a, b) = (a:real) * b;

(*Makes a polynomial, given a coefficient and it's power.*)
fun make_poly (coeff:real, power) = 
	if (power = 0) then coeff::[]
	else (make_poly(0.0, power - 1)@(coeff::[]));

(*Removes trailing zeroes.*)
fun clean_poly ([]) = []
| 	clean_poly (a::y) = 
		if (length(y) = 0) then (a:real)::[]
		else if (last(y) - 0.0 < epsilon)
			then a::clean_poly(rev(drop(rev(y), 1)))
   		else a::y;

(*Finds factors of the given integer.*)
fun find_factors (a, y) =
	if (y > a) then nil
	else if (a mod y = 0) then [y, ~y]@find_factors(a, y + 1)
	else find_factors(a, y + 1);

(*Finds a real number from the list of real numbers.*)
fun present(a, []) = false
| 	present(a, b::y) =
		if (((a:real) - (b:real) < epsilon) andalso (a - b > ~epsilon))
			then true
		else present(a, y);

(*Removes duplicates from a list of real numbers.*)
fun remove_duplicates ([]) = []
| 	remove_duplicates (a::y) = 
		if (present((a:real), y)) then remove_duplicates(y)
		else a::remove_duplicates(y);

(*Makes rational numbers, given a numerator and a list of denominators.*)
fun make_rationals_single (a, []) = []
| 	make_rationals_single (a, b::y) = (real(a) / real(b))::
									  make_rationals_single(a, y);

(*Makes rational numbers, given a lists of numerators and denominators.*)
fun make_rationals ([], y) = []
| 	make_rationals (a::x, y) = make_rationals_single(a, y)@
							   make_rationals(x, y);

(*Converts a list of integers to a list of real numbers.*)
fun make_real ([]) = []
| 	make_real (a::y) = real(a)::make_real(y);

(*Makes a factor, give a zero of a polynomial*)
fun make_zero (a:real) = a::(1.0::[]);

(*Takes floor of a list of real numbers.*)
fun take_floor ([]) = []
| 	take_floor (a::y) = floor(a)::take_floor(y);

(*Converts a polynomial with real coefficients to a polynomial with integer
  coefficients by multiplying with an appropriate power of 10.*)
fun make_int ([], n) = []
| 	make_int ((a:real)::y, n) = 
		if (n > length(y)) then take_floor(a::y)
		else if (nth(a::y, n) - real(floor(nth(a::y, n))) < epsilon)
			then make_int(a::y, n + 1)
		else make_int(bin_map(mult, 10.0, a::y), n);

(*Takes modulus of an integer.*)
fun modulus (a) =
	if (a < 0) then ~a
	else a;
