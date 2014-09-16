//=========================================================================
// 5-Stage Bypass Pipelined Processor
//=========================================================================

`ifndef LAB2_PROC_PIPELINED_PROC_ALT_V
`define LAB2_PROC_PIPELINED_PROC_ALT_V

`include "vc-mem-msgs.v"
`include "lab2-proc-PipelinedProcAltCtrl.v"
`include "lab2-proc-PipelinedProcAltDpath.v"
`define LAB2_PROC_FROM_MNGR_MSG_NBITS 32
`define LAB2_PROC_TO_MNGR_MSG_NBITS 32

module lab2_proc_PipelinedProcAlt
#(
  parameter p_num_cores = 1,
  parameter p_core_id   = 0
)
(
  input  logic                                      clk,
  input  logic                                      reset,

  // Instruction Memory Request Port

  output logic [`VC_MEM_REQ_MSG_NBITS(8,32,32)-1:0] imemreq_msg,
  output logic                                      imemreq_val,
  input  logic                                      imemreq_rdy,

  // Instruction Memory Response Port

  input  logic [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]   imemresp_msg,
  input  logic                                      imemresp_val,
  output logic                                      imemresp_rdy,

  // Data Memory Request Port

  output logic [`VC_MEM_REQ_MSG_NBITS(8,32,32)-1:0] dmemreq_msg,
  output logic                                      dmemreq_val,
  input  logic                                      dmemreq_rdy,

  // Data Memory Response Port

  input  logic [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]   dmemresp_msg,
  input  logic                                      dmemresp_val,
  output logic                                      dmemresp_rdy,

  // From mngr streaming port

  input  logic [`LAB2_PROC_FROM_MNGR_MSG_NBITS-1:0] from_mngr_msg,
  input  logic                                      from_mngr_val,
  output logic                                      from_mngr_rdy,

  // To mngr streaming port

  output logic [`LAB2_PROC_TO_MNGR_MSG_NBITS-1:0]   to_mngr_msg,
  output logic                                      to_mngr_val,
  input  logic                                      to_mngr_rdy,

  // Stats enable output

  output logic                                      stats_en
);

  //----------------------------------------------------------------------
  // Control Unit
  //----------------------------------------------------------------------

  lab2_proc_PipelinedProcAltCtrl ctrl
  (
    .clk                    (clk),
    .reset                  (reset)
  );
  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  lab2_proc_PipelinedProcAltDpath
  #(
    .p_num_cores  (p_num_cores),
    .p_core_id    (p_core_id)
  )
  dpath
  (
    .clk                     (clk),
    .reset                   (reset)
  );

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  pisa_InstTasks pisa();

  logic [`VC_TRACE_NBITS_TO_NCHARS(32)*8-1:0] f_str;
  `VC_TRACE_BEGIN
  begin


  end
  `VC_TRACE_END

endmodule

`endif

