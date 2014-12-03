//========================================================================
// ubmark-quicksort
//========================================================================

#include "ubmark.h"
#include "ubmark-quicksort.dat"

//------------------------------------------------------------------------
// quicksort-scalar
//------------------------------------------------------------------------

// http://www.cquestions.com/2008/01/c-program-for-quick-sort.html
void qsort_in_place( int*src, int first, int last)
{
  // don't dynamically allocate
  static int p;
  static int i;
  static int j;
  static int temp;

  if(first < last)
  {
    // Choose last element as pivot. Most likely fresh in mem/cache
    p = last;
    i = first;
    j = last;

    while (i < j)
    {
      while(src[i] <= src[p] && i < last)
      {
        i++;
      }
      while(src[j] > src[p])
      {
        j--;
      }
      if(i<j)
      {
        temp = src[i];
        src[i] = src[j];
        src[j] = temp;
      }
    }

    temp = src[p];
    src[p] = src[j];
    src[j] = temp;
    qsort_in_place(src,first,j-1);
    qsort_in_place(src,(j+1),last);
  }
}

__attribute__ ((noinline))
void quicksort_scalar( int* dest, int* src, int size )
{
  // forced to dynamically allocate
  int p;
  int i;
  int j;

  int temp;
  int first = 0;
  int last = size-1;

  printf("Size is : %d\n",size);


  if(first < last)
  {
    // Choose last element as pivot. Most likely fresh in mem/cache
    p = last;
    i = first;
    j = last;

    while (i < j)
    {
      while(src[i] <= src[p] && i < last)
      {
        // Make dest match src
        dest[i] = src[i];

        i++;
      }
      while(src[j] > src[p])
      {
        // Make dest match src
        dest[j] = src[j];

        j--;
      }
      if(i<j)
      {
        temp = src[i];
        src[i] = src[j];
        src[j] = temp;

        // Make dest match src
        dest[i] = src[i];
        dest[j] = src[j];
      }
    }

    temp = src[p];
    src[p] = src[j];
    src[j] = temp;

    // Make dest match src
    dest[j] = src[j];
    dest[p] = src[p];

    qsort_in_place(dest,first,j-1);
    qsort_in_place(dest,(j+1),last);
  }
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

