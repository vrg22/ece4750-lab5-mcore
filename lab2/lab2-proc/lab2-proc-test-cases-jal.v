//========================================================================
// Test Cases for jal instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_jal_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc " ); init_src( 32'h00000001 );
  inst( "jal   [+8]          " ); // goto 1:
  // send zero if fail
  inst( "mtc0  r0, proc2mngr " ); // we don't expect a message here
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // 1:
  // pass
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "mtc0  r31, proc2mngr" ); init_sink( c_reset_vector + 8 );

  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

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


