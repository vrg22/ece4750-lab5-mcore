//========================================================================
// mtbmark-sort
//========================================================================

#include "mtbmark.h"
#include "mtbmark-sort.dat"

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
void sort_scalar( int* src, int size )
{
  printf("Sort size is %d\n",size);
  qsort_in_place(src,0,size-1);
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

  printf("Number of cores is %d\n",num_cores);

  // Size of the part of the vector each core will compute

  int core_size = get_core_size( size );

  // Determine core ID

  int core_id = get_core_id();

  int i;

  for(i = 0; i < size ; i++)
  {
    dest[i] = 0;
  }
  int max_int = 0x8FFFFFFF;

  int* offset_zero   = src;
  int* offset_one    = src + core_size;
  int* offset_two    = src + 2*core_size;
  int* offset_three  = src + 3*core_size;

  int count_zero  = 0;
  int count_one   = 0;
  int count_two   = 0;
  int count_three = 0;

  //--------------------------------------------------------------------
  // Start counting stats
  //--------------------------------------------------------------------

  test_stats_on();

  // Spawn threads and perform parallel computation

  spawn();
#ifdef _MIPS_ARCH_MAVEN
  sort_scalar(src+core_id*core_size, core_size);
#else
  sort_scalar(src, core_size);
  sort_scalar(src+core_size, core_size);
  sort_scalar(src+core_size+core_size, core_size);
  sort_scalar(src+core_size+core_size+core_size, core_size);
#endif
  join();

  for( i = 0; i < core_size; i++)
  {
    printf("0: %d, 1: %d, 2: %d, 3: %d\n",*(offset_zero+i),*(offset_one+i),*(offset_two+i),*(offset_three+i));
  }

  if( core_id == 0 )
  {
    for( i = 0 ; i < size ; i++ )
    {
      if( (*offset_zero <= *offset_one   || count_one  == core_size) && 
          (*offset_zero <= *offset_two   || count_two   == core_size) &&
          (*offset_zero <= *offset_three || count_three == core_size) &&
          count_zero < core_size)
      {
        dest[i] = *offset_zero;
        printf("Inserted %d from 0\n",dest[i]);
        offset_zero++;
        count_zero++;
        printf("Count 0 is %d\n",count_zero);
        printf("Now 0: %d, 1: %d, 2: %d, 3: %d\n\n",*(offset_zero),*(offset_one),*(offset_two),*(offset_three));
      }
      else if( (*offset_one <= *offset_zero  || count_zero  == core_size) && 
               (*offset_one <= *offset_two   || count_two   == core_size) &&
               (*offset_one <= *offset_three || count_three == core_size) &&
               count_one < core_size )
      {
        dest[i] = *offset_one;
        printf("Inserted %d from 1\n",dest[i]);
        offset_one++;
        count_one++;
        printf("Count 1 is %d\n",count_one);
        printf("Now 0: %d, 1: %d, 2: %d, 3: %d\n\n",*(offset_zero),*(offset_one),*(offset_two),*(offset_three));
      }
      else if( (*offset_two <= *offset_zero  || count_zero  == core_size) && 
               (*offset_two <= *offset_one   || count_one   == core_size) &&
               (*offset_two <= *offset_three || count_three == core_size) &&
               count_two < core_size )
      {
        dest[i] = *offset_two;
        printf("Inserted %d from 2\n",dest[i]);
        offset_two++;
        count_two++;
        printf("Count 2 is %d\n",count_two);
        printf("Now 0: %d, 1: %d, 2: %d, 3: %d\n\n",*(offset_zero),*(offset_one),*(offset_two),*(offset_three));
      }
      else
      {
        dest[i] = *offset_three;
        printf("Inserted %d from 3\n",dest[i]);
        offset_three++;
        count_three++;
        printf("Count 3 is %d\n",count_three);
        printf("Now 0: %d, 1: %d, 2: %d, 3: %d\n\n",*(offset_zero),*(offset_one),*(offset_two),*(offset_three));
      }
    }

  }

  //--------------------------------------------------------------------
  // Stop counting stats
  //--------------------------------------------------------------------

  test_stats_off();

  // Control thread verifies solution

  if ( core_id == 0 )
    verify_results( dest, ref, size );

  return 0;
}

