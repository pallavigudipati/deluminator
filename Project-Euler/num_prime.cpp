#include <iostream>
#include <math.h>
#include <vector>

using namespace std;


bool check_prime(long long int n) {
	long double iter = sqrt((long double)n);
	long long int i = (long long int)iter + 1;

	for (; i > 1; --i) {
		if (n % i == 0) {
			return false;
		}
	}
	return true;
}

main() {
	int iter = 0;
	for (long int i = 0; iter <= 10001; ++i) {
		if (check_prime(i)) {
			cout << i << endl;
			iter++;
		}	
	}
}
