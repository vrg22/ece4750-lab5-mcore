//========================================================================
// Test Cases for bltz instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_bltz_basic;
begin

  // In jump/branch tests, a bitvector tracks the paths that are taken
  // when the jumps/branches are taken / not taken. The bitvector starts
  // at 32'b0, and we raise bits in the bitvector depending on which
  // paths we take. At the end of the test, we send the bitvector to the
  // sink to check whether we took the paths we expected to take.

  clear_mem;

  address( c_reset_vector );
  // Initialize bitvector
  inst( "addiu r5, r0, 0     ");
  inst( "mfc0  r3, mngr2proc "); init_src(  32'hfffffffe );
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "bltz  r3, [+7]      "); // goto id_a: -.
  inst( "addiu r5, r5, 0b1   "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
                                 //             |
  // id_a:                       //             |
  inst( "nop                 "); // <- - - - - -'
  inst( "bltz  r0, [+7]      "); // goto id_b: (branch not taken)
  inst( "addiu r5, r5, 0b10  ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");

  // id_b:
  inst( "nop                 ");
  inst( "bltz  r3, [+7]      "); // goto id_c: -.
  inst( "addiu r5, r5, 0b100 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
  inst( "nop                 "); //             |
                                 //             |
  // id_c:                       //             |
  inst( "nop                 "); // <- - - - - -'
  inst( "mtc0  r5, proc2mngr "); init_sink( 32'b0010 );
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_bltz_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  //-------------------------------------------
  // (Bypass) Testing bltz:
  // src0_nops( 0 )
  //-------------------------------------------

  // load the bitvector
  inst( "addiu r5, r0, 0   ");

  // load the sources
  inst( "mfc0 r1, mngr2proc"); init_src( 32'd0 );

  // forward branch, we assume not taken
  inst( "bltz r1, [+2]" );
  inst( "addiu r5, r5, 0b1" );

  // check bitvector
  inst( "mtc0 r5, proc2mngr"); init_sink( 32'b1 );

  //-------------------------------------------
  // (Bypass) Testing bltz:
  // src0_nops( 1 )
  //-------------------------------------------

  // load the bitvector
  inst( "addiu r5, r0, 0   ");

  // load the sources
  inst( "mfc0 r1, mngr2proc"); init_src( 32'd0 );
  inst( "nop               ");

  // forward branch, we assume not taken
  inst( "bltz r1, [+2]" );
  inst( "addiu r5, r5, 0b1" );

  // check bitvector
  inst( "mtc0 r5, proc2mngr"); init_sink( 32'b1 );

  //-------------------------------------------
  // (Bypass) Testing bltz:
  // src0_nops( 2 )
  //-------------------------------------------

  // load the bitvector
  inst( "addiu r5, r0, 0   ");

  // load the sources
  inst( "mfc0 r1, mngr2proc"); init_src( 32'd0 );
  inst( "nop               ");
  inst( "nop               ");

  // forward branch, we assume not taken
  inst( "bltz r1, [+2]" );
  inst( "addiu r5, r5, 0b1" );

  // check bitvector
  inst( "mtc0 r5, proc2mngr"); init_sink( 32'b1 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_bltz_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Branch tests
  //----------------------------------------------------------------------

  //-------------------------------------------
  // (Value) Testing bltz:
  // src0( -1 )
  // - Test that branch is taken
  //-------------------------------------------

    // load the bitvector
    inst( "addiu r5, r0, 0   ");

    // load the sources
    inst( "mfc0 r1, mngr2proc"); init_src( -1 ); // src0
    inst( "mfc0 r3, mngr2proc"); init_src( -1 ); // helper

    // forward branch, if taken goto 2:
    inst( "bltz r1, [+4]" );
    inst( "addiu r5, r5, 0b1" );

    // 1: goto 3:
    inst( "addiu r5, r5, 0b10" );
    inst( "bltz r3, [+3]" );

    // 2: backward branch, if taken goto 1:
    inst( "addiu r5, r5, 0b100" );
    inst( "bltz r1, [-3]" );

    // 3: check bitvector
    inst( "mtc0 r5, proc2mngr"); init_sink( 32'b110 );

  //-------------------------------------------
  // (Value) Testing bltz:
  // src0( 0x80000000 )          //largest negative 32-bit value        //CHECK!
  // - Test that branch is taken
  //-------------------------------------------

    // load the bitvector
    inst( "addiu r5, r0, 0   ");

    // load the sources
    inst( "mfc0 r1, mngr2proc"); init_src( -2147483648 ); // src0          //0x80000000 = -2147483648 in decimal
    inst( "mfc0 r3, mngr2proc"); init_src( -1 ); // helper

    // forward branch, if taken goto 2:
    inst( "bltz r1, [+4]" );
    inst( "addiu r5, r5, 0b1" );

    // 1: goto 3:
    inst( "addiu r5, r5, 0b10" );
    inst( "bltz r3, [+3]" );

    // 2: backward branch, if taken goto 1:
    inst( "addiu r5, r5, 0b100" );
    inst( "bltz r1, [-3]" );

    // 3: check bitvector
    inst( "mtc0 r5, proc2mngr"); init_sink( 32'b110 );

  //-------------------------------------------
  // (Value) Testing bltz:
  // src0( 0 )
  // - Test that branch is NOT taken
  //-------------------------------------------

    // load the bitvector
    inst( "addiu r5, r0, 0   ");

    // load the sources
    inst( "mfc0 r1, mngr2proc"); init_src( 0 );  // src0
    inst( "mfc0 r3, mngr2proc"); init_src( -1 ); // helper

    // forward branch, if taken goto 2:
    inst( "bltz r1, [+4]" );
    inst( "addiu r5, r5, 0b1" );

    // 1: goto 3:
    inst( "addiu r5, r5, 0b10" );
    inst( "bltz r3, [+3]" );

    // 2: backward branch, if taken goto 1:
    inst( "addiu r5, r5, 0b100" );
    inst( "bltz r1, [-3]" );

    // 3: check bitvector
    inst( "mtc0 r5, proc2mngr"); init_sink( 32'b011 );

  //-------------------------------------------
  // (Value) Testing bltz:
  // src0( 1 )
  // - Test that branch is NOT taken
  //-------------------------------------------

    // load the bitvector
    inst( "addiu r5, r0, 0   ");

    // load the sources
    inst( "mfc0 r1, mngr2proc"); init_src( 1 ); // src0
    inst( "mfc0 r3, mngr2proc"); init_src( -1 ); // helper

    // forward branch, if taken goto 2:
    inst( "bltz r1, [+4]" );
    inst( "addiu r5, r5, 0b1" );

    // 1: goto 3:
    inst( "addiu r5, r5, 0b10" );
    inst( "bltz r3, [+3]" );

    // 2: backward branch, if taken goto 1:
    inst( "addiu r5, r5, 0b100" );
    inst( "bltz r1, [-3]" );

    // 3: check bitvector
    inst( "mtc0 r5, proc2mngr"); init_sink( 32'b011 );

  //-------------------------------------------
  // (Value) Testing bltz:
  // src0( 0x7fffffff )                   //Largest Positive Value      //CHECK!
  // - Test that branch is NOT taken
  //-------------------------------------------

    // load the bitvector
    inst( "addiu r5, r0, 0   ");

    // load the sources
    inst( "mfc0 r1, mngr2proc"); init_src( 2147483647 ); // src0              //0x7fffffff = 2147483647 in decimal
    inst( "mfc0 r3, mngr2proc"); init_src( -1 ); // helper

    // forward branch, if taken goto 2:
    inst( "bltz r1, [+4]" );
    inst( "addiu r5, r5, 0b1" );

    // 1: goto 3:
    inst( "addiu r5, r5, 0b10" );
    inst( "bltz r3, [+3]" );

    // 2: backward branch, if taken goto 1:
    inst( "addiu r5, r5, 0b100" );
    inst( "bltz r1, [-3]" );

    // 3: check bitvector
    inst( "mtc0 r5, proc2mngr"); init_sink( 32'b011 );

  //----------------------------------------------------------------------
  // Test that there is no branch delay slot
  //----------------------------------------------------------------------

  inst( "mfc0 r1, mngr2proc  " ); init_src( -32'd1 );
  inst( "addu r2, r0, r0     " );
  inst( "bltz r1, [+5]       " ); // br -.
  inst( "addu r2, r2, r1     " ); //     |
  inst( "addu r2, r2, r1     " ); //     |
  inst( "addu r2, r2, r1     " ); //     |
  inst( "addu r2, r2, r1     " ); //     |
  inst( "addu r2, r2, r1     " ); // < - '
  inst( "addu r2, r2, r1     " );
  inst( "mtc0 r2, proc2mngr  " ); init_sink( -32'd2 );

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_bltz_long;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Test backwards walk (back to back branch taken)
  //----------------------------------------------------------------------

  inst( "mfc0  r1, mngr2proc  "); init_src( -32'd1 );
  for ( idx = 0; idx < 10; idx = idx + 1 ) begin
    inst( "bltz   r1,     [+13]  ");
    inst( "mtc0  r0, proc2mngr  "); // we don't expect a message here
    inst( "nop                  ");
    inst( "mtc0  r1, proc2mngr  "); init_sink( -32'd1 );
    inst( "bltz   r1, [+10]  ");
    inst( "bltz   r1, [-2]   "); // goto two above
    inst( "bltz   r1, [-1]   "); // goto one above
    inst( "bltz   r1, [-1]   "); // goto one above
    inst( "bltz   r1, [-1]   "); // goto one above
    inst( "bltz   r1, [-1]   "); // goto one above
    inst( "bltz   r1, [-1]   "); // goto one above
    inst( "bltz   r1, [-1]   "); // goto one above
    inst( "bltz   r1, [-1]   "); // goto one above
    inst( "bltz   r1, [-1]   "); // goto one above
  end

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask


//------------------------------------------------------------------------
// Test Case: bltz basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "bltz basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_bltz_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: bltz bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "bltz bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_bltz_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: bltz value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "bltz value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_bltz_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: bltz stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "bltz stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_bltz_long;
  run_test;
end
`VC_TEST_CASE_END




