//========================================================================
// Test Cases for sw instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sw_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc " ); init_src(   32'h00002000 );
  inst( "mfc0  r5, mngr2proc " ); init_src(   32'h00000001 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "sw    r5, 0(r3)     " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "lw    r4, 0(r3)     " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "mtc0  r4, proc2mngr " ); init_sink(  32'h00000001 );

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
// Test Case: sw basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "sw basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sw_basic;
  run_test;
end
`VC_TEST_CASE_END

// add more test cases here


