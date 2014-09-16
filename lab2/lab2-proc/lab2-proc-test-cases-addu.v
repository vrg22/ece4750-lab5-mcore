//========================================================================
// Test Cases for addu instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_addu_basic;
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
  inst( "addu r3, r2, r1    " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000009 );
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

task init_addu_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing addu: src0( 0xd ), src1( 0xb ), result( 0x18 )
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
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h18 );

  // (Dest Bypass) Testing addu: src0( 0xe ), src1( 0xb ), result( 0x19 )
  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
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
  inst( "addu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h19 );

  // (Dest Bypass) Testing addu: src0( 0xf ), src1( 0xb ), result( 0x1a )
  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
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
  inst( "addu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1a );


  // (Bypass) Testing addu: src0( 0xd ), src1( 0xb ), result( 0x18 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "addu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h18 );

  // (Bypass) Testing addu: src0( 0xe ), src1( 0xb ), result( 0x19 )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "addu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h19 );

  // (Bypass) Testing addu: src0( 0xf ), src1( 0xb ), result( 0x1a )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "addu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1a );

  // (Bypass) Testing addu: src0( 0xd ), src1( 0xb ), result( 0x18 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "addu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h18 );

  // (Bypass) Testing addu: src0( 0xe ), src1( 0xb ), result( 0x19 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "addu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h19 );

  // (Bypass) Testing addu: src0( 0xf ), src1( 0xb ), result( 0x1a )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "addu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1a );


  // (Bypass) Testing addu: src0( 0xd ), src1( 0xb ), result( 0x18 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "addu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h18 );

  // (Bypass) Testing addu: src0( 0xe ), src1( 0xb ), result( 0x19 )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "addu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h19 );

  // (Bypass) Testing addu: src0( 0xf ), src1( 0xb ), result( 0x1a )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "addu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1a );

  // (Bypass) Testing addu: src0( 0xd ), src1( 0xb ), result( 0x18 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "addu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h18 );

  // (Bypass) Testing addu: src0( 0xe ), src1( 0xb ), result( 0x19 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "addu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h19 );

  // (Bypass) Testing addu: src0( 0xf ), src1( 0xb ), result( 0x1a )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "addu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1a );

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

task init_addu_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) addu: src0( 0x0 ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) addu: src0( 0x1 ), src1( 0x1 ), result( 0x2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h2 );

  // (Value Testing) addu: src0( 0x3 ), src1( 0x7 ), result( 0xa )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h3 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7 );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'ha );


  // (Value Testing) addu: src0( 0x0 ), src1( 0xffff8000 ), result( 0xffff8000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffff8000 );

  // (Value Testing) addu: src0( 0x80000000 ), src1( 0x0 ), result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );

  // (Value Testing) addu: src0( 0x80000000 ), src1( 0xffff8000 ), result( 0x7fff8000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff8000 );


  // (Value Testing) addu: src0( 0x0 ), src1( 0x7fff ), result( 0x7fff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff );

  // (Value Testing) addu: src0( 0x7fffffff ), src1( 0x0 ), result( 0x7fffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fffffff );

  // (Value Testing) addu: src0( 0x7fffffff ), src1( 0x7fff ), result( 0x80007ffe )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80007ffe );


  // (Value Testing) addu: src0( 0x80000000 ), src1( 0x7fff ), result( 0x80007fff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80007fff );

  // (Value Testing) addu: src0( 0x7fffffff ), src1( 0xffff8000 ), result( 0x7fff7fff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff7fff );


  // (Value Testing) addu: src0( 0x0 ), src1( 0xffffffff ), result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );

  // (Value Testing) addu: src0( 0xffffffff ), src1( 0x1 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) addu: src0( 0xffffffff ), src1( 0xffffffff ), result( 0xfffffffe )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "addu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffe );


  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing addu: src0( 0xd ), src1( 0xb ), result( 0x18 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "addu r1, r1, r2    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h18 );

  // (Src1 equals Dest) Testing addu: src0( 0xe ), src1( 0xb ), result( 0x19 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "addu r2, r1, r2    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h19 );

  // (Src0 equals Src1) Testing addu: src0( 0xf ), src1( 0xf ), result( 0x1e )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "addu r2, r1, r1    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h1e );

  // (Srcs equals Dest) Testing addu: src0( 0x10 ), src1( 0x10 ), result( 0x20 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "addu r1, r1, r1    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h20 );

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
task init_addu_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) addu: src0( 0x1 ), src1( 0x1 ), result( 0x2 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
    inst( "addu r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h2 );

    // (Value Testing) addu: src0( 0x3 ), src1( 0x7 ), result( 0xa )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h3 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7 );
    inst( "addu r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'ha );
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
// Test Case: addu basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "addu basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addu_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addu bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "addu bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addu_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addu value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "addu value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addu_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addu stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "addu stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_addu_long;
  run_test;
end
`VC_TEST_CASE_END



