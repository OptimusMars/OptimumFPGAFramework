// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

// It will be Xilinx AXI Datamover full analog

module axi_host_rd
  import axi_pkg::*;
#(
  parameter AXI_DWIDTH  = 128       ,
  parameter AXI_AWIDTH  = 32        ,
  parameter AXI_IDWIDTH = 1         ,
  parameter AXIS_DWIDTH = AXI_DWIDTH
) (
  input                          aclk                ,
  input                          areset_n            ,
  //! AXI Master
  output logic [AXI_IDWIDTH-1:0] m_axi_arid          ,
  output logic [ AXI_AWIDTH-1:0] m_axi_araddr        ,
  output logic [            7:0] m_axi_arlen         ,
  output logic [            2:0] m_axi_arsize        ,
  output logic [            1:0] m_axi_arburst       ,
  output logic                   m_axi_arlock        ,
  output logic [            3:0] m_axi_arcache       ,
  output logic [            2:0] m_axi_arprot        ,
  output logic [            3:0] m_axi_arregion      ,
  output logic [            3:0] m_axi_arqos         ,
  output logic                   m_axi_arvalid       ,
  input                          m_axi_arready       ,
  //!
  input        [AXI_IDWIDTH-1:0] m_axi_rid           ,
  input        [ AXI_DWIDTH-1:0] m_axi_rdata         ,
  input        [            1:0] m_axi_rresp         ,
  input                          m_axi_rlast         ,
  input                          m_axi_rvalid        ,
  output logic                   m_axi_rready        ,
  //!
  input                          s_axis_cmd_tvalid   ,
  output logic                   s_axis_cmd_tready   ,
  input  AxiMasterRdCtrl_t       s_axis_cmd_tdata    ,
  //!
  output logic                   m_axis_status_tvalid,
  input                          m_axis_status_tready,
  output AxiMasterRdStatus_t     m_axis_status_tdata ,
  //!
  output logic [AXIS_DWIDTH-1:0] m_axis_tdata        ,
  output logic [AXIS_DWIDTH/8:0] m_axis_tkeep        ,
  output logic                   m_axis_tlast        ,
  output logic                   m_axis_tvalid       ,
  input                          m_axis_tready
);

localparam VERSION = 0;

initial begin
  if(AXI_DWIDTH != 128) $error("Invalid parameter");
  if(AXI_AWIDTH != 32)  $error("Invalid parameter");
  if(AXI_DWIDTH != AXIS_DWIDTH) $error("Invalid parameter");
end

typedef enum int {  ST_IDLE = 0,      //! Wait for transaction
                    ST_GEN_ADDR,      //! Generate address
                    ST_TRANSACTION,   //! Transaction phase
                    ST_GEN_STATUS     //! Generate status
                  } fsm_t;

fsm_t fsm;
logic transaction_complete;
logic transaction_go;
AxiMasterRdCtrl_t ctrl;
AxiMasterRdStatus_t status;

task axi_ar_clear();
  m_axi_arid    <= '0;
  m_axi_araddr  <= '0;
  m_axi_arlen   <= '0;
  m_axi_arsize  <= '0;
  m_axi_arburst <= '0;
  m_axi_arlock  <= '0;
  m_axi_arcache <= '0;
  m_axi_arprot  <= '0;
  m_axi_arregion<= '0;
  m_axi_arqos   <= '0;
  m_axi_arvalid <= '0;
endtask

task axi_ar_send(AxiMasterRdCtrl_t ctrl);
  m_axi_arid    <= m_axi_arid + 1'b1;
  m_axi_araddr  <= ctrl.address;
  m_axi_arlen   <= axi_pkg::axiLen(ctrl, SIZE_16);
  m_axi_arsize  <= SIZE_16;
  m_axi_arvalid <= '1;
endtask

task axis_status_send();
  m_axis_status_tvalid  <= '1;
  m_axis_status_tdata   <= status;
endtask

task axis_status_clear();
  m_axis_status_tvalid  <= '0;
endtask

task axi_ar_invalid();
  m_axi_arvalid <= '0;
endtask

function logic axi_ar_accepted();
  return axi_pkg::axiAccepted(m_axi_arvalid, m_axi_arready);
endfunction

task axi_r_accept_data();
  m_axis_tdata     = m_axi_rdata;
  m_axis_tlast     = m_axi_rlast;
  m_axis_tvalid    = m_axi_rvalid;
endtask

always_comb begin
  transaction_go       = s_axis_cmd_tready && s_axis_cmd_tvalid;
  transaction_complete = fsm == ST_GEN_STATUS;
  axi_r_accept_data();
end

always_ff @(posedge aclk or negedge areset_n) begin
  if(!areset_n) begin
    ctrl              <= '0;
    s_axis_cmd_tready <= '1;
    fsm               <= ST_IDLE;
    axi_ar_clear();
    m_axi_rready      <= '0;
    status            <= '0;
  end
  else begin

    if(transaction_complete)
      s_axis_cmd_tready <= '1;
    else if(s_axis_cmd_tvalid)
      s_axis_cmd_tready <= '0;

    case (fsm)
      ST_IDLE : begin
        axis_status_clear();
        if(transaction_go) begin
          ctrl <= s_axis_cmd_tdata;
          fsm  <= ST_GEN_ADDR;
        end
      end
      ST_GEN_ADDR : begin
        if(!axi_ar_accepted()) begin
          axi_ar_send(ctrl);
        end else begin
          axi_ar_invalid();
          fsm          <= ST_TRANSACTION;
          m_axi_rready <= '1;
        end
      end
      ST_TRANSACTION : begin
        if(m_axi_rlast) begin
          m_axi_rready <= '0;
          fsm          <= ST_TRANSACTION;
          status       <= m_axi_rresp;
        end
      end
      ST_GEN_STATUS : begin
        axis_status_send();
        fsm <= ST_IDLE;
      end
      default : fsm <= ST_IDLE;
    endcase
  end
end

endmodule