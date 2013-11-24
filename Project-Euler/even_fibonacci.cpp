#include <iostream>
#include <vector>

using namespace std;

main() {
	int num1 = 1;
	int num2 = 2;
	int sum = 0;

	for (; num2 <= 4000000;) {
		if (num2 % 2 == 0) {
		   sum += num2;
		}
 		int temp = num2;
		num2 = num1 + num2;
		num1 = temp;		
	}
	cout << sum << endl;
}
