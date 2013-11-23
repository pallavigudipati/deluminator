all : sudoku_main

sudoku_main : sudoku_main.o sudoku
	g++ -g -o sudoku_main sudoku_main.cpp

sudoku : sudoku.o
	g++ -c -fpermissive sudoku.cpp sudoku.h -o sudoku.o
