//========================================================================
// Test Cases for srl instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_srl_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srl r3, r2, 0x0007   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h01000000 );

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

task init_srl_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing srl: src0( 0xd ), shamt = 3, result( 0x1 )
  // dest_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srl r3, r1, 0x0003   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Dest Bypass) Testing srl: src0( 0x8000000e ), shamt = 4, result( 0x8000000 )
  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srl r3, r1, 0x0004   " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h8000000 );

  // (Dest Bypass) Testing srl: src0( 0x8000000f ), shamt = 1, result( 0x40000007 )
  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srl r3, r1, 0x0001   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h40000007 );


  // (Bypass) Testing srl: src0( 0xd ), shamt = 3, result( 0x1 )
  // src0_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "srl r3, r1, 0x0003   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Bypass) Testing srl: src0( 0x8000000e ), shamt = 4, result( 0x8000000 )
  // src0_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "srl r3, r1, 0x0004   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h8000000 );

  // (Bypass) Testing srl: src0( 0x8000000f ), shamt = 1, result( 0x40000007 )
  // src0_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srl r3, r1, 0x0001   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h40000007 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_srl_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) srl: src0( 0x0 ), shamt = 0, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "srl r3, r1, 0x0      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) srl: src0( 0x0 ), shamt = 31, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "srl r3, r1, 0x1f   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) srl: src0( 0x80000000 ), shamt = 0, result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "srl r3, r1, 0x0      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );

  // (Value Testing) srl: src0( 0x80000000 ), shamt = 1, result( 0x40000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "srl r3, r1, 0x1      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h40000000 );

  // (Value Testing) srl: src0( 0x80000000 ), shamt = 31, result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "srl r3, r1, 0x1f   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) srl: src0( 0x7fffffff ), shamt = 1, result( 0x3fffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "srl r3, r1, 0x1   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h3fffffff );

  // (Value Testing) srl: src0( 0x7fffffff ), shamt = 31, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "srl r3, r1, 0x1f   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing srl: src0( 0xd ), shamt = 1, result( 0x6 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "srl r1, r1, 0x1    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h6 );

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
task init_srl_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) srl: src0( 0x1 ), shamt = 1, result( 0x0 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "srl r3, r1, 0x1    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

    // (Value Testing) srl: src0( 0x80000000 ), shamt = 31, result( 0x1 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
    inst( "srl r3, r1, 0x1f    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );
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
// Test Case: srl basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "srl basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srl_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srl bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "srl bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srl_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srl value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "srl value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srl_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srl stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "srl stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_srl_long;
  run_test;
end
`VC_TEST_CASE_END

