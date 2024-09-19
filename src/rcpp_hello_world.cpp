
#include <Rcpp.h>
using namespace Rcpp;

extern "C" SEXP cs_model();

// [[Rcpp::export]]
List rcpp_hello_world() {

    CharacterVector x = CharacterVector::create( "foo", "bar" )  ;
    NumericVector y   = NumericVector::create( 0.0, 1.0 ) ;
    List z            = List::create( x, y ) ;

    return z ;
}

// [[Rcpp::export]]
void rcpp_cs_model() {
	cs_model();
}
