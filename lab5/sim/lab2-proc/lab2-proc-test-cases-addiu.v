//========================================================================
// Test Cases for addiu instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_addiu_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000005 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "addiu r3, r2, 0x0004 " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000009 );

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

task init_addiu_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // Test "addiu", 0xd (reg) + 0xb (imm) = 0x18 (result), dest bypass in X

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "addiu r2, r1, 0xb    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h18 );

  // Test "addiu", 0xd (reg) + 0xa (imm) = 0x17 (result), dest bypass in M

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "addiu r2, r1, 0xa    " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h17 );

  // Test "addiu", 0xd (reg) + 0x9 (imm) = 0x16 (result), dest bypass in W

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "addiu r2, r1, 0x9    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h16 );

  // Test "addiu", 0xd (reg) + 0xb (imm) = 0x18 (result), src0 bypass in X

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "addiu r2, r1, 0xb    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h18 );

  // Test "addiu", 0xd (reg) + 0xa (imm) = 0x17 (result), src0 bypass in M

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "addiu r2, r1, 0xa    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h17 );

  // Test "addiu", 0xd (reg) + 0x9 (imm) = 0x16 (result), src0 bypass in W

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "addiu r2, r1, 0x9    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h16 );

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

task init_addiu_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // Test "addiu", 0x0 (reg) + 0x0 (imm) = 0x0 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h0 );
  inst( "addiu r2, r1, 0x0      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h0 );

  // Test "addiu", 0x1 (reg) + 0x1 (imm) = 0x2 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h1 );
  inst( "addiu r2, r1, 0x1      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h2 );

  // Test "addiu", 0x3 (reg) + 0x7 (imm) = 0xa (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h3 );
  inst( "addiu r2, r1, 0x7      " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'ha );

  // Test "addiu", 0x00000000 (reg) + 0x8000 (imm) = 0xffff8000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000000 );
  inst( "addiu r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'hffff8000 );

  // Test "addiu", 0x80000000 (reg) + 0x0000 (imm) = 0x80000000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h80000000 );
  inst( "addiu r2, r1, 0x0000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h80000000 );

  // Test "addiu", 0x80000000 (reg) + 0x8000 (imm) = 0x7fff8000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h80000000 );
  inst( "addiu r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7fff8000 );

  // Test "addiu", 0x00000000 (reg) + 0x7fff (imm) = 0x00007fff (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000000 );
  inst( "addiu r2, r1, 0x7fff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00007fff );

  // Test "addiu", 0x7fffffff (reg) + 0x0000 (imm) = 0x7fffffff (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7fffffff );
  inst( "addiu r2, r1, 0x0000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7fffffff );

  // Test "addiu", 0x7fffffff (reg) + 0x7fff (imm) = 0x80007ffe (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7fffffff );
  inst( "addiu r2, r1, 0x7fff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h80007ffe );

  // Test "addiu", 0x80000000 (reg) + 0x7fff (imm) = 0x80007fff (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h80000000 );
  inst( "addiu r2, r1, 0x7fff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h80007fff );

  // Test "addiu", 0x7fffffff (reg) + 0x8000 (imm) = 0x7fff7fff (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h7fffffff );
  inst( "addiu r2, r1, 0x8000   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h7fff7fff );

  // Test "addiu", 0x00000000 (reg) + 0xffff (imm) = 0xffffffff (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000000 );
  inst( "addiu r2, r1, 0xffff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'hffffffff );

  // Test "addiu", 0xffffffff (reg) + 0x0001 (imm) = 0x00000000 (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'hffffffff );
  inst( "addiu r2, r1, 0x0001   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00000000 );

  // Test "addiu", 0xffffffff (reg) + 0xffff (imm) = 0xfffffffe (result)

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'hffffffff );
  inst( "addiu r2, r1, 0xffff   " );
  inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'hfffffffe );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // Test "addiu", 0xd (reg) + 0xb (imm) = 0x18 (result), src0 == dest

  inst( "mfc0 r1, mngr2proc     " ); init_src(  32'hd );
  inst( "addiu r1, r1, 0xb      " );
  inst( "mtc0 r1, proc2mngr     " ); init_sink( 32'h18 );

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
task init_addiu_long;
begin
  clear_mem;

  address( c_reset_vector );

  // create a long sequence of instructions to test stalls and bubbles
  for ( idx = 0; idx < 100; idx = idx + 1 ) begin

    // Test "addiu", 0x00000001 (reg) + 0x0001 (imm) = 0x00000002 (result)

    inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000001 );
    inst( "addiu r2, r1, 0x0001   " );
    inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h00000002 );

    // Test "addiu", 0x00000003 (reg) + 0x0007 (imm) = 0x0000000a (result)

    inst( "mfc0 r1, mngr2proc     " ); init_src(  32'h00000003 );
    inst( "addiu r2, r1, 0x0007   " );
    inst( "mtc0 r2, proc2mngr     " ); init_sink( 32'h0000000a );

  end

  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );
  inst( "nop                    " );

end
endtask

//------------------------------------------------------------------------
// Test Case: addiu basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "addiu basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addiu_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addiu bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "addiu bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addiu_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addiu value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "addiu value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addiu_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addiu stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "addiu stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_addiu_long;
  run_test;
end
`VC_TEST_CASE_END

