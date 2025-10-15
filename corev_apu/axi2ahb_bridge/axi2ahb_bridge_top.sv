// AXI4 to AHB-Lite bridge (non-pipelined, correct AHB two-phase)
// - Single-beat transfers only (no bursts)
// - AHB uses only IDLE and NONSEQ
// - Fixed 32-bit accesses
// - Non-pipelined: Address phase and Data phase are separated and do NOT overlap
// - AXI write requires AW + W handshake (common simple approach)
module axi2ahb_bridge_top (
    input  logic        aclk,
    input  logic        aresetn,
    // AXI4 write address channel
    input  logic [8:0]  axi_awid,
    input  logic [31:0] axi_awaddr,
    input  logic [7:0]  axi_awlen,
    input  logic [2:0]  axi_awsize,
    input  logic [1:0]  axi_awburst,
    input  logic        axi_awvalid,
    output logic        axi_awready,
    // AXI4 write data channel
    input  logic [63:0] axi_wdata,
    input  logic [3:0]  axi_wstrb,
    input  logic        axi_wlast,
    input  logic        axi_wvalid,
    output logic        axi_wready,
    // AXI4 write response channel
    output logic [8:0]  axi_bid,
    output logic [1:0]  axi_bresp,
    output logic        axi_bvalid,
    input  logic        axi_bready,
    // AXI4 read address channel
    input  logic [8:0]  axi_arid,
    input  logic [31:0] axi_araddr,
    input  logic [7:0]  axi_arlen,
    input  logic [2:0]  axi_arsize,
    input  logic [1:0]  axi_arburst,
    input  logic        axi_arvalid,
    output logic        axi_arready,
    // AXI4 read data channel
    output logic [8:0]  axi_rid,
    output logic [63:0] axi_rdata,
    output logic [1:0]  axi_rresp,
    output logic        axi_rlast,
    output logic        axi_rvalid,
    input  logic        axi_rready,
    // AHB-Lite master interface
    output logic [31:0] haddr,
    output logic [1:0]  htrans,
    output logic        hwrite,
    output logic [2:0]  hsize,
    output logic [63:0] hwdata,
    input  logic [63:0] hrdata,
    input  logic        hready,
    input  logic [1:0]  hresp
);
// AHB transfer types (we only use IDLE and NONSEQ)
localparam HTRANS_IDLE  = 2'b00;
localparam HTRANS_NONSEQ = 2'b10;
// Bridge states implementing two-phase AHB: IDLE -> ADDR -> DATA -> RESP
typedef enum logic [1:0] {S_IDLE=2'd0, S_ADDR=2'd1, S_DATA=2'd2, S_RESP=2'd3} state_t;
state_t state_r, state_n;
// Internal registers
logic [8:0]  id_reg;
logic [31:0] addr_reg;
logic [63:0] wdata_reg;
logic [3:0]  wstrb_reg;
logic        pending_write; // 1=write, 0=read
logic [63:0] hrdata_reg_n, hrdata_reg;
// AXI response constants
localparam AXI_RESP_OKAY = 2'b00;
// Default combinational outputs
always_comb begin
    // AXI defaults
    axi_awready = 1'b0;
    axi_wready  = 1'b0;
    axi_bvalid  = 1'b0;
    axi_bresp   = AXI_RESP_OKAY;
    axi_bid     = id_reg;
    axi_arready = 1'b0;
    axi_rvalid  = 1'b0;
    axi_rresp   = AXI_RESP_OKAY;
    axi_rdata   = hrdata; // pass-through when ready
    axi_rid     = id_reg;
    axi_rlast   = 1'b1;
    // AHB defaults
    haddr  = 32'h0;
    htrans = HTRANS_IDLE;
    hwrite = 1'b0;
    hsize  = 3'd2; // 32-bit
    hwdata = 'h0;
    state_n = state_r;
	hrdata_reg_n = '0;
    // Next-state / outputs
    case (state_r)
        // Idle: accept new AXI request
        S_IDLE: begin
          axi_arready = 1'b1;
          axi_awready = 1'b0;
          axi_wready  = 1'b0;
            // Accept a write only when AW and W are both valid (simple bridge policy)
            if (axi_awvalid && axi_wvalid) begin
                // handshake acceptance --- pulse ready so master sees acceptance
                // capture AW/W into regs (sequencing handled in sequential block)
                // Drive AHB address phase signals for one cycle: NONSEQ + address
                haddr  = '0;
                htrans = '0;
                hwrite = 1'b0;
                hsize  = 3'd0;
				axi_awready = 1'b1;
				axi_wready  = 1'b1;
                // NOTE: hwdata must NOT be driven in address phase in compliance with AHB
                state_n = S_ADDR;
            end else if (axi_arvalid) begin
                // Drive AHB address phase for read
                haddr  = '0;
                htrans = '0;
                hwrite = 1'b0;
                hsize  = 3'd0;
                state_n = S_ADDR;
            end
        end
        // Address phase: address/control driven. On next cycle, move to DATA phase.
        S_ADDR: begin
            // Maintain address phase outputs until next clock edge
            haddr  = addr_reg;
            htrans = HTRANS_NONSEQ;
            hwrite = pending_write;
            hsize  = 3'd2;
            // In this non-pipelined bridge we wait one cycle (address phase)
            // then move to DATA phase where data is transferred and we wait for hready.
            state_n = S_DATA;
        end
        // Data phase: for writes drive hwdata and wait for hready; for reads wait for hready/sample hrdata
        S_DATA: begin
            haddr  = addr_reg;
            // Once in data phase, htrans must go IDLE (data phase uses htrans=IDLE in AHB spec)
            htrans = HTRANS_IDLE;
			hrdata_reg_n = hrdata;
            hwrite = '0;
            hsize  = 3'd2;
            if (pending_write) begin
                // Drive write data in data phase
                hwdata = wdata_reg;
                // Wait for hready to indicate completion
                if (hready) begin
                    // Proceed to RESP to produce AXI response
                    state_n = S_RESP;
                end else begin
                    state_n = S_DATA;
                end
            end else begin
                // Read: wait for hready and sample hrdata
                if (hready) begin
                    // hrdata is available this cycle; produce AXI read response
                    state_n = S_RESP;
                end else begin
                    state_n = S_DATA;
                end
            end
        end
        // RESP: present AXI response (B or R) until accepted, then return to IDLE
        S_RESP: begin
            if (pending_write) begin
                axi_bvalid = 1'b1;
                axi_bresp  = AXI_RESP_OKAY;
                axi_bid    = id_reg;
                if (axi_bready) begin
                    state_n = S_IDLE;
                end else begin
                    state_n = S_RESP;
                end
            end else begin
                axi_rvalid = 1'b1;
                axi_rresp  = AXI_RESP_OKAY;
                axi_rdata  = hrdata_reg; // sampled from slave
                axi_rid    = id_reg;
                axi_rlast  = 1'b1;
                if (axi_rready) begin
                    state_n = S_IDLE;
                end else begin
                    state_n = S_RESP;
                end
            end
        end
        default: state_n = S_IDLE;
    endcase
