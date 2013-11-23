#include <iostream>
using namespace std;

// Status
#define IN_QUEUE 0
#define AT_COUNTER 1
#define OUT_QUEUE 2

class Person {
  public:
	// Constructor. 'require' is the number of goods required.
	Person(int require);
	~Person() {};
	
	// Prints person's information.
	void PrintInfo();

	// A unique Id that every person entering the entry
	// queue gets.
	int person_id_;

	// The Id of the counter it gets goods from.
	int  counter_;

	// pair.first: One of the above mentioned #defs.
	// pair.second: The time till which this status will remain for sure.
    // For invalid/unknown/default entries, it's -1.
	pair<int, int> status_till_;

	// Number of goods required at any point of time.
	int goods_required_;

	// Number of goods collected at any point of time.
	int goods_collected_;	

	// Entry queue entering time.
	int in_queue_entry_time_;

	// Entry queue exiting time/Counter entering time.
	int counter_entry_time_;

	// Exit queue entering time/Counter exiting time.
	int out_queue_entry_time_;

	// Exit queue exiting time.
	int out_queue_exit_time_;
};

Person::Person(int require) {
	counter_ = -1;
	status_till_.first = IN_QUEUE;
	goods_collected_ = 0;
	goods_required_ = require;
	in_queue_entry_time_ = -1;
	counter_entry_time_ = -1;
	out_queue_entry_time_ = -1;
	out_queue_exit_time_ = -1;
}

void Person::PrintInfo() {
	cout << "Person Id: " << person_id_ << endl;
	cout << "Status: " << status_till_.first << " till: "
		 << status_till_.second << endl;
	cout << "Counter: " << counter_ << endl;
	cout << "Goods collected: " << goods_collected_ << endl;
	cout << "Goods required: " << goods_required_ << endl;
	cout << "In queue entry time: " << in_queue_entry_time_ << endl;
	cout << "Counter entry time: " << counter_entry_time_ << endl;
	cout << "Out queue entry time: " << out_queue_entry_time_ << endl;
	cout << "Out queue exit tme: " << out_queue_exit_time_ << endl;
}
