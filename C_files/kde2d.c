#include <R.h>
#include <Rmath.h>

#define M_PI 3.14159265358979323846

void kde2d(double* x, double* y, int* n, int* m, double* g_x, double* g_y, double* bw, double* res){

    /*
    x - x coords
    y - y coords
    n - length of x,y
    m - length of g_x, g_y
    g_x - x grid
    g_y - y grid
    bw - bandwidth
    res - density estimates
    */
    
    double z_x, z_y, c;


    for (int i = 0; i < *m; i++)
    {
        
        c = 0;

        for (int j = 0; j < *n; j++)
        {
            
            z_x = g_x[i] - x[j];
            z_y = g_y[i] - y[j];

            c += (1/(2*M_PI*(*bw)*(*bw))) * exp((-1/(2*(*bw)*(*bw))) * (z_x*z_x + z_y*z_y)); 

        }
        
        res[i] = c / *n;

    }
    

}