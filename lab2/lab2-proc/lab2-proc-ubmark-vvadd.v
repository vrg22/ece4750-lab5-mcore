//========================================================================
// ubmark-vvadd: vector-vector addition kernel
//========================================================================
//
// This code does adds the values of two arrays and stores the result to
// the destination array. The code is equivalent to:
//
// void vvadd( int *dest, int *src0, int *src1, int size ) {
//   for ( int i = 0; i < size; i++ )
//     *dest++ = *src0++ + *src1++;
// }

// pointers for the input and output arrays
localparam c_vvadd_src0_ptr = 32'h2000;
localparam c_vvadd_src1_ptr = 32'h3000;
localparam c_vvadd_dest_ptr = 32'h4000;
localparam c_vvadd_size     = 1;

//------------------------------------------------------------------------
// initialize unoptimized (not unrolled) vector vector add kernel
//------------------------------------------------------------------------

task init_vvadd_unopt;
begin
  clear_mem;

  address( c_reset_vector );
  // load pointers and array size
  inst( "mfc0  r1, mngr2proc " ); init_src( c_vvadd_size );
  inst( "mfc0  r2, mngr2proc " ); init_src( c_vvadd_src0_ptr );
  inst( "mfc0  r3, mngr2proc " ); init_src( c_vvadd_src1_ptr );
  inst( "mfc0  r4, mngr2proc " ); init_src( c_vvadd_dest_ptr );
  inst( "addiu r5, r0, 0     " );
  // loop:
  inst( "lw    r6, 0(r2)     " );
  inst( "lw    r7, 0(r3)     " );
  inst( "addu  r8, r6, r7    " );
  inst( "sw    r8, 0(r4)     " );
  inst( "addiu r2, r2, 4     " );
  inst( "addiu r3, r3, 4     " );
  inst( "addiu r4, r4, 4     " );
  inst( "addiu r5, r5, 1     " );
  inst( "bne   r5, r1, [-8]  " ); // goto loop:
  // after loop:, marks the end of program
  inst( "mtc0  r0, proc2mngr " ); init_sink( 32'h00000000 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // initialize data
  init_vvadd_data;

end
endtask

//------------------------------------------------------------------------
// initialize optimized (unrolled) vector vector add kernel
//------------------------------------------------------------------------

task init_vvadd_opt;
begin
  clear_mem;

  address( c_reset_vector );
  // load pointers and array size
  inst( "mfc0  r1, mngr2proc " ); init_src( c_vvadd_size  );
  inst( "mfc0  r2, mngr2proc " ); init_src( c_vvadd_src0_ptr );
  inst( "mfc0  r3, mngr2proc " ); init_src( c_vvadd_src1_ptr );
  inst( "mfc0  r4, mngr2proc " ); init_src( c_vvadd_dest_ptr );
  inst( "addiu r5, r0, 0     " );
  // loop:
  inst( "lw    r6,   0(r2)   " );
  inst( "lw    r7,   4(r2)   " );
  inst( "lw    r8,   8(r2)   " );
  inst( "lw    r9,  12(r2)   " );
  inst( "lw    r10,  0(r3)   " );
  inst( "lw    r11,  4(r3)   " );
  inst( "lw    r12,  8(r3)   " );
  inst( "lw    r13, 12(r3)   " );
  inst( "addu  r6, r6, r10   " );
  inst( "addu  r7, r7, r11   " );
  inst( "addu  r8, r8, r12   " );
  inst( "addu  r9, r9, r13   " );
  inst( "sw    r6,   0(r4)   " );
  inst( "sw    r7,   4(r4)   " );
  inst( "sw    r8,   8(r4)   " );
  inst( "sw    r9,  12(r4)   " );
  inst( "addiu r5, r5, 4     " );
  inst( "addiu r2, r2, 16    " );
  inst( "addiu r3, r3, 16    " );
  inst( "addiu r4, r4, 16    " );
  inst( "bne   r5, r1, [-20] " ); // goto loop:
  // after loop:, marks the end of program
  inst( "mtc0  r0, proc2mngr " ); init_sink( 32'h00000000 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // initialize data
  init_vvadd_data;

end
endtask

//------------------------------------------------------------------------
// initialize source and reference data for vvadd
//------------------------------------------------------------------------

task init_vvadd_data;
begin

  ubmark_name = "vvadd";
  ubmark_dest_size = c_vvadd_size;

  address( c_vvadd_src0_ptr );

  data( 32'd16807       );


  address( c_vvadd_src1_ptr );

  data( 32'd282475249   );

  ref_address( c_vvadd_dest_ptr );

  ref_data( 32'd282492056  );



end
endtask
