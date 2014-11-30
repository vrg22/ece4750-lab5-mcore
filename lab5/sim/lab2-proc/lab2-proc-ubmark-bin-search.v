//========================================================================
// ubmark-bin-search: binary search kernel
//========================================================================
//
// This code performs a binary search in a dictionary of key value pairs.
// The corresponding keys and values are accessed by using the same index
// to the respective array (e.g. for dict[v] = k, if v == dict_keys[5],
// then k == dict_values[5]). The dictionary is sorted by keys so that
// dict_keys[i + 1] >= dict_keys[i]. The dictionary size is dict_sz.
//
// The kernel performs searches for the keys in srch_keys in the
// dictionary, and if found, saves the corresponding value to the
// srch_values. There are srch_sz many total queries to the dictionary.
//
// void bin_search( int srch_keys[], int srch_values[], int srch_sz,
//                  int dict_keys[], int dict_values[], int dict_sz ) {
//
//   for ( int i = 0; i < srch_sz; i++ ) {
//     int key     = srch_keys[i];
//     int idx_min = 0;
//     int idx_mid = dict_sz / 2;
//     int idx_max = dict_sz - 1;
//
//     bool done = false;
//     srch_values[i] = -1;
//     do {
//       int midkey = dict_keys[idx_mid];
//
//       if ( key == midkey ) {
//         srch_values[i] = dict_values[idx_mid];
//         done = true;
//       }
//
//       if ( key > midkey )
//         idx_min = idx_mid + 1;
//       else if ( key < midkey )
//         idx_max = idx_mid - 1;
//
//       idx_mid = ( idx_min + idx_max ) / 2;
//
//     } while ( !done && (idx_min <= idx_max) );
//   }
// }

// pointers for the input and output arrays
localparam c_bin_search_s_keys_ptr    = 32'h2000;
localparam c_bin_search_s_values_ptr  = 32'h3000;
localparam c_bin_search_s_sz          = 20;
localparam c_bin_search_d_keys_ptr    = 32'h4000;
localparam c_bin_search_d_values_ptr  = 32'h5000;
localparam c_bin_search_d_sz          = 50;


