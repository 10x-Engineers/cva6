// =====================================================================
// AXI4-Full DMA Engine (Multi-outstanding, Burst up to 16, 64-bit data)
// Author : Gull
// =====================================================================
module axi4_dma_engine #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 64,
  parameter ID_WIDTH   = 5,
  parameter MAX_BURST  = 16
)(
  input  logic                     clk,
  input  logic                     rst_n,

  // =============================
  // AXI4 Slave Interface (Register Access)
  // =============================
  input  logic [ID_WIDTH-1:0]      s_axi_awid,
  input  logic [ADDR_WIDTH-1:0]    s_axi_awaddr,
  input  logic                     s_axi_awvalid,
  output logic                     s_axi_awready,

  input  logic [DATA_WIDTH-1:0]    s_axi_wdata,
  input  logic [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
  input  logic                     s_axi_wvalid,
  output logic                     s_axi_wready,

  output logic [ID_WIDTH-1:0]      s_axi_bid,
  output logic [1:0]               s_axi_bresp,
  output logic                     s_axi_bvalid,
  input  logic                     s_axi_bready,

  input  logic [ID_WIDTH-1:0]      s_axi_arid,
  input  logic [ADDR_WIDTH-1:0]    s_axi_araddr,
  input  logic                     s_axi_arvalid,
  output logic                     s_axi_arready,

  output logic [ID_WIDTH-1:0]      s_axi_rid,
  output logic [DATA_WIDTH-1:0]    s_axi_rdata,
  output logic [1:0]               s_axi_rresp,
  output logic                     s_axi_rvalid,
  output logic                     s_axi_rlast,
  input  logic                     s_axi_rready,

  // =============================
  // AXI4 Master Interface (Data)
  // =============================
  // Write Address
  output logic [ID_WIDTH-1:0]      m_axi_awid,
  output logic [ADDR_WIDTH-1:0]    m_axi_awaddr,
  output logic [7:0]               m_axi_awlen,
  output logic [2:0]               m_axi_awsize,
  output logic [1:0]               m_axi_awburst,
  output logic                     m_axi_awlock,
  output logic [3:0]               m_axi_awcache,
  output logic [2:0]               m_axi_awprot,
  output logic [3:0]               m_axi_awqos,
  output logic [3:0]               m_axi_awregion,
  output logic [5:0]               m_axi_awuser,
  output logic                     m_axi_awvalid,
  input  logic                     m_axi_awready,

  // Write Data
  output logic [DATA_WIDTH-1:0]    m_axi_wdata,
  output logic [(DATA_WIDTH/8)-1:0] m_axi_wstrb,
  output logic                     m_axi_wlast,
  output logic [5:0]               m_axi_wuser,
  output logic                     m_axi_wvalid,
  input  logic                     m_axi_wready,

  // Write Response
  input  logic [ID_WIDTH-1:0]      m_axi_bid,
  input  logic [1:0]               m_axi_bresp,
  input  logic                     m_axi_bvalid,
  output logic                     m_axi_bready,

  // Read Address
  output logic [ID_WIDTH-1:0]      m_axi_arid,
  output logic [ADDR_WIDTH-1:0]    m_axi_araddr,
  output logic [7:0]               m_axi_arlen,
  output logic [2:0]               m_axi_arsize,
  output logic [1:0]               m_axi_arburst,
  output logic                     m_axi_ar_lock,
  output logic [3:0]               m_axi_ar_cache,
  output logic [2:0]               m_axi_ar_prot,
  output logic [3:0]               m_axi_ar_qos,
  output logic [3:0]               m_axi_ar_region,
  output logic [5:0]               m_axi_ar_user,    // 6
  output logic                     m_axi_arvalid,
  input  logic                     m_axi_arready,

  // Read Data
  input  logic [ID_WIDTH-1:0]      m_axi_rid,
  input  logic [DATA_WIDTH-1:0]    m_axi_rdata,
  input  logic [1:0]               m_axi_rresp,
  input  logic                     m_axi_rlast,
  input  logic                     m_axi_rvalid,
  output logic                     m_axi_rready
);

  // ==========================================================
  // Register Map (accessible via AXI slave)
  // ==========================================================
  typedef enum logic [7:0] {
    REG_SRC_ADDR   = 8'h0,
    REG_DST_ADDR   = 8'h8,
    REG_LEN        = 8'h10,
    REG_CTRL       = 8'h14,
    REG_STATUS     = 8'h18
  } reg_addr_e;

  logic [ADDR_WIDTH-1:0] src_addr_reg, dst_addr_reg;
  logic [31:0]           len_reg;
  logic [31:0]           ctrl_reg;
  logic [31:0]           status_reg;
  logic [ID_WIDTH-1:0] s_axi_arid_reg;
  logic [ID_WIDTH-1:0] s_axi_bid_reg;

  // CTRL bits
  localparam CTRL_START_BIT  = 0;
  localparam CTRL_DIR_BIT    = 1; // 0=Read (Mem->Dev), 1=Write (Dev->Mem)
  localparam CTRL_BURST_BITS = 4;

  // STATUS bits
  localparam STATUS_BUSY_BIT = 0;
  localparam STATUS_DONE_BIT = 1;

  // ==========================================================
  // AXI Slave Register Access
  // ==========================================================
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      s_axi_awready <= 0;
      s_axi_wready  <= 0;
      s_axi_bvalid  <= 0;
      s_axi_arready <= 0;
      s_axi_rvalid  <= 0;
      src_addr_reg  <= 0;
      dst_addr_reg  <= 0;
      len_reg       <= 0;
      ctrl_reg      <= 0;
      status_reg    <= 0;
      s_axi_arid_reg <= '0;
      s_axi_rlast <= '0;
      s_axi_bid_reg <= '0;
    end else begin
      // Write channel
      s_axi_awready <= s_axi_awvalid && s_axi_wvalid;
      s_axi_wready  <= s_axi_awvalid && s_axi_wvalid;
      if (s_axi_awvalid && s_axi_wvalid && s_axi_awready && s_axi_wready) begin
        case (s_axi_awaddr[7:0])
          REG_SRC_ADDR: src_addr_reg <= s_axi_wdata[ADDR_WIDTH-1:0];
          REG_DST_ADDR: dst_addr_reg <= s_axi_wdata[ADDR_WIDTH-1:0];
          REG_LEN:      len_reg      <= s_axi_wdata[31:0];
          REG_CTRL:     ctrl_reg     <= s_axi_awaddr[2] ? s_axi_wdata[63:32] : s_axi_wdata[31:0];
        endcase
        s_axi_bvalid <= 1;
        s_axi_bid_reg <= s_axi_awid;
      end else if (s_axi_bvalid && s_axi_bready)
        s_axi_bvalid <= 0;

      // Read channel
      s_axi_arready <= s_axi_arvalid;
      if (s_axi_arvalid && s_axi_arready) begin
        case (s_axi_araddr[7:0])
          REG_SRC_ADDR: s_axi_rdata <= src_addr_reg;
          REG_DST_ADDR: s_axi_rdata <= dst_addr_reg;
          REG_LEN:      s_axi_rdata <= len_reg;
          REG_CTRL:     s_axi_rdata <= ctrl_reg;
          REG_STATUS:   s_axi_rdata <= status_reg;
          default:      s_axi_rdata <= 0;
        endcase
        s_axi_rvalid <= 1;
        s_axi_arid_reg <= s_axi_arid;
        s_axi_rlast <= 1;
      end else if (s_axi_rvalid && s_axi_rready)
        s_axi_rvalid <= 0;

      if((m_axi_rvalid & m_axi_rready) | (m_axi_bvalid & m_axi_bready)) begin
        ctrl_reg[0] <= 1'b0; // Indicate transfer completion
      end
    end
  end
  assign s_axi_bresp = 2'b00;
  assign s_axi_rresp = 2'b00;
  assign s_axi_rid   = s_axi_arid_reg;
  assign s_axi_bid   = s_axi_bid_reg;

  // ==========================================================
  // DMA FSM
  // ==========================================================
  typedef enum logic [3:0] {
    IDLE,
    READ_ADDR,
    READ_DATA,
    WRITE_ADDR,
    WRITE_DATA,
    WAIT_RESP,
    COMPLETE
  } dma_state_e;

  dma_state_e state, next_state;

  logic [ADDR_WIDTH-1:0] addr_ptr_src, addr_ptr_dst;
  logic [31:0]           bytes_remaining;
  logic [7:0]            burst_len;
  logic [2047:0] [63:0] data_buf;
  integer                i;

  // assign burst_len = (len_reg >= (MAX_BURST * (DATA_WIDTH/8))) ? (MAX_BURST-1) :
  //                    ((len_reg / (DATA_WIDTH/8)) - 1);

  assign burst_len = 8'h0;

  // FSM state transitions
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else        state <= next_state;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) data_buf <= '0;
    else if (m_axi_rvalid & m_axi_rready & !(|m_axi_rresp)) data_buf[dst_addr_reg[10:0]] <= m_axi_rdata;
  end

  always_comb begin
    next_state = state;
    case (state)
      IDLE: if (ctrl_reg[CTRL_START_BIT])
               next_state = (ctrl_reg[CTRL_DIR_BIT]) ? WRITE_ADDR : READ_ADDR;

      READ_ADDR:  if (m_axi_arready) next_state = READ_DATA;
      READ_DATA:  if (m_axi_rvalid && m_axi_rlast) next_state = COMPLETE;

      WRITE_ADDR: if (m_axi_awready & m_axi_wready && m_axi_wlast) next_state = WAIT_RESP;
      WRITE_DATA: if (m_axi_wvalid && m_axi_wlast) next_state = WAIT_RESP;
      WAIT_RESP:  if (m_axi_bvalid) next_state = COMPLETE;
      COMPLETE:   next_state = IDLE;
    endcase
  end

  assign m_axi_awid     = '0;       // 5
  assign m_axi_awaddr   = dst_addr_reg;     // 52/34
  assign m_axi_awlen    = '0;      // 8
  assign m_axi_awsize   = 3'h3;     // 3
  assign m_axi_awburst  = '0;
  assign m_axi_awlock   = '0;
  assign m_axi_awcache  = '0;
  assign m_axi_awprot   = '0;
  assign m_axi_awqos    = '0;
  assign m_axi_awregion = '0;
  assign m_axi_awuser   = 6'h2;
  assign m_axi_awvalid  = (state == WRITE_ADDR);

  assign m_axi_wdata    = data_buf[src_addr_reg[10:0]]; // In real DMA, loop through buffer
  assign m_axi_wstrb    = '1;
  assign m_axi_wlast    = 1'b1;
  assign m_axi_wuser    = 6'h2;
  assign m_axi_wvalid   = (state == WRITE_ADDR);
  assign m_axi_bready   = 1'b1;

  assign m_axi_arid     = '0;
  assign m_axi_araddr   = src_addr_reg;
  assign m_axi_arlen    = '0;
  assign m_axi_arsize   = 3'h3;
  assign m_axi_arburst  = '0;
  assign m_axi_arlock   = '0;
  assign m_axi_arcache  = '0;
  assign m_axi_arprot   = '0;
  assign m_axi_arqos    = '0;
  assign m_axi_arregion = '0;
  assign m_axi_ar_user  = 6'h2;
  assign m_axi_arvalid  = (state == READ_ADDR);
  assign m_axi_rready   = 1'b1;

endmodule

