#include <iostream>

#include "counter.cpp"

using namespace std;

// All the views offered.
#define VIEW_PERSON 1
#define VIEW_COUNTER 2 
#define VIEW_IN_QUEUE 3
#define VIEW_OUT_QUEUE 4

// Declared in counter.cpp. The global clock.
extern int time_;

class Display {
  public:
	// Constructor. Takes all the inputs required to continuously print
	// all the attribute for a particular view.
	Display(int view, vector<Person*>* persons, QueueSimulator* in_queue,
			QueueSimulator* out_queue, vector<Counter*>* counters);
	~Display() {};

	// Prints the ouput for the given view, at a given instant.
	void Print();

	// Prints the final snapshot of entry and exit queue after the
	// simulation ends.
	void PrintFinal();

  private:
	// Prints from the POV of a Person/Request.
	void PrintPersonView();

	// Prints from the POV of a Counter.
	void PrintCounterView();

	// Prints from the POV of the entry queue.
	void PrintInQueueView();

	// Prints from the POV of the exit queue.
	void PrintOutQueueView();
	
	// One of the above #defs. If not, just prints the final snapshot. 
	int view_;

	// Vector of Person objects which have exited the exit queue.
	vector<Person*>* persons_;

	// Entry queue.
   	QueueSimulator* in_queue_;

	// Exit queue.
	QueueSimulator* out_queue_;

	// All the counters.
	vector<Counter*>* counters_;
};

Display::Display(int view, vector<Person*>* persons, QueueSimulator* in_queue,
				QueueSimulator* out_queue, vector<Counter*>* counters) {
	view_ = view;
	persons_ = persons;
   	in_queue_ = in_queue;
	out_queue_ = out_queue;
	counters_ = counters;
}

void Display::Print() {
	switch (view_) {
		case VIEW_PERSON:
			PrintPersonView();
			break;
		case VIEW_COUNTER:
			PrintCounterView();
			break;
		case VIEW_IN_QUEUE:
			PrintInQueueView();
			break;
		case VIEW_OUT_QUEUE:
			PrintOutQueueView();
			break;
	}
}

// Prints the information of all the people that have exited the exit queue
// in the last one second. Final snapshot take care of the people stranded
// in the entry and exit queues.
void Display::PrintPersonView() {
	cout << "Time " << time_ << endl << endl;
	// Iterates over all the Person objecs in the vector.
	for (int i = 0; i < persons_->size(); ++i) {
		(*persons_)[i]->PrintInfo();
	}
	cout << "_________________________________" << endl;
}

void Display::PrintInQueueView() {
	cout << "Time " << time_ << endl << endl;
	cout << "In Queue ";
	in_queue_->PrintInfo();
	cout << "_________________________________" << endl;
}

void Display::PrintOutQueueView() {
	cout << "Time " << time_ << endl << endl;
	cout << "Out Queue ";
	out_queue_->PrintInfo();
	cout << "_________________________________" << endl;
}

void Display::PrintCounterView() {
	cout << "Time " << time_ << endl << endl;
	// Iterates over all the counters.
	for (int i = 0; i < counters_->size(); ++i) {
		(*counters_)[i]->PrintInfo();
		cout << endl;
	}
	cout << "_________________________________" << endl;
}

void Display::PrintFinal() {
	cout << "Final Snapshot" << endl << endl;
	PrintInQueueView();
	PrintOutQueueView();	
}	
