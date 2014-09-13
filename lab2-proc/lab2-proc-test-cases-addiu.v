//========================================================================
// Test Cases for addiu instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_addiu_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000005 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "addiu r3, r2, 0x0004 " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000009 );

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask

// add more test vectors here


//------------------------------------------------------------------------
// Test Case: addiu basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "addiu basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addiu_basic;
  run_test;
end
`VC_TEST_CASE_END

// add more test cases here


