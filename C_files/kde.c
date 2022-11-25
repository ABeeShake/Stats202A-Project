#include <math.h>

#define M_PI 3.14159265358979323846

void KDE(int* n, int* m, double* x, double* g, double* y, double* bw){

    /*
    n - length of observed value vector
    m - length of grid vector
    x - vector of observed values
    g - grid of points to estimate
    y - result vector
    */

   for (int i = 0; i < *m; i++)
   {

    double sum = 0.0;

    for (int j = 0; j < *n; j++)
    {
        sum += (1 / (*bw * sqrt(2*M_PI))) * exp(-(x[j] - g[i]) * (x[j] - g[i]) / (2 * *bw * *bw));
    }
    
    y[i] = sum / (*n * *bw);

   }

}