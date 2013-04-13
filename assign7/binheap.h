#include <iostream>
using namespace std;
#include "node.cpp"

class binheap
{
	private:	
		node* root;
		int num; 

	public:
		binheap();
		void set_root( node* a );
		node* get_root();
		void set_num( int value );
		int get_num();

		void meld( binheap* a );
		void insert( int value );
		node* delete_max();
		node* search( int value );
		void increase_key( int value, int amount );

		node* find_max();
		node* find_max_prev();
		void merge( binheap* a );
};
