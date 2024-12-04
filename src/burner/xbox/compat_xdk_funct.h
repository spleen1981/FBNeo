#include <xtl.h>
#include <xbox.h>

#define snprintf(...) _snprintf(__VA_ARGS__)

#define FP_NAN       0
#define FP_INFINITE  1
#define FP_NORMAL    2
#define FP_SUBNORMAL 3
#define FP_ZERO      4

#define VirtualAlloc(a,b,c,d) XMemAlloc(b, XALLOC_MEMPROTECT_READWRITE)
#define VirtualFree(a,b,c) XMemFree(a, XALLOC_MEMPROTECT_READWRITE)
#define SetThreadAffinityMask(a,b) XSetThreadProcessor(a, b)

int isinf(double x);
int fpclassify(double x);
long long int round(float a);
int isnan( double a);
double log2(double a);