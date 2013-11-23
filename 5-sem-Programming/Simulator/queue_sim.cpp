#include <iostream>
#include <list>
#include <vector>

#include "person.cpp"
using namespace std;

class QueueSimulator {
  public:
	// Constructor.
	QueueSimulator();
	~QueueSimulator() {}
	
	// Pushes 'person' into the queue.
	void JoinQueue(Person* person);

	// Pops the first person from the queue.
	Person* LeaveQueue();

	// Prints information.
	void PrintInfo();

	// Unique id assigned to every counter.
	int counter_id_;

	// Current size of the queue.
	int size_;

	// The actual queue implementation using a list.
	// List of Person objects present in the queue.
	list<Person*> queue_simulator_;
};

QueueSimulator::QueueSimulator() {
	size_ = 0;
}

void QueueSimulator::JoinQueue(Person* person) {
	queue_simulator_.push_back(person);
	size_++;
}

Person* QueueSimulator::LeaveQueue() {
	size_--;
	Person* person = queue_simulator_.front();
	queue_simulator_.pop_front();
	return person;
}

void QueueSimulator::PrintInfo() {
	for (list<Person*>::iterator it = queue_simulator_.begin();
		 it != queue_simulator_.end(); ++it)  {
		(*it)->PrintInfo();
		cout << endl;
	}
};
