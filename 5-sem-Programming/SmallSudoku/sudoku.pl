/* Sudoku solver for a 4x4 valid_sudoku. */

count([], Y, 0).
count([H|R], Y, Z) :-  H = Y, count(R, Y, W), J is W + 1, Z = J.
count([H|R], Y, Z) :-  H \= Y, count(R, Y, W), Z = W.

correct_set(X) :- count(X, 1, 1), count(X, 2, 1),
				  count(X, 3, 1), count(X, 4, 1).

in([], X, 0).
in(Y, X, A) :- Y = [H | T], H = X, A = 1.
in(Y, X, A) :- Y = [H | T], H \= X, in(T, X, AT), A = AT.

sudoku(X) :- count(X, 1, 4), count(X, 2, 4), count(X, 3, 4),
			 count(X, 4, 4), valid_sudoku(X, []). 

valid_sudoku([X1, X2, X3, X4,
			  X5, X6, X7, X8,
		 	  X9, X10, X11, X12,
			  X13, X14, X15, X16], Y)
	:- 	
		correct_set([X1, X2, X3, X4]), 
		correct_set([X5, X6, X7, X8]), 
		correct_set([X9, X10, X11, X12]), 
		correct_set([X13, X14, X15, X16]), 
		correct_set([X1, X5, X9, X13]), 
		correct_set([X2, X6, X10, X14]), 
		correct_set([X3, X7, X11, X15]), 
		correct_set([X4, X8, X12, X16]), 
		correct_set([X1, X2, X5, X6]), 
		correct_set([X3, X4, X7, X8]), 
		correct_set([X9, X10, X13, X14]), 
		correct_set([X11, X12, X15, X16]). 

valid_sudoku(X, Y) :- rotate(X, SM),
		in(Y, SM, 0), append(Y, [SM], Y2), valid_sudoku(SM, Y2).

rotate([X1, X2, X3, X4,
		X5, X6, X7, X8,
		X9, X10, X11, X12,
		X13, X14, X15, X16], SM)

	:-	SM = [X4, X1, X2, X3,
			  X5, X6, X7, X8,
			  X9, X10, X11, X12,
			  X13, X14, X15, X16].

rotate([X1, X2, X3, X4,
		X5, X6, X7, X8,
		X9, X10, X11, X12,
		X13, X14, X15, X16], SM)
		
	:- SM = [X1, X2, X3, X4,
			X8, X5, X6, X7,
			X9, X10, X11, X12,
			X13, X14, X15, X16].
		
rotate([X1, X2, X3, X4,
		X5, X6, X7, X8,
		X9, X10, X11, X12,
		X13, X14, X15, X16], SM)
		
	:- SM = [X1, X2, X3, X4,
			 X5, X6, X7, X8,
			 X12, X9, X10, X11,
			 X13, X14, X15, X16].

rotate([X1, X2, X3, X4,
		X5, X6, X7, X8,
		X9, X10, X11, X12,
		X13, X14, X15, X16], SM)
		
	:- SM = [X1, X2, X3, X4,
			 X5, X6, X7, X8,
			 X9, X10, X11, X12,
			 X16, X13, X14, X15].

rotate([X1, X2, X3, X4,
		X5, X6, X7, X8,
		X9, X10, X11, X12,
		X13, X14, X15, X16], SM)
		
	:- SM = [X13, X2, X3, X4,
			 X1, X6, X7, X8,
			 X5, X10, X11, X12,
			 X9, X14, X15, X16].

rotate([X1, X2, X3, X4,
		X5, X6, X7, X8,
		X9, X10, X11, X12,
		X13, X14, X15, X16], SM)
		
	:- SM = [X1, X14, X3, X4,
			 X5, X2, X7, X8,
			 X9, X6, X11, X12,
			 X13, X10, X15, X16].

rotate([X1, X2, X3, X4,
		X5, X6, X7, X8,
		X9, X10, X11, X12,
		X13, X14, X15, X16], SM)
		
	:- SM = [X1, X2, X15, X4,
			 X5, X6, X3, X8,
			 X9, X10, X7, X12,
			 X13, X14, X11, X16].

rotate([X1, X2, X3, X4,
		X5, X6, X7, X8,
		X9, X10, X11, X12,
		X13, X14, X15, X16], SM)
		
	:- SM = [X1, X2, X3, X16,
			 X5, X6, X7, X4,
			 X9, X10, X11, X8,
			 X13, X14, X15, X12].
