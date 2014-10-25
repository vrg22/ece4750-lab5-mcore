//=========================================================================
// Baseline Blocking Cache Control
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_BASE_CTRL_V
`define LAB3_MEM_BLOCKING_CACHE_BASE_CTRL_V

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
  output logic                                             memresp_rdy,

  // Status Signals

  input logic [2:0]      cachereq_type,
  input logic [abw-1:0]  cachereq_addr,
  input logic            tag_match,

  // Control Signals

  output logic         cachereq_en,
  output logic         memresp_en,
  output logic         refill_mux_sel,
  output logic         tag_array_wen,
  output logic         tag_array_ren,
  output logic         data_array_wen,
  output logic         data_array_ren,
  output logic [15:0]  data_array_wben,                  
  output logic         read_data_reg_en,
  output logic         read_tag_reg_en,
  output logic         memreq_tag_mux_sel,
  output logic [1:0]   read_byte_mux_sel,
  output logic [2:0]   cacheresp_type,                    // cacheresp_type: Init - 000, Read - 010, Write - 100
  output logic [2:0]   memreq_type

 );


  //========================================================================
  // Control and status signal structs (for internal use only)
  //========================================================================

  // Control signals (ctrl->dpath)

  typedef struct packed {

    logic         cachereq_en;          // Enable for cache request message registers
    logic         memresp_en;           // Enable for memory response enable register
    logic         refill_mux_sel;       // Sel for cache line refill mux behind data array
    logic         tag_array_wen;        // Write enable for tag array
    logic         tag_array_ren;        // Read enable for tag array
    logic         data_array_wen;       // Write enable for data array
    logic         data_array_ren;       // Read enable for data array
    logic [15:0]  data_array_wben;      // Write byte enable for data array             
    logic         read_data_reg_en;     // Enable for data array output register
    logic         read_tag_reg_en;      // Enable for tag array output register
    logic         memreq_tag_mux_sel;   // Sel for memory request tag mux in front of tag array output register
    logic [1:0]   read_byte_mux_sel;    // Sel for read byte select mux in front of data array output register
    logic [2:0]   cacheresp_type;       // read/write/init for cache response message
    logic [2:0]   memreq_type;          // read/write/init for memory request message

  } lab3_mem_cs_t;

  // create new control signal struct
  lab3_mem_cs_t cs;


  //----------------------------------------------------------------------
  // State Definitions
  //----------------------------------------------------------------------

  typedef enum logic [$clog2(4)-1:0] {
    STATE_IDLE,
    STATE_TAG_CHECK,
    STATE_INIT_DATA_ACCESS,
    STATE_WAIT
  } state_t;


  //----------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------

  state_t state_reg;
  state_t state_next;

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


  always @(*) begin

    state_next = state_reg;

    case ( state_reg )

      STATE_IDLE:             if ( cachereq_val && cachereq_rdy ) begin
                                state_next = STATE_TAG_CHECK;
                              end
      STATE_TAG_CHECK: 
                              if ( 1 ) begin
                                state_next = STATE_INIT_DATA_ACCESS;
                              end
      STATE_INIT_DATA_ACCESS: if ( 1 ) begin
                                assign cs_cacheresp_type = 3'b000; 
                                state_next = STATE_WAIT;
                              end

      STATE_WAIT:             if ( cacheresp_rdy ) begin
                                state_next = STATE_IDLE;
                              end

    endcase

  end


  //----------------------------------------------------------------------
  // State Outputs
  //----------------------------------------------------------------------
  
  // CONVENTION FROM DATAPATH DIAGRAM:
  // top mux line selected by 0, bottom line by max mux-sel value
  
  localparam x   = 1'bx;

  task set_cs
  (
    input logic         cs_cachereq_rdy,
    input logic         cs_cacheresp_val,
    input logic         cs_memreq_val,
    input logic         cs_memresp_rdy,
    input logic         cs_cachereq_en,
    input logic         cs_memresp_en,
    input logic         cs_refill_mux_sel,
    input logic         cs_tag_array_wen,
    input logic         cs_tag_array_ren,
    input logic         cs_data_array_wen,
    input logic         cs_data_array_ren,
    input logic [15:0]  cs_data_array_wben,                  
    input logic         cs_read_data_reg_en,
    input logic         cs_read_tag_reg_en,
    input logic         cs_memreq_tag_mux_sel,
    input logic [1:0]   cs_read_byte_mux_sel,
    input logic [2:0]   cs_cacheresp_type,
    input logic [2:0]   cs_memreq_type
  );
  begin
    cachereq_rdy          = cs_cachereq_rdy;
    cacheresp_val         = cs_cacheresp_val;
    memreq_val            = cs_memreq_val;
    memresp_rdy           = cs_memresp_rdy;
    cs.cachereq_en        = cs_cachereq_en;
    cs.memresp_en         = cs_memresp_en;
    cs.refill_mux_sel     = cs_refill_mux_sel;
    cs.tag_array_wen      = cs_tag_array_wen;
    cs.tag_array_ren      = cs_tag_array_ren;
    cs.data_array_wen     = cs_data_array_wen;
    cs.data_array_ren     = cs_data_array_ren;
    cs.data_array_wben    = cs_data_array_wben;
    cs.read_data_reg_en   = cs_read_data_reg_en;
    cs.read_tag_reg_en    = cs_read_tag_reg_en;
    cs.memreq_tag_mux_sel = cs_memreq_tag_mux_sel;
    cs.read_byte_mux_sel  = cs_read_byte_mux_sel;
    cs.cacheresp_type     = cs_cacheresp_type;
    cs.memreq_type        = cs_memreq_type;
  end
  endtask


  // Set outputs using a control signal "table"

  always @(*) begin

    set_cs( x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x );

    case ( state_reg )
      
      // cachereq  cacheresp  memreq  memresp  cachereq  memresp  refill  tag_array  tag_array  data_array  data_array  data_array  read_data  read_tag  memreq_tag  read_byte   cacheresp  memreq
      // rdy       val        val     rdy      en        en       mux_sel wen        ren        wen         ren         wben (16)   reg_en     reg_en    mux_sel     mux_sel (2) type (3)   type (3)
      
      STATE_IDLE:               set_cs( 1,  0,  0,  0,  0, 0, x, 0, 0, 0, 0, 16'bx, 0, 0, x, 2'bxx, 3'bxxx, 3'bxxx ); 
      STATE_TAG_CHECK: 
                                set_cs( 0,  0,  0,  0,  1, 0, x, 0, 1, 0, 0, 16'bx, 0, 0, x, 2'bxx, 3'bxxx, 3'bxxx ); 
      STATE_INIT_DATA_ACCESS:   set_cs( 0,  0,  0,  0,  1, 0, 0, 1, 0, 1, 0, 16'bx, 0, 0, x, 2'bxx, 3'bxxx, 3'bxxx );            
      STATE_WAIT:               set_cs( 0,  0,  0,  0,  0, 0, x, 0, 0, 0, 0, 16'bx, 0, 0, x, 2'bxx, 3'bxxx, 3'bxxx ); 

    endcase

  end


  // Unpack cs struct control signals

   assign cachereq_en        = cs.cachereq_en;
   assign memresp_en         = cs.memresp_en;
   assign refill_mux_sel     = cs.refill_mux_sel;
   assign tag_array_wen      = cs.tag_array_wen;
   assign tag_array_ren      = cs.tag_array_ren;
   assign data_array_wen     = cs.data_array_wen;
   assign data_array_ren     = cs.data_array_ren;
   assign data_array_wben    = cs.data_array_wben;
   assign read_data_reg_en   = cs.read_data_reg_en;
   assign read_tag_reg_en    = cs.read_tag_reg_en;
   assign memreq_tag_mux_sel = cs.memreq_tag_mux_sel;
   assign read_byte_mux_sel  = cs.read_byte_mux_sel;
   assign cacheresp_type     = cs.cacheresp_type;
   assign memreq_type        = cs.memreq_type;


endmodule

`endif
