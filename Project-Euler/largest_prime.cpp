#include <iostream>
#include <vector>
#include <math.h>
#include <algorithm>

using namespace std;

bool check_prime(long long int n);

main() {
	long double iter = sqrt(600851475143.0);
	//cout << iter;
	iter += 1;
	vector<long long int> factors;
	long long int i = (long long int)iter;
	
	for (; i >= 1; --i) {
		if (600851475143 % i == 0) {
			factors.push_back(i);
			factors.push_back(600851475143 / i);
		}
	}

	cout << "done with factorization" << endl;	
	std::sort(factors.begin(), factors.end());
	for (int j = factors.size() - 1; j >= 0; --j) {
		if (check_prime(factors[j])) {
			cout << factors[j] << endl;
			break;
		}
	}
	/*
	long long int i = 600851475143;
	long long int factor = 1;
	for (; i > 1; --i) {
		if (factor % i == 0) {
			factor = 1;
		}

		if(600851475143 % i == 0 && i > factor) {
			factor = i;
		}
	}
	cout << factor;
	*/
}

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
