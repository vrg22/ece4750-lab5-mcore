//========================================================================
// Test Harness for Memory Request/Response Network
//========================================================================

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelayUnorderedSink.v"
`include "vc-test.v"
`include "vc-trace.v"
`include "vc-net-msgs.v"
`include "vc-mem-msgs.v"
`include "vc-param-utils.v"
`include "lab5-mcore-MemNet.v"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_mem_opaque_nbits   = 4,
  parameter p_mem_addr_nbits     = 32,
  parameter p_mem_data_nbits     = 32,
  parameter p_num_ports          = 4
)
(
  input  logic        clk,
  input  logic        reset,
  input  logic [31:0] src_max_delay,
  input  logic [31:0] sink_max_delay,
  output logic        done
);

  // Shorter names

  localparam o = p_mem_opaque_nbits;
  localparam a = p_mem_addr_nbits;
  localparam d = p_mem_data_nbits;

  localparam ns = $clog2(p_num_ports);
  localparam no = 4;

  localparam rq = `VC_MEM_REQ_MSG_NBITS(o,a,d);
  localparam rs = `VC_MEM_RESP_MSG_NBITS(o,d);

  // Test network wires

  logic [p_num_ports-1:0]    req_in_val;
  logic [p_num_ports-1:0]    req_in_rdy;
  logic [p_num_ports*rq-1:0] req_in_msg;

  logic [p_num_ports-1:0]    req_out_val;
  logic [p_num_ports-1:0]    req_out_rdy;
  logic [p_num_ports*rq-1:0] req_out_msg;

  logic [p_num_ports-1:0]    resp_in_val;
  logic [p_num_ports-1:0]    resp_in_rdy;
  logic [p_num_ports*rs-1:0] resp_in_msg;

  logic [p_num_ports-1:0]    resp_out_val;
  logic [p_num_ports-1:0]    resp_out_rdy;
  logic [p_num_ports*rs-1:0] resp_out_msg;

  //----------------------------------------------------------------------
  // Generate loop for source/sink
  //----------------------------------------------------------------------

  genvar i;

  generate
  for ( i = 0; i < p_num_ports; i = i + 1 ) begin: SRC_SINK_INIT

    // request source/sinks

    // local wires for the source and sink iteration

    logic            req_src_val;
    logic            req_src_rdy;
    logic [rq-1:0]   req_src_msg;
    logic            req_src_done;

    logic            req_sink_val;
    logic            req_sink_rdy;
    logic [rq-1:0]   req_sink_msg;

    logic            req_sink_done;

    // connect the local wires to the wide network ports

    assign req_in_val[`VC_PORT_PICK_FIELD(1,i)] = req_src_val;
    assign req_in_msg[`VC_PORT_PICK_FIELD(rq,i)] = req_src_msg;
    assign req_src_rdy = req_in_rdy[`VC_PORT_PICK_FIELD(1,i)];

    assign req_sink_val = req_out_val[`VC_PORT_PICK_FIELD(1,i)];
    assign req_sink_msg = req_out_msg[`VC_PORT_PICK_FIELD(rq,i)];
    assign req_out_rdy[`VC_PORT_PICK_FIELD(1,i)] = req_sink_rdy;

    vc_TestRandDelaySource#(rq) req_src
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (src_max_delay),
      .val        (req_src_val),
      .rdy        (req_src_rdy),
      .msg        (req_src_msg),
      .done       (req_src_done)
    );

    // We use an unordered sink because the messages can come out of order

    vc_TestRandDelayUnorderedSink#(rq) req_sink
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (sink_max_delay),
      .val        (req_sink_val),
      .rdy        (req_sink_rdy),
      .msg        (req_sink_msg),
      .done       (req_sink_done)
    );

    // response source/sinks

    // local wires for the source and sink iteration

    logic            resp_src_val;
    logic            resp_src_rdy;
    logic [rs-1:0]   resp_src_msg;
    logic            resp_src_done;

    logic            resp_sink_val;
    logic            resp_sink_rdy;
    logic [rs-1:0]   resp_sink_msg;

    logic            resp_sink_done;

    // connect the local wires to the wide network ports

    assign resp_in_val[`VC_PORT_PICK_FIELD(1,i)] = resp_src_val;
    assign resp_in_msg[`VC_PORT_PICK_FIELD(rs,i)] = resp_src_msg;
    assign resp_src_rdy = resp_in_rdy[`VC_PORT_PICK_FIELD(1,i)];

    assign resp_sink_val = resp_out_val[`VC_PORT_PICK_FIELD(1,i)];
    assign resp_sink_msg = resp_out_msg[`VC_PORT_PICK_FIELD(rs,i)];
    assign resp_out_rdy[`VC_PORT_PICK_FIELD(1,i)] = resp_sink_rdy;

    vc_TestRandDelaySource#(rs) resp_src
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (src_max_delay),
      .val        (resp_src_val),
      .rdy        (resp_src_rdy),
      .msg        (resp_src_msg),
      .done       (resp_src_done)
    );

    // We use an unordered sink because the messages can come out of order

    vc_TestRandDelayUnorderedSink#(rs) resp_sink
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (sink_max_delay),
      .val        (resp_sink_val),
      .rdy        (resp_sink_rdy),
      .msg        (resp_sink_msg),
      .done       (resp_sink_done)
    );


  end
  endgenerate

  //----------------------------------------------------------------------
  // Memory Request/Response Network under test
  //----------------------------------------------------------------------

  lab5_mcore_MemNet
  #(
    .p_mem_opaque_nbits (p_mem_opaque_nbits),
    .p_mem_addr_nbits   (p_mem_addr_nbits),
    .p_mem_data_nbits   (p_mem_data_nbits),
    .p_num_ports        (p_num_ports)
  )
  net
  (
    .clk      (clk),
    .reset    (reset),

    .req_in_val   (req_in_val),
    .req_in_rdy   (req_in_rdy),
    .req_in_msg   (req_in_msg),

    .req_out_val  (req_out_val),
    .req_out_rdy  (req_out_rdy),
    .req_out_msg  (req_out_msg),

    .resp_out_val  (resp_out_val),
    .resp_out_rdy  (resp_out_rdy),
    .resp_out_msg  (resp_out_msg),

    .resp_in_val (resp_in_val),
    .resp_in_rdy (resp_in_rdy),
    .resp_in_msg (resp_in_msg)
  );

  // Accumulate done signals from all sources and sinks

  integer j;
  always @(*) begin
    done       = 1'b1;
    for ( j = 0; j < p_num_ports; j = j + 1 ) begin
      `VC_GEN_CALL_4( done = done & SRC_SINK_INIT, j, req_src_done );
      `VC_GEN_CALL_4( done = done & SRC_SINK_INIT, j, req_sink_done );
      `VC_GEN_CALL_4( done = done & SRC_SINK_INIT, j, resp_src_done );
      `VC_GEN_CALL_4( done = done & SRC_SINK_INIT, j, resp_sink_done );
    end
  end

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  `VC_TRACE_BEGIN
  begin

    for ( j = 0; j < p_num_ports; j = j + 1 ) begin
      if ( j != 0 )
        vc_trace.append_str( trace_str, "|" );

      `VC_GEN_CALL_4( SRC_SINK_INIT, j, req_src.trace( trace_str ) );
    end

    vc_trace.append_str( trace_str, " > " );

    for ( j = 0; j < p_num_ports; j = j + 1 ) begin
      if ( j != 0 )
        vc_trace.append_str( trace_str, "|" );

      `VC_GEN_CALL_4( SRC_SINK_INIT, j, req_sink.trace( trace_str ) );
    end

    vc_trace.append_str( trace_str, "|!|" );

    for ( j = 0; j < p_num_ports; j = j + 1 ) begin
      if ( j != 0 )
        vc_trace.append_str( trace_str, "|" );

      `VC_GEN_CALL_4( SRC_SINK_INIT, j, resp_src.trace( trace_str ) );
    end

    vc_trace.append_str( trace_str, " > " );

    for ( j = 0; j < p_num_ports; j = j + 1 ) begin
      if ( j != 0 )
        vc_trace.append_str( trace_str, "|" );

      `VC_GEN_CALL_4( SRC_SINK_INIT, j, resp_sink.trace( trace_str ) );
    end

  end
  `VC_TRACE_END

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( "lab5-mcore-MemNet" )

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  localparam c_mem_opaque_nbits   = 4;
  localparam c_mem_addr_nbits     = 32;
  localparam c_mem_data_nbits     = 32;
  localparam c_num_ports          = 4;

  // Shorter names

  localparam o = c_mem_opaque_nbits;
  localparam a = c_mem_addr_nbits;
  localparam d = c_mem_data_nbits;

  localparam ns = $clog2(c_num_ports);
  localparam no = 4;

  localparam rq = `VC_MEM_REQ_MSG_NBITS(o,a,d);
  localparam rs = `VC_MEM_RESP_MSG_NBITS(o,d);

  localparam c_req_net_msg_nbits  = `VC_NET_MSG_NBITS(rq,no,ns);
  localparam c_resp_net_msg_nbits = `VC_NET_MSG_NBITS(rs,no,ns);

  localparam nrq = c_req_net_msg_nbits;
  localparam nrs = c_resp_net_msg_nbits;

  logic        th_reset = 1'b1;
  logic [31:0] th_src_max_delay;
  logic [31:0] th_sink_max_delay;
  logic        th_done;

  logic [10:0] th_req_src_index  [10:0];
  logic [10:0] th_req_sink_index [10:0];
  logic [10:0] th_resp_src_index  [10:0];
  logic [10:0] th_resp_sink_index [10:0];

  TestHarness #(o,a,d,c_num_ports,nrq,nrs) th
  (
    .clk            (clk),
    .reset          (th_reset),
    .src_max_delay  (th_src_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .done           (th_done)
  );

  // Helper task to initialize source/sink delays
  integer i;
  task init_rand_delays
  (
    input logic [31:0] src_max_delay,
    input logic [31:0] sink_max_delay
  );
  begin
    // we also clear the src/sink indexes and contents
    for ( i = 0; i < c_num_ports; i = i + 1 ) begin
      th_req_src_index[i] = 0;
      th_req_sink_index[i] = 0;
      th_resp_src_index[i] = 0;
      th_resp_sink_index[i] = 0;
      `VC_GEN_CALL_4( th.SRC_SINK_INIT, i,
                      req_src.src.m[0] = 'hx );
      `VC_GEN_CALL_4( th.SRC_SINK_INIT, i,
                      resp_src.src.m[0] = 'hx );
      `VC_GEN_CALL_4( th.SRC_SINK_INIT, i,
                      req_sink.sink.m[0] = 'hx );
      `VC_GEN_CALL_4( th.SRC_SINK_INIT, i,
                      resp_sink.sink.m[0] = 'hx );
    end
    th_src_max_delay  = src_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask


  task init_req_src
  (
    input logic [31:0]    port,

    input logic [nrq-1:0] msg
  );
  begin

    `VC_GEN_CALL_4( th.SRC_SINK_INIT, port,
                    req_src.src.m[th_req_src_index[port]] = msg );

    `VC_GEN_CALL_4( th.SRC_SINK_INIT, port,
                    req_src.src.m[th_req_src_index[port] + 1] = 'hx );

    // increment the index
    th_req_src_index[port] = th_req_src_index[port] + 1;

  end
  endtask

  task init_resp_src
  (
    input logic [31:0]    port,

    input logic [nrs-1:0] msg
  );
  begin

    `VC_GEN_CALL_4( th.SRC_SINK_INIT, port,
                    resp_src.src.m[th_resp_src_index[port]] = msg );

    `VC_GEN_CALL_4( th.SRC_SINK_INIT, port,
                    resp_src.src.m[th_resp_src_index[port] + 1] = 'hx );

    // increment the index
    th_resp_src_index[port] = th_resp_src_index[port] + 1;

  end
  endtask

  task init_req_sink
  (
    input logic [31:0]    port,

    input logic [nrq-1:0] msg
  );
  begin

    `VC_GEN_CALL_4( th.SRC_SINK_INIT, port,
                    req_sink.sink.m[th_req_sink_index[port]] = msg );

    `VC_GEN_CALL_4( th.SRC_SINK_INIT, port,
                    req_sink.sink.m[th_req_sink_index[port] + 1] = 'hx );

    // increment the index
    th_req_sink_index[port] = th_req_sink_index[port] + 1;

  end
  endtask

  task init_resp_sink
  (
    input logic [31:0]    port,

    input logic [nrs-1:0] msg
  );
  begin

    `VC_GEN_CALL_4( th.SRC_SINK_INIT, port,
                    resp_sink.sink.m[th_resp_sink_index[port]] = msg );

    `VC_GEN_CALL_4( th.SRC_SINK_INIT, port,
                    resp_sink.sink.m[th_resp_sink_index[port] + 1] = 'hx );

    // increment the index
    th_resp_sink_index[port] = th_resp_sink_index[port] + 1;

  end
  endtask

  // Helper task to initalize memory requests and responses

  logic [rq-1:0] th_req_src_msg;
  logic [rq-1:0] th_req_sink_msg;
  logic [rs-1:0] th_resp_sink_msg;
  logic [rs-1:0] th_resp_src_msg;

  task init_req
  (
    input logic [ns-1:0]                                  src_idx,
    input logic [ns-1:0]                                  dest_idx,
    input logic [`VC_MEM_REQ_MSG_TYPE_NBITS(o,a,d)-1:0]   memreq_type,
    input logic [`VC_MEM_REQ_MSG_OPAQUE_NBITS(o,a,d)-1:0] memreq_opaque,
    input logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,a,d)-1:0]   memreq_addr,
    input logic [`VC_MEM_REQ_MSG_LEN_NBITS(o,a,d)-1:0]    memreq_len,
    input logic [`VC_MEM_REQ_MSG_DATA_NBITS(o,a,d)-1:0]   memreq_data

  );
  begin
    th_req_src_msg[`VC_MEM_REQ_MSG_TYPE_FIELD(o,a,d)]   = memreq_type;
    th_req_src_msg[`VC_MEM_REQ_MSG_OPAQUE_FIELD(o,a,d)] = memreq_opaque;
    th_req_src_msg[`VC_MEM_REQ_MSG_ADDR_FIELD(o,a,d)]   = memreq_addr;
    th_req_src_msg[`VC_MEM_REQ_MSG_LEN_FIELD(o,a,d)]    = memreq_len;
    th_req_src_msg[`VC_MEM_REQ_MSG_DATA_FIELD(o,a,d)]   = memreq_data;

    th_req_sink_msg[`VC_MEM_REQ_MSG_TYPE_FIELD(o,a,d)]   = memreq_type;
    // response opaque field is concatenated with the source information
    th_req_sink_msg[`VC_MEM_REQ_MSG_OPAQUE_FIELD(o,a,d)] =
                                      { src_idx, memreq_opaque[o-ns-1:0] };
    th_req_sink_msg[`VC_MEM_REQ_MSG_ADDR_FIELD(o,a,d)]   = memreq_addr;
    th_req_sink_msg[`VC_MEM_REQ_MSG_LEN_FIELD(o,a,d)]    = memreq_len;
    th_req_sink_msg[`VC_MEM_REQ_MSG_DATA_FIELD(o,a,d)]   = memreq_data;

    init_req_src(  src_idx,  th_req_src_msg );
    init_req_sink( dest_idx, th_req_sink_msg );
  end
  endtask

  logic [ns-1:0]                                 proc_idx;

  task init_resp
  (
    input logic [ns-1:0]                                 src_idx,
    input logic [`VC_MEM_RESP_MSG_TYPE_NBITS(o,d)-1:0]   memresp_type,
    input logic [`VC_MEM_RESP_MSG_OPAQUE_NBITS(o,d)-1:0] memresp_opaque,
    input logic [`VC_MEM_RESP_MSG_LEN_NBITS(o,d)-1:0]    memresp_len,
    input logic [`VC_MEM_RESP_MSG_DATA_NBITS(o,d)-1:0]   memresp_data

  );
  begin
    th_resp_src_msg[`VC_MEM_RESP_MSG_TYPE_FIELD(o,d)]   = memresp_type;
    th_resp_src_msg[`VC_MEM_RESP_MSG_OPAQUE_FIELD(o,d)] = memresp_opaque;
    th_resp_src_msg[`VC_MEM_RESP_MSG_LEN_FIELD(o,d)]    = memresp_len;
    th_resp_src_msg[`VC_MEM_RESP_MSG_DATA_FIELD(o,d)]   = memresp_data;

    // extract the proc index and the proc opaque fields
    proc_idx = memresp_opaque[o-1 -: ns ];

    th_resp_sink_msg[`VC_MEM_RESP_MSG_TYPE_FIELD(o,d)]   = memresp_type;
    th_resp_sink_msg[`VC_MEM_RESP_MSG_OPAQUE_FIELD(o,d)] = memresp_opaque;
    th_resp_sink_msg[`VC_MEM_RESP_MSG_LEN_FIELD(o,d)]    = memresp_len;
    th_resp_sink_msg[`VC_MEM_RESP_MSG_DATA_FIELD(o,d)]   = memresp_data;

    init_resp_src(  src_idx,  th_resp_src_msg );
    init_resp_sink( proc_idx, th_resp_sink_msg );
  end
  endtask

  // Helper local params

  localparam rqr  = `VC_MEM_REQ_MSG_TYPE_READ;
  localparam rqw  = `VC_MEM_REQ_MSG_TYPE_WRITE;

  localparam rsr = `VC_MEM_RESP_MSG_TYPE_READ;
  localparam rsw = `VC_MEM_RESP_MSG_TYPE_WRITE;

  // Common dataset

  task init_common;
  begin
    // Clear the memory

    #5;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    // Initialize Port


    //       src dst type opq   addr          len   data
    init_req( 0,  1, rqr, 4'h2, 32'h001f0512, 2'd0, 32'hcafebabe );
    init_req( 1,  1, rqr, 4'h9, 32'h201f0510, 2'd0, 32'h88888abe );
    init_req( 1,  0, rqr, 4'hf, 32'h011f0501, 2'd1, 32'hc0febabe );
    init_req( 2,  3, rqr, 4'h2, 32'h009f0532, 2'd0, 32'h999beffe );
    init_req( 2,  3, rqw, 4'h1, 32'h00100533, 2'd0, 32'hcafebeef );
    init_req( 3,  2, rqr, 4'h0, 32'h001ff527, 2'd2, 32'hbeefbabe );
    init_req( 3,  0, rqr, 4'hc, 32'h00000507, 2'd0, 32'hf00cafee );
    init_req( 0,  2, rqr, 4'hd, 32'h00100523, 2'd0, 32'hccccccbe );
    init_req( 1,  0, rqw, 4'he, 32'h00108501, 2'd1, 32'hccaaccfe );
    init_req( 2,  2, rqr, 4'h8, 32'h002f2220, 2'd0, 32'hbabecafe );
    init_req( 3,  0, rqr, 4'h7, 32'h00222502, 2'd0, 32'hcacafeca );


    //        src type opq   len   data
    init_resp( 1, rsr, 4'h0, 2'd0, 32'hxxxxxxxx );
    init_resp( 0, rsr, 4'h4, 2'd0, 32'hdeadbeef );
    init_resp( 0, rsw, 4'h0, 2'd0, 32'hbeefxxxx );
    init_resp( 3, rsr, 4'h8, 2'd0, 32'hxxxxf00b );
    init_resp( 2, rsw, 4'ha, 2'd1, 32'hxxxxxxxx );
    init_resp( 2, rsr, 4'h7, 2'd0, 32'hxe110e00 );
    init_resp( 1, rsr, 4'hc, 2'd0, 32'h44558900 );
    init_resp( 2, rsw, 4'h3, 2'd1, 32'hx2xx1xxx );
    init_resp( 0, rsr, 4'h6, 2'd2, 32'hx33110xx );
    init_resp( 2, rsr, 4'h5, 2'd0, 32'haxxxxxxx );
    init_resp( 0, rsr, 4'h1, 2'd0, 32'hbxxbbbxx );
    init_resp( 3, rsr, 4'he, 2'd0, 32'hxcafexxx );
    init_resp( 3, rsr, 4'h2, 2'd0, 32'hcafebabe );

  end
  endtask

  // Helper task to run test

  task run_test;
  begin
    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.vc_trace.cycles < 1500) ) begin
      th.display_trace();
      #10;
    end

    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // no delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "no delays" )
  begin
    init_rand_delays( 0, 0 );

    init_common;

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // rand delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "rand delays" )
  begin
    init_rand_delays( 3, 5 );

    init_common;

    run_test;
  end
  `VC_TEST_CASE_END


  `VC_TEST_SUITE_END
endmodule

