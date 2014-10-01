//========================================================================
// Test Cases for andi instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_andi_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000005 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "andi r3, r2, 0x0004 " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000004 );

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

task init_andi_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // Test "andi", 0xd (reg) & 0xb (imm) = 0x9 (result), dest bypass in X

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "andi r2, r1, 0xb    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h9 );

  // Test "andi", 0xd (reg) & 0xa (imm) = 0x8 (result), dest bypass in M

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "andi r2, r1, 0xa    " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h8 );

  // Test "andi", 0xd (reg) & 0x9 (imm) = 0x9 (result), dest bypass in W

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "andi r2, r1, 0x9    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h9 );

  // Test "andi", 0xd (reg) & 0xb (imm) = 0x9 (result), src0 bypass in X

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "andi r2, r1, 0xb    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h9 );

  // Test "andi", 0xd (reg) & 0xa (imm) = 0x8 (result), src0 bypass in M

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "andi r2, r1, 0xa    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h8 );

  // Test "andi", 0xd (reg) & 0x9 (imm) = 0x9 (result), src0 bypass in W

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "andi r2, r1, 0x9    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h9 );

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

task init_andi_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // Test "andi", 0x0 (reg) & 0x0 (imm) = 0x0 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h0 );
  inst( "andi r2, r1, 0x0      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h0 );

  // Test "andi", 0x1 (reg) & 0x1 (imm) = 0x1 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h1 );
  inst( "andi r2, r1, 0x1      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h1 );

  // Test "andi", 0x3 (reg) & 0x7 (imm) = 0x3 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h3 );
  inst( "andi r2, r1, 0x7      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h3 );

  // Test "andi", 0x00000000 (reg) & 0x8000 (imm) = 0x00000000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000000 );
  inst( "andi r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00000000 );

  // Test "andi", 0x80000000 (reg) & 0x0000 (imm) = 0x00000000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h80000000 );
  inst( "andi r2, r1, 0x0000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00000000 );

  // Test "andi", 0x80008000 (reg) & 0x8000 (imm) = 0x00008000 (result)                  

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h80008000 );
  inst( "andi r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00008000 );

  // Test "andi", 0x00001234 (reg) & 0x7fff (imm) = 0x00001234 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00001234 );
  inst( "andi r2, r1, 0x7fff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00001234 );

  // Test "andi", 0x7ffffedc (reg) & 0xf3a2 (imm) = 0xf280 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7ffffedc );
  inst( "andi r2, r1, 0xf3a2   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'hf280 );

  // Test "andi", 0x7fffffff (reg) & 0x7fff (imm) = 0x7fff (result)					

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7fffffff );
  inst( "andi r2, r1, 0x7fff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7fff );

  // Test "andi", 0x827d9c21 (reg) & 0xac0d (imm) = 0x8c01 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h827d9c21 );
  inst( "andi r2, r1, 0xac0d   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h8c01 );

  // Test "andi", 0x7fffffff (reg) & 0x8000 (imm) = 0x8000 (result)                

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7fffffff );
  inst( "andi r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h8000 );

  // Test "andi", 0x11111111 (reg) & 0xffff (imm) = 0x1111 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h11111111 );
  inst( "andi r2, r1, 0xffff  " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h1111 );

  // Test "andi", 0x40c0d090 (reg) & 0xf083 (imm) = 0xd080 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h40c0d090  );
  inst( "andi r2, r1, 0xf083   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'hd080 );

  // Test "andi", 0xffffffff (reg) & 0xffff (imm) = 0xffff (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'hffffffff );
  inst( "andi r2, r1, 0xffff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'hffff );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // Test "andi", 0xd (reg) & 0xb (imm) = 0x9 (result), src0 == dest

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'hd );
  inst( "andi r1, r1, 0xb      " );
  inst( "mtc0 r1, proc2mngr     " ); init_sink( 32'h9 );

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
task init_andi_long;
begin
  clear_mem;

  address( c_reset_vector );

  // create a long sequence of instructions to test stalls and bubbles
  for ( idx = 0; idx < 100; idx = idx + 1 ) begin

    // Test "andi", 0x00000001 (reg) & 0x0001 (imm) = 0x00000001 (result)

    inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000001 );
    inst( "andi r2, r1, 0x0001   " );
    inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00000001 );

    // Test "andi", 0x00000003 (reg) & 0x0007 (imm) = 0x00000003 (result)

    inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000003 );
    inst( "andi r2, r1, 0x0007   " );
    inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00000003 );

  end

  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );

end
endtask


//------------------------------------------------------------------------
// Test Case: andi basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "andi basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_andi_basic;
  run_test;
end
`VC_TEST_CASE_END


// add more test cases here

//------------------------------------------------------------------------
// Test Case: andi bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "andi bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_andi_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: andi value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "andi value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_andi_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: andi stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "andi stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_andi_long;
  run_test;
end
`VC_TEST_CASE_END






































