//========================================================================
// Test Cases for slti instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_slti_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000005 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slti r3, r2, 0x0006  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000001 );

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_slti_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing slti: src0( 0xd ), imm = 0x000b, result( 0x0 )
  // dest_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slti r3, r1, 0x000b   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Dest Bypass) Testing slti: src0( 0x700e ), imm = 0x700e, result( 0x0 )
  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h700e );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slti r3, r1, 0x700e   " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Dest Bypass) Testing slti: src0( 0x8000000f ), imm = 0x1, result( 0x1 )
  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slti r3, r1, 0x0001   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );


  // (Bypass) Testing slti: src0( 0xd ), imm = 0x000b, result( 0x0 )
  // src0_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "slti r3, r1, 0x000b   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Bypass) Testing slti: src0( 0x700e ), imm = 0x700e, result( 0x0 )
  // src0_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h700e );
  inst( "nop                  " );
  inst( "slti r3, r1, 0x700e   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Bypass) Testing slti: src0( 0x8000000f ), imm = 0x1, result( 0x1 )
  // src0_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slti r3, r1, 0x0001   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_slti_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) slti: src0( 0x0 ), imm = 0x0, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "slti r3, r1, 0x0000      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) slti: src0( 0x0 ), imm = 0x1, result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "slti r3, r1, 0x0001   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) slti: src0( 0xffffffff ), imm = 0x0, result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "slti r3, r1, 0x0000      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) slti: src0( 0x80000000 ), imm = 0xffff, result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "slti r3, r1, 0xffff      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) slti: src0( 0x80000000 ), imm = 0x0, result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "slti r3, r1, 0x0   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) slti: src0( 0xffff8000 ), imm = 0x8000, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "slti r3, r1, 0x8000   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) slti: src0( 0xffff7fff ), imm = 0x8000, result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffff7fff );
  inst( "slti r3, r1, 0x8000   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) slti: src0( 0x8000 ), imm = 0x7fff, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000 );
  inst( "slti r3, r1, 0x7fff   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) slti: src0( 0x7ffe ), imm = 0x7fff, result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7ffe );
  inst( "slti r3, r1, 0x7fff   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing slti: src0( 0xd ), imm = 0x1, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "slti r1, r1, 0x1    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h0 );

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
// Long tests
//------------------------------------------------------------------------

integer idx;
task init_slti_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) slti: src0( 0x0 ), imm = 0x1, result( 0x1 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
    inst( "slti r3, r1, 0x1    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

    // (Value Testing) slti: src0( 0x7fffffff ), imm = 0x7fff, result( 0x0 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
    inst( "slti r3, r1, 0x7fff    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );
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
// Test Case: slti basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "slti basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slti_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slti bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "slti bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slti_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slti value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "slti value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slti_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slti stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "slti stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_slti_long;
  run_test;
end
`VC_TEST_CASE_END

