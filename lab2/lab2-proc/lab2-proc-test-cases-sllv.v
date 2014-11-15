//========================================================================
// Test Cases for sllv instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sllv_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000002 );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h00000004 );
  inst( "nop                " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sllv r3, r2, r1      " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000010 );
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

task init_sllv_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing sllv: src0( 0xd ), src1( 0x3 ), result( 0x68 )
  // dest_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h3 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sllv r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h68 );

  // (Dest Bypass) Testing sllv: src0( 0x8000000e ), src1( 0x4 ), result( 0xe0 )
  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0 );

  // (Dest Bypass) Testing sllv: src0( 0x8000000f ), src1( 0x1 ), result( 0x1e )
  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1e );


  // (Bypass) Testing sllv: src0( 0xd ), src1( 0x3 ), result( 0x68 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h3 );
  inst( "sllv r3, r1, r2      " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h68 );

  // (Bypass) Testing sllv: src0( 0x8000000e ), src1( 0x4 ), result( 0xe0 )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "nop                  " );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0 );

  // (Bypass) Testing sllv: src0( 0x8000000f ), src1( 0x1 ), result( 0x1e )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1e );

  // (Bypass) Testing sllv: src0( 0x8000000e ), src1( 0x4 ), result( 0xe0 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0 );

  // (Bypass) Testing sllv: src0( 0x8000000e ), src1( 0x4 ), result( 0xe0 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "nop                  " );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0 );

  // (Bypass) Testing sllv: src0( 0x8000000f ), src1( 0x1 ), result( 0x1e )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1e );

  // (Bypass) Testing sllv: src0( 0xd ), src1( 0x3 ), result( 0x68 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h3 );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "sllv r3, r1, r2      " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h68 );

  // (Bypass) Testing sllv: src0( 0x8000000e ), src1( 0x4 ), result( 0xe0 )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0 );

  // (Bypass) Testing sllv: src0( 0x8000000f ), src1( 0x1 ), result( 0x1e )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1e );

  // (Bypass) Testing sllv: src0( 0x8000000e ), src1( 0x4 ), result( 0xe0 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0 );

  // (Bypass) Testing sllv: src0( 0x8000000e ), src1( 0x4 ), result( 0xe0 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h4 );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0 );

  // (Bypass) Testing sllv: src0( 0x8000000f ), src1( 0x1 ), result( 0x1e )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sllv r3, r1, r2   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1e );
  end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_sllv_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) sllv: src0( 0x0 ), shamt = 0, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "sllv r3, r1, r2      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) sllv: src0( 0x0 ), shamt = 31, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1f );
  inst( "sllv r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) sllv: src0( 0x1 ), shamt = 0, result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "sllv r3, r1, r2      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) sllv: src0( 0x80000000 ), shamt = 1, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "sllv r3, r1, r2      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) sllv: src0( 0x1 ), shamt = 31, result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1f );
  inst( "sllv r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );

  // (Value Testing) sllv: src0( 0x7fffffff ), shamt = 1, result( 0xfffffffe )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "sllv r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffe );

  // (Value Testing) sllv: src0( 0x2 ), shamt = 31, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1f );
  inst( "sllv r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing sllv: src0( 0xd ), shamt = 1, result( 0x1a )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "sllv r1, r1, r2    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h1a );

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
task init_sllv_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) sllv: src0( 0x1 ), shamt = 1, result( 0x2 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
    inst( "sllv r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h2 );

    // (Value Testing) sllv: src0( 0x80000000 ), shamt = 1, result( 0x0 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
    inst( "sllv r3, r1, r2    " );
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
// Test Case: sllv basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "sllv basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sllv_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sllv bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "sllv bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sllv_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sllv value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "sllv value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sllv_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sllv stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "sllv stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_sllv_long;
  run_test;
end
`VC_TEST_CASE_END

