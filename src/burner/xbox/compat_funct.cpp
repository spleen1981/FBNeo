#include <math.h>
#include <iostream>
long long int round(float a) {
	long long int result;
	if (a - floor(a) >= 0.5)
		result = floor(a) + 1;
	else
		result = floor(a);
	return result;
}

int isnan( double a) {
	return _isnan(a);
}

double log2(double a) {
	return log((double)a)*1.44269504088896340736;
}