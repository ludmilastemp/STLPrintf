#include <stdio.h>

extern "C" void STLPrintf (const char* fmt,
                           ...);

int main ()
{
    printf ("begin\n");

    //STLPrintf ("1234567890987654321234567890Hello ME-%s-%sOW%c%c%c0%s", "Ha-ha-ha",
    //           "12345678901234567890123456789012345678901234567890");

    int i = 0;
    //for (int i = 0; i < 45; i++)
    {
        printf    ("%d %s %x %d %%%c%b\n",
                   -1, "love", 3802, 100, 33, 31);
        STLPrintf ("%d %s %x %d %%%c%b\n",
                   -1, "love", 3802, 100, 33, 31);
    }

    STLPrintf ("%d %d %d %d%s", -5, 999, 888, -137456, "Aloha");

    printf ("\nend");

    return 0;
}










// __cdecl


    /**
extern "C" void my_printf(const char* fmt);

void my_printf(const char* fmt)
{
    printf("Your format string: %s\n", fmt);
}       */



           /**
void as();

typedef void (*func_t)();

int main()
{
    int number = 1...16;

    if ( number < 10 )
    {
        return number + '0';
    }
    else
    {
        return number - 10 + 'A';
    }

    char hex_digits[] = {'0', '1', '2', '3', ..., 'D', 'E', 'F'};
    return hex_digits[number];




    func_t handlers[] = {
        as,








        as,
        as,
        sd,





        asd,
        asd,
    };

    handler[option]();

    return 0;
}            */