task init_bin_search;
begin
  clear_mem;

  address( c_reset_vector );
  // load the arguments
  inst( "mfc0  r1, mngr2proc " ); init_src( c_bin_search_s_keys_ptr );
  inst( "mfc0  r2, mngr2proc " ); init_src( c_bin_search_s_values_ptr );
  inst( "mfc0  r3, mngr2proc " ); init_src( c_bin_search_s_sz );
  inst( "mfc0  r4, mngr2proc " ); init_src( c_bin_search_d_keys_ptr );
  inst( "mfc0  r5, mngr2proc " ); init_src( c_bin_search_d_values_ptr );
  inst( "mfc0  r6, mngr2proc " ); init_src( c_bin_search_d_sz );

  inst( "addiu r7, r0, 0     " ); // loop counter i is in r7

  // 0:
  inst( "sll   r25, r7, 2    " ); // multiply by 4 to get i in the
                                  // index form
  inst( "addu  r9, r1, r25   " ); // pointer to i in srch_keys
  inst( "lw    r9, 0(r9)     " ); // key = srch_keys[i]
  inst( "addiu r10, r0, 0    " ); // idx_min
  inst( "sra   r11, r6, 1    " ); // idx_mid = dict_sz/2
  inst( "addiu r12, r6, -1   " ); // idx_max = (dict_sz-1)
  inst( "addiu r13, r0, 0    " ); // done = false

  inst( "addiu r14, r0, -1   " ); // -1
  inst( "addu  r15, r2, r25  " ); // i pointer in srch_values
  inst( "sw    r14, 0(r15)   " ); // srch_values[i] = -1

  // 1:
  inst( "sll   r24, r11, 2   " ); // idx_mid in pointer form
  inst( "addu  r16, r4, r24  " ); // idx_mid pointer in dict_keys
  inst( "lw    r17, 0(r16)   " ); // midkey = dict_keys[idx_mid]

  inst( "bne   r9, r17, [+6] " ); // if ( key == midkey ) goto 2:
  // If block starts
  inst( "addu  r16, r5, r24  " ); // idx_mid pointer in dict_values
  inst( "lw    r18, 0(r16)   " ); // dict_values[idx_mid]

  //inst( "sll   r25, r7, 2    " ); // multiply by 4 to get i in the
                                  // index form
  inst( "addu  r15, r2, r25  " ); // i pointer in srch_values
  inst( "sw    r18, 0(r15)   " ); // srch_values[i] = dict_values[idx_mid]
  inst( "addiu r13, r0, 1    " ); // done = true
  // if block ends

  // 2:
  inst( "slt   r18, r17, r9  " ); // midkey < key
  inst( "beq   r18, r0, [+3] " ); // if ( midkey < key ) goto 3:
  // if block for midkey < key
  inst( "addiu r10, r11, 1   " ); // idx_min = idx_mid + 1
  inst( "j     [+4]          " ); // goto 4:
  // end of if block
  // else block
  // 3:
  inst( "slt   r18, r9, r17  " ); // midkey > key
  inst( "beq   r18, r0, [+2] " ); // if ( midkey > key ) goto 4:
  // if block for midkey > key
  inst( "addiu r12, r11, -1  " ); // idx_max = idx_mid - 1
  // end of if block
  // 4:
  inst( "addu  r20, r10, r12 " ); // idx_min + idx_max
  inst( "sra   r11, r20, 1   " ); // idx_mid = ( idx_min + idx_max ) / 2

  inst( "slt   r21, r12, r10 " ); // idx_max < idx_min
  inst( "or    r22, r21, r13 " ); // done || (idx_max < idx_min)
  inst( "beq   r22, r0, [-20]" ); // while
                                  // ( !(done || (idx_max < idx_min)) )
                                  // goto 1:
  inst( "addiu r7,  r7, 1    " ); // i++
  inst( "bne   r7, r3, [-32] " ); // if (i < srch_sz) goto 0:

  // after loop:, marks the end of program
  inst( "mtc0  r0, proc2mngr " ); init_sink( 32'h00000000 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // initialize data
  init_bin_search_data;

end
endtask

//------------------------------------------------------------------------
// initialize source and reference data for bin_search
//------------------------------------------------------------------------

task init_bin_search_data;
begin

  ubmark_name = "bin-search";
  ubmark_dest_size = c_bin_search_s_sz;

  address( c_bin_search_d_keys_ptr );

  data( 275   ); // value: 798595
  data( 878   ); // value: 595
  data( 1657  ); // value: 542393
  data( 1664  ); // value: 325578
  data( 3228  ); // value: 491343
  data( 3818  ); // value: 165764
  data( 4202  ); // value: 739097
  data( 4253  ); // value: 171178
  data( 5181  ); // value: 782769
  data( 6341  ); // value: 436425
  data( 7698  ); // value: 671149
  data( 11143 ); // value: 589635
  data( 11316 ); // value: 193967
  data( 14950 ); // value: 829238
  data( 16074 ); // value: 170346
  data( 17944 ); // value: 914024
  data( 18251 ); // value: 698162
  data( 18916 ); // value: 982032
  data( 19092 ); // value: 741715
  data( 22083 ); // value: 817101
  data( 22405 ); // value: 518773
  data( 26000 ); // value: 259119
  data( 26339 ); // value: 167312
  data( 29355 ); // value: 856192
  data( 30040 ); // value: 23860
  data( 31255 ); // value: 739931
  data( 31403 ); // value: 572441
  data( 31638 ); // value: 523771
  data( 31656 ); // value: 731363
  data( 31838 ); // value: 413579
  data( 32269 ); // value: 574345
  data( 32338 ); // value: 869877
  data( 33053 ); // value: 802405
  data( 34243 ); // value: 444519
  data( 34572 ); // value: 830965
  data( 34970 ); // value: 210033
  data( 35059 ); // value: 320642
  data( 36367 ); // value: 756770
  data( 37682 ); // value: 602310
  data( 38659 ); // value: 602370
  data( 39663 ); // value: 256383
  data( 41420 ); // value: 45340
  data( 43407 ); // value: 408225
  data( 47464 ); // value: 262452
  data( 48264 ); // value: 762720
  data( 50083 ); // value: 940979
  data( 50481 ); // value: 405786
  data( 53694 ); // value: 496582
  data( 53726 ); // value: 655206
  data( 55278 ); // value: 220685

  address( c_bin_search_d_values_ptr );

  data( 798595 );
  data( 595    );
  data( 542393 );
  data( 325578 );
  data( 491343 );
  data( 165764 );
  data( 739097 );
  data( 171178 );
  data( 782769 );
  data( 436425 );
  data( 671149 );
  data( 589635 );
  data( 193967 );
  data( 829238 );
  data( 170346 );
  data( 914024 );
  data( 698162 );
  data( 982032 );
  data( 741715 );
  data( 817101 );
  data( 518773 );
  data( 259119 );
  data( 167312 );
  data( 856192 );
  data( 23860  );
  data( 739931 );
  data( 572441 );
  data( 523771 );
  data( 731363 );
  data( 413579 );
  data( 574345 );
  data( 869877 );
  data( 802405 );
  data( 444519 );
  data( 830965 );
  data( 210033 );
  data( 320642 );
  data( 756770 );
  data( 602310 );
  data( 602370 );
  data( 256383 );
  data( 45340  );
  data( 408225 );
  data( 262452 );
  data( 762720 );
  data( 940979 );
  data( 405786 );
  data( 496582 );
  data( 655206 );
  data( 220685 );

  address( c_bin_search_s_keys_ptr );

  data( 33053 ); // value: 802405
  data( 47464 ); // value: 262452
  data( 48264 ); // value: 762720
  data( 32338 ); // value: 869877
  data( 34243 ); // value: 444519
  data( 3818  ); // value: 165764
  data( 4202  ); // value: 739097
  data( 22405 ); // value: 518773
  data( 36367 ); // value: 756770
  data( 3228  ); // value: 491343
  data( 275   ); // value: 798595
  data( 39663 ); // value: 256383
  data( 5181  ); // value: 782769
  data( 26000 ); // value: 259119
  data( 1657  ); // value: 542393
  data( 31255 ); // value: 739931
  data( 50481 ); // value: 405786
  data( 4253  ); // value: 171178
  data( 35059 ); // value: 320642
  data( 6341  ); // value: 436425
  data( 7698  ); // value: 671149
  data( 32269 ); // value: 574345
  data( 11143 ); // value: 589635
  data( 26339 ); // value: 167312
  data( 16074 ); // value: 170346
  data( 18251 ); // value: 698162
  data( 50083 ); // value: 940979
  data( 53694 ); // value: 496582
  data( 18916 ); // value: 982032
  data( 38659 ); // value: 602370
  data( 11316 ); // value: 193967
  data( 41420 ); // value: 45340
  data( 14950 ); // value: 829238
  data( 53726 ); // value: 655206
  data( 55278 ); // value: 220685
  data( 17944 ); // value: 914024
  data( 34970 ); // value: 210033
  data( 30040 ); // value: 23860
  data( 31838 ); // value: 413579
  data( 31638 ); // value: 523771
  data( 19092 ); // value: 741715
  data( 31656 ); // value: 731363
  data( 34572 ); // value: 830965
  data( 1664  ); // value: 325578
  data( 37682 ); // value: 602310
  data( 22083 ); // value: 817101
  data( 43407 ); // value: 408225
  data( 878   ); // value: 595
  data( 29355 ); // value: 856192
  data( 31403 ); // value: 572441

  ref_address( c_bin_search_s_values_ptr );

  ref_data( 802405 );
  ref_data( 262452 );
  ref_data( 762720 );
  ref_data( 869877 );
  ref_data( 444519 );
  ref_data( 165764 );
  ref_data( 739097 );
  ref_data( 518773 );
  ref_data( 756770 );
  ref_data( 491343 );
  ref_data( 798595 );
  ref_data( 256383 );
  ref_data( 782769 );
  ref_data( 259119 );
  ref_data( 542393 );
  ref_data( 739931 );
  ref_data( 405786 );
  ref_data( 171178 );
  ref_data( 320642 );
  ref_data( 436425 );
  ref_data( 671149 );
  ref_data( 574345 );
  ref_data( 589635 );
  ref_data( 167312 );
  ref_data( 170346 );
  ref_data( 698162 );
  ref_data( 940979 );
  ref_data( 496582 );
  ref_data( 982032 );
  ref_data( 602370 );
  ref_data( 193967 );
  ref_data( 45340  );
  ref_data( 829238 );
  ref_data( 655206 );
  ref_data( 220685 );
  ref_data( 914024 );
  ref_data( 210033 );
  ref_data( 23860  );
  ref_data( 413579 );
  ref_data( 523771 );
  ref_data( 741715 );
  ref_data( 731363 );
  ref_data( 830965 );
  ref_data( 325578 );
  ref_data( 602310 );
  ref_data( 817101 );
  ref_data( 408225 );
  ref_data( 595    );
  ref_data( 856192 );
  ref_data( 572441 );

end
endtask
