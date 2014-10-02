//========================================================================
// Test Cases for srav instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_srav_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000002 );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h80000004 );
  inst( "nop                " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srav r3, r2, r1      " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0000001 );
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
// Bypassing tests
//------------------------------------------------------------------------

task init_srav_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing srav: src0( 0xd ), src1( 0x3 ), result( 0x1 )
  // dest_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h3 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srav r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Dest Bypass) Testing srav: src0( 0x8000000e ), src1( 0x4 ), result( 0xf8000000 )
  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf8000000 );

  // (Dest Bypass) Testing srav: src0( 0x8000000f ), src1( 0x1 ), result( 0xc0000007 )
  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hc0000007 );


  // (Bypass) Testing srav: src0( 0xd ), src1( 0x3 ), result( 0x1 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h3 );
  inst( "srav r3, r1, r2      " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Bypass) Testing srav: src0( 0x8000000e ), src1( 0x4 ), result( 0xf8000000 )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "nop                  " );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf8000000 );

  // (Bypass) Testing srav: src0( 0x8000000f ), src1( 0x1 ), result( 0xc0000007 )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hc0000007 );

  // (Bypass) Testing srav: src0( 0x8000000e ), src1( 0x4 ), result( 0xf8000000 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf8000000 );

  // (Bypass) Testing srav: src0( 0x8000000e ), src1( 0x4 ), result( 0xf8000000 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "nop                  " );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf8000000 );

  // (Bypass) Testing srav: src0( 0x8000000f ), src1( 0x1 ), result( 0xc0000007 )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hc0000007 );

  // (Bypass) Testing srav: src0( 0xd ), src1( 0x3 ), result( 0x1 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h3 );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "srav r3, r1, r2      " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Bypass) Testing srav: src0( 0x8000000e ), src1( 0x4 ), result( 0xf8000000 )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf8000000 );

  // (Bypass) Testing srav: src0( 0x8000000f ), src1( 0x1 ), result( 0xc0000007 )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hc0000007 );

  // (Bypass) Testing srav: src0( 0x8000000e ), src1( 0x4 ), result( 0xf8000000 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf8000000 );

  // (Bypass) Testing srav: src0( 0x8000000e ), src1( 0x4 ), result( 0xf8000000 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf8000000 );

  // (Bypass) Testing srav: src0( 0x8000000f ), src1( 0x1 ), result( 0xc0000007 )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srav r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hc0000007 );
  end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_srav_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) srav: src0( 0x0 ), shamt = 0, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "srav r3, r1, r2      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) srav: src0( 0x0 ), shamt = 31, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1f );
  inst( "srav r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) srav: src0( 0x80000000 ), shamt = 0, result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "srav r3, r1, r2      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );

  // (Value Testing) srav: src0( 0x80000000 ), shamt = 1, result( 0xc0000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "srav r3, r1, r2      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hc0000000 );

  // (Value Testing) srav: src0( 0x80000000 ), shamt = 31, result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1f );
  inst( "srav r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );

  // (Value Testing) srav: src0( 0x7fffffff ), shamt = 1, result( 0x3fffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "srav r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h3fffffff );

  // (Value Testing) srav: src0( 0x7fffffff ), shamt = 31, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1f );
  inst( "srav r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing srav: src0( 0xd ), shamt = 1, result( 0x6 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "srav r1, r1, r2    " );
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
task init_srav_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) srav: src0( 0x1 ), shamt = 1, result( 0x0 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
    inst( "srav r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

    // (Value Testing) srav: src0( 0x80000000 ), shamt = 31, result( 0xffffffff )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1f );
    inst( "srav r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );
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
// Test Case: srav basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "srav basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srav_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srav bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "srav bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srav_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srav value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "srav value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srav_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srav stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "srav stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_srav_long;
  run_test;
end
`VC_TEST_CASE_END


