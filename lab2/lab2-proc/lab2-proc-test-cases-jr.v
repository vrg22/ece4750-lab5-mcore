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

// add more test vectors here

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

// add more test cases here


