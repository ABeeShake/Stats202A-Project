#include <math.h>

void tetrachoric(int* n, int* x, int* y, int* res){

    int a,b,c,d;

    for (int i = 0; i < *n; i++)
    {
        
        if (x[i] == 1 && y[i] == 1)
        {
            a += 1;
        } else if (x[i] == 1 && y[i] == 0)
        {
            b += 1;
        } else if (x[1] == 0 && y[i] == 1)
        {
            c += 1;
        } else
        {
            d += 1;
        }
        
        *res = cos(180 / (1 + sqrt((b*c)/(a*d))));

    }
    

}