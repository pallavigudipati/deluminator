#include <iostream>
#include "binheap.cpp"
using namespace std;

main()
{
	binheap* a = new binheap;
	binheap* b = new binheap;
	
	char red[] = { 0x1b, '[', '1', ';', '3', '1', 'm', 0 };
	char blue[] = { 0x1b, '[', '1', ';', '3', '4', 'm', 0 };
	char normal[] = { 0x1b, '[', '0', ';', '3', '9', 'm', 0 };

	while( 1 )
	{
		cout << "Select operation :" << endl;
		cout << "1) Insert." << endl << "2) Delete maximum." << endl << "3) Increase key." << endl;
		cout << "4) Meld Heap A and Heap B." << endl << "5) Print." << endl << "6) Exit." << endl;
		cout << "---------------------------------------------------------------------------------------" << endl;	
		/*
		Printing
		eg:
		4
		4{ 2{ 1 } 3 } 
	
		- 4 is a node in the root list
		- children of 4 are 2 , 3
		- child of 2 is 1

		*/
		int option;
		cin >> option;
		
		if( option == 1 )
		{
			cout << "1) Heap A." << endl << "2) Heap B." << normal << endl;
			int sub_option;
			cin >> sub_option;
			if( sub_option == 1 )
			{
				int value;
				cout << "Enter value." << endl;
				cin >> value;
				a ->  insert( value );
			}
			
			else if( sub_option == 2 )
			{
				int value;
				cout << "Enter value." << endl;
				cin >> value;
				b ->  insert( value );
			}

			else
				cout << red << "ERROR : Invalid option." << normal << endl;
		}
		
		else if( option == 2 )
		{
			cout << "1) Heap A." << endl << "2) Heap B." << normal << endl;
			int sub_option;
			cin >> sub_option;
			if( sub_option == 1 )
			{
				if( a -> get_root() == NULL )
					cout << red << "ERROR : Heap A is empty." << normal << endl;
				else
				{	
					node* temp = a ->  delete_max();
					cout << "Maximum value :" << blue << temp -> get_data() << normal << endl;
				}	
			}
			
			else if( sub_option == 2 )
			{
				if( b -> get_root() == NULL )
					cout << red << "ERROR : Heap B is empty." << normal << endl;
				else
				{	
					node* temp = b ->  delete_max();
					cout << "Maximum value :" << blue << temp -> get_data() << normal << endl;
				}	
			}

			else
				cout << red << "ERROR : Invalid option." << endl;
		}

		else if( option == 3 )
		{
			cout << "1) Heap A." << endl << "2) Heap B." << normal << endl;
			int sub_option;
			cin >> sub_option;
			if( sub_option == 1 )
			{
				if( a -> get_root() == NULL )
					cout << red << "ERROR : Heap A is empty." << normal << endl;
				else
				{	
					int value, amount;
					cout << "Please enter the value and amount to be increased." << endl;
					cin >> value >> amount;
					a -> increase_key( value, amount );
				}	
			}
			
			else if( sub_option == 2 )
			{
				if( b -> get_root() == NULL )
					cout << red << "ERROR : Heap B is empty." << normal << endl;
				else
				{	
					int value, amount;
					cout << "Please enter the value and amount to be increased." << endl;
					cin >> value >> amount;
					b -> increase_key( value, amount );
				}	
			}

			else
				cout << red << "Invalid option." << normal << endl;
		}

		else if( option == 4 )
		{
			a -> meld( b );
		}	
		
		else if( option == 5 )
		{
			cout << "1) Heap A." << endl << "2) Heap B." << normal << endl;
			int sub_option;
			cin >> sub_option;
			if( sub_option == 1 )
			{
				if( a -> get_root() == NULL )
					cout << red << "ERROR : Heap A is empty." << normal << endl;
				else
				{
					a -> print();
				}	
			}
			
			else if( sub_option == 2 )
			{
				if( b -> get_root() == NULL )
					cout << red << "ERROR : Heap B is empty." << normal << endl;
				else
				{
					b -> print();	
				}	
			}

		}	
		else if( option == 6 )
			break;

		else
			cout << red << "ERROR : Invalid option." << normal << endl;
	}	
}	
