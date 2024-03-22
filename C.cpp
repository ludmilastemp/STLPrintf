#include <stdio.h>

extern "C" void STLPrintf (const char* fmt,
                           ...) __attribute__((format(printf, 1, 2)));

int main ()
{
    printf ("begin\n");

    STLPrintf ("%p%t%w%d", 1, 2, 3, 4);

    STLPrintf ("%dd = %bb = %oo = %xx \n%c%s",
                25, 25, 25, 25,
                'W', "ay to life");

    printf ("\nend");

    return 0;
}