end
// Sequential: capture AXI signals into registers on accept and maintain state
always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        state_r <= S_IDLE;
        id_reg <= 'h0;
        addr_reg <= 32'h0;
        wdata_reg <= 'h0;
        wstrb_reg <= 4'h0;
        pending_write <= 1'b0;
		hrdata_reg	<= '0;
    end else begin
        state_r <= state_n;
		hrdata_reg <= hrdata_reg_n;
        // Capture AW+W for write when they are accepted (axi_awready && axi_wready)
        if (state_r == S_IDLE) begin
            if (axi_awvalid && axi_wvalid) begin
                // record id/address/data for the upcoming transfer
                id_reg <= axi_awid;
                addr_reg <= axi_awaddr;
                wdata_reg <= axi_wdata;
                wstrb_reg <= axi_wstrb;
                pending_write <= 1'b1;
            end else if (axi_arvalid) begin
                id_reg <= axi_arid;
                addr_reg <= axi_araddr;
                pending_write <= 1'b0;
            end
        end
        // Clear registers when returning to IDLE after response accepted
        if (state_r == S_RESP && state_n == S_IDLE) begin
            addr_reg <= 32'h0;
            wdata_reg <= 'h0;
            wstrb_reg <= 4'h0;
            pending_write <= 1'b0;
            id_reg <= 'h0;
        end
    end
end
// Optional SVA checks as comments (use assertions in your testbench):
// - assert(addr aligned to 4 bytes)
// - assert(axi_awsize == 2'b010 && axi_arsize == 2'b010) // 32-bit
// - assert(HTRANS only IDLE or NONSEQ driven)
endmodule
