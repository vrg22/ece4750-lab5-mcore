//========================================================================
// Test Cases for lui instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_lui_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "lui  r1, 0x0001   " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "mtc0 r1, proc2mngr" ); init_sink(  32'h00010000 );

  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );

end
endtask

// add more test vectors here


//------------------------------------------------------------------------
// Test Case: lui basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "lui basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lui_basic;
  run_test;
end
`VC_TEST_CASE_END

// add more test cases here


