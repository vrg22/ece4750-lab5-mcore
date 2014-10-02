//========================================================================
// Test Cases for sra instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sra_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h80008000 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sra r3, r2, 0x0003   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf0001000 );

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

task init_sra_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing sra: src0( 0xd ), shamt = 3, result( 0x1 )
  // dest_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sra r3, r1, 0x0003   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Dest Bypass) Testing sra: src0( 0x8000000e ), shamt = 4, result( 0xf8000000 )
  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sra r3, r1, 0x0004   " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf8000000 );

  // (Dest Bypass) Testing sra: src0( 0x8000000f ), shamt = 1, result( 0xc0000007 )
  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sra r3, r1, 0x0001   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hc0000007 );


  // (Bypass) Testing sra: src0( 0xd ), shamt = 3, result( 0x1 )
  // src0_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "sra r3, r1, 0x0003   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Bypass) Testing sra: src0( 0x8000000e ), shamt = 4, result( 0xf8000000 )
  // src0_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000e );
  inst( "nop                  " );
  inst( "sra r3, r1, 0x0004   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf8000000 );

  // (Bypass) Testing sra: src0( 0x8000000f ), shamt = 1, result( 0xc0000007 )
  // src0_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000000f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sra r3, r1, 0x0001   " );
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

task init_sra_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) sra: src0( 0x0 ), shamt = 0, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "sra r3, r1, 0x0      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) sra: src0( 0x0 ), shamt = 31, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "sra r3, r1, 0x1f   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) sra: src0( 0x80000000 ), shamt = 0, result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "sra r3, r1, 0x0      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );

  // (Value Testing) sra: src0( 0x80000000 ), shamt = 1, result( 0xc0000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "sra r3, r1, 0x1      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hc0000000 );

  // (Value Testing) sra: src0( 0x80000000 ), shamt = 31, result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "sra r3, r1, 0x1f   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );

  // (Value Testing) sra: src0( 0x7fffffff ), shamt = 1, result( 0x3fffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "sra r3, r1, 0x1   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h3fffffff );

  // (Value Testing) sra: src0( 0x7fffffff ), shamt = 31, result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "sra r3, r1, 0x1f   " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing sra: src0( 0xd ), shamt = 1, result( 0x6 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "sra r1, r1, 0x1    " );
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
task init_sra_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) sra: src0( 0x1 ), shamt = 1, result( 0x0 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "sra r3, r1, 0x1    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

    // (Value Testing) sra: src0( 0x80000000 ), shamt = 31, result( 0xffffffff )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
    inst( "sra r3, r1, 0x1f    " );
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
// Test Case: sra basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "sra basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sra_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sra bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "sra bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sra_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sra value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "sra value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sra_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sra stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "sra stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_sra_long;
  run_test;
end
`VC_TEST_CASE_END


