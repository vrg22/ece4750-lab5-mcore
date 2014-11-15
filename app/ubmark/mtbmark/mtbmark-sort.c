//========================================================================
// mtbmark-sort
//========================================================================

#include "mtbmark.h"
#include "mtbmark-sort.dat"

__attribute__ ((noinline))
void sort_scalar( int* dest, int* src, int size )
{
  // implement sorting algorithm here
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
  // Number of cores

  int num_cores = get_num_cores();

  // Size of the part of the vector each core will compute

  int core_size = get_core_size( size );

  // Determine core ID

  int core_id = get_core_id();

  //--------------------------------------------------------------------
  // Start counting stats
  //--------------------------------------------------------------------

  test_stats_on();

  // Spawn threads and perform parallel computation

  spawn();

  // distribute work and call sort_scalar()

  // Join threads

  join();

  // do the final reduction step here

  //--------------------------------------------------------------------
  // Stop counting stats
  //--------------------------------------------------------------------

  test_stats_off();

  // Control thread verifies solution

  if ( core_id == 0 )
    verify_results( dest, ref, size );

  return 0;
}

