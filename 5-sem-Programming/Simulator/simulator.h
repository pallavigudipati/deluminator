#include <iostream>

#include "display.cpp"

using namespace std;

// Declared in counter.cpp. The global clock.
// The clock is incremented at a granularity of 1 unit.
// A clock tick: t -> t + 1.
extern int time_;
char red[] = { 0x1b, '[', '1', ';', '3', '1', 'm', 0 };
char blue[] = { 0x1b, '[', '1', ';', '3', '4', 'm', 0 };
char normal[] = { 0x1b, '[', '0', ';', '3', '9', 'm', 0 };

class Simulator {
  public:
	  // Loads all the user specifications from the console.
	  void LoadSpecifications();

	  // Runs the simulation.
	  void RunSimulation();

  private:
	  // Displays all the information.
	  Display* display_;

	  // The following 4 functions take place after every clock tick.
	  // Moves all the Person objects that have finished their
	  // transactions to the exit queue.
	  void JoinExitQueue();

	  // Moved all the new Person objects to the entry queue.
	  void JoinEntryQueue();

	  // Removes all the Person objects that have waited in the exit queue for
	  // the alloted time from the exit queue.
	  void ExitExitQueue();

	  // Moves the front Person objects from the entry queue to
	  // open counters.
	  void ExitEntryQueue();

	  // Finds all the unoccupied(OPEN) counters at ay instant.
	  vector<int> FindEmptyCounters();

	  // Number of counter that have closed down. The simulation stops
	  // when all the counters have closed.
	  int num_closed_;

	  // Initial size of the entry queue.
	  int initial_size_;

	  // View for display.
	  int view_;

	  // Rate at which the entry queue is filled.
	  // Always a non-negative integer.
	  int rate_in_queue_;

	  // The person_id_ of the last person to enter the entry queue + 1.
	  int last_person_id_;

	  // All the counters.
	  vector<Counter*> counters_;

	  // Entry queue.
	  // (In-queue and entry-queue are used synonymously in the comments.)
	  QueueSimulator in_queue_;

	  // Exit queue.
	  // (Out-queue and exit-queue are used synonymously in the comments.)
	  QueueSimulator out_queue_;

	  // Person objects that are currently at any one of the counters.
	  vector<Person*> at_counters_;

	  // All the Person objects that have exited the exit-queue in the
	  // last one second. Used by the Display class.
	  vector<Person*> display_person_;

	  // A placeholder function. Default set to one. Return the
	  // goods requirement of a Person object from a probability
	  // distribution that can be filled in by the user.
	  virtual int Sampling() {
		  return 1;
	  }
};
