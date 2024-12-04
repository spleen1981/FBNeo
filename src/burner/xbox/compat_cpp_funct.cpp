#include "compat_cpp_funct.h"
#include <math.h>
#include <cmath>
#include <cfloat>

#include <iostream>
long long int round(float a) {
	long long int result;
	if (a - floor(a) >= 0.5)
		result = floor(a) + 1;
	else
		result = floor(a);
	return result;
}

int isinf(double x) {
    return !_finite(x) && !isnan(x);
}

int isnan( double a) {
	return _isnan(a);
}

double log2(double a) {
	return log((double)a)*1.44269504088896340736;
}

int fpclassify(double x) {
    if (isnan(x)) {
        return FP_NAN;
    } else if (isinf(x)) {
        return FP_INFINITE;
    } else if (x == 0.0) {
        return FP_ZERO;
    } else if (std::fabs(x) < DBL_MIN) {
        return FP_SUBNORMAL;
    } else {
        return FP_NORMAL;
    }
}