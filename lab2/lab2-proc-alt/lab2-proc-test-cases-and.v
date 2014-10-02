//========================================================================
// Test Cases for and instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_and_basic;
begin
  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000005 );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h00000014 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "and r3, r2, r1     " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000004 );
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

task init_and_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing and: src0( 0xd ), src1( 0xb ), result( 0x9 )
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
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h9 );

  // (Dest Bypass) Testing and: src0( 0xe ), src1( 0xb ), result( 0xa )
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
  inst( "and r3, r1, r2    " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'ha );

  // (Dest Bypass) Testing and: src0( 0xf ), src1( 0xb ), result( 0xb )
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
  inst( "and r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hb );


  // (Bypass) Testing and: src0( 0x1d ), src1( 0x1b ), result( 0x19 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1d );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1b );
  inst( "and r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h19 );

  // (Bypass) Testing and: src0( 0xbeff ), src1( 0xbeef ), result( 0xbeef )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hbeff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hbeef );
  inst( "nop                  " );
  inst( "and r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hbeef );

  // (Bypass) Testing and: src0( 0xf0 ), src1( 0xbb ), result( 0xb0 )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hbb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "and r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hb0 );

  // (Bypass) Testing and: src0( 0xdddddddd ), src1( 0xbbbbbbbb ), result( 0x99999999 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hdddddddd );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hbbbbbbbb );
  inst( "and r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h99999999 );

  // (Bypass) Testing and: src0( 0xabcdef01 ), src1( 0x12345678 ), result( 0x02044600 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'habcdef01 );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h12345678 );
  inst( "nop                  " );
  inst( "and r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h02044600 );

  // (Bypass) Testing and: src0( 0xfab ), src1( 0xbbb ), result( 0xbab )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hfab );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hbbb );
  inst( "and r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hbab );


  // (Bypass) Testing and: src0( 0xdad ), src1( 0xbad ), result( 0x9ad )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hdad );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hbad );
  inst( "and r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h9ad );

  // (Bypass) Testing and: src0( 0xead ), src1( 0xbead ), result( 0xead )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'head );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hbead );
  inst( "and r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'head );

  // (Bypass) Testing and: src0( 0xfabe ), src1( 0xbabe ), result( 0xbabe )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hfabe );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hbabe );
  inst( "and r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hbabe );

  // (Bypass) Testing and: src0( 0x1234 ), src1( 0x4321 ), result( 0x0220 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1234 );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h4321 );
  inst( "nop                  " );
  inst( "and r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0220 );

  // (Bypass) Testing and: src0( 0x11 ), src1( 0xbe ), result( 0x10 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h11 );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hbe );
  inst( "nop                  " );
  inst( "and r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h10 );

  // (Bypass) Testing and: src0( 0xb ), src1( 0xe ), result( 0xa )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "and r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'ha );

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

task init_and_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) and: src0( 0x0 ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) and: src0( 0x1 ), src1( 0x1 ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) and: src0( 0x0 ), src1( 0x1 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );


  // (Value Testing) and: src0( 0xf ), src1( 0x1 ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) and: src0( 0x80000000 ), src1( 0xffffffff ), result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );

  // (Value Testing) and: src0( 0x80008000 ), src1( 0xffff8000 ), result( 0x80008000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80008000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80008000 );


  // (Value Testing) and: src0( 0xa2345678 ), src1( 0xa2345678 ), result( 0xa2345678 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'ha2345678 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'ha2345678 );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'ha2345678 );

  // (Value Testing) and: src0( 0x7fffffff ), src1( 0xfffffff7 ), result( 0x7ffffff7 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hfffffff7 );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7ffffff7 );

  // (Value Testing) and: src0( 0x7fff ), src1( 0x7fff ), result( 0x7fff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff );


  // (Value Testing) and: src0( 0x80000001 ), src1( 0x80000091 ), result( 0x80000001 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000001 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h80000091 );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000001 );

  // (Value Testing) and: src0( 0xffffffff ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );


  // (Value Testing) and: src0( 0x0 ), src1( 0xffffffff ), result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) and: src0( 0xffffffff ), src1( 0x1 ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) and: src0( 0xffffffff ), src1( 0xffffffff ), result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "and r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );


  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing and: src0( 0xd ), src1( 0xb ), result( 0x9 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "and r1, r1, r2    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h9 );

  // (Src1 equals Dest) Testing and: src0( 0xe ), src1( 0xb ), result( 0xa )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "and r2, r1, r2    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'ha );

  // (Src0 equals Src1) Testing and: src0( 0xf ), src1( 0xf ), result( 0xf )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "and r2, r1, r1    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hf );

  // (Srcs equals Dest) Testing and: src0( 0x10 ), src1( 0x10 ), result( 0x10 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "and r1, r1, r1    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h10 );

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
task init_and_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) and: src0( 0x1 ), src1( 0x1 ), result( 0x1 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
    inst( "and r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

    // (Value Testing) and: src0( 0x3 ), src1( 0x7 ), result( 0x3 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h3 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7 );
    inst( "and r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h3 );
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
// Test Case: and basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "and basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_and_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: and bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "and bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_and_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: and value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "and value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_and_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: and stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "and stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_and_long;
  run_test;
end
`VC_TEST_CASE_END



