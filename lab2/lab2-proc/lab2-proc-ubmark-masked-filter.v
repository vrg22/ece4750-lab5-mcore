//========================================================================
// ubmark-masked-filter: masked filter kernel
//========================================================================
//
// This code implements a median filter for a 2D array (e.g. an image).
// Filtering is selectively enabled for some of the pixels using a mask.
//
//
// void masked_filter( int dest[], int mask[], int src[],
//                     int nrows, int ncols )
// {
//   int coeff0 = 64;
//   int coeff1 = 48;
//   int norm_shamt = 8;
//   for ( int ridx = 1; ridx < nrows-1; ridx++ ) {
//     for ( int cidx = 1; cidx < ncols-1; cidx++ ) {
//       if ( mask[ ridx*ncols + cidx ] != 0 ) {
//         int out = ( src[ (ridx-1)*ncols + cidx     ] * coeff1 )
//                 + ( src[ ridx*ncols     + (cidx-1) ] * coeff1 )
//                 + ( src[ ridx*ncols     + cidx     ] * coeff0 )
//                 + ( src[ ridx*ncols     + (cidx+1) ] * coeff1 )
//                 + ( src[ (ridx+1)*ncols + cidx     ] * coeff1 );
//         dest[ ridx*ncols + cidx ] = out >> norm_shamt;
//       }
//       else
//         dest[ ridx*ncols + cidx ] = src[ ridx*ncols + cidx ];
//     }
//   }
// }


// pointers for the input and output arrays
localparam c_masked_filter_dest_ptr = 32'h2000;
localparam c_masked_filter_mask_ptr = 32'h3000;
localparam c_masked_filter_src_ptr  = 32'h4000;
localparam c_masked_filter_nrows    = 10;
localparam c_masked_filter_ncols    = 10;


