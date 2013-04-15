#include <iostream>
using namespace std;
#include "binheap.h"

binheap :: binheap()
{
	root = NULL;
	num =0;
}	

void binheap :: set_root( node* a ) 
{
	root = a;
}	

node* binheap :: get_root()
{
	return root;
}

void binheap :: set_num( int value )
{
	num = value;
}	

int binheap :: get_num()
{
	return num;
}	

void binheap :: insert( int value )
{
	binheap* a = new binheap;
	node* to_insert = new node( value );
	a -> set_root( to_insert );
	a -> set_num( 1 );

	this -> meld( a );
	//this -> set_num( this -> get_num() + 1 );
}

node* binheap :: delete_max()
{
	node* max = this -> find_max();
	node* max_prev = this -> find_max_prev();
	
	if( max_prev == NULL )
	{
		this -> set_root( max -> get_sibling() );
		max -> set_sibling( NULL );
	}	

	else
	{
		max_prev -> set_sibling( max -> get_sibling() );
		max -> set_sibling( NULL );
	}	

	binheap* a = new binheap;
	a -> set_root( max -> get_lmc() );

	if( max -> get_lmc() == NULL )
	{
		//this -> set_num( get_num() - 1 );
		return max;
	}

	else
	{	
		max -> get_lmc() -> set_parent( NULL );
		
		node* temp1 = a -> get_root();
	  	node* temp2 = NULL;
	//	node* temp3 = NULL;
		while( temp1 != NULL )
		{	
			temp1 -> set_parent( NULL );
			
			if( temp2 == NULL )
			{
				temp2 = temp1;
				temp1 = temp1 -> get_sibling();
			}	

			else
			{	
				node* temp3 = temp1 -> get_sibling();
				//temp2 = temp1 -> get_sibling();
				//temp3 = temp2 -> get_sibling();
				temp1 -> set_sibling( temp2 );
				temp2 = temp1;
				temp1 = temp3;
				//temp3 = temp3 -> get_sibling();					
			}
		}	
		
		a -> get_root() -> set_sibling( NULL );
		a -> set_root( temp2 );

		this -> meld( a );
		this -> set_num( this -> get_num() - 1 );	
		return max;
	}	
}	

node* binheap :: search( int value )
{
	if( this -> get_root() -> get_data() == value )
		return this -> get_root();

	else
	{
		node* temp = this -> get_root() -> get_lmc();
		while( temp != NULL )
		{
			binheap* tempheap = new binheap;
			tempheap -> set_root( temp );
			node* ans = tempheap -> search( value );
			if( ans != NULL )
				return ans;
			temp = temp -> get_sibling();
		}	

		return NULL;
	}	
}

void binheap :: meld( binheap* a )
{
	this -> merge( a );

	node* temp = this -> get_root();
	node* temp_prev = NULL;
	
	while( temp != NULL && temp -> get_sibling() != NULL )
	{
		if( temp -> get_degree() == temp -> get_sibling() -> get_degree() )
		{
			if( temp -> get_sibling() -> get_sibling() == NULL || 
				temp -> get_degree() != temp -> get_sibling() -> get_sibling() -> get_degree() )
			{
				if( temp -> get_data() <= temp -> get_sibling() -> get_data() )
				{	
					if( temp_prev == NULL )
					{
						this -> set_root( temp -> get_sibling() );
					}
					
					else
					{	
						temp_prev -> set_sibling( temp -> get_sibling() );
					}

					temp -> set_parent( temp -> get_sibling() );
					temp -> set_sibling( temp -> get_parent() -> get_lmc() );
					temp -> get_parent() -> set_lmc( temp );
					temp -> get_parent() -> set_degree( temp -> get_parent() -> get_degree() + 1 );
					temp = temp -> get_parent();
				}
				
				else
				{
					node* temp2 = temp -> get_sibling();
					temp -> set_sibling( temp2 -> get_sibling() );
					temp2 -> set_parent( temp );
					temp2 -> set_sibling( temp -> get_lmc() );
					temp -> set_lmc( temp2 );
					temp -> set_degree( temp -> get_degree() + 1 );
				}			
			}

			else
			{
				temp_prev = temp;
				temp = temp -> get_sibling();
			}
		}
		
		else
		{
			temp_prev = temp;
			temp = temp -> get_sibling();
		}	
	}
}	

