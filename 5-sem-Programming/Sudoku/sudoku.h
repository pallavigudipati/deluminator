#include <iostream>
#include <vector>
#include <map>
#include <utility>

using namespace std;

#define SUBSIZE 3
#define SIZE 9

class Sudoku {
  public:
	Sudoku() {}
	~Sudoku() {}

	void LoadData(string filename);
	bool CheckLegitimate();
	bool PreliminaryChecks();
	void MakeInventory();
	void PrintInventory();
	void Solve();
	void Exchange(int box1, int box2, int value1, int value2);
	int GetBox(int x, int y);
	pair<int, int> GetCoords(int box_number, int value);
	pair<int, int> GetBoxCoords(int box_number, int value);
	void ShuffleBox(int box_number, vector<int> new_positions);
	void Rotate(bool row, int line);
	void MultiRotate(bool row, int line, int freq);
	void LastShuffle();
	vector<int> GetPerfectPositions(int box_number);
	void Print();
	void PrintVector(vector<int> input);

  private:
	vector<vector<int> > data_;
	map<pair<int, int>, int> inventory_;
};
