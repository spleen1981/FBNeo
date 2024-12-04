#define snprintf(...) _snprintf(__VA_ARGS__)

#define FP_NAN       0
#define FP_INFINITE  1
#define FP_NORMAL    2
#define FP_SUBNORMAL 3
#define FP_ZERO      4

int isinf(double x);
int fpclassify(double x);
long long int round(float a);
int isnan( double a);
double log2(double a);