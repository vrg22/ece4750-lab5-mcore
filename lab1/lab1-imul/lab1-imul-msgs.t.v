//========================================================================
// lab1-imul-msgs Unit Tests
//========================================================================

`include "lab1-imul-msgs.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "lab1-imul-msgs" )

  //----------------------------------------------------------------------
  // Test GCD Request Message
  //----------------------------------------------------------------------

  // Declare request message variable

  lab1_imul_req_msg_t req_msg;

  // Helper task

  task t1
  (
    input [31:0] a,
    input [31:0] b
  );
  begin
    req_msg.a = a;
    req_msg.b = b;
    #1;
    `VC_TEST_NET( req_msg.a, a );
    `VC_TEST_NET( req_msg.b, b );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "lab1_imul_req_msg_t" )
  begin

    #21;

    t1( 32'h0a0a0a0a, 32'h0b0b0b0b );
    t1( 32'h0c0c0c0c, 32'h0d0d0d0d );
    t1( 32'h0e0e0e0e, 32'h0f0f0f0f );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test GCD Response Message
  //----------------------------------------------------------------------

  // Declare response message variable

  lab1_imul_resp_msg_t resp_msg;

  // Helper task

  task t2
  (
    input [31:0] result
  );
  begin
    resp_msg.result = result;
    #1;
    `VC_TEST_NET( resp_msg, result );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 2, "lab1_imul_resp_msg_t" )
  begin

    #21;

    t2( 32'h0a0a0b0b );
    t2( 32'h0c0c0d0d );
    t2( 32'h0e0e0f0f );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

