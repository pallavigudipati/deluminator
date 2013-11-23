#include "sudoku.h"

#include <math.h>
#include <fstream>

using namespace std;

void Sudoku::LoadData(string filename) {
	ifstream input(filename.c_str());
	for (int i = 0; i < SIZE; ++i) {
		vector<int> row;
		for (int j = 0; j < SIZE; ++j) {
			int value;
			input >> value;
			row.push_back(value);
		}
		data_.push_back(row);
	}
	input.close();
}

bool Sudoku::PreliminaryChecks() {
	// Subsize check.
	if (SIZE % SUBSIZE != 0 || pow(SUBSIZE, 2) != SIZE) {
		cout << "ERROR : Given pair of SIZE and SUBSIZE is not possible." << endl;
		return false;
	}

	// Data check
	if (data_.size() != SIZE) {
		cout << "ERROR : Incorrect data." << endl;
		return false;
	}

	for (int i = 0; i < SIZE; ++i) {
		if (data_[i].size() != SIZE) {
			cout << "ERROR : Incorrect data." << endl;
			return false;
		}
	}

	// Symbol check.
	for (int i = 0; i < SIZE; ++i) {
		for (int j = 0; j < SIZE; ++j) {
			if (data_[i][j] < 0 || data_[i][j] > 8) {
				cout << "ERROR : Symbol check failed." << endl;
				return false;
			}
		}
	}

	// All checks passed.
	return true; 
}

void Sudoku::MakeInventory() {
	for (int i = 0; i < pow(SIZE / SUBSIZE, 2); ++i) {
		for (int j = 0; j < SIZE; ++j) {
			inventory_[make_pair(i + 1, j)] = 0;
		}
	}
	for (int i = 0; i < SIZE; ++i) {
		for (int j = 0; j < SIZE; ++j) {
			inventory_[make_pair(GetBox(i, j), data_[i][j])]++;
		}
	}
}

void Sudoku::PrintInventory() {
	cout << endl;
	for (int i = 0; i < SIZE; ++i) {
		int total = 0;
		for (int j = 0; j < pow(SIZE / SUBSIZE, 2); ++j) {
			total += inventory_[make_pair(j + 1, i)];
		}
		cout << "Symbol " << i << " : Count " << total << endl;
	}
	cout << endl;
}

int Sudoku::GetBox(int x, int y) {
	return ((x / SUBSIZE) * SUBSIZE + (y / SUBSIZE + 1));
}

bool Sudoku::CheckLegitimate() {
	for (int i = 0; i < SIZE; ++i) {
		int total = 0;
		for (int j = 0; j < pow(SIZE / SUBSIZE, 2); ++j) {
			total += inventory_[make_pair(j + 1, i)];
			if (total > SIZE) {
				return false;
			}
		}
	}
	return true;
}

void Sudoku::Solve() {
	for (int i = 0; i < pow(SIZE / SUBSIZE, 2); ++i) {
		for (int j = 0; j < SIZE; ++j) {
			if (inventory_[make_pair(i + 1, j)] == 0) {
				int extra;
				for (int k = 0; k < SIZE; ++k) {
					if (inventory_[make_pair(i + 1, k)] > 1) {
						extra = k;
						break;
					}
				}
				for (int k = i + 1; k < pow(SIZE / SUBSIZE, 2); ++k) {
					int count = inventory_[make_pair(k + 1, j)]; 
					if (count > 1) {
						Exchange(i + 1, k + 1, extra, j);
						inventory_[make_pair(i + 1, extra)]--;
						inventory_[make_pair(i + 1, j)]++;
						inventory_[make_pair(k + 1, extra)]++;
						inventory_[make_pair(k + 1, j)]--;
						break;
					}
				}
			}
		}
	}
	LastShuffle();
}

void Sudoku::Exchange(int box1, int box2, int value1, int value2) {
	pair<int, int> coords1 = GetCoords(box1, value1);
	pair<int, int> coords2 = GetCoords(box2, value2);
	pair<int, int> box_coords1 = GetBoxCoords(box1, value1);
	pair<int, int> box_coords2 = GetBoxCoords(box2, value2);
	bool same_row = false;

	// Same row.
	if (coords1.first == coords2.first) {
		same_row = true;
		if ((coords1.first + 1) % SUBSIZE) {
			Rotate(false, coords1.second);
			coords1.first++;
			box_coords1.first++;
		} else {
			MultiRotate(false, coords1.second, SIZE - SUBSIZE + 1);
			coords1.first -= SUBSIZE - 1;
			box_coords1.first -= SUBSIZE - 1;
		}
	}

	// Other case.
	int next_column = (coords2.second / SUBSIZE) * SUBSIZE +
		              ((box_coords2.second + 1) % SUBSIZE);
	MultiRotate(true, coords1.first,
				(next_column - coords1.second + SIZE) % SIZE);
	MultiRotate(false, next_column,		
				(coords2.first - coords1.first + SIZE) % SIZE);
	vector<int> new_positions;
	for (int i = 0; i < SUBSIZE; ++i) {
		for (int j = 0; j < SUBSIZE; ++j) {
			if (i == box_coords2.first && j == box_coords2.second) {
				new_positions.push_back(box_coords2.first * SUBSIZE +
						                (next_column % SUBSIZE));
			} else if (i == box_coords2.first && j == next_column % SUBSIZE) {
				new_positions.push_back(box_coords2.first * SUBSIZE + box_coords2.second);
			} else {
				new_positions.push_back(i * SUBSIZE + j);
			}
		}
	}
	ShuffleBox(box2, new_positions);
	MultiRotate(false, next_column,
				(coords1.first - coords2.first + SIZE) % SIZE);
	MultiRotate(true, coords1.first,
				(coords1.second - next_column + SIZE) % SIZE);
	
	// Same row.
	if (same_row) {
		if (!(coords1.first % SUBSIZE)) {
			MultiRotate(false, coords1.second, SUBSIZE - 1);
		} else {
			MultiRotate(false, coords1.second, SIZE - 1);
		}
	}
}

