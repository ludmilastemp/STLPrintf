#include <stdio.h>

extern "C" void STLPrintf (const char* fmt,
                           ...);

int main ()
{
    printf ("begin\n");

    printf    ("%d %s %x %d %%%c%b\n",
               -1, "love", 3802, 100, 33, 31);
    STLPrintf ("%d %s %x %d %%%c%b\n",
               -1, "love", 3802, 100, 33, 31);

    printf ("\nend");

    return 0;
}
