//========================================================================
// ubmark-quicksort
//========================================================================

#include "ubmark.h"
#include "ubmark-quicksort.dat"

//------------------------------------------------------------------------
// quicksort-scalar
//------------------------------------------------------------------------

__attribute__ ((noinline))
void quicksort_scalar( int* dest, int* src, int size )
{
  // implement quicksort algorithm here
  int i;

  // dummy copy src into dest
  for ( i = 0; i < size; i++ )
    dest[i] = src[i];
}

//------------------------------------------------------------------------
// verify_results
//------------------------------------------------------------------------

void verify_results( int dest[], int ref[], int size )
{
  int i;
  for ( i = 0; i < size; i++ ) {
    if ( !( dest[i] == ref[i] ) ) {
      test_fail( i, dest[i], ref[i] );
    }
  }
  test_pass();
}

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

int main( int argc, char* argv[] )
{

    int dest[size];

    int i;
    for ( i = 0; i < size; i++ )
      dest[i] = 0;

    test_stats_on();
    quicksort_scalar( dest, src, size );
    test_stats_off();

    verify_results( dest, ref, size );

    return 0;
}