void binheap :: increase_key( int value, int amount )
{
	binheap* super = new binheap;
	node* supernode = new node;
	super -> set_root( supernode );
	supernode -> set_lmc( this -> get_root() );

	char red[] = { 0x1b, '[', '1', ';', '3', '1', 'm', 0 };
	char blue[] = { 0x1b, '[', '1', ';', '3', '4', 'm', 0 };
	char normal[] = { 0x1b, '[', '0', ';', '3', '9', 'm', 0 };
	
	node* key = super -> search( value );
//	if( value + amount < 0 )
//	{
//		
//		cout << red << "ERROR : New key less than zero." << normal << endl;
//		return;
//	}	
	if( key == NULL )
	{
		cout << red << "ERROR : Value not found." << normal << endl;
		return;
	}	

	else
	{
		node* temp = key;

		if( amount < 0 )
		{
			cout << red << "ERROR : New key is less than existing key." << normal << endl;
			return;	
		}	
			
		else
		{
			key -> set_data( key -> get_data() + amount );
			while( temp -> get_parent() != NULL )
			{
				if( temp -> get_parent() -> get_data() >= temp -> get_data() )
					return;
				else
				{
					int temp2 = temp -> get_data();
					temp -> set_data( temp -> get_parent() -> get_data() );
					temp -> get_parent() -> set_data( temp2 );
					temp = temp -> get_parent();
				}	
			}	
		}	
	}	

}	

node* binheap :: find_max()
{
	node* temp = this -> get_root();
	node* max = temp;

	while( temp != NULL )
	{
		if( temp -> get_data() > max -> get_data() )
			max = temp;
		temp = temp -> get_sibling();
	}	
	
	return max;
}

node* binheap :: find_max_prev()
{
	node* temp = this -> get_root();
	node* max = temp;
	node* max_prev = NULL;
	node* temp_prev = NULL;

	while( temp != NULL )
	{
		if( temp -> get_data() > max -> get_data() )
		{	
			max = temp;
			max_prev = temp_prev;
		}	
		temp_prev = temp;
		temp = temp -> get_sibling();
	}	
	
	return max_prev;
}

void binheap :: merge( binheap* a )
{
	
	if( a -> get_root() == NULL)
		return;
	
	else if( this -> get_root() == NULL )
	{
		this -> set_root( a -> get_root() );
		this -> set_num( a -> get_num() );
		return;
	}

	else if( a -> get_root() -> get_degree() < this -> get_root() -> get_degree() )
	{
		node* temp;
		int tempnum;

		temp = this -> get_root();
		tempnum = this -> get_num();
		
		this -> set_root( a -> get_root() );
		this -> set_num( a -> get_num() );
		
		a -> set_root( temp );
		a -> set_num( tempnum );
	}
	
	node* temp_a = this -> get_root();
	node* temp_b = a -> get_root();

	while( temp_a -> get_sibling() != NULL && temp_b != NULL )
	{
		if( temp_a -> get_sibling() -> get_degree() <= temp_b -> get_degree() )
			temp_a = temp_a -> get_sibling();

		else
		{
			node* temp = temp_b;
			temp_b = temp_b -> get_sibling();
			temp -> set_sibling( temp_a -> get_sibling() );
			temp_a -> set_sibling( temp );
			temp_a = temp_a -> get_sibling();
		}
	}

	if(temp_b != NULL)
	{
		temp_a -> set_sibling( temp_b );
	}
	
	this -> set_num( this -> get_num() + a -> get_num() );
	a -> set_root(NULL);	
}

void binheap :: print()
{
	node* temp = this -> get_root();

	char red[] = { 0x1b, '[', '1', ';', '3', '1', 'm', 0 };
	char blue[] = { 0x1b, '[', '1', ';', '3', '4', 'm', 0 };
	char normal[] = { 0x1b, '[', '0', ';', '3', '9', 'm', 0 };

	cout << endl;
	while( temp != NULL )
	{
		cout << blue << temp -> get_data() << normal << endl;
		this -> rec_print( temp );
		temp = temp -> get_sibling();
		cout << endl << endl;
	}
}	

void binheap :: rec_print( node* a )
{
	if( a == NULL )
		return;
	else if( a -> get_lmc() == NULL )
	{
		cout <<  a -> get_data() << " ";
		return;
	}	

	else
	{
		cout << a -> get_data() << "{ ";
		node* temp = a -> get_lmc();

		while( temp != NULL )
		{
			this -> rec_print( temp );
			temp = temp -> get_sibling();
		}	

		cout << "} ";
	}	
}	
