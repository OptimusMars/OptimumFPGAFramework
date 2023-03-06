package axi_pkg;

// Read this for information
// AMBA® AXI and ACE Protocol Specification

typedef enum logic [2:0] {
  SIZE_1 = '0,
  SIZE_2,
  SIZE_4,
  SIZE_8,
  SIZE_16,
  SIZE_32,
  SIZE_64,
  SIZE_128
} AxiSize_t;    // In bytes

typedef enum logic [1:0] {
  FIXED = 0,
  INCR  = 1,
  WRAP  = 2
} AxiBurst_t;

typedef enum logic [1:0] {
  OKAY = 0,   //! normal access success
  EXOKAY,     //! exclusive access success
  SLVERR,     //! Subordinate error 
  DECERR      //! decode error
} AxiResp_t;

typedef struct packed {
  logic Bufferable;
  logic Cacheable;
  logic ReadAllocate;
  logic WriteAllocate;
} AxiCache_t;

typedef struct packed {
  logic [31:0] address;
  logic [15:0] bytes;   // In bytes
  AxiSize_t    size;
  AxiBurst_t   burst;
} AxiHostRdCtrl_t;

typedef struct packed {
  AxiResp_t resp;
} AxiHostRdStatus_t;

function int axiSize2bytes(AxiSize_t size);
  axiSize2bytes = 1 << int'(size);
endfunction

function bit addressAligned(logic [31:0] address, AxiSize_t size);
  addressAligned = bit'(((((address) % (size)) == 0) ? 1 : 0));
endfunction

function logic [7:0] axiLen(AxiHostRdCtrl_t ctrl, AxiSize_t size);
  logic [7:0] ret;
  if(!((((ctrl.bytes) % (size)) == 0) ? 1 : 0))
    ret = (ctrl.bytes) / axiSize2bytes(size);
  else 
    ret = (ctrl.bytes) / axiSize2bytes(size) + 1;
  return ret; 
endfunction

function logic axiAccepted(logic valid, logic ready);
  return valid && ready;
endfunction

function logic axiSuccess(AxiResp_t resp);
  return (resp == OKAY) || (resp == EXOKAY);
endfunction

task axiArClear(axi4_rd_intf rd());
  rd.id    <= '0;
  rd.addr  <= '0;
  rd.len   <= '0;
  rd.size  <= '0;
  rd.burst <= '0;
  rd.lock  <= '0;
  rd.cache <= '0;
  rd.prot  <= '0;
  rd.region<= '0;
  rd.qos   <= '0;
  rd.valid <= '0;
endtask

task axiAwClear(axi4_wr_intf wr());
  wr.id    <= '0;
  wr.addr  <= '0;
  wr.len   <= '0;
  wr.size  <= '0;
  wr.burst <= '0;
  wr.lock  <= '0;
  wr.cache <= '0;
  wr.prot  <= '0;
  wr.region<= '0;
  wr.qos   <= '0;
  wr.valid <= '0;
endtask

task axiArSend(axi4_rd_intf rd(), AxiMasterRdCtrl_t ctrl);
  rd.id    <= rd.id + 1'b1;
  rd.addr  <= ctrl.address;
  rd.len   <= axi_pkg::axiLen(ctrl, ctrl.size);
  rd.size  <= ctrl.size;
  rd.valid <= '1;
  rd.burst <= ctrl.burst;
endtask

task axiAwSend(axi4_wr_intf rd(), AxiMasterRdCtrl_t ctrl);
  rd.id    <= rd.id + 1'b1;
  rd.addr  <= ctrl.address;
  rd.len   <= axi_pkg::axiLen(ctrl, ctrl.size);
  rd.size  <= ctrl.size;
  rd.valid <= '1;
  rd.burst <= ctrl.burst;
endtask

function logic axiArAccepted(axi4_rd_intf rd());
  return axi_pkg::axiAccepted(rd.rvalid, m_axi_arready);
endfunction

task axi_r_accept_data();
  m_axis_tdata     = m_axi_rdata;
  m_axis_tlast     = m_axi_rlast;
  m_axis_tvalid    = m_axi_rvalid;
endtask


endpackage