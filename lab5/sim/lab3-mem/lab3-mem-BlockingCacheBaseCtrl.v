//=========================================================================
// Baseline Blocking Cache Control
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_BASE_CTRL_V
`define LAB3_MEM_BLOCKING_CACHE_BASE_CTRL_V

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
`include "lab3-mem-DecodeWben.v"
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
`include "vc-mem-msgs.v"
`include "vc-assert.v"

module lab3_mem_BlockingCacheBaseCtrl
#(
  parameter size    = 256,            // Cache size in bytes

  parameter p_idx_shamt = 0,

  parameter p_opaque_nbits  = 8,

  // local parameters not meant to be set from outside
  parameter dbw     = 32,             // Short name for data bitwidth
  parameter abw     = 32,             // Short name for addr bitwidth
  parameter clw     = 128,            // Short name for cacheline bitwidth
  parameter nblocks = size*8/clw,     // Number of blocks in the cache

  parameter o = p_opaque_nbits
)
(
  input  logic                                             clk,
  input  logic                                             reset,

  // Cache Request

  input  logic                                             cachereq_val,
  output logic                                             cachereq_rdy,

  // Cache Response

  output logic                                             cacheresp_val,
  input  logic                                             cacheresp_rdy,

  // Memory Request

  output logic                                             memreq_val,
  input  logic                                             memreq_rdy,

  // Memory Response

  input  logic                                             memresp_val,
//+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++++
//   output logic                                             memresp_rdy
//+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++++++
//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
  output logic                                             memresp_rdy,
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
  // control signals (ctrl->dpath)
  output logic [1:0]                                       amo_sel,
  output logic                                             cachereq_en,
  output logic                                             memresp_en,
  output logic                                             is_refill,
  output logic                                             tag_array_wen,
  output logic                                             tag_array_ren,
  output logic                                             data_array_wen,
  output logic                                             data_array_ren,
  // width of cacheline divided by number of bits per byte
  output logic [clw/8-1:0]                                 data_array_wben,
  output logic                                             read_data_reg_en,
  output logic                                             read_tag_reg_en,
  output logic [$clog2(clw/dbw)-1:0]                       read_byte_sel,
  output logic [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0]    memreq_type,
  output logic [`VC_MEM_RESP_MSG_TYPE_NBITS(o,dbw)-1:0]    cacheresp_type,

   // status signals (dpath->ctrl)
  input  logic [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw)-1:0] cachereq_type,
  input  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] cachereq_addr,
  input  logic                                             tag_match
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
 );

//+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++++
// 
//   // Drop incoming requests
// 
//   assign cachereq_rdy = 1'b1;
// 
//   // Always send out incorrect data
// 
//   assign cacheresp_val = 1'b1;
// 
//   // Do nothing for memory req/resp ports
// 
//   assign memreq_val  = 1'b0;
//   assign memresp_rdy = 1'b0;
// 
//+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
  //----------------------------------------------------------------------
  // State Definitions
  //----------------------------------------------------------------------

  localparam STATE_IDLE               = 4'd0;
  localparam STATE_TAG_CHECK          = 4'd1;
  localparam STATE_READ_DATA_ACCESS   = 4'd2;
  localparam STATE_WRITE_DATA_ACCESS  = 4'd3;
  localparam STATE_WAIT               = 4'd4;
  localparam STATE_REFILL_REQUEST     = 4'd5;
  localparam STATE_REFILL_WAIT        = 4'd6;
  localparam STATE_REFILL_UPDATE      = 4'd7;
  localparam STATE_EVICT_PREPARE      = 4'd8;
  localparam STATE_EVICT_REQUEST      = 4'd9;
  localparam STATE_EVICT_WAIT         = 4'd10;
  localparam STATE_AMO_READ_DATA_ACCESS  = 4'd11;
  localparam STATE_AMO_WRITE_DATA_ACCESS = 4'd12;
  localparam STATE_INIT_DATA_ACCESS   = 4'd15;

  //----------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( reset ) begin
      state_reg <= STATE_IDLE;
    end
    else begin
      state_reg <= state_next;
    end
  end

  //----------------------------------------------------------------------
  // State Transitions
  //----------------------------------------------------------------------

  logic in_go    ; assign in_go     = cachereq_val  && cachereq_rdy;
  logic out_go   ; assign out_go    = cacheresp_val && cacheresp_rdy;
  logic hit      ; assign hit       = is_valid && tag_match;
  logic is_read  ; assign is_read   = cachereq_type == `VC_MEM_REQ_MSG_TYPE_READ;
  logic is_write ; assign is_write  = cachereq_type == `VC_MEM_REQ_MSG_TYPE_WRITE;
  logic is_init  ; assign is_init   = cachereq_type == `VC_MEM_REQ_MSG_TYPE_WRITE_INIT;
  logic is_amo   ; assign is_amo    = amo_sel != 2'b0;
  logic read_hit ; assign read_hit  = is_read && hit;
  logic write_hit; assign write_hit = is_write && hit;
  logic amo_hit  ; assign amo_hit   = is_amo && hit;
  logic miss     ; assign miss      = !hit;
  logic refill   ; assign refill    = miss && !is_dirty;
  logic evict    ; assign evict     = miss && is_dirty;

  // determine amo type

  always @(*) begin
    case ( cachereq_type )
      `VC_MEM_REQ_MSG_TYPE_AMO_ADD: amo_sel = 2'h1;
      `VC_MEM_REQ_MSG_TYPE_AMO_AND: amo_sel = 2'h2;
      `VC_MEM_REQ_MSG_TYPE_AMO_OR : amo_sel = 2'h3;
      default                     : amo_sel = 2'h0;
    endcase
  end

  logic[3:0] state_reg;
  logic[3:0] state_next;

  always @(*) begin

    state_next = state_reg;
    case ( state_reg )

      STATE_IDLE:
             if ( in_go        ) state_next = STATE_TAG_CHECK;

      STATE_TAG_CHECK:
             if ( is_init      ) state_next = STATE_INIT_DATA_ACCESS;
        else if ( read_hit     ) state_next = STATE_READ_DATA_ACCESS;
        else if ( write_hit    ) state_next = STATE_WRITE_DATA_ACCESS;
        else if ( amo_hit      ) state_next = STATE_AMO_READ_DATA_ACCESS;
        else if ( refill       ) state_next = STATE_REFILL_REQUEST;
        else if ( evict        ) state_next = STATE_EVICT_PREPARE;

      STATE_READ_DATA_ACCESS:
        state_next = STATE_WAIT;

      STATE_WRITE_DATA_ACCESS:
        state_next = STATE_WAIT;

      STATE_INIT_DATA_ACCESS:
        state_next = STATE_WAIT;

      STATE_AMO_READ_DATA_ACCESS:
        state_next = STATE_AMO_WRITE_DATA_ACCESS;

      STATE_AMO_WRITE_DATA_ACCESS:
        state_next = STATE_WAIT;

      STATE_REFILL_REQUEST:
             if ( memreq_rdy   ) state_next = STATE_REFILL_WAIT;
        else if ( !memreq_rdy  ) state_next = STATE_REFILL_REQUEST;

      STATE_REFILL_WAIT:
             if ( memresp_val  ) state_next = STATE_REFILL_UPDATE;
        else if ( !memresp_val ) state_next = STATE_REFILL_WAIT;

      STATE_REFILL_UPDATE:
             if ( is_read      ) state_next = STATE_READ_DATA_ACCESS;
        else if ( is_write     ) state_next = STATE_WRITE_DATA_ACCESS;
        else if ( is_amo       ) state_next = STATE_AMO_READ_DATA_ACCESS;

      STATE_EVICT_PREPARE:
        state_next = STATE_EVICT_REQUEST;

      STATE_EVICT_REQUEST:
             if ( memreq_rdy   ) state_next = STATE_EVICT_WAIT;
        else if ( !memreq_rdy  ) state_next = STATE_EVICT_REQUEST;

      STATE_EVICT_WAIT:
             if ( memresp_val  ) state_next = STATE_REFILL_REQUEST;
        else if ( !memresp_val ) state_next = STATE_EVICT_WAIT;

      STATE_WAIT:
             if ( out_go       ) state_next = STATE_IDLE;

    endcase

  end

  //----------------------------------------------------------------------
  // Valid/Dirty bits record
  //----------------------------------------------------------------------

  logic [3:0] cachereq_idx;
  logic       valid_bit_in;
  logic       valid_bits_write_en;
  logic       is_valid;

  assign cachereq_idx = cachereq_addr[4+p_idx_shamt +: 4];

  vc_ResetRegfile_1r1w#(1,16) valid_bits
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (cachereq_idx),
    .read_data  (is_valid),
    .write_en   (valid_bits_write_en),
    .write_addr (cachereq_idx),
    .write_data (valid_bit_in)
  );

  logic       dirty_bit_in;
  logic       dirty_bits_write_en;
  logic       is_dirty;

  vc_ResetRegfile_1r1w#(1,16) dirty_bits
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (cachereq_idx),
    .read_data  (is_dirty),
    .write_en   (dirty_bits_write_en),
    .write_addr (cachereq_idx),
    .write_data (dirty_bit_in)
  );

  //----------------------------------------------------------------------
  // State Outputs
  //----------------------------------------------------------------------

  // General parameters
  localparam x       = 1'dx;

  // Parameters for is_refill
  localparam r_x     = 1'dx;
  localparam r_c     = 1'd0; // fill data array from _c_ache
  localparam r_m     = 1'd1; // fill data array from _m_em

  // Parameters for memreq_type_mux
  localparam m_x     = 1'dx;
  localparam m_e     = `VC_MEM_REQ_MSG_TYPE_WRITE; // write to memory in an _e_vict
  localparam m_r     = `VC_MEM_REQ_MSG_TYPE_READ;  // write to memory in a _r_efill

  task cs
  (
   input logic cs_cachereq_rdy,
   input logic cs_cacheresp_val,
   input logic cs_memreq_val,
   input logic cs_memresp_rdy,
   input logic cs_cachereq_en,
   input logic cs_memresp_en,
   input logic cs_is_refill,
   input logic cs_tag_array_wen,
   input logic cs_tag_array_ren,
   input logic cs_data_array_wen,
   input logic cs_data_array_ren,
   input logic cs_read_data_reg_en,
   input logic cs_read_tag_reg_en,
   input logic cs_memreq_type,
   input logic cs_valid_bit_in,
   input logic cs_valid_bits_write_en,
   input logic cs_dirty_bit_in,
   input logic cs_dirty_bits_write_en
  );
  begin
    cachereq_rdy        = cs_cachereq_rdy;
    cacheresp_val       = cs_cacheresp_val;
    memreq_val          = cs_memreq_val;
    memresp_rdy         = cs_memresp_rdy;
    cachereq_en         = cs_cachereq_en;
    memresp_en          = cs_memresp_en;
    is_refill           = cs_is_refill;
    tag_array_wen       = cs_tag_array_wen;
    tag_array_ren       = cs_tag_array_ren;
    data_array_wen      = cs_data_array_wen;
    data_array_ren      = cs_data_array_ren;
    read_data_reg_en    = cs_read_data_reg_en;
    read_tag_reg_en     = cs_read_tag_reg_en;
    memreq_type         = cs_memreq_type;
    valid_bit_in        = cs_valid_bit_in;
    valid_bits_write_en = cs_valid_bits_write_en;
    dirty_bit_in        = cs_dirty_bit_in;
    dirty_bits_write_en = cs_dirty_bits_write_en;
  end
  endtask

  // Set outputs using a control signal "table"

  always @(*) begin
                                   cs( 0,   0,    0,  0,   x,    x,   r_x,   0,    0,    0,    0,    0,   0,   m_x, x,    0,    x,    0     );
    case ( state_reg )
      //                              cache cache mem mem  cache mem         tag   tag   data  data  read read mem  valid valid dirty dirty
      //                              req   resp  req resp req   resp is     array array array array data tag  req  bit   write bit   write
      //                              rdy   val   val rdy  en    en   refill wen   ren   wen   ren   en   en   type in    en    in    en
      STATE_IDLE:                  cs( 1,   0,    0,  0,   1,    0,   r_x,   0,    0,    0,    0,    0,   0,   m_x, x,    0,    x,    0     );
      STATE_TAG_CHECK:             cs( 0,   0,    0,  0,   0,    0,   r_x,   0,    1,    0,    0,    0,   0,   m_x, x,    0,    x,    0     );
      STATE_READ_DATA_ACCESS:      cs( 0,   0,    0,  0,   0,    0,   r_x,   0,    0,    0,    1,    1,   0,   m_x, x,    0,    x,    0     );
      STATE_WRITE_DATA_ACCESS:     cs( 0,   0,    0,  0,   0,    0,   r_c,   1,    0,    1,    0,    0,   0,   m_x, 1,    1,    1,    1     );
      STATE_INIT_DATA_ACCESS:      cs( 0,   0,    0,  0,   0,    0,   r_c,   1,    0,    1,    0,    0,   0,   m_x, 1,    1,    0,    1     );
      STATE_AMO_READ_DATA_ACCESS:  cs( 0,   0,    0,  0,   0,    0,   r_x,   0,    0,    0,    1,    1,   0,   m_x, x,    0,    x,    0     );
      STATE_AMO_WRITE_DATA_ACCESS: cs( 0,   0,    0,  0,   0,    0,   r_c,   1,    0,    1,    0,    0,   0,   m_x, 1,    1,    1,    1     );
      STATE_REFILL_REQUEST:        cs( 0,   0,    1,  0,   0,    0,   r_x,   0,    0,    0,    0,    0,   0,   m_r, x,    0,    x,    0     );
      STATE_REFILL_WAIT:           cs( 0,   0,    0,  1,   0,    1,   r_x,   0,    0,    0,    0,    0,   0,   m_x, x,    0,    x,    0     );
      STATE_REFILL_UPDATE:         cs( 0,   0,    0,  0,   0,    0,   r_m,   1,    0,    1,    0,    0,   0,   m_x, 1,    1,    0,    1     );
      STATE_EVICT_PREPARE:         cs( 0,   0,    0,  0,   0,    0,   r_x,   0,    1,    0,    1,    1,   1,   m_x, x,    0,    x,    0     );
      STATE_EVICT_REQUEST:         cs( 0,   0,    1,  0,   0,    0,   r_x,   0,    0,    0,    0,    0,   0,   m_e, x,    0,    x,    0     );
      STATE_EVICT_WAIT:            cs( 0,   0,    0,  1,   0,    0,   r_x,   0,    0,    0,    0,    0,   0,   m_x, x,    0,    x,    0     );
      STATE_WAIT:                  cs( 0,   1,    0,  0,   0,    0,   r_x,   0,    0,    0,    0,    0,   0,   m_x, x,    0,    x,    0     );

    endcase
  end

  // Building data_array_wben
  // This is in control because we want to facilitate more complex patterns
  //   when we want to start supporting subword accesses

  logic [1:0] cachereq_offset;
  logic [15:0] wben_decoder_out;

  assign cachereq_offset = cachereq_addr[3:2];

  lab3_mem_DecoderWben#(2) wben_decoder
  (
    .in  (cachereq_offset),
    .out (wben_decoder_out)
  );

  // Choose byte to read from cacheline based on what the offset was

  assign read_byte_sel = cachereq_offset;

  always @(*) begin

    // Logic to enable writing of the entire cacheline in case of refill and just one word for writes and init

    if ( is_refill )
      data_array_wben = 16'hffff;
    else
      data_array_wben = wben_decoder_out;

    // Managing the cache response type based on cache request type

    cacheresp_type = cachereq_type;
  end

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( cachereq_val  );
      `VC_ASSERT_NOT_X( cacheresp_rdy );
      `VC_ASSERT_NOT_X( memreq_rdy    );
      `VC_ASSERT_NOT_X( memresp_val   );

      // Asserts for the init instruction to guard against undefined behavior
      if ( state_reg == STATE_INIT_DATA_ACCESS ) begin
        `VC_ASSERT( !is_dirty );
      end
    end
  end
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

endmodule

`endif
