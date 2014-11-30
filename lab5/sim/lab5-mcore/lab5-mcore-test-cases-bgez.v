//========================================================================
// Test Cases for bgez instruction
//========================================================================
// this file is to be `included by lab5-mcore-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_bgez_basic;
begin

  // In jump/branch tests, a bitvector tracks the paths that are taken
  // when the jumps/branches are taken / not taken. The bitvector starts
  // at 32'b0, and we raise bits in the bitvector depending on which
  // paths we take. At the end of the test, we send the bitvector to the
  // sink to check whether we took the paths we expected to take.

  clear_mem;

  address( c_reset_vector );
  // Initialize bitvector
  inst( "addiu r5, r0, 0     ");
  inst( "mfc0  r3, mngr2proc "); init_src(  32'hfffffffe );
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "bgez  r0, [+7]      "); // goto id_a: -.
  inst( "addiu r5, r5, 0b1   "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
                                 //             |
  // id_a:                       //             |
  inst( "nop                 "); // <- - - - - -'
  inst( "bgez  r3, [+7]      "); // goto id_b: (branch not taken)
  inst( "addiu r5, r5, 0b10  ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");

  // id_b:
  inst( "nop                 ");
  inst( "bgez  r0, [+7]      "); // goto id_c: -.
  inst( "addiu r5, r5, 0b100 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
                                 //             |
  // id_c:                       //             |
  inst( "nop                 "); // <- - - - - -'
  inst( "mtc0  r5, proc2mngr "); init_sink( 32'b0010 );
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_bgez_bypass;
begin

  clear_mem;

  address( c_reset_vector );
  
  //-----------------------------------------------------------------
  // Bypassing tests
  //-----------------------------------------------------------------
  
  test_br1_src0_byp( 0, "bgez", -1 );
  test_br1_src0_byp( 1, "bgez", -1 );
  test_br1_src0_byp( 2, "bgez", -1 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_bgez_value;
begin

  clear_mem;

  address( c_reset_vector );

  //-----------------------------------------------------------------
  // Branch tests
  //-----------------------------------------------------------------
  
  test_br1_op_taken( "bgez", 0 );
  test_br1_op_taken( "bgez", 1 );

  test_br1_op_nottaken( "bgez", -1  );
  test_br1_op_nottaken( "bgez", -10 );

  //----------------------------------------------------------------------
  // Test that there is no branch delay slot
  //----------------------------------------------------------------------

  inst( "mfc0 r3, mngr2proc  " ); init_src( 32'd1 );
  inst( "mfc0 r1, mngr2proc  " ); init_src( 32'd1 );
  inst( "addu r2, r0, r0     " );
  inst( "bgez  r3,[+5]       " );
  inst( "addu r2, r2, r1     " );
  inst( "addu r2, r2, r1     " );
  inst( "addu r2, r2, r1     " );
  inst( "addu r2, r2, r1     " );
  inst( "addu r2, r2, r1     " ); // branch here
  inst( "addu r2, r2, r1     " );
  inst( "mtc0 r2, proc2mngr  " ); init_sink( 32'd2 );


  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_bgez_long;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Test backwards walk (back to back branch taken)
  //----------------------------------------------------------------------

  inst( "mfc0  r3, mngr2proc  "); init_src( 32'd0 );
  inst( "mfc0  r1, mngr2proc  "); init_src( 32'd1 );
  for ( idx = 0; idx < 10; idx = idx + 1 ) begin
    inst( "bgez   r3, [+13]  ");
    inst( "mtc0  r0, proc2mngr  "); // we don't expect a message here
    inst( "nop                  ");
    inst( "mtc0  r1, proc2mngr  "); init_sink(32'd1 );
    inst( "bgez   r3,  [+10]  ");
    inst( "bgez   r3,  [-2]   "); // goto two above
    inst( "bgez   r3,  [-1]   "); // goto one above
    inst( "bgez   r3,  [-1]   "); // goto one above
    inst( "bgez   r3,  [-1]   "); // goto one above
    inst( "bgez   r3,  [-1]   "); // goto one above
    inst( "bgez   r3,  [-1]   "); // goto one above
    inst( "bgez   r3,  [-1]   "); // goto one above
    inst( "bgez   r3,  [-1]   "); // goto one above
    inst( "bgez   r3,  [-1]   "); // goto one above
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: bgez basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "bgez basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_bgez_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: bgez bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "bgez bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_bgez_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: bgez value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "bgez value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_bgez_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: bgez stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "bgez stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_bgez_long;
  run_test;
end
`VC_TEST_CASE_END

