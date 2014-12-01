//========================================================================
// 1-Core Processor-Cache-Network
//========================================================================

`ifndef LAB5_MCORE_PROC_CACHE_NET_ALT_V
`define LAB5_MCORE_PROC_CACHE_NET_ALT_V
`define LAB4_NET_NUM_PORTS_4

`include "vc-mem-msgs.v"
`include "vc-trace.v"

`include "lab2-proc-PipelinedProcAlt.v"
`include "lab3-mem-BlockingCacheAlt.v"
`include "lab5-mcore-MemNet.v"

module lab5_mcore_ProcCacheNetAlt
#(
  parameter p_icache_nbytes = 256,
  parameter p_dcache_nbytes = 256,

  parameter p_num_cores     = 4,

  // local params not meant to be set from outside

  parameter c_opaque_nbits  = 8,
  parameter c_addr_nbits    = 32,
  parameter c_data_nbits    = 32,
  parameter c_cacheline_nbits = 128,

  parameter o = c_opaque_nbits,
  parameter a = c_addr_nbits,
  parameter d = c_data_nbits,
  parameter l = c_cacheline_nbits,

  parameter c_memreq_nbits  = `VC_MEM_REQ_MSG_NBITS(o,a,l),
  parameter c_memresp_nbits = `VC_MEM_RESP_MSG_NBITS(o,l)
)
(
  input  logic                       clk,
  input  logic                       reset,

  // proc0 manager ports

  input  logic [31:0]                proc0_from_mngr_msg,
  input  logic                       proc0_from_mngr_val,
  output logic                       proc0_from_mngr_rdy,

  output logic [31:0]                proc0_to_mngr_msg,
  output logic                       proc0_to_mngr_val,
  input  logic                       proc0_to_mngr_rdy,

  output logic [c_memreq_nbits-1:0]  memreq0_msg,
  output logic                       memreq0_val,
  input  logic                       memreq0_rdy,

  input  logic [c_memresp_nbits-1:0] memresp0_msg,
  input  logic                       memresp0_val,
  output logic                       memresp0_rdy,

  output logic [c_memreq_nbits-1:0]  memreq1_msg,
  output logic                       memreq1_val,
  input  logic                       memreq1_rdy,

  input  logic [c_memresp_nbits-1:0] memresp1_msg,
  input  logic                       memresp1_val,
  output logic                       memresp1_rdy,

  output logic                       stats_en
);

  //----------------------------------------------------------------------
  // Processor-Cache connection wires
  //----------------------------------------------------------------------

  // Instruction Cache Refill Network - Memory Wires

  logic [c_memreq_nbits-1:0]  icache_refill_req_net_out_msg;
  logic [c_memreq_nbits-1:0]  icache_refill_req_net_out_val;
  logic [c_memreq_nbits-1:0]  icache_refill_req_net_out_rdy;
  logic [c_memresp_nbits-1:0] icache_refill_resp_net_in_msg;
  logic [c_memresp_nbits-1:0] icache_refill_resp_net_in_val;
  logic [c_memresp_nbits-1:0] icache_refill_resp_net_in_rdy;


  // Instruction Cache - Instruction Cache Refill Network Wires

  logic [`VC_PORT_PICK_NBITS(l,p_num_ports)-1:0] icache_refill_req_net_in_msg;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] icache_refill_req_net_in_val;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] icache_refill_req_net_in_rdy;
  logic [`VC_PORT_PICK_NBITS(l,p_num_ports)-1:0] icache_refill_resp_net_out_msg;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] icache_refill_resp_net_out_val;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] icache_refill_resp_net_out_rdy;

  // Instruction Cache - Processor Wires

  logic [`VC_PORT_PICK_NBITS(l,p_num_ports)-1:0] imemreq_msg;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] imemreq_val;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] imemreq_rdy;
  logic [`VC_PORT_PICK_NBITS(l,p_num_ports)-1:0] imemresp_msg;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] imemresp_val;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] imemresp_rdy;

  // Data Cache Refill Network - Memory Wires

  logic [c_memreq_nbits-1:0]  dcache_refill_req_net_out_msg;
  logic [c_memreq_nbits-1:0]  dcache_refill_req_net_out_val;
  logic [c_memreq_nbits-1:0]  dcache_refill_req_net_out_rdy;
  logic [c_memresp_nbits-1:0] dcache_refill_resp_net_in_msg;
  logic [c_memresp_nbits-1:0] dcache_refill_resp_net_in_val;
  logic [c_memresp_nbits-1:0] dcache_refill_resp_net_in_rdy;

  // Data Cache - Data Cache Refill Network Wires

  logic [`VC_PORT_PICK_NBITS(l,p_num_ports)-1:0] dcache_refill_req_net_in_msg;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dcache_refill_req_net_in_val;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dcache_refill_req_net_in_rdy;
  logic [`VC_PORT_PICK_NBITS(l,p_num_ports)-1:0] dcache_refill_resp_net_out_msg;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dcache_refill_resp_net_out_val;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dcache_refill_resp_net_out_rdy;

  // Data Cache - Data Cache Network Wires

  logic [`VC_PORT_PICK_NBITS(l,p_num_ports)-1:0] dcache_req_net_out_msg;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dcache_req_net_out_val;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dcache_req_net_out_rdy;
  logic [`VC_PORT_PICK_NBITS(l,p_num_ports)-1:0] dcache_resp_net_in_msg;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dcache_resp_net_in_val;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dcache_resp_net_in_rdy;

  // Data Cache - Processor Wires

  logic [`VC_PORT_PICK_NBITS(l,p_num_ports)-1:0] dmemreq_msg;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dmemreq_val;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dmemreq_rdy;
  logic [`VC_PORT_PICK_NBITS(l,p_num_ports)-1:0] dmemresp_msg;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dmemresp_val;
  logic [`VC_PORT_PICK_NBITS(1,p_num_ports)-1:0] dmemresp_rdy; 


// ---------------------------------------------------------------------


  // Instruction Cache Refill Network

  lab5_mcore_MemNet #(c_opaque_nbits, c_addr_nbits, c_data_nbits, p_num_cores, 1) icache_refill_net
  (
    .clk          (clk),
    .reset        (reset),
    .req_in_msg   (icache_refill_req_net_in_msg),
    .req_in_val   (icache_refill_req_net_in_val),
    .req_in_rdy   (icache_refill_req_net_in_rdy),
    .resp_out_msg (icache_refill_resp_net_out_msg),
    .resp_out_val (icache_refill_resp_net_out_val),
    .resp_out_rdy (icache_refill_resp_net_out_rdy),
    .req_out_msg  (icache_refill_req_net_out_msg),
    .req_out_val  (icache_refill_req_net_out_val),
    .req_out_rdy  (icache_refill_req_net_out_rdy),
    .resp_in_msg  (icache_refill_resp_net_in_msg),
    .resp_in_val  (icache_refill_resp_net_in_val),
    .resp_in_rdy  (icache_refill_resp_net_in_rdy)
  );

  // Data Cache Refill Network

  lab5_mcore_MemNet #(c_opaque_nbits, c_addr_nbits, c_data_nbits, p_num_cores, 0) dcache_refill_net
  (
    .clk          (clk),
    .reset        (reset),
    .req_in_msg   (dcache_refill_req_net_in_msg),
    .req_in_val   (dcache_refill_req_net_in_val),
    .req_in_rdy   (dcache_refill_req_net_in_rdy),
    .resp_out_msg (dcache_refill_resp_net_out_msg),
    .resp_out_val (dcache_refill_resp_net_out_val),
    .resp_out_rdy (dcache_refill_resp_net_out_rdy),
    .req_out_msg  (dcache_refill_req_net_out_msg),
    .req_out_val  (dcache_refill_req_net_out_val),
    .req_out_rdy  (dcache_refill_req_net_out_rdy),
    .resp_in_msg  (dcache_refill_resp_net_in_msg),
    .resp_in_val  (dcache_refill_resp_net_in_val),
    .resp_in_rdy  (dcache_refill_resp_net_in_rdy)
  );

  // Data Cache Network

  lab5_mcore_MemNet #(c_opaque_nbits, c_addr_nbits, c_data_nbits, p_num_cores, 1) dcache_net
  (
    .clk          (clk),
    .reset        (reset),
    .req_in_msg   (dmemreq_msg),
    .req_in_val   (dmemreq_val),
    .req_in_rdy   (dmemreq_rdy), 
    .resp_out_msg (dmemresp_msg),
    .resp_out_val (dmemresp_val),
    .resp_out_rdy (dmemresp_rdy),
    .req_out_msg  (dcache_req_net_out_msg),
    .req_out_val  (dcache_req_net_out_msg),
    .req_out_rdy  (dcache_req_net_out_msg),
    .resp_in_msg  (dcache_resp_net_in_msg),
    .resp_in_val  (dcache_resp_net_in_msg),
    .resp_in_rdy  (dcache_resp_net_in_msg)
  );

  // Pipelined Processor and Set-Associative Instruction/Data Cache Generation

  genvar i;
  generate
  for ( i = 0; i < p_num_cores; i = i + 1 ) begin: CORES
    if ( i == 0 ) begin: PROC

      // processor core 0

      lab2_proc_PipelinedProcAlt #(1,i) CORES[i]
      (
        .clk            (clk),
        .reset          (reset),
        
        .imemreq_msg    (imemreq_msg[`VC_PORT_PICK_FIELD(l,i]),
        .imemreq_val    (imemreq_val[`VC_PORT_PICK_FIELD(1,i]),
        .imemreq_rdy    (imemreq_rdy[`VC_PORT_PICK_FIELD(1,i]),

        .imemresp_msg   (imemresp_msg[`VC_PORT_PICK_FIELD(l,i]),
        .imemresp_val   (imemresp_val[`VC_PORT_PICK_FIELD(1,i]),
        .imemresp_rdy   (imemresp_rdy[`VC_PORT_PICK_FIELD(1,i]),

        .dmemreq_msg    (dmemreq_msg[`VC_PORT_PICK_FIELD(l,i]),
        .dmemreq_val    (dmemreq_val[`VC_PORT_PICK_FIELD(1,i]),
        .dmemreq_rdy    (dmemreq_rdy[`VC_PORT_PICK_FIELD(1,i]),

        .dmemresp_msg   (dmemresp_msg[`VC_PORT_PICK_FIELD(l,i]),
        .dmemresp_val   (dmemresp_val[`VC_PORT_PICK_FIELD(1,i]),
        .dmemresp_rdy   (dmemresp_rdy[`VC_PORT_PICK_FIELD(1,i]),

        .from_mngr_msg  (proc0_from_mngr_msg),
        .from_mngr_val  (proc0_from_mngr_val),
        .from_mngr_rdy  (proc0_from_mngr_rdy),

        .to_mngr_val    (proc0_to_mngr_val),
        .to_mngr_msg    (proc0_to_mngr_msg),
        .to_mngr_rdy    (proc0_to_mngr_rdy),

        .stats_en(stats_en)
      );

      // instruction cache 0

      lab3_mem_BlockingCacheAlt #(p_icache_nbytes, 0, o) CORES[i]
      (
        .clk            (clk),
        .reset          (reset),
        .cachereq_msg   (imemreq_msg[`VC_PORT_PICK_FIELD(l,i]),
        .cachereq_val   (imemreq_val[`VC_PORT_PICK_FIELD(1,i]),
        .cachereq_rdy   (imemreq_rdy[`VC_PORT_PICK_FIELD(1,i]),
        .cacheresp_msg  (imemresp_msg[`VC_PORT_PICK_FIELD(l,i]),
        .cacheresp_val  (imemresp_val[`VC_PORT_PICK_FIELD(1,i]),
        .cacheresp_rdy  (imemresp_rdy[`VC_PORT_PICK_FIELD(1,i]),
        .memreq_msg     (icache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(l,i]),
        .memreq_val     (icache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memreq_rdy     (icache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memresp_msg    (icache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(l,i]),
        .memresp_val    (icache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memresp_rdy    (icache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(1,i])
      );

      // data cache 0

      lab3_mem_BlockingCacheAlt #(p_icache_nbytes, 0, o) CORES[i]
      (
        .clk            (clk),
        .reset          (reset),
        .cachereq_msg   (dmemreq_msg[`VC_PORT_PICK_FIELD(l,i]),
        .cachereq_val   (dmemreq_val[`VC_PORT_PICK_FIELD(1,i]),
        .cachereq_rdy   (dmemreq_rdy[`VC_PORT_PICK_FIELD(1,i]),
        .cacheresp_msg  (dmemresp_msg[`VC_PORT_PICK_FIELD(l,i]),
        .cacheresp_val  (dmemresp_val[`VC_PORT_PICK_FIELD(1,i]),
        .cacheresp_rdy  (dmemresp_rdy[`VC_PORT_PICK_FIELD(1,i]),
        .memreq_msg     (dcache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(l,i]),
        .memreq_val     (dcache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memreq_rdy     (dcache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memresp_msg    (dcache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(l,i]),
        .memresp_val    (dcache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memresp_rdy    (dcache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(1,i])
      );

    end
    else begin: PROC

      // processor core i

      lab2_proc_PipelinedProcAlt #(1,i) CORES[i]
      (
        .clk            (clk),
        .reset          (reset),
        
        .imemreq_msg    (imemreq_msg[`VC_PORT_PICK_FIELD(l,i]),
        .imemreq_val    (imemreq_val[`VC_PORT_PICK_FIELD(1,i]),
        .imemreq_rdy    (imemreq_rdy[`VC_PORT_PICK_FIELD(1,i]),

        .imemresp_msg   (imemresp_msg[`VC_PORT_PICK_FIELD(l,i]),
        .imemresp_val   (imemresp_val[`VC_PORT_PICK_FIELD(1,i]),
        .imemresp_rdy   (imemresp_rdy[`VC_PORT_PICK_FIELD(1,i]),

        .dmemreq_msg    (dmemreq_msg[`VC_PORT_PICK_FIELD(l,i]),
        .dmemreq_val    (dmemreq_val[`VC_PORT_PICK_FIELD(1,i]),
        .dmemreq_rdy    (dmemreq_rdy[`VC_PORT_PICK_FIELD(1,i]),

        .dmemresp_msg   (dmemresp_msg[`VC_PORT_PICK_FIELD(l,i]),
        .dmemresp_val   (dmemresp_val[`VC_PORT_PICK_FIELD(1,i]),
        .dmemresp_rdy   (dmemresp_rdy[`VC_PORT_PICK_FIELD(1,i]),

        .from_mngr_msg  (),
        .from_mngr_val  (),
        .from_mngr_rdy  (),

        .to_mngr_val    (),
        .to_mngr_msg    (),
        .to_mngr_rdy    (),

        .stats_en(stats_en)
      );

      // instruction cache i

      lab3_mem_BlockingCacheAlt #(p_icache_nbytes, 0, o) CORES[i]
      (
        .clk            (clk),
        .reset          (reset),
        .cachereq_msg   (imemreq_msg[`VC_PORT_PICK_FIELD(l,i]),
        .cachereq_val   (imemreq_val[`VC_PORT_PICK_FIELD(1,i]),
        .cachereq_rdy   (imemreq_rdy[`VC_PORT_PICK_FIELD(1,i]),
        .cacheresp_msg  (imemresp_msg[`VC_PORT_PICK_FIELD(l,i]),
        .cacheresp_val  (imemresp_val[`VC_PORT_PICK_FIELD(1,i]),
        .cacheresp_rdy  (imemresp_rdy[`VC_PORT_PICK_FIELD(1,i]),
        .memreq_msg     (icache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(l,i]),
        .memreq_val     (icache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memreq_rdy     (icache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memresp_msg    (icache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(l,i]),
        .memresp_val    (icache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memresp_rdy    (icache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(1,i])
      );

      // data cache i

      lab3_mem_BlockingCacheAlt #(p_icache_nbytes, 0, o) CORES[i]
      (
        .clk            (clk),
        .reset          (reset),
        .cachereq_msg   (dmemreq_msg[`VC_PORT_PICK_FIELD(l,i]),
        .cachereq_val   (dmemreq_val[`VC_PORT_PICK_FIELD(1,i]),
        .cachereq_rdy   (dmemreq_rdy[`VC_PORT_PICK_FIELD(1,i]),
        .cacheresp_msg  (dmemresp_msg[`VC_PORT_PICK_FIELD(l,i]),
        .cacheresp_val  (dmemresp_val[`VC_PORT_PICK_FIELD(1,i]),
        .cacheresp_rdy  (dmemresp_rdy[`VC_PORT_PICK_FIELD(1,i]),
        .memreq_msg     (dcache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(l,i]),
        .memreq_val     (dcache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memreq_rdy     (dcache_refill_req_net_in_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memresp_msg    (dcache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(l,i]),
        .memresp_val    (dcache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(1,i]),
        .memresp_rdy    (dcache_refill_resp_net_out_msg[`VC_PORT_PICK_FIELD(1,i])
      );

    end
  end
  endgenerate


  // Connecting global memory ports to refill ports

  assign memreq0_msg                    =   icache_refill_req_net_out_msg;
  assign memreq0_val                    =   icache_refill_req_net_out_val;,
  assign icache_refill_req_net_out_rdy  =   memreq0_rdy;
  assign icache_refill_resp_net_in_msg  =   memresp0_msg;
  assign icache_refill_resp_net_in_val  =   memresp0_val;
  assign memresp0_rdy                   =   icache_refill_resp_net_in_rdy;
  assign memreq1_msg                    =   dcache_refill_req_net_out_msg;
  assign memreq1_val                    =   dcache_refill_req_net_out_val;,
  assign dcache_refill_req_net_out_rdy  =   memreq1_rdy;
  assign dcache_refill_resp_net_in_msg  =   memresp1_msg;
  assign dcache_refill_resp_net_in_val  =   memresp1_val;
  assign memresp1_rdy                   =   dcache_refill_resp_net_in_rdy;




  /*****************************    LINE TRACING    *************************************/

  `VC_TRACE_BEGIN
  begin
    uncomment following for line tracing

    proc0.trace( trace_str );
    icache0.trace( trace_str );

    vc_trace.append_str( trace_str, "|" );

    proc1.trace( trace_str );
    icache1.trace( trace_str );

    vc_trace.append_str( trace_str, "|" );

    proc2.trace( trace_str );
    icache2.trace( trace_str );

    vc_trace.append_str( trace_str, "|" );

    proc3.trace( trace_str );
    icache3.trace( trace_str );

    vc_trace.append_str( trace_str, "|" );

    dcache0.trace( trace_str );
    dcache1.trace( trace_str );
    dcache2.trace( trace_str );
    dcache3.trace( trace_str );

  end
  `VC_TRACE_END

endmodule



`endif /* LAB5_MCORE_PROC_CACHE_NET_ALT_V */
