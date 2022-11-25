#include <R.h>
#include <Rmath.h>

void NW_estimate(double *x, double *y, int *n, double *b,double *g, int *m, double *est){
    
    int i,j;
    double a1,a2,c;

    for(i = 0; i < *m; i++){
    
        a1 = 0.0;
        a2 = 0.0;

        for(j=0; j < *n; j++){
        
            c = dnorm((x[j]-g[i])/ *b,0,1,0);
            a1 += y[j] * c;
            a2 += c;
        }

        est[i] = a1/a2;

    }


}