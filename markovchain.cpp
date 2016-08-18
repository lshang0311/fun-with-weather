#include <Rcpp.h>
using namespace Rcpp;

/**
 * A Markov Chain for sequence generation
 * 
 * Created by lshang on Aug 17, 2016
 */

// [[Rcpp::export]]
IntegerVector generate_sequence(NumericMatrix transitionMatrix, int n) {
   IntegerVector sequence(n);
   int N = transitionMatrix.ncol();
   int state = N - 1;
   for (int i = 0; i < n; i++) {
      sequence[i] = state;
      
      double r = R::runif(0,1); 
      double sum = 0.0;
      for (int j = 0; j < N; j++) {
         sum += transitionMatrix(state,j);
         if (r <= sum) {
            state = j;
            break;
         }
      }
   }
   
   return sequence;
}