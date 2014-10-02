//========================================================================
// Test Cases for sll instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sll_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h80008000 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sll r3, r2, 0x0003   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00040000 );

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

task init_sll_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing sll: src0( 0xd ), shamt = 3, result( 0x68 )
  // dest_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sll r3, r1, 0x0003   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h68 );

  // (Dest Bypass) Testing sll: src0( 0x8000000e ), shamt = 4, result( 0xe0 )
  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sll r3, r1, 0x0004   " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0 );

  // (Dest Bypass) Testing sll: src0( 0x8000000f ), shamt = 1, result( 0x1e )
  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sll r3, r1, 0x0001   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1e );


  // (Bypass) Testing sll: src0( 0xd ), shamt = 3, result( 0x68 )
  // src0_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "sll r3, r1, 0x0003   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h68 );

  // (Bypass) Testing sll: src0( 0x8000000e ), shamt = 4, result( 0xe0 )
  // src0_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "sll r3, r1, 0x0004   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0 );

  // (Bypass) Testing sll: src0( 0x8000000f ), shamt = 1, result( 0x1e )
  // src0_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sll r3, r1, 0x0001   " );
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

task init_sll_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) sll: src0( 0x0 ), shamt = 0, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "sll r3, r1, 0x0      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) sll: src0( 0x0 ), shamt = 31, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "sll r3, r1, 0x1f   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) sll: src0( 0x1 ), shamt = 0, result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "sll r3, r1, 0x0      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) sll: src0( 0x80000000 ), shamt = 1, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "sll r3, r1, 0x1      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) sll: src0( 0x1 ), shamt = 31, result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "sll r3, r1, 0x1f   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );

  // (Value Testing) sll: src0( 0x7fffffff ), shamt = 1, result( 0xfffffffe )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "sll r3, r1, 0x1   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffe );

  // (Value Testing) sll: src0( 0x2 ), shamt = 31, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2 );
  inst( "sll r3, r1, 0x1f   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing sll: src0( 0xd ), shamt = 1, result( 0x1a )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "sll r1, r1, 0x1    " );
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
task init_sll_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) sll: src0( 0x1 ), shamt = 1, result( 0x2 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "sll r3, r1, 0x1    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h2 );

    // (Value Testing) sll: src0( 0x80000000 ), shamt = 1, result( 0x0 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
    inst( "sll r3, r1, 0x1    " );
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
// Test Case: sll basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "sll basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sll_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sll bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "sll bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sll_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sll value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "sll value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sll_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sll stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "sll stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_sll_long;
  run_test;
end
`VC_TEST_CASE_END

