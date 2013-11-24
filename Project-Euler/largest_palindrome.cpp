#include <iostream>
#include <sstream>
#include <vector>
#include <string>

using namespace std;

bool check_pal(int n) {
	stringstream ss;
	ss << n;
	string str = ss.str();
	string rev;
	for (int i = str.size() - 1; i >= 0; --i) {
	   rev.push_back(str[i]);
	}
	if (str == rev) {
		return true;
	} else {
		return false;
	}	
}

main() {
	int pal = 0;
	
	for (int i = 100; i <= 999; ++i) {
	   for (int j = i; j <= 999; ++j) {
			if (check_pal(i * j)) {
				if (i * j > pal) {
					pal = i * j;
				}
			}		
	   }
	}
	cout << pal << endl;
}
