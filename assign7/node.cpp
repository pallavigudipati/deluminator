#include <iostream>
using namespace std;
#include "node.h"

node :: node()
{
	parent = NULL;
	lmc = NULL;
	sibling = NULL;
	data = -1;
	degree = 0;
}	

node :: node( int value )
{
	parent = NULL;
	lmc = NULL;
	sibling = NULL;
	data = value;
	degree = 0;
}

void node :: set_degree( int value )
{
	degree = value;
}	

int node :: get_degree()
{
	return degree;
}	

void node :: set_data( int value )
{
	data = value;
}	

int node :: get_data()
{
	return data;
}	

void node :: set_parent( node* a )
{
	parent = a;
}	

node* node :: get_parent()
{
	return parent;
}	

void node :: set_lmc( node* a )
{
	lmc = a;
}	

node* node :: get_lmc()
{
	return lmc;
}	

void node :: set_sibling( node* a )
{
	sibling = a;
}	

node* node :: get_sibling()
{
	return sibling;
}	


