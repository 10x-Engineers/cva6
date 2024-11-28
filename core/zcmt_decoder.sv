// Author: Farhan Ali Shah, 10xEngineers
// Date: 15.11.2024
// Description: ZCMT extension in the CVA6 core targeting the 32-bit embedded-class platforms (CV32A60x).
// ZCMT is a code-size reduction feature that utilizes compressed table jump instructions (cm.jt and cm.jalt) to
//reduce code size for embedded systems
//
module zcmt_decoder #(
    parameter config_pkg::cva6_cfg_t CVA6Cfg = config_pkg::cva6_cfg_empty,
    parameter type dcache_req_i_t = logic,
    parameter type dcache_req_o_t = logic,
    parameter type jvt_t = logic,
    parameter type branchpredict_sbe_t = logic
) (
    input logic clk_i,  // Clock
    input logic rst_ni,  // Synchronous reset
    input logic [31:0] instr_i,  // instruction
    input logic [CVA6Cfg.VLEN-1:0] pc_i,  // PC
    input logic is_zcmt_instr_i,  // Intruction is of macro extension
    input logic illegal_instr_i,  // From compressed decoder
    input logic is_compressed_i,  // is compressed instruction
    input logic issue_ack_i,  // Check if the intruction is acknowledged
    input jvt_t jvt_i,
    input dcache_req_o_t req_port_i,  // Data cache request ouput - CACHE

    output logic          [31:0] instr_o,          // Instruction out
    output logic                 illegal_instr_o,  // Illegel instruction
    output logic                 is_compressed_o,  // is compressed instruction
    output logic                 fetch_stall_o,    // Wait while address fetched from table
    output dcache_req_i_t        req_port_o        // Data cache request input - CACHE
);

  // FSM States
  enum logic [1:0] {
    IDLE,         // Wait for ZCMT instruction
    REQ_SENT,     // Request sent to fetch the entry from jump table
    TABLE_FETCH,  // Check the valid data from jump table and record
    JUMP          // Calculate the offset for jump and create jal instruction
  }
      state_d, state_q;

  //zcmt instruction type
  enum logic {
    JT,   // 0 cm.jt instruction
    JALT  // 1: cm.jalt instruction
  } zcmt_instr_type;
  
  // Temporary registers
  logic [7:0] index;  //index of instruction
  //Physical address: jvt + (index <<2)
  logic [CVA6Cfg.XLEN+1:0] table_address;  //Virtual  address: {00,Physical address}
  logic [CVA6Cfg.XLEN-1:0] data_rdata_d, data_rdata_q;  //data received from instruction memory
  logic [20:0] jump_addr;  //jump address immidiate

  always_comb begin
    state_d               = state_q;
    data_rdata_d          = data_rdata_q;
    illegal_instr_o       = 1'b0;
    is_compressed_o       = is_zcmt_instr_i ? 1'b1 : is_compressed_i;
    fetch_stall_o         = is_zcmt_instr_i ? 1'b1 : 0;

    //cache request port
    req_port_o.data_wdata = 1'b0;
    req_port_o.data_wuser = '0;
    req_port_o.data_req   = 1'b0;
    req_port_o.data_we    = 1'b0;
    req_port_o.data_be    = 1'b0;
    req_port_o.data_size  = 2'b10;
    req_port_o.data_id    = 1;
    req_port_o.kill_req   = 0;
    req_port_o.tag_valid  = 1;

    if (is_zcmt_instr_i) begin
      if (instr_i[9:2] < 32) begin  //cm.JT instruction
        zcmt_instr_type = JT;
        index = instr_i[9:2];
      end else if ((instr_i[9:2] >= 32) & (instr_i[9:2] <= 255)) begin  //cm.JALT instruction
        zcmt_instr_type = JALT;
        index = instr_i[9:2];
      end else begin
        illegal_instr_o = 1'b1;
        instr_o = instr_i;
      end

      if (CVA6Cfg.XLEN == 32) begin
        table_address = {2'b00, ({jvt_i.base, jvt_i.mode} + (index << 2))};
        req_port_o.address_index = table_address[9:0];
        req_port_o.address_tag = table_address[33:10];
      end else if (CVA6Cfg.XLEN == 64) begin
        //table_address = {2'b00,({jvt_i.base, jvt_i.mode} + (index << 3))};
        // will will completed in future( for 64 bit embedded core)
        illegal_instr_o = 1'b1;
      end else illegal_instr_o = 1'b1;
    end else begin
      illegal_instr_o = illegal_instr_i;
      instr_o         = instr_i;
    end

    unique case (state_q)
      IDLE: begin
        if (is_zcmt_instr_i) begin
          state_d = REQ_SENT;
        end else begin
          state_d = IDLE;
        end
      end
      REQ_SENT: begin
        state_d = TABLE_FETCH;
        req_port_o.data_req = 1'b1;
      end
      TABLE_FETCH: begin
        if (req_port_i.data_rvalid) begin
          data_rdata_d = req_port_i.data_rdata;
          state_d = JUMP;
        end else begin
          state_d = TABLE_FETCH;
        end
      end
      JUMP: begin
        jump_addr = $unsigned($signed(data_rdata_q) - $signed(pc_i));
        if (zcmt_instr_type == JT) begin //- jal pc_offset, x0 for no return stack
          instr_o = {
            jump_addr[20], jump_addr[10:1], jump_addr[11], jump_addr[19:12], 5'h0, riscv::OpcodeJal
          };  
        end else if (zcmt_instr_type == JALT) begin //- jal pc_offset, x1 for return stack
          instr_o = {
            jump_addr[20], jump_addr[10:1], jump_addr[11], jump_addr[19:12], 5'h1, riscv::OpcodeJal
          }; 
        end
        state_d = IDLE;
      end
      default: begin
        state_d = IDLE;
      end
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      state_q      <= IDLE;
      data_rdata_q <= '0;

    end else begin
      state_q      <= state_d;
      data_rdata_q <= data_rdata_d;
    end
  end
endmodule
