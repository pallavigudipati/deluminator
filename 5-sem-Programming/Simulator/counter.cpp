#include <iostream>

#include "queue_sim.cpp"
using namespace std;

// Counter status.
#define CLOSED 0
#define OPEN 1
#define OCCUPIED 2

// The global clock.
int time_;


class Counter {
  public:
	// Constructor. 'initial_goods' is the initial amount of goods
	// given to the counter.
	Counter(int initial_goods);
	~Counter() {};

	// Accepts the request made by 'person'.
	bool AcceptRequest(Person* person);

	// Prints information.
	void PrintInfo();

	// Unique Id assigned to every counter.
	int counter_id_;

	// pair.first: One of the above #defs.
    // pair.second: The time till which this status will remain for sure.
	// For invalid/unknown/default entries, it's -1.	
	pair<int, int> status_till_;
	
	// Maximum/Initial number of goods present at the counter.
	int max_num_goods_;

	// Number of goods currently present.
	int num_goods_;

	// Closing time of the counter.
	int closing_time_;

	// The Id of the person currently occupying the counter.
    // It's -1 if the counter is closed or unoccupied.	
	int person_id_;

};

Counter::Counter(int initial_goods) {
	if (!initial_goods) {
		status_till_.first = CLOSED;
		status_till_.second = -1;
		return;
	}
	status_till_.first = OPEN;
	status_till_.second = -1;
	max_num_goods_ = initial_goods;
	num_goods_ = initial_goods;
	person_id_ = -1;
}

bool Counter::AcceptRequest(Person* person) {
	person->status_till_.first = AT_COUNTER;
	person_id_ = person->person_id_;	
	status_till_.first = OCCUPIED;
	
	// If the goods required by the person are less than or equal to the
	// current number of goods present at the counter.
	if (person->goods_required_ < num_goods_) {
		num_goods_ -= person->goods_required_;
		person->goods_collected_ = person->goods_required_;
		status_till_.second = time_ + person->goods_collected_;
		person->goods_required_ = 0;
	} else {
		// If the goods required by the person are greater than the
		// current number of goods present at the counter.
		person->goods_collected_ = num_goods_;
		person->goods_required_ -= num_goods_;
		closing_time_ = time_ + num_goods_;
		status_till_.second = time_ + num_goods_;
		num_goods_ = 0;
	}
	
	person->status_till_.second = time_ + person->goods_collected_;
}

// Print information.
void Counter::PrintInfo() {
	cout << "Counter Id: " << counter_id_ << endl;
	cout << "Status: ";

	if (status_till_.first == OPEN) {
	   cout << "OPEN";
	} else if (status_till_.first == OCCUPIED) {
 		cout << "OCCUPIED";
	} else {
 		cout << "CLOSED";
	}
	
	cout << "  till: " << status_till_.second << endl;
	cout << "Max number of goods: " <<  max_num_goods_ << endl;
	cout << "Present number of goods: " <<  num_goods_  << endl;
	cout << "Closing time: " << closing_time_ << endl;
	cout << "Person Id: " << person_id_ << endl;
}
