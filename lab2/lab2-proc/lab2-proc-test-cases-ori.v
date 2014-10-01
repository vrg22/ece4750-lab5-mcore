//========================================================================
// Test Cases for ori instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_ori_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000021 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "ori r3, r2, 0x0003   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000023 );

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask


// add more test vectors here

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_ori_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // Test "ori", 0xd (reg) | 0xb (imm) = 0xf (result), dest bypass in X

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "ori r2, r1, 0xb    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hf );

  // Test "ori", 0xd (reg) | 0xa (imm) = 0xF (result), dest bypass in M

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "ori r2, r1, 0xa    " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hF );

  // Test "ori", 0xd (reg) | 0x9 (imm) = 0xd (result), dest bypass in W

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "ori r2, r1, 0x9    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hd );

  // Test "ori", 0xd (reg) | 0xb (imm) = 0xf (result), src0 bypass in X

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "ori r2, r1, 0xb    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hf );

  // Test "ori", 0xd (reg) | 0xa (imm) = 0xf (result), src0 bypass in M

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "ori r2, r1, 0xa    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hf );

  // Test "ori", 0xd (reg) | 0x9 (imm) = 0xd (result), src0 bypass in W

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "ori r2, r1, 0x9    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hd );

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

task init_ori_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // Test "ori", 0x0 (reg) | 0x0 (imm) = 0x0 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h0 );
  inst( "ori r2, r1, 0x0      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h0 );

  // Test "ori", 0x1 (reg) | 0x1 (imm) = 0x1 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h1 );
  inst( "ori r2, r1, 0x1      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h1 );

  // Test "ori", 0x3 (reg) | 0x7 (imm) = 0x7 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h3 );
  inst( "ori r2, r1, 0x7      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7 );

  // Test "ori", 0x00000000 (reg) | 0x8000 (imm) = 0x8000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000000 );
  inst( "ori r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h8000 );

  // Test "ori", 0x80000000 (reg) | 0x0000 (imm) = 0x80000000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h80000000 );
  inst( "ori r2, r1, 0x0000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h80000000 );

  // Test "ori", 0x80008000 (reg) | 0x8000 (imm) = 0x80008000 (result)                  

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h80008000 );
  inst( "ori r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h80008000 );

  // Test "ori", 0x00001234 (reg) | 0x7fff (imm) = 0x7fff (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00001234 );
  inst( "ori r2, r1, 0x7fff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7fff );

  // Test "ori", 0x7ffffedc (reg) | 0xf3a2 (imm) = 0x7ffffffe (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7ffffedc );
  inst( "ori r2, r1, 0xf3a2   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7ffffffe );

  // Test "ori", 0x7fffffff (reg) | 0x7fff (imm) = 0x7fff (result)         

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7fffffff );
  inst( "ori r2, r1, 0x7fff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7fffffff );

  // Test "ori", 0x827d9c21 (reg) | 0xac0d (imm) = 0x827dbc2d (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h827d9c21 );
  inst( "ori r2, r1, 0xac0d   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h827dbc2d );

  // Test "ori", 0x7fffffff (reg) | 0x8000 (imm) = 0x7fffffff (result)                

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7fffffff );
  inst( "ori r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7fffffff );

  // Test "ori", 0x11111111 (reg) | 0xffff (imm) = 0x1111ffff (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h11111111 );
  inst( "ori r2, r1, 0xffff  " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h1111ffff );

  // Test "ori", 0x40c0d090 (reg) | 0xf083 (imm) = 0x40c0f093 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h40c0d090  );
  inst( "ori r2, r1, 0xf083   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h40c0f093 );

  // Test "ori", 0xffffffff (reg) | 0xffff (imm) = 0xffffffff (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'hffffffff );
  inst( "ori r2, r1, 0xffff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'hffffffff );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // Test "ori", 0xd (reg) | 0xb (imm) = 0xf (result), src0 == dest

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'hd );
  inst( "ori r1, r1, 0xb      " );
  inst( "mtc0 r1, proc2mngr     " ); init_sink( 32'hf );

  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );

end
endtask


//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------
integer idx;
task init_ori_long;
begin
  clear_mem;

  address( c_reset_vector );

  // create a long sequence of instructions to test stalls and bubbles
  for ( idx = 0; idx < 100; idx = idx + 1 ) begin

    // Test "ori", 0x00000001 (reg) | 0x0001 (imm) = 0x00000001 (result)

    inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000001 );
    inst( "ori r2, r1, 0x0001   " );
    inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00000001 );

    // Test "ori", 0x00000003 (reg) | 0x0007 (imm) = 0x00000007 (result)

    inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000003 );
    inst( "ori r2, r1, 0x0007   " );
    inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00000007 );

  end

  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );

end
endtask

//------------------------------------------------------------------------
// Test Case: ori basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "ori basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_ori_basic;
  run_test;
end
`VC_TEST_CASE_END


// add more test cases here

//------------------------------------------------------------------------
// Test Case: ori bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "ori bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_ori_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: ori value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "ori value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_ori_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: ori stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "ori stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_ori_long;
  run_test;
end
`VC_TEST_CASE_END