pair<int, int> Sudoku::GetCoords(int box_number, int value) {
	int x_start = SUBSIZE * ((box_number - 1) / SUBSIZE);
    int y_start = SUBSIZE * ((box_number - 1) % SUBSIZE);
	for (int i = x_start; i < x_start + SUBSIZE; ++i) {
		for (int j = y_start; j < y_start + SUBSIZE; ++j) {
			if (data_[i][j] == value) {
				return make_pair(i, j);
			}
		}
	}
}

pair<int, int> Sudoku::GetBoxCoords(int box_number, int value) {
	pair<int, int> coords = GetCoords(box_number, value);
	coords.first -= SUBSIZE * (coords.first / SUBSIZE);
	coords.second -= SUBSIZE * (coords.second / SUBSIZE);
	return coords;
}

void Sudoku::ShuffleBox(int box_number, vector<int> new_positions) {
	int x_start = SUBSIZE * ((box_number - 1) / SUBSIZE);
    int y_start = SUBSIZE * ((box_number - 1) % SUBSIZE);
	vector<int> box_copy;	
	for (int i = x_start; i < x_start + SUBSIZE; ++i) {
		for (int j = y_start; j < y_start + SUBSIZE; ++j) {
			box_copy.push_back(data_[i][j]);
		}
	}
	int it = 0;
	for (int i = x_start; i < x_start + SUBSIZE; ++i) {
		for (int j = y_start; j < y_start + SUBSIZE; ++j) {
			data_[i][j] = box_copy[new_positions[it]];
			it++;
		}
	}
	cout << "Shuffle : " << box_number << " : ";
	PrintVector(box_copy);
	cout << "   to    ";
	PrintVector(new_positions);
    cout << endl;
}

void Sudoku::Rotate(bool row, int line) {
	if (line < 0 || line > SIZE - 1) {
		cout << "Rotate getting an out-of-bound value." << endl;
		return;
	}
	if (row) {
		int last = data_[line][SIZE - 1];
		for (int i = SIZE - 1; i > 0; --i) {
			data_[line][i] = data_[line][i - 1];
		}
		data_[line][0] = last;
	}
	else {
		int last = data_[SIZE - 1][line];
		for (int i = SIZE - 1; i > 0; --i) {
			data_[i][line] = data_[i - 1][line];
		}
		data_[0][line] = last;
	}	
	cout << "Rotate : ";
	if (row) {
		cout << "Row : " << line + 1 << endl;
	} else {
		cout << "Column : " << line + 1 << endl;
	}
}

void Sudoku::MultiRotate(bool row, int line, int freq) {
	if (line < 0 || line > SIZE - 1) {
		cout << "MultiRotate giving Rotate an out-of-bound value." << endl;
	}
	for (int i = 0; i < freq; ++i) {
		Rotate(row, line);
	}
}

void Sudoku::LastShuffle() {
	for (int i = 0; i < pow(SIZE / SUBSIZE, 2); ++i) {
		vector<int> positions = GetPerfectPositions(i + 1);
		ShuffleBox(i + 1, positions);
	}
}

vector<int> Sudoku::GetPerfectPositions(int box_number) {
	map<int, int> value_position;
	int position = 0;
	int x_start = SUBSIZE * ((box_number - 1) / SUBSIZE);
    int y_start = SUBSIZE * ((box_number - 1) % SUBSIZE);
	for (int i = x_start; i < x_start + SUBSIZE; ++i) {
		for (int j = y_start; j < y_start + SUBSIZE; ++j) {
			value_position[data_[i][j]] = position;
			position++;	
		}
	}
	vector<int> correct_positions;

	for (int i = (box_number - 1) / SUBSIZE +
		 (((box_number - 1) % SUBSIZE) * SUBSIZE),
		 it = 0; it < SIZE; ++it, i = (i + 1) % SIZE) {
		correct_positions.push_back(value_position[i]);
	}
	return correct_positions;
}

void Sudoku::Print() {
	cout << endl <<  " -------------------------" << endl;
	for (int i = 0; i < SIZE; ++i) {
		cout << " | ";
		for (int j = 0; j < SIZE; ++j) {
			cout << data_[i][j] << " ";
			if (!((j + 1) % SUBSIZE)) {
				cout << "| ";
			}
		}
		cout << endl;
		if (!((i + 1) % SUBSIZE)) {
			cout << " -------------------------" << endl;
		}
	}
	cout << endl;
}

void Sudoku::PrintVector(vector<int> input) {
	for (int i = 0; i < input.size(); ++i) {
		cout << input[i] << " ";
	}
}
