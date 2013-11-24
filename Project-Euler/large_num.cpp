#include <iostream>
#include <vector>
#include <stdlib.h>
#include <stdio.h>

using namespace std;

main() {
	vector<int>pattern;
	int max = 0;
	for (int i = 0; i < 1000; ++i) {
		char temp[1];
		cin >> temp[0];
		cout << temp << endl;
		pattern.push_back(atoi(temp));
	}
	cout << "reading over" << endl;
	for (int i = 0; i <= pattern.size() - 5; ++i) {
		int temp = pattern[i] * pattern[i + 1] * pattern[i + 2]
					* pattern[i + 3] * pattern[i + 4];
		if (temp > max) {
			max = temp;
		}
	}
	cout << max << endl;
}
