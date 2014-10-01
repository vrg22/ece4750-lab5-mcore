//========================================================================
// Test Cases for xori instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_xori_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000005 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "xori r3, r2, 0x0002  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000007 );

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

task init_xori_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // Test "xori", 0xd (reg) ^ 0xb (imm) = 0x4 (result), dest bypass in X

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "xori r2, r1, 0xb    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h4 );

  // Test "xori", 0xd (reg) ^ 0xa (imm) = 0x7 (result), dest bypass in M

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "xori r2, r1, 0xa    " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h7 );

  // Test "xori", 0xd (reg) ^ 0x9 (imm) = 0x4 (result), dest bypass in W

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "xori r2, r1, 0x9    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h4 );

  // Test "xori", 0xd (reg) ^ 0xb (imm) = 0x6 (result), src0 bypass in X

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "xori r2, r1, 0xb    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h6 );

  // Test "xori", 0xd (reg) ^ 0xa (imm) = 0x7 (result), src0 bypass in M

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "xori r2, r1, 0xa    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h7 );

  // Test "xori", 0xd (reg) ^ 0x9 (imm) = 0x4 (result), src0 bypass in W

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "xori r2, r1, 0x9    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h4 );

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

task init_xori_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // Test "xori", 0x0 (reg) ^ 0x0 (imm) = 0x0 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h0 );
  inst( "xori r2, r1, 0x0      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h0 );

  // Test "xori", 0x1 (reg) ^ 0x1 (imm) = 0x0 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h1 );
  inst( "xori r2, r1, 0x1      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h0 );

  // Test "xori", 0x3 (reg) ^ 0x7 (imm) = 0x4 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h3 );
  inst( "xori r2, r1, 0x7      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h4 );

  // Test "xori", 0x00000000 (reg) ^ 0x8000 (imm) = 0x8000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000000 );
  inst( "xori r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h8000 );

  // Test "xori", 0x80000000 (reg) ^ 0x0000 (imm) = 0x80000000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h80000000 );
  inst( "xori r2, r1, 0x0000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h80000000 );

  // Test "xori", 0x80008000 (reg) ^ 0x8000 (imm) = 0x80000000 (result)                  

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h80008000 );
  inst( "xori r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h80000000 );

  // Test "xori", 0x7ffffedc (reg) ^ 0xf3a2 (imm) = 0x7fff0d7e (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7ffffedc );
  inst( "xori r2, r1, 0xf3a2   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7fff0d7e );

  // Test "xori", 0x7fffffff (reg) ^ 0x7fff (imm) = 0x7fff8000 (result)         

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7fffffff );
  inst( "xori r2, r1, 0x7fff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7fff8000 );

  // Test "xori", 0x827d9c21 (reg) ^ 0xac0d (imm) = 0x827d302c (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h827d9c21 );
  inst( "xori r2, r1, 0xac0d   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h827d302c );

  // Test "xori", 0x7fffffff (reg) ^ 0x8000 (imm) = 0x7fff7fff (result)                

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7fffffff );
  inst( "xori r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7fff7fff );

  // Test "xori", 0x11111111 (reg) ^ 0xffff (imm) = 0x1111eeee (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h11111111 );
  inst( "xori r2, r1, 0xffff  " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h1111eeee );

  // Test "xori", 0x40c0d090 (reg) ^ 0xf083 (imm) = 0x40C02013 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h40c0d090  );
  inst( "xori r2, r1, 0xf083   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'hd080 );

  // Test "xori", 0xffffffff (reg) ^ 0xffff (imm) = 0xffff0000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'hffffffff );
  inst( "xori r2, r1, 0xffff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'hffff0000 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // Test "xori", 0xd (reg) ^ 0xb (imm) = 0x6 (result), src0 == dest

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'hd );
  inst( "xori r1, r1, 0xb      " );
  inst( "mtc0 r1, proc2mngr     " ); init_sink( 32'h6 );

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
task init_xori_long;
begin
  clear_mem;

  address( c_reset_vector );

  // create a long sequence of instructions to test stalls and bubbles
  for ( idx = 0; idx < 100; idx = idx + 1 ) begin

    // Test "xori", 0x00000001 (reg) ^ 0x0001 (imm) = 0x00000000 (result)

    inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000001 );
    inst( "xori r2, r1, 0x0001   " );
    inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00000000 );

    // Test "xori", 0x00000003 (reg) ^ 0x0007 (imm) = 0x00000004 (result)

    inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000003 );
    inst( "xori r2, r1, 0x0007   " );
    inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00000004 );

  end

  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );

end
endtask


//------------------------------------------------------------------------
// Test Case: xori basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "xori basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_xori_basic;
  run_test;
end
`VC_TEST_CASE_END


// add more test cases here

//------------------------------------------------------------------------
// Test Case: xori bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "xori bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_xori_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: xori value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "xori value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_xori_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: xori stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "xori stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_xori_long;
  run_test;
end
`VC_TEST_CASE_END