task init_masked_filter;
begin
  clear_mem;

  address( c_reset_vector );
  // load the arguments
  inst( "mfc0  r4, mngr2proc " ); init_src( c_masked_filter_dest_ptr );
  inst( "mfc0  r5, mngr2proc " ); init_src( c_masked_filter_mask_ptr );
  inst( "mfc0  r6, mngr2proc " ); init_src( c_masked_filter_src_ptr );
  inst( "mfc0  r7, mngr2proc " ); init_src( c_masked_filter_nrows );
  inst( "mfc0  r8, mngr2proc " ); init_src( c_masked_filter_ncols );

  inst( "addiu r24, r0, 64   " ); // coeff0
  inst( "addiu r25, r0, 48   " ); // coeff1

  // Assume that nrows and ncols are positive and otherwise well-behaved
  inst( "addiu r2, r7, -1    " ); // end condition nrows
  inst( "addiu r3, r8, -1    " ); // end condition ncols

  inst( "addiu r9, r0, 1     " ); // ridx starts at 1
  // 0: row loop
  inst( "addiu r10, r0, 1    " ); // cidx starts at 1
  // 1: col loop

  // Calculate mask index
  inst( "mul   r11, r8, r9   " ); // ridx*ncols
  inst( "addu  r11, r11, r10 " ); // ridx*ncols + cidx
  inst( "sll   r11, r11, 2   " ); // ridx*ncols + cidx (pointer)
  inst( "addu  r12, r5, r11  " ); // ridx*ncols + cidx (pointer) for mask
  inst( "lw    r12, 0(r12)   " ); // mask[ridx*ncols + cidx]

  // If
  inst( "beq   r12, r0, [+31]" ); // if ( !mask[ridx*ncols + cidx] ) goto 2:

  // If block
  inst( "addu  r12, r6, r11  " ); // ridx*ncols + cidx (pointer) for src
  inst( "lw    r13, 0(r12)   " ); // src[ridx*ncols + cidx]
  inst( "mul   r13, r13, r24 " ); // src[ridx*ncols + cidx] * coeff0
  inst( "addu  r23, r13, r0  " ); // out = src[ridx*ncols + cidx] * coeff0

  inst( "lw    r13, 4(r12)   " ); // src[ridx*ncols + (cidx+1)]
  inst( "mul   r13, r13, r25 " ); // src[ridx*ncols + (cidx+1)] * coeff1
  inst( "addu  r23, r23, r13 " ); // out += src[ridx*ncols + (cidx+1)] * coeff1

  inst( "lw    r13, -4(r12)  " ); // src[ridx*ncols + (cidx-1)]
  inst( "mul   r13, r13, r25 " ); // src[ridx*ncols + (cidx-1)] * coeff1
  inst( "addu  r23, r23, r13 " ); // out += src[ridx*ncols + (cidx-1)] * coeff1

  inst( "addiu r22, r9, 1    " ); // ridx+1
  inst( "mul   r12, r8, r22  " ); // (ridx+1)*ncols
  inst( "addu  r12, r12, r10 " ); // (ridx+1)*ncols + cidx
  inst( "sll   r12, r12, 2   " ); // (ridx+1)*ncols + cidx (pointer)
  inst( "addu  r13, r6, r12  " ); // (ridx+1)*ncols + cidx (pointer) for src
  inst( "lw    r13, 0(r13)   " ); // src[(ridx+1)*ncols + cidx]
  inst( "mul   r14, r13, r25 " ); // src[(ridx+1)*ncols + cidx] * coeff1
  inst( "addu  r23, r23, r14 " ); // out += src[(ridx+1)*ncols + cidx] *
                                  //                            coeff1

  inst( "addiu r22, r9, -1   " ); // ridx-1
  inst( "mul   r12, r8, r22  " ); // (ridx-1)*ncols
  inst( "addu  r12, r12, r10 " ); // (ridx-1)*ncols + cidx
  inst( "sll   r12, r12, 2   " ); // (ridx-1)*ncols + cidx (pointer)
  inst( "addu  r13, r6, r12  " ); // (ridx-1)*ncols + cidx (pointer) for src
  inst( "lw    r13, 0(r13)   " ); // src[(ridx-1)*ncols + cidx]
  inst( "mul   r14, r13, r25 " ); // src[(ridx-1)*ncols + cidx] * coeff1
  inst( "addu  r23, r23, r14 " ); // out += src[(ridx-1)*ncols + cidx] *
                                  //                            coeff1

  inst( "addu  r12, r4, r11  " ); // ridx*ncols + cidx (pointer) for dest
  inst( "sra   r23, r23, 8   " ); // out >>= shamt
  inst( "sw    r23, 0(r12)   " ); // dest[ridx*ncols + cidx] = out
  inst( "j     [+5]          " ); // End of if block, goto 3:

  // Else block
  // 2:
  inst( "addu  r12, r6, r11  " ); // ridx*ncols + cidx (pointer) for src
  inst( "lw    r13, 0(r12)   " ); // src[ridx*ncols + cidx]
  inst( "addu  r14, r4, r11  " ); // ridx*ncols + cidx (pointer) for dest
  inst( "sw    r13, 0(r14)   " ); // dest[ridx*ncols + cidx] =
                                  //                  src[ridx*ncols + cidx]

  // 3:
  inst( "addiu r10, r10, 1   " ); // cidx++
  inst( "bne   r10, r3, [-41]" ); // if ( cidx != ncols - 1 ) goto 1:
  inst( "addiu r9, r9, 1     " ); // ridx++
  inst( "bne   r9, r2, [-44] " ); // if ( ridx != nrows - 1 ) goto 0:

  // after loop, marks the end of program
  inst( "mtc0  r0, proc2mngr " ); init_sink( 32'h00000000 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // initialize data
  init_masked_filter_data;

end
endtask

//------------------------------------------------------------------------
// initialize source and reference data for masked_filter
//------------------------------------------------------------------------

task init_masked_filter_data;
begin

  ubmark_name = "masked-filter";
  ubmark_dest_size = c_masked_filter_nrows * c_masked_filter_ncols;

  address( c_masked_filter_src_ptr );

  data( 119 );
  data( 119 );
  data( 182 );
  data( 136 );
  data( 136 );
  data( 95 );
  data( 196 );
  data( 186 );
  data( 34 );
  data( 34 );
  data( 190 );
  data( 190 );
  data( 182 );
  data( 83 );
  data( 1 );
  data( 122 );
  data( 122 );
  data( 40 );
  data( 43 );
  data( 43 );
  data( 190 );
  data( 190 );
  data( 134 );
  data( 83 );
  data( 83 );
  data( 122 );
  data( 122 );
  data( 40 );
  data( 43 );
  data( 43 );
  data( 255 );
  data( 255 );
  data( 14 );
  data( 73 );
  data( 73 );
  data( 65 );
  data( 65 );
  data( 200 );
  data( 200 );
  data( 165 );
  data( 106 );
  data( 255 );
  data( 121 );
  data( 92 );
  data( 92 );
  data( 248 );
  data( 248 );
  data( 200 );
  data( 200 );
  data( 216 );
  data( 203 );
  data( 203 );
  data( 121 );
  data( 92 );
  data( 92 );
  data( 248 );
  data( 196 );
  data( 196 );
  data( 91 );
  data( 91 );
  data( 203 );
  data( 203 );
  data( 215 );
  data( 221 );
  data( 221 );
  data( 251 );
  data( 196 );
  data( 196 );
  data( 91 );
  data( 91 );
  data( 251 );
  data( 218 );
  data( 215 );
  data( 221 );
  data( 221 );
  data( 0 );
  data( 135 );
  data( 135 );
  data( 13 );
  data( 13 );
  data( 251 );
  data( 218 );
  data( 19 );
  data( 19 );
  data( 250 );
  data( 0 );
  data( 0 );
  data( 189 );
  data( 187 );
  data( 28 );
  data( 3 );
  data( 23 );
  data( 19 );
  data( 19 );
  data( 163 );
  data( 16 );
  data( 16 );
  data( 121 );
  data( 206 );
  data( 206 );

  address( c_masked_filter_mask_ptr );

  data( 0 );
  data( 255 );
  data( 255 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 255 );
  data( 255 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 0 );
  data( 0 );
  data( 255 );
  data( 255 );
  data( 0 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 0 );
  data( 0 );
  data( 255 );
  data( 255 );
  data( 0 );
  data( 0 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 255 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );

  // initialize the dest array to 0

  address( c_masked_filter_dest_ptr );

  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );
  data( 0 );

  ref_address( c_masked_filter_dest_ptr );

  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 190 );
  ref_data( 182 );
  ref_data( 83 );
  ref_data( 1 );
  ref_data( 122 );
  ref_data( 122 );
  ref_data( 40 );
  ref_data( 43 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 190 );
  ref_data( 134 );
  ref_data( 83 );
  ref_data( 83 );
  ref_data( 122 );
  ref_data( 122 );
  ref_data( 40 );
  ref_data( 43 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 255 );
  ref_data( 14 );
  ref_data( 73 );
  ref_data( 73 );
  ref_data( 65 );
  ref_data( 65 );
  ref_data( 200 );
  ref_data( 200 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 192 );
  ref_data( 121 );
  ref_data( 92 );
  ref_data( 92 );
  ref_data( 248 );
  ref_data( 248 );
  ref_data( 200 );
  ref_data( 200 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 197 );
  ref_data( 148 );
  ref_data( 121 );
  ref_data( 145 );
  ref_data( 248 );
  ref_data( 196 );
  ref_data( 196 );
  ref_data( 91 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 208 );
  ref_data( 196 );
  ref_data( 195 );
  ref_data( 202 );
  ref_data( 251 );
  ref_data( 196 );
  ref_data( 164 );
  ref_data( 96 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 220 );
  ref_data( 179 );
  ref_data( 182 );
  ref_data( 185 );
  ref_data( 0 );
  ref_data( 135 );
  ref_data( 133 );
  ref_data( 83 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 150 );
  ref_data( 93 );
  ref_data( 100 );
  ref_data( 138 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 189 );
  ref_data( 187 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );
  ref_data( 0 );

end
endtask
