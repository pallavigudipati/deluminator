#include <iostream>

#include "simulator.h"

using namespace std;

// Most of the commenting done in "simulator.h".
void Simulator::LoadSpecifications() {
	// Counters....
	time_ = -1;
	int num_counters;
	cin >> num_counters;
	// Loop till we get a legitimate value.
	// This is done for all the inputs.
	while (num_counters < 0) {
		cout << red << "ERROR: Please input a non-negative value." 
			 << normal <<  endl;
		cin >> num_counters;
	}

	// ..... and their initial number of goods.
	int initial_goods;
	for (int i = 0; i < num_counters; ++i) {
		cin >> initial_goods;
		if (initial_goods < 0) {
			cout << red << "ERROR: Please input a non-negative value."
				 << normal << endl;
			i--;
			continue;
		}
		Counter* counter = new Counter(initial_goods);
		counter->counter_id_ = i;
		counters_.push_back(counter);
	}

	// In-Queue
	// Rate.
	int rate;
	cin >> rate;

	while (rate < 0) {
		cout << "ERROR: Please input a non-negative value."
			 << endl;
		cin >> rate;
	}

	rate_in_queue_ = rate;
	cin >> initial_size_;
	last_person_id_ = 0;
	// Initial Person objects in queue need their good requirements to
	// be specified. The Sampling() function is NOT used for them.
	for (int i = 0; i < initial_size_; ++i) {
		int require;
		cin >> require;
		if (require < 0) {
			cout << "ERROR: Please input a non-negative value."
				 << endl;
			i--;
			continue;
		}
		Person* person = new Person(require);
		person->person_id_ = last_person_id_;
		last_person_id_++;
		person->in_queue_entry_time_ = time_;
		in_queue_.JoinQueue(person);
	} 

	// View
	int view;
	cin >> view;
	view_ = view;

	// Display
	display_ = new Display(view, &display_person_, &in_queue_, &out_queue_,
							&counters_); 
}

// TODO : print errors for rate and view not being integers
// time_: After the end of t th second.
void Simulator::RunSimulation() {
	display_->Print();
	while(1) {
		time_++;	
		//TODO : what if a person with zero goods requirement comes 
		JoinExitQueue();
		ExitExitQueue();
		JoinEntryQueue();
		ExitEntryQueue();
		display_->Print();
		if (num_closed_ == counters_.size()) {
			display_->PrintFinal();
			// End the simulation when the number of closed counters
			// equals the total number of counters.
			cout << "Simulation ended at time = " << time_ << endl;
			return;
		}
	}
}

void Simulator::ExitEntryQueue() {
	vector<int> open_counters = FindEmptyCounters();
	// Iterated over all the open(unoccupied) counters.
	for (int i = 0; i < open_counters.size(); ++i) {
		if (!in_queue_.size_) {
			break;
		}
		Person* person = in_queue_.LeaveQueue();
		person->counter_entry_time_ = time_;
		at_counters_.push_back(person);
		person->counter_ = open_counters[i];
		counters_[open_counters[i]]->AcceptRequest(person);
	}
}

void Simulator::ExitExitQueue() {
	display_person_.clear();
	// Pops out all the Person objects that have waited for their
	// specified amount of time.
	while (out_queue_.size_) {
		Person* person = out_queue_.queue_simulator_.front();
		if (person->status_till_.second == -1) {
			// 'person' is at the front of the exit queue.
			person->status_till_.second = time_ + person->goods_collected_;
		}
		// 'person' at the front of the exit queue has waited for
		// the specified time.
		if (person->status_till_.second <= time_) {
			out_queue_.LeaveQueue();
			person->out_queue_exit_time_ = time_;
			display_person_.push_back(person);
		} else {
			break;
		}
	}
}

void Simulator::JoinEntryQueue() {
	// Iterates over the number of Person objects that join the queue.
	for (int i = 0; i < rate_in_queue_; ++i) {
		int goods = Sampling();
		while (goods < 0) {	
			cout << "ERROR: Please input a non-negative value."
				 << endl;
			goods = Sampling();
		}
		Person* person = new Person(goods);
		person->person_id_ = last_person_id_;
		last_person_id_++;
		person->in_queue_entry_time_ = time_;
		in_queue_.JoinQueue(person);
	}
}

void Simulator::JoinExitQueue() {
	// Iterates over all the Person objects at counters.
	for (int i = 0; i < at_counters_.size(); ++i) {
		Person* person = at_counters_[i];
		// Current transaction is finished.
		if (person->status_till_.second <= time_) {
			person->status_till_.first = OUT_QUEUE;
			person->status_till_.second = -1;
			person->out_queue_entry_time_ = time_;
			at_counters_.erase(at_counters_.begin() + i);
			out_queue_.JoinQueue(person);
		}
	}	
}

vector<int> Simulator::FindEmptyCounters() {
	vector<int> open_counters;
	num_closed_ = 0;
	// Iterates over all the counters.
	for (int i = 0; i < counters_.size(); ++i) {
		// Closed counters.
		if (counters_[i]->status_till_.first == CLOSED) {
			num_closed_++;
		} else if (counters_[i]->status_till_.first == OPEN) {
			// Open(Unoccupied) counters.
			// Counter is empty. 
			if (!counters_[i]->num_goods_) {
				counters_[i]->status_till_.first = CLOSED;
				counters_[i]->status_till_.second = -1;
				num_closed_++;
				counters_[i]->person_id_ = -1;
			} else {
				// Counter is not empty.
				open_counters.push_back(i);
			}
		} else {
			// Occupied counters.
			// The current transactions are finished.
			if (counters_[i]->status_till_.second <= time_) {
				// Counter is empty.
				if (!counters_[i]->num_goods_) {
					counters_[i]->status_till_.first = CLOSED;
					counters_[i]->person_id_ = -1;
					num_closed_++;
					counters_[i]->status_till_.second = -1;
				} else {
					// Counter is not empty.
					counters_[i]->status_till_.first = OPEN;
					counters_[i]->person_id_ = -1;
					open_counters.push_back(i);
				}
			}
		}
	}
	return open_counters;
}

