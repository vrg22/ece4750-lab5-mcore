//========================================================================
// 1-Core Processor-Cache-Network
//========================================================================

`ifndef LAB5_MCORE_PROC_CACHE_NET_BASE_V
`define LAB5_MCORE_PROC_CACHE_NET_BASE_V

`include "vc-mem-msgs.v"
`include "vc-trace.v"

`include "lab2-proc-PipelinedProcAlt.v"
`include "lab3-mem-BlockingCacheAlt.v"

module lab5_mcore_ProcCacheNetBase
#(
  parameter p_icache_nbytes = 256,
  parameter p_dcache_nbytes = 256,

  // local params not meant to be set from outside

  parameter c_opaque_nbits = 8,
  parameter c_addr_nbits = 32,
  parameter c_data_nbits = 32,
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


 // Processor-Cache wires

  logic [c_memreq_nbits-1:0] imemreq_msg;
  logic                      imemreq_val;
  logic                      imemreq_rdy;
  logic [c_memreq_nbits-1:0] dmemreq_msg;
  logic                      dmemreq_val;
  logic                      dmemreq_rdy;

  // Pipelined Processor 

  lab2_proc_PipelinedProcAlt #(1,0) proc0
  (
    .clk            (clk),
    .reset          (reset),

    .imemreq_msg    (imemreq_msg),
    .imemreq_val    (imemreq_val),
    .imemreq_rdy    (imemreq_rdy),

    .imemresp_msg   (imemresp_msg),
    .imemresp_val   (imemresp_val),
    .imemresp_rdy   (imemresp_rdy),

    .dmemreq_msg    (dmemreq_msg),
    .dmemreq_val    (dmemreq_val),
    .dmemreq_rdy    (dmemreq_rdy),

    .dmemresp_msg   (dmemresp_msg),
    .dmemresp_val   (dmemresp_val),
    .dmemresp_rdy   (dmemresp_rdy),

    .from_mngr_msg  (proc0_from_mngr_msg),
    .from_mngr_val  (proc0_from_mngr_val),
    .from_mngr_rdy  (proc0_from_mngr_rdy),

    .to_mngr_val    (proc0_to_mngr_val),
    .to_mngr_msg    (proc0_to_mngr_msg),
    .to_mngr_rdy    (proc0_to_mngr_rdy),

    .stats_en(stats_en)
  );


  // Instruction Cache

  lab3-mem-BlockingCacheAlt #(p_icache_nbytes,1) icache0
  (
    .clk            (clk),
    .reset          (reset),

    .cachereq_msg   (imemreq_msg),
    .cachereq_val   (imemreq_val),
    .cachereq_rdy   (imemreq_rdy),

    .cacheresp_msg  (imemresp_msg),
    .cacheresp_val  (imemresp_val),
    .cacheresp_rdy  (imemresp_rdy),    

    .memreq_msg     (memreq0_msg),
    .memreq_val     (memreq0_val),
    .memreq_rdy     (memreq0_rdy),

    .memresp_msg    (memresp0_msg),
    .memresp_val    (memresp0_val),
    .memresp_rdy    (memresp0_rdy),    
  );


  // Data Cache

  lab3-mem-BlockingCacheAlt #(p_icache_nbytes,1) dcache0
  (
    .clk            (clk),
    .reset          (reset),

    .cachereq_msg   (dmemreq_msg),
    .cachereq_val   (dmemreq_val),
    .cachereq_rdy   (dmemreq_rdy),

    .cacheresp_msg  (dmemresp_msg),
    .cacheresp_val  (dmemresp_val),
    .cacheresp_rdy  (dmemresp_rdy),    

    .memreq_msg     (memreq1_msg),
    .memreq_val     (memreq1_val),
    .memreq_rdy     (memreq1_rdy),

    .memresp_msg    (memresp1_msg),
    .memresp_val    (memresp1_val),
    .memresp_rdy    (memresp1_rdy),    
  );



  /**********************************    LINE TRACING    ************************************/


  `VC_TRACE_BEGIN
  begin
    // uncomment following for line tracing

    // proc0.trace( trace_str );
    // vc_trace.append_str( trace_str, "|" );
    // icache0.trace( trace_str );
    // dcache0.trace( trace_str );
  end
  `VC_TRACE_END

endmodule



`endif /* LAB5_MCORE_PROC_CACHE_NET_BASE_V */
