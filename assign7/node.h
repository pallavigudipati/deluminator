#include <iostream>
using namespace std;

class node
{
	private:
		node* parent;
		node* lmc;
		node* sibling;
		int data;
		int degree;

	public:
		node();
		node( int value );
		void set_degree( int value );
		int get_degree();
		void set_data( int value );
		int get_data();
		void set_parent( node* a );
		node* get_parent();
		void set_lmc( node* a );
		node* get_lmc();	
		void set_sibling( node* a );
		node* get_sibling();
}; 
