//========================================================================
// Test Cases for jal instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_jal_basic;
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
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "jal   [+7]          "); // goto 1:
  inst( "addiu r5, r5, 0b01  "); //         |
  inst( "nop                 "); //         |
  inst( "nop                 "); //         |
  inst( "nop                 "); //         |
  inst( "nop                 "); //         |
  inst( "nop                 "); //         |
                                 //         |
  // 1:                          //         |
  inst( "addiu r5, r5, 0b10  "); // <- - - -'
  inst( "mtc0  r5, proc2mngr "); init_sink( 32'b10 );
  inst( "mtc0  r31, proc2mngr"); init_sink( c_reset_vector + 7*4 );

  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");

end
endtask

// add more test vectors here

//------------------------------------------------------------------------
// Test Case: jal basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "jal basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jal_basic;
  run_test;
end
`VC_TEST_CASE_END

// add more test cases here


