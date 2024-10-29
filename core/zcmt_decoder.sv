// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Rohan Arshid, 10xEngineers
// Date: 22.01.2024
// Description: Contains the logic for decoding cm.push, cm.pop, cm.popret, 
//              cm.popretz, cm.mvsa01, and cm.mva01s instructions of the 
//              Zcmp Extension

module zcmt_decoder #(
  parameter config_pkg::cva6_cfg_t CVA6Cfg = config_pkg::cva6_cfg_empty,
  parameter type dcache_req_i_t = logic,
  parameter type dcache_req_o_t = logic
) (
  input  logic [31:0] instr_i,
  input  logic [CVA6Cfg.VLEN-1:0] pc_i,
  input  logic        clk_i,                      // Clock
  input  logic        rst_ni,                     // Synchronous reset
  input  logic        is_macro_instr_i,           // Intruction is of macro extension
  input  logic        illegal_instr_i,            // From compressed decoder
  input  logic        is_compressed_i,
  input  logic        issue_ack_i,                // Check if the intruction is acknowledged
  input  logic [CVA6Cfg.XLEN-1:6] jvt_base_i,
  input  logic [5:0] jvt_mode_i,
  output logic [31:0] instr_o,
  output logic        illegal_instr_o,
  output logic        is_compressed_o,
  output logic        fetch_stall_o,              //Wait while push/pop/move instructions expand
  output logic        is_last_macro_instr_o,
  output logic        is_double_rd_macro_instr_o,
  output logic [CVA6Cfg.XLEN-1:0] table_address,
  // Data cache request ouput - CACHE
  input dcache_req_o_t req_port_i,
  // Data cache request input - CACHE
  output dcache_req_i_t req_port_o
  );

// FSM States
enum logic {
  IDLE,
  TABLE_FETCH
}
    state_d, state_q;

//zcmt instruction type
enum logic{
  JT,
  JALT
} zcmt_instr_type;

// Temporary registers

logic [31:0] instr_o_reg;

logic [7:0] index;
logic [31:0] jvt_table_add;


logic                                 data_gnt;
logic                                 data_rvalid;
logic [CVA6Cfg.DcacheIdWidth-1:0]     data_rid;
logic [CVA6Cfg.XLEN-1:0]              data_rdata;
logic [CVA6Cfg.DCACHE_USER_WIDTH-1:0] data_ruser;

logic [CVA6Cfg.XLEN+1:0]               table_a;
logic [20:0]              jump_add;
logic [20:0]                          pc_offset;


assign data_gnt     = req_port_i.data_gnt;
assign data_rvalid  = req_port_i.data_rvalid;
assign data_rid     = req_port_i.data_rid;

assign data_ruser   = req_port_i.data_ruser;

riscv::itype_t itype_inst;
assign instr_o = instr_o_reg;
always_comb begin
  state_d                    = state_q;
  illegal_instr_o            = 1'b0;
  fetch_stall_o              = 1'b0;
  is_last_macro_instr_o      = 1'b0;
  is_double_rd_macro_instr_o = 1'b0;
  is_compressed_o            = is_macro_instr_i ? 1'b1 : is_compressed_i;
  table_address              = '0;

  if (is_macro_instr_i) begin

    unique case (instr_i[12:10])
      //zcmt instruction
      3'b000: begin
        if(instr_i[9:2] < 32) begin                 //JT instruction
            zcmt_instr_type = JT;
            index = instr_i[9:2];
        end else if(instr_i[9:2] >= 32) begin       //JALT instruction
            zcmt_instr_type = JALT;
            index = instr_i[9:2];
        end else begin
            illegal_instr_o = 1'b1;
            instr_o_reg     = instr_i;
        end
      end
      default: begin
        illegal_instr_o = 1'b1;
        instr_o_reg     = instr_i;
      end
    endcase

  end else begin
    illegal_instr_o = illegal_instr_i;
    instr_o_reg     = instr_i;
  end

  unique case (state_q)
    IDLE: begin
      if (is_macro_instr_i) begin
        state_d = TABLE_FETCH;
        fetch_stall_o = 1;
        //is_last_macro_instr_o = 1;
      
        case (zcmt_instr_type)
          JT: begin
              if(CVA6Cfg.XLEN  == 32) begin
                  jvt_table_add = {jvt_base_i[31:6],6'b000000};
                  table_address =  jvt_table_add + (index <<2);
                  table_a = {2'b00,table_address[CVA6Cfg.XLEN-1:0]};
                  req_port_o.address_index = table_a[9:0];
                  req_port_o.address_tag = table_a[33:10];
                  req_port_o.data_wdata = 1'b0;
                  req_port_o.data_wuser = '0;
                  req_port_o.data_req = 1'b1;
                  req_port_o.data_we = 1'b0;
                  req_port_o.data_be = 1'b0;
                  req_port_o.data_size = 2'b10;
                  req_port_o.data_id = 3;
                  req_port_o.kill_req = 0;
                  req_port_o.tag_valid = 1;
          
                end else if(CVA6Cfg.XLEN  == 64) begin
                  jvt_table_add = {jvt_base_i[31:6],6'b000000};
                  table_address =  jvt_table_add + (index <<3);
                  table_a = {2'b00,table_address[CVA6Cfg.XLEN-1:0]};
                          
                end else begin
                  illegal_instr_o = 1'b1;
                  instr_o_reg     = instr_i;
                end
          end
          JALT: begin
              if(CVA6Cfg.XLEN  == 32) begin
                  jvt_table_add = {jvt_base_i[31:6],6'b000000};
                  table_address =  jvt_table_add + (index <<3);
                  table_a = {2'b00,table_address[CVA6Cfg.XLEN-1:0]};
                  req_port_o.address_index = table_a[9:0];
                  req_port_o.address_tag = table_a[33:10];
                  req_port_o.data_wdata = 1'b1;
                  req_port_o.data_wuser = '0;
                  req_port_o.data_req = 1'b1;
                  req_port_o.data_we = 1'b0;
                  req_port_o.data_be = 1'b0;
                  req_port_o.data_size = 2'b11;
                  req_port_o.data_id = 3;
                  req_port_o.kill_req = 0;
                  req_port_o.tag_valid = 1;
              
                end else if(CVA6Cfg.XLEN  == 64) begin
                    jvt_table_add = {jvt_base_i[31:6],6'b000000};
                    table_address =  jvt_table_add + (index <<3);
                    table_a = {2'b00,table_address[CVA6Cfg.XLEN-1:0]};
                
                end else begin
                  illegal_instr_o = 1'b1;
                  instr_o_reg     = instr_i;
                  
                end
                
          end
          default: state_d = IDLE;
        endcase
        
      end else begin
        state_d = IDLE;
      end
    end
    TABLE_FETCH: begin
      if (data_rid & data_rvalid) begin
          data_rdata   = req_port_i.data_rdata;
          //pc_offset = pc_i - data_rdata;
          //jump_add = pc_offset & ~1;
          jump_add = $unsigned($signed(pc_i) - $signed(data_rdata));
          instr_o_reg = {jump_add, 5'h0, riscv::OpcodeJal};  //- jal pc_offset, x0
  
          fetch_stall_o = 0;
          is_last_macro_instr_o = 1;
          //is_double_rd_macro_instr_o = 1;
          state_d = IDLE;
      end else begin
          state_d = TABLE_FETCH;
      end
    end
    default: begin
      state_d = IDLE;
    end
  endcase
end

always_ff @(posedge clk_i or negedge rst_ni) begin
  if (~rst_ni) begin
    state_q <= IDLE;

  end else begin
    state_q <= state_d;

  end
end
endmodule
