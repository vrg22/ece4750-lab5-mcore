//=========================================================================
// 5-Stage Base Pipelined Processor
//=========================================================================

`ifndef LAB2_PROC_PIPELINED_PROC_BASE_V
`define LAB2_PROC_PIPELINED_PROC_BASE_V

`include "vc-mem-msgs.v"
`include "vc-DropUnit.v"
`include "lab2-proc-PipelinedProcBaseCtrl.v"
`include "lab2-proc-PipelinedProcBaseDpath.v"
`include "pisa-inst.v"
`include "vc-queues.v"
`include "vc-trace.v"

`define LAB2_PROC_FROM_MNGR_MSG_NBITS 32
`define LAB2_PROC_TO_MNGR_MSG_NBITS 32

module lab2_proc_PipelinedProcBase
(
  input  logic                                      clk,
  input  logic                                      reset,

  // Instruction Memory Request Port

  output logic [`VC_MEM_REQ_MSG_NBITS(8,32,32)-1:0] imemreq_msg,
  output logic                                      imemreq_val,
  input  logic                                      imemreq_rdy,

  // Instruction Memory Response Port

  input  logic[`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]    imemresp_msg,
  input  logic                                      imemresp_val,
  output logic                                      imemresp_rdy,

  // Data Memory Request Port

  output logic [`VC_MEM_REQ_MSG_NBITS(8,32,32)-1:0] dmemreq_msg,
  output logic                                      dmemreq_val,
  input  logic                                      dmemreq_rdy,

  // Data Memory Response Port

  input  logic[`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]    dmemresp_msg,
  input  logic                                      dmemresp_val,
  output logic                                      dmemresp_rdy,

  // From mngr streaming port

  input  logic[`LAB2_PROC_FROM_MNGR_MSG_NBITS-1:0]  from_mngr_msg,
  input  logic                                      from_mngr_val,
  output logic                                      from_mngr_rdy,

  // To mngr streaming port

  output logic [`LAB2_PROC_TO_MNGR_MSG_NBITS-1:0]   to_mngr_msg,
  output logic                                      to_mngr_val,
  input  logic                                      to_mngr_rdy

);

  localparam creq_nbits = `VC_MEM_REQ_MSG_NBITS(8,32,32);

  //----------------------------------------------------------------------
  // data mem req/resp
  //----------------------------------------------------------------------

  logic [31:0] dmemreq_msg_addr;
  logic [31:0] dmemreq_msg_data;
  logic [31:0] dmemresp_msg_data;

  logic [31:0] imemreq_msg_addr;

  // imereq_enq signals coming in from the ctrl unit
  logic [`VC_MEM_REQ_MSG_NBITS(8,32,32)-1:0] imemreq_enq_msg;
  logic                                      imemreq_enq_val;
  logic                                      imemreq_enq_rdy;

  // imemresp signals after the dropping unit

  logic                                    imemresp_val_drop;
  logic                                    imemresp_rdy_drop;

  // imemresp drop signal

  logic                                    imemresp_drop;

  // control signals (ctrl->dpath)

  logic [1:0]  pc_sel_F;
  logic        reg_en_F;
  logic        reg_en_D;
  logic        reg_en_X;
  logic        reg_en_M;
  logic        reg_en_W;
  logic [1:0]  op1_sel_D;
  logic [3:0]  alu_fn_X;
  logic        wb_result_sel_M;
  logic [4:0]  rf_waddr_W;
  logic        rf_wen_W;

  // status signals (dpath->ctrl)

  logic [31:0] inst_D;
  logic        br_cond_eq_X;

  logic val_PF;
  assign val_PF = imemreq_val && imemreq_rdy;


  //----------------------------------------------------------------------
  // Pack Memory Request Messages
  //----------------------------------------------------------------------

  vc_MemReqMsgPack#(8,32,32) imemreq_msg_pack
  (
    .type_  (`VC_MEM_REQ_MSG_TYPE_READ),
    .opaque (8'b0),
    .addr   (imemreq_msg_addr),
    .len    (2'd0),
    .data   (32'bx),
    .msg    (imemreq_enq_msg)
  );

  vc_MemReqMsgPack#(8,32,32) dmemreq_msg_pack
  (
    .type_  (`VC_MEM_REQ_MSG_TYPE_READ),
    .opaque (8'b0),
    .addr   (dmemreq_msg_addr),
    .len    (2'd0),
    .data   (dmemreq_msg_data),
    .msg    (dmemreq_msg)
  );


  //----------------------------------------------------------------------
  // Unpack Memory Response Messages
  //----------------------------------------------------------------------

  vc_MemRespMsgUnpack#(8,32) dmemresp_msg_unpack
  (
    .msg    (dmemresp_msg),
    .opaque (),
    .type_  (),
    .len    (),
    .data   (dmemresp_msg_data)
  );

  //----------------------------------------------------------------------
  // Control Unit
  //----------------------------------------------------------------------

  lab2_proc_PipelinedProcBaseCtrl ctrl
  (
    .clk                    (clk),
    .reset                  (reset),

    // Instruction Memory Port

    .imemreq_val            (imemreq_enq_val),
    .imemreq_rdy            (imemreq_enq_rdy),
    .imemresp_val           (imemresp_val_drop),
    .imemresp_rdy           (imemresp_rdy_drop),
    .imemresp_drop          (imemresp_drop),

    // Data Memory Port

    .dmemreq_val            (dmemreq_val),
    .dmemreq_rdy            (dmemreq_rdy),
    .dmemresp_val           (dmemresp_val),
    .dmemresp_rdy           (dmemresp_rdy),

    // mngr communication ports

    .from_mngr_val          (from_mngr_val),
    .from_mngr_rdy          (from_mngr_rdy),
    .to_mngr_val            (to_mngr_val),
    .to_mngr_rdy            (to_mngr_rdy),

    // control signals (ctrl->dpath)

    .pc_sel_F               (pc_sel_F),
    .reg_en_F               (reg_en_F),
    .reg_en_D               (reg_en_D),
    .reg_en_X               (reg_en_X),
    .reg_en_M               (reg_en_M),
    .reg_en_W               (reg_en_W),
    .op1_sel_D              (op1_sel_D),
    .wb_result_sel_M        (wb_result_sel_M),
    .alu_fn_X               (alu_fn_X),
    .rf_waddr_W             (rf_waddr_W),
    .rf_wen_W               (rf_wen_W),

    // status signals (dpath->ctrl)

    .inst_D                 (inst_D),
    .br_cond_eq_X           (br_cond_eq_X)

  );

  //----------------------------------------------------------------------
  // Bypass Queue
  //----------------------------------------------------------------------

  vc_Queue#(`VC_QUEUE_BYPASS,creq_nbits,2) imem_queue
  (
    .clk     (clk),
    .reset   (reset),
    .enq_val (imemreq_enq_val),
    .enq_rdy (imemreq_enq_rdy),
    .enq_msg (imemreq_enq_msg),
    .deq_val (imemreq_val),
    .deq_rdy (imemreq_rdy),
    .deq_msg (imemreq_msg)
  );

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  lab2_proc_PipelinedProcBaseDpath dpath
  (
    .clk                     (clk),
    .reset                   (reset),

    // Instruction Memory Port

    .imemreq_msg_addr        (imemreq_msg_addr),
    .imemresp_msg            (imemresp_msg),
    .imemresp_val            (imemresp_val),
    .imemresp_rdy            (imemresp_rdy),

    // Data Memory Port

    .dmemreq_msg_addr        (dmemreq_msg_addr),
    .dmemresp_msg_data       (dmemresp_msg_data),

    // mngr communication ports

    .from_mngr_data          (from_mngr_msg),
    .to_mngr_data            (to_mngr_msg),

    // control signals (ctrl->dpath)

    .imemresp_val_drop       (imemresp_val_drop),
    .imemresp_rdy_drop       (imemresp_rdy_drop),
    .imemresp_drop           (imemresp_drop),
    .pc_sel_F                (pc_sel_F),
    .reg_en_F                (reg_en_F),
    .reg_en_D                (reg_en_D),
    .reg_en_X                (reg_en_X),
    .reg_en_M                (reg_en_M),
    .reg_en_W                (reg_en_W),
    .op1_sel_D               (op1_sel_D),
    .alu_fn_X                (alu_fn_X),
    .wb_result_sel_M         (wb_result_sel_M),
    .rf_waddr_W              (rf_waddr_W),
    .rf_wen_W                (rf_wen_W),

    // status signals (dpath->ctrl)

    .inst_D                  (inst_D),
    .br_cond_eq_X            (br_cond_eq_X)

  );


  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  pisa_InstTasks pisa();

  logic [`VC_TRACE_NBITS_TO_NCHARS(32)*8-1:0] f_str;
  `VC_TRACE_BEGIN
  begin

    $sformat( f_str, "%x", dpath.pc_F );
    ctrl.pipe_ctrl_F.trace_pipe_stage( trace_str, f_str, 8 );

    vc_trace.append_str( trace_str, "|" );

    ctrl.pipe_ctrl_D.trace_pipe_stage( trace_str,
                              pisa.disasm(ctrl.inst_D ), 22 );

    vc_trace.append_str( trace_str, "|" );

    ctrl.pipe_ctrl_X.trace_pipe_stage( trace_str,
                              pisa.disasm_tiny(ctrl.inst_X ), 4 );

    vc_trace.append_str( trace_str, "|" );

    ctrl.pipe_ctrl_M.trace_pipe_stage( trace_str,
                              pisa.disasm_tiny(ctrl.inst_M ), 4 );

    vc_trace.append_str( trace_str, "|" );

    ctrl.pipe_ctrl_W.trace_pipe_stage( trace_str,
                              pisa.disasm_tiny(ctrl.inst_W ), 4 );


  end
  `VC_TRACE_END

endmodule

`endif

