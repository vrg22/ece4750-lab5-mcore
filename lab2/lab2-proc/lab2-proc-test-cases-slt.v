//========================================================================
// Test Cases for slt instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_slt_basic;
begin
  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000005 );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h00000004 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "slt r3, r2, r1     " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000001 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_slt_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing slt: src0( 0xd ), src1( 0xb ), result( 0x0 )
  // dest_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Dest Bypass) Testing slt: src0( 0xb ), src1( 0xe ), result( 0x1 )
  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Dest Bypass) Testing slt: src0( 0x10 ), src1( 0x10 ), result( 0x0 )
  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h10 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );


  // (Bypass) Testing slt: src0( 0xd ), src1( 0xb ), result( 0x0 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Bypass) Testing slt: src0( 0xb ), src1( 0xe ), result( 0x1 )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Bypass) Testing slt: src0( 0x10 ), src1( 0x10 ), result( 0x0 )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h10 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Bypass) Testing slt: src0( 0xd ), src1( 0xb ), result( 0x0 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Bypass) Testing slt: src0( 0xb ), src1( 0xe ), result( 0x1 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Bypass) Testing slt: src0( 0x10 ), src1( 0x10 ), result( 0x0 )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h10 );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );


  // (Bypass) Testing slt: src0( 0xd ), src1( 0xb ), result( 0x0 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Bypass) Testing slt: src0( 0xe ), src1( 0xb ), result( 0x1 )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hb );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Bypass) Testing slt: src0( 0x10 ), src1( 0x10 ), result( 0x0 )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h10 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Bypass) Testing slt: src0( 0xd ), src1( 0xb ), result( 0x0 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Bypass) Testing slt: src0( 0xb ), src1( 0xe ), result( 0x1 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Bypass) Testing slt: src0( 0x10 ), src1( 0x10 ), result( 0x0 )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h10 );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slt r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

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
// Value tests
//------------------------------------------------------------------------

task init_slt_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) slt: src0( 0x0 ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) slt: src0( 0x1 ), src1( 0x1 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) slt: src0( 0x0 ), src1( 0x1 ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );


  // (Value Testing) slt: src0( 0x1 ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) slt: src0( 0x80000000 ), src1( 0x0 ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) slt: src0( 0x80000000 ), src1( 0xffffffff ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );


  // (Value Testing) slt: src0( 0xffffffff ), src1( 0x0 ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) slt: src0( 0x80000000 ), src1( 0x7fffffff ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) slt: src0( 0x7fffffff ), src1( 0x80000000 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );


  // (Value Testing) slt: src0( 0xffffffff ), src1( 0x80000000 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "slt r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing slt: src0( 0x0 ), src1( 0x1 ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "slt r1, r1, r2    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h1 );

  // (Src1 equals Dest) Testing slt: src0( 0x1 ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "slt r2, r1, r2    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h0 );

  // (Src0 equals Src1) Testing slt: src0( 0xf ), src1( 0xf ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "slt r2, r1, r1    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h0 );

  // (Srcs equals Dest) Testing slt: src0( 0x10 ), src1( 0x10 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "slt r1, r1, r1    " );
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
task init_slt_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) slt: src0( 0x1 ), src1( 0x0 ), result( 0x0 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
    inst( "slt r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

    // (Value Testing) slt: src0( 0x3 ), src1( 0x7 ), result( 0x1 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h3 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7 );
    inst( "slt r3, r1, r2    " );
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
// Test Case: slt basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "slt basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slt_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slt bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "slt bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slt_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slt value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "slt value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slt_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slt stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "slt stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_slt_long;
  run_test;
end
`VC_TEST_CASE_END

