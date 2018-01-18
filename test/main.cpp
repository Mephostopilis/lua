#include <vector>
#include <iostream>

int main(int argv, char * argc[]) {
	std::vector<int> v = { 7, 5, 16, 8 };
	v.push_back(25);

	for (int n : v) {
		std::cout << n << '\n';
	}

	std::cout << v[0] << '\n';
	std::cout << v[1] << '\n';

	//v.insert(2, 3);


	system("pause");
	return 0;
}