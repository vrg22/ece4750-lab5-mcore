//========================================================================
// Memory-Network message adapters
//========================================================================

`ifndef LAB5_MCORE_MEM_NET_ADAPTERS_V
`define LAB5_MCORE_MEM_NET_ADAPTERS_V

`include "vc-mem-msgs.v"
`include "vc-net-msgs.v"

module lab5_mcore_MemReqMsgToNetMsg
#(

  // the source index where this memory request is originating (core id)

  parameter p_net_src = 0,

  // number of sources and destinations (cores and banks)

  parameter p_num_ports = 4,

  // memory-related parameters

  parameter p_mem_opaque_nbits = 8,
  parameter p_mem_addr_nbits = 32,
  parameter p_mem_data_nbits = 32,

  // network-related parameters

  parameter p_net_opaque_nbits = 4,
  parameter p_net_srcdest_nbits = 3,

  // number of words in a cacheline

  parameter p_cacheline_nwords = 4,

  // single cache/mem bank mode

  parameter p_single_bank = 0,

  // remaining parameters are not meant to be set from outside

  // shorter names for memory parameters

  parameter mo = p_mem_opaque_nbits,
  parameter ma = p_mem_addr_nbits,
  parameter md = p_mem_data_nbits,

  // network payload is the memory message

  parameter c_mem_msg_nbits = `VC_MEM_REQ_MSG_NBITS(mo,ma,md),
  parameter c_net_payload_nbits = c_mem_msg_nbits,

  // shorter names for network parameters

  parameter np = c_net_payload_nbits,
  parameter no = p_net_opaque_nbits,
  parameter ns = p_net_srcdest_nbits,

  parameter c_net_msg_nbits = `VC_NET_MSG_NBITS(np,no,ns)

)
(

  input  logic [c_mem_msg_nbits-1:0] mem_msg,

  output logic [c_net_msg_nbits-1:0] net_msg

);
  // destination indexing from the memory address

  localparam c_dest_addr_lsb = 2 + $clog2(p_cacheline_nwords);
  localparam c_dest_addr_msb = c_dest_addr_lsb + p_net_srcdest_nbits - 1;

  // extract the address of the memory message to determine network source

  logic [p_mem_addr_nbits-1:0]                 mem_addr;
  logic [`VC_NET_MSG_DEST_NBITS(np,no,ns)-1:0] net_dest;

  assign mem_addr = mem_msg[`VC_MEM_REQ_MSG_ADDR_FIELD(mo,ma,md)];

  // if there is a single cache/mem bank, destination is 0
  assign net_dest = p_single_bank ? 0 :
                                    mem_addr[c_dest_addr_msb:c_dest_addr_lsb];

  // we use high bits of the opaque field to put the destination info

  logic [mo-1:0] mem_msg_opaque;
  logic [mo-1:0] mem_src_opaque;

  assign mem_msg_opaque = mem_msg[`VC_MEM_REQ_MSG_OPAQUE_FIELD(mo,ma,md)];

  assign mem_src_opaque = { p_net_src[ns-1:0], mem_msg_opaque[mo-ns-1:0] };

  // we re-pack the memory message with the new opaque field

  logic [`VC_MEM_REQ_MSG_NBITS(mo,ma,md)-1:0] net_payload;

  vc_MemReqMsgPack #(mo,ma,md) mem_pack
  (
    .type_  (mem_msg[`VC_MEM_REQ_MSG_TYPE_FIELD(mo,ma,md)]),
    .opaque (mem_src_opaque),
    .addr   (mem_msg[`VC_MEM_REQ_MSG_ADDR_FIELD(mo,ma,md)]),
    .len    (mem_msg[`VC_MEM_REQ_MSG_LEN_FIELD(mo,ma,md)]),
    .data   (mem_msg[`VC_MEM_REQ_MSG_DATA_FIELD(mo,ma,md)]),

    .msg    (net_payload)
  );

  // then we pack the memory message as a network message

  vc_NetMsgPack
  #(
    .p_payload_nbits  (c_net_payload_nbits),
    .p_opaque_nbits   (p_net_opaque_nbits),
    .p_srcdest_nbits  (p_net_srcdest_nbits)
  )
  net_pack
  (
    .dest     (net_dest),
    .src      (p_net_src[ns-1:0]),
    .opaque   ({p_net_opaque_nbits{1'b0}}),
    .payload  (net_payload),

    .msg      (net_msg)
  );

endmodule


module lab5_mcore_MemRespMsgToNetMsg
#(

  // the source index where this memory response is originating (bank id)

  parameter p_net_src = 0,

  // number of sources and destinations (cores and banks)

  parameter p_num_ports = 4,

  // memory-related parameters

  parameter p_mem_opaque_nbits = 8,
  parameter p_mem_data_nbits = 32,

  // network-related parameters

  parameter p_net_opaque_nbits = 4,
  parameter p_net_srcdest_nbits = 3,

  // number of words in a cacheline

  parameter p_cacheline_nwords = 4,

  // remaining parameters are not meant to be set from outside

  // shorter names for memory parameters

  parameter mo = p_mem_opaque_nbits,
  parameter md = p_mem_data_nbits,

  // network payload is the memory message

  parameter c_mem_msg_nbits     = `VC_MEM_RESP_MSG_NBITS(mo,md),
  parameter c_net_payload_nbits = `VC_MEM_RESP_MSG_NBITS(mo,md),

  // shorter names for network parameters

  parameter np = c_net_payload_nbits,
  parameter no = p_net_opaque_nbits,
  parameter ns = p_net_srcdest_nbits,

  parameter c_net_msg_nbits = `VC_NET_MSG_NBITS(np,no,ns)

)
(

  input  logic [c_mem_msg_nbits-1:0] mem_msg,

  output logic [c_net_msg_nbits-1:0] net_msg

);

  // extract the opaque field from memory message

  logic [p_mem_opaque_nbits-1:0]  mem_msg_opaque;
  logic [p_net_srcdest_nbits-1:0] net_dest;

  assign mem_msg_opaque = mem_msg[`VC_MEM_RESP_MSG_OPAQUE_FIELD(mo,md)];
  assign net_dest = mem_msg_opaque[mo-1 -: ns];

  // re-pack the memory message without the destination opaque field

  logic [`VC_MEM_RESP_MSG_NBITS(mo,md)-1:0] net_payload;

  vc_MemRespMsgPack #(mo,md) mem_pack
  (
    .type_  (mem_msg[`VC_MEM_RESP_MSG_TYPE_FIELD(mo,md)]),
    .opaque (mem_msg_opaque),
    .len    (mem_msg[`VC_MEM_RESP_MSG_LEN_FIELD(mo,md)]),
    .data   (mem_msg[`VC_MEM_RESP_MSG_DATA_FIELD(mo,md)]),

    .msg    (net_payload)
  );

  // then we pack the memory message as a network message

  vc_NetMsgPack
  #(
    .p_payload_nbits  (c_net_payload_nbits),
    .p_opaque_nbits   (p_net_opaque_nbits),
    .p_srcdest_nbits  (p_net_srcdest_nbits)
  )
  net_pack
  (
    .dest     (net_dest),
    .src      (p_net_src[ns-1:0]),
    .opaque   ({p_net_opaque_nbits{1'b0}}),
    .payload  (net_payload),

    .msg      (net_msg)
  );

endmodule


`endif /* LAB5_MCORE_MEM_NET_ADAPTERS_V */
