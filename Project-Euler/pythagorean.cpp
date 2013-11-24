#include <iostream>
#include <vector>

using namespace std;

int main() {

	for (int i = 1; i < 1000; ++i) {
		for (int j = i + 1; j < 1000; ++j) {
		  	int k = 1000 - i - j;
	   	   	if ( k > j && k * k == i * i + j * j) {
				cout << i << " " << j << " " << k << endl;
				cout << i * j * k << endl;
		   		return 0;
		 	}
   		}
	}		
}
