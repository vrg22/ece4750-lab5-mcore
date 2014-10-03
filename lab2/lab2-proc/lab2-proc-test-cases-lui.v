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

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_lui_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing lui: imm = 0x1, result( 0x00010000 )
  // dest_nops( 0 )

  inst( "lui r1, 0x0001   " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h00010000 );

  // (Dest Bypass) Testing lui: imm = 0x1, result( 0x00010000 )
  // dest_nops( 1 )

  inst( "lui r3, 0x0001      " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00010000 );

  // (Dest Bypass) Testing lui: imm = 0x1, result( 0x00010000 )
  // dest_nops( 2 )

  inst( "lui r1, 0x0001      " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h00010000 );

  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_lui_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) lui: imm = 0x0, result( 0x00000000 )

  inst( "lui r1, 0x0000      " );
  inst( "mtc0 r1, proc2mngr  " ); init_sink( 32'h00000000 );

  // (Value Testing) lui: imm = 0xffff, result( 0xffff0000 )

  inst( "lui r1, 0xffff   " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'hffff0000 );

end
endtask

//------------------------------------------------------------------------
// Long tests
//------------------------------------------------------------------------

integer idx;
task init_lui_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) lui: imm = 0x1, result( 0x00010000 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
    inst( "lui  r3, 0x0001    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00010000 );

    // (Value Testing) lui: imm = 0x7fff, result( 0x7fff0000 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fff );
    inst( "lui  r3, 0x7fff      " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff0000 );
  end

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask

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

//------------------------------------------------------------------------
// Test Case: lui bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "lui bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lui_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lui value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "lui value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lui_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lui stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "lui stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_lui_long;
  run_test;
end
`VC_TEST_CASE_END