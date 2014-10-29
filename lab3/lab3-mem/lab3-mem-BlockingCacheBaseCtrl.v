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

  output  logic                                            cachereq_en, 

  input   logic [2:0]                                      cachereq_type, 
  input   logic [abw-1:0]                                  cachereq_addr, 
  
  output  logic                                            tag_array_ren, 
  output  logic                                            tag_array_wen, 
  
  input   logic                                            tag_match,
  output  logic                                            write_data_mux_sel,
  output  logic                                            evict_addr_reg_en,
  output  logic                                            memreq_addr_mux_sel, 
  output  logic [2:0]                                      cacheresp_type,

  output  logic                                            memresp_en,
  output  logic                                            data_array_ren,
  output  logic                                            data_array_wen,
  output  logic [15:0]                                     data_array_wben,
  output  logic                                            read_data_reg_en,
  output  logic [1:0]                                      read_word_mux_sel,
  output  logic [2:0]                                      memreq_type

 );

  //----------------------------------------------------------------------
  // State Definitions
  //----------------------------------------------------------------------

  typedef enum logic [$clog2(12)-1:0] {
    STATE_IDLE,
    STATE_TAG_CHECK,
    STATE_INIT_DATA_ACCESS,
    STATE_READ_DATA_ACCESS,
    STATE_WRITE_DATA_ACCESS,
    STATE_WAIT,
    STATE_EVICT_PREPARE,
    STATE_EVICT_REQUEST,
    STATE_EVICT_WAIT,
    STATE_REFILL_REQUEST,
    STATE_REFILL_WAIT,
    STATE_REFILL_UPDATE
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

    always @(*) begin

    state_next = state_reg;

    case ( state_reg )

      STATE_IDLE:               
        if ( cachereq_val && cachereq_rdy ) begin
          state_next = STATE_TAG_CHECK;
        end
        else begin
          state_next = STATE_WAIT;
        end
      default:
        state_next = STATE_WAIT;
    endcase
  end

  // HELPER FOR wben BITS

  logic [15:0] wb;
  logic [1:0]  wsel;

  assign wsel = cachereq_addr[3:2];     

  always @(*) begin
    case ( cachereq_addr[3:2] )
      00: wb = 16'b1111000000000000;
      01: wb = 16'b0000111100000000;
      10: wb = 16'b0000000011110000;
      11: wb = 16'b0000000000001111;
    endcase
  end

  // END HELPER


  task set_cs
  (
    input  logic          cs_cachereq_rdy,
    input  logic          cs_cacheresp_val,
    input  logic          cs_memreq_val,
    input  logic          cs_memresp_rdy,
    input  logic          cs_cachereq_en, 
    input  logic          cs_tag_array_ren, 
    input  logic          cs_tag_array_wen,
    input  logic          cs_write_data_mux_sel,
    input  logic          cs_evict_addr_reg_en,
    input  logic          cs_memreq_addr_mux_sel, 
    input  logic [2:0]    cs_cacheresp_type,
    input  logic          cs_memresp_en,
    input  logic          cs_data_array_ren,
    input  logic          cs_data_array_wen,
    input  logic [15:0]   cs_data_array_wben,
    input  logic          cs_read_data_reg_en,
    input  logic [1:0]    cs_read_word_mux_sel,
    input  logic [2:0]    cs_memreq_type
  );
  begin
    cachereq_rdy         =    cs_cachereq_rdy;      
    cacheresp_val        =    cs_cacheresp_val;      
    memreq_val           =    cs_memreq_val;    
    memresp_rdy          =    cs_memresp_rdy;
    cachereq_en          =    cs_cachereq_en;   
    tag_array_ren        =    cs_tag_array_ren;      
    tag_array_wen        =    cs_tag_array_wen;      
    write_data_mux_sel   =    cs_write_data_mux_sel;            
    evict_addr_reg_en    =    cs_evict_addr_reg_en;          
    memreq_addr_mux_sel  =    cs_memreq_addr_mux_sel;            
    cacheresp_type       =    cs_cacheresp_type;        
    memresp_en           =    cs_memresp_en;          
    data_array_ren       =    cs_data_array_ren;        
    data_array_wen       =    cs_data_array_wen;        
    data_array_wben      =    cs_data_array_wben;        
    read_data_reg_en     =    cs_read_data_reg_en;          
    read_word_mux_sel    =    cs_read_word_mux_sel;          
    memreq_type          =    cs_memreq_type;    
  end
  endtask

  localparam y = 1'b1;
  localparam n = 1'b0;
  localparam x = 1'bx;

  localparam nwb = 16'dx;

  localparam ze = 2'b00;
  localparam fs = 2'b01;
  localparam sn = 2'b10;
  localparam th = 2'b11;

  localparam ev_reg = 1'b0;
  localparam m_addr = 1'b1;

  always @(*) begin

    case ( state_reg )
                              //        C   C   M   M    C   TAG  TAG  WD EA MRQ CRSP M   DTA DTA DTA  RD   RD  MREQ
                              //        REQ RSP REQ RSP  REQ REN  WEN  MX EN ADR TYPE RSP ARR ARR ARR  DTA  WR  TYPE
                              //        RDY VAL VAL RDY  EN                  MX       EN  REN WEN WBEN REN  MX     
      STATE_IDLE               :set_cs( y,  n,  n,  n,   y,  x,   n,   x, n, x,  0,   n,  n,  n,  n,   nwb, ze, 0   ); 
      default                  :set_cs( n,  n,  n,  n,   n,  n,   n,   x, n, x,  0,   n,  n,  n,  n,   nwb, ze, 0   );
    endcase

  end

endmodule

`endif
