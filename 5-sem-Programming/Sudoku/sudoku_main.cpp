#include <iostream>
#include <fstream>
#include "sudoku.cpp"

using namespace std;

main() {
	Sudoku sudoku;
	sudoku.LoadData("input.txt");
	cout << "Initial input." << endl;
	sudoku.Print();

	if (sudoku.PreliminaryChecks()) {
		sudoku.MakeInventory();
		if (!sudoku.CheckLegitimate()) {
			sudoku.PrintInventory();
			cout << "Cannot be solved : Not a legitimate sudoku." << endl;
		} else {
			sudoku.Solve();
			cout << "Solved output." << endl;
			sudoku.Print();	
		}
	} else {
		cout << "Failed preliminary checks." << endl;
	}
}
