// A sample code.
#include <iostream>

#include "simulator.cpp"

using namespace std;

// A sample class using the library.
class NewSimulator: public Simulator {
  public:
	int Sampling() {
		return 9;
	}
};

main() {
	NewSimulator simulator;
	simulator.LoadSpecifications();
	simulator.RunSimulation();
}
