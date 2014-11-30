//========================================================================
// Test Cases for jr instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_jr_basic;
begin

  clear_mem;

  // In jump/branch tests, a bitvector tracks the paths that are taken
  // when the jumps/branches are taken / not taken. The bitvector starts
  // at 32'b0, and we raise bits in the bitvector depending on which
  // paths we take. At the end of the test, we send the bitvector to the
  // sink to check whether we took the paths we expected to take.

  address( c_reset_vector );
  // Initialize bitvector
  inst( "addiu r5, r0, 0    " );
  // send the target pc
  inst( "mfc0  r2, mngr2proc"); init_src( c_reset_vector + 14 * 4 );
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "jr    r2           "); // goto 1:-.
  inst( "addiu r5, r5, 0b01 "); //         |
  inst( "nop                "); //         |
  inst( "nop                "); //         |
  inst( "nop                "); //         |
  inst( "nop                "); //         |
  inst( "nop                "); //         |
                                //         |
  // 1:                         //         |
  inst( "addiu r5, r5, 0b10 "); // <- - - -'
  inst( "mtc0  r5, proc2mngr"); init_sink( 32'b10 );

  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");

end
endtask

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test vectors here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_jr_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_jr_src0_byp( 0, "jr" );
  test_jr_src0_byp( 1, "jr" );
  test_jr_src0_byp( 2, "jr" );
  test_jr_src0_byp( 3, "jr" );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Misc tests
//------------------------------------------------------------------------

task init_jr_misc;
begin

  clear_mem;

  address( c_reset_vector );


  inst( "mfc0  r5, mngr2proc" ); init_src( 32'h00000001 );
  // send the target pcs
  // address of 1:
  inst( "mfc0  r1, mngr2proc" ); init_src( c_reset_vector + 12 * 4 );
  // address of 2:
  inst( "mfc0  r2, mngr2proc" ); init_src( c_reset_vector + 15 * 4 );
  // address of 3:
  inst( "mfc0  r3, mngr2proc" ); init_src( c_reset_vector + 18 * 4 );
  inst( "jr    r2           " ); // goto 2:
  // send zero if fail
  inst( "mtc0  r0, proc2mngr" ); // we don't expect a message here
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );

  // 1:
  // pass
  inst( "mtc0  r5, proc2mngr" ); init_sink( 32'h00000001 );
  inst( "jr    r3           " ); // goto 3:
  // fail
  inst( "mtc0  r0, proc2mngr" );

  // 2:
  // pass
  inst( "mtc0  r5, proc2mngr" ); init_sink( 32'h00000001 );
  inst( "jr    r1           " ); // goto 1:
  // fail
  inst( "mtc0  r0, proc2mngr" );

  // 3:
  // pass
  inst( "mtc0  r5, proc2mngr" ); init_sink( 32'h00000001 );

  // test branch's priority over jump
  inst( "mfc0  r2, mngr2proc" ); init_src( c_reset_vector + 23 * 4 );
  inst( "bne   r5, r0, [+4] " ); // goto 5:
  inst( "jr    r2           " );
  inst( "mtc0  r0, proc2mngr" );

  // 4:
  // fail
  inst( "mtc0  r0, proc2mngr" );
  // 5:
  // pass
  inst( "mtc0  r5, proc2mngr" ); init_sink( 32'h00000001 );

  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_jr_long;
begin

  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_jr_src0_byp( 0, "jr" );
  end

  test_insert_nops( 8 );

end
endtask

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: jr basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "jr basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jr_basic;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test cases here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++


//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: jr bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "jr bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jr_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: jr misc
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "jr misc" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jr_misc;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: jr stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(4, "jr stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_jr_long;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
