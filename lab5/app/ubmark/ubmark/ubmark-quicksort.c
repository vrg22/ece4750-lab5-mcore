//========================================================================
// ubmark-quicksort
//========================================================================

#include "ubmark.h"
#include "ubmark-quicksort.dat"

//------------------------------------------------------------------------
// quicksort-scalar
//------------------------------------------------------------------------

void qsort_in_place( int*src, int first, int last)
{
  static int p;
  static int i;
  static int j;
  static int temp;

  if(first < last)
  {
    p = first;
    i = first;
    j = last;

    while (i < j)
    {
      while(src[i] <= src[p] && i < last)
      {
        i++;
        printf("Incrementing i\n");
      }
      while(src[j] > src[p])
      {
        j--;
        printf("Decrementing j\n");
      }
      if(i<j)
      {
        temp = src[i];
        src[i] = src[j];
        src[j] = temp;
        printf("Swapping\n");
      }
      printf("I: %d, J: %d\n", i,j);
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
  int i;
  printf("Size is : %d\n",size);

  for(i = 0 ; i < size ; i++)
  {
    dest[i] = src[i];
  }

  qsort_in_place(dest,0,size-1);
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

