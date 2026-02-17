///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 25-June-2025
/// Description:
///////////////////////////////////////////////////////////////////////////

module mdcfg_regs
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import rfm_pkg::mdcfg_t;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic          clk,                     // Clock Rising Edge
  input  logic          rst_n,                   // Reset Active Low

  // AHB-LITE Interface ==> MDCFG Registers
  input  logic [2:0]    mdcfg_selected_demux,    // MDCFG demux to select
  input  logic [2:0]    mdcfg_reg_demux_sel,     // MDCFG register write path demux select signal
  input  logic [15:0]   mdcfg_reg_swdata,        // Write data for MDCFG registers

  // Address Check ==> MDCFG Registers
  input  logic          mdcfg_legal,             // Indicates whether incoming address belongs to MDCFG region section 1

  // Regmap ==> MDCFG Registers
  input  logic          mdcfg_reg_write_valid,   // MDCFG register write valid signal

  // Base Registers ==> MDCFG Registers
  input  logic [5:0]    mdcfglck_f,              // Indicates the number of locked mdcfg registers
  input  logic [7:0]    hwcfg1_entry_num,        // Indicates the number of supoorted entries

  // MDCFG Registers ==> Regmap
  output mdcfg_t [62:0] mdcfg_table              // MDCFG Registers
);

  localparam NUM_MDCFG_DEMUXES = (int'(CFG.MD_NUM) + 7)/8;   // Indicates the number of MDCFG Register demuxes

  //###############################
  // Internal Signals Declarations
  //###############################

  logic                         is_mdcfg_reg_locked, is_write_valid, is_write_data_valid;   // Indicates if writing to mdcfg is allowed, based on locking condition and WARL access.
  logic                         mdcfg_reg_write_valid_q;
  logic [2:0]                   mdcfg_reg_demux_sel_q, mdcfg_selected_demux_q;
  logic [15:0]                  mdcfg_reg_swdata_q;
  logic [NUM_MDCFG_DEMUXES-1:0] mdcfg_demux_enable;
  int                           mdcfg_reg_index;

  // Registers/Fields SW write enable and write data signals
  logic [CFG.MD_NUM-1:0][15:0] mdcfg_t_swdata;
  logic [CFG.MD_NUM-1:0]       mdcfg_t_swen;

  // Determine whether MDCFG(m) is locked based on mdcfglck.f. MDCFG(m) is locked for m < mdcfglck.f
  // To get the mdcfg register offset multiply the mdcfg_selected_demux_q value by 8 (shift by 3) and add mdcfg_reg_demux_sel_q
  assign is_mdcfg_reg_locked = (({3'b000, mdcfg_reg_demux_sel_q} + ({3'b000, mdcfg_selected_demux_q} << 3)) < mdcfglck_f);

  // Determine whether write is allowed on register based on locking condition
  assign is_write_valid = mdcfg_reg_write_valid_q && !is_mdcfg_reg_locked;

  // MDCFG(m).t is a WARL field. The range of legal value is defined by hwcfg1.entry_num
  assign is_write_data_valid = (mdcfg_reg_swdata_q <= {{8{1'b0}}, hwcfg1_entry_num});

  //****************************************************************************************************
  // Generate DEMUX enable signals
  //****************************************************************************************************
  for (genvar i = 0; i < NUM_MDCFG_DEMUXES; i++) begin : gen_mdcfg_demux_enable

    // Determine the mdcfg demux to select based on mdcfg_selected_demux_q (address bit [7:5]) signal and qualify it with
    // mdcfg_legal signal to generate demux enable signals
    assign mdcfg_demux_enable[i] = mdcfg_legal && (mdcfg_selected_demux_q == i);
  end

  //****************************************************************************************************
  // Registers/Fields SW Write Data Signals based on WARL Condition
  //****************************************************************************************************
  for (genvar m_reg_index = 0; m_reg_index < int'(CFG.MD_NUM); m_reg_index++) begin : gen_mdcfg_swdata

    // MDCFG.t is programmed with the new data when data is legal (mdcfg_reg_swdata_q <= hwcfg1_entry_num),
    // otherwise the field is configured with maximum supported value hwcfg1_entry_num
    assign mdcfg_t_swdata[m_reg_index] = is_write_data_valid ?
                                         mdcfg_reg_swdata_q :       // Write new data
                                         {{8{1'b0}}, hwcfg1_entry_num};   // Configure to maximum supported value
  end

  //****************************************************************************************************
  // DEMUX for Registers/Fields SW Write Enable Signals
  //****************************************************************************************************
  always_comb begin : mdcfg_write_path

    // The outer loop generates the mdcfg register demuxes based on NUM_MDCFG_DEMUXES
    for (int j = 0; j < NUM_MDCFG_DEMUXES; j++) begin : gen_write_outer_loop

      // The inner for loop generates 8 instances of mdcfg register/fields SW write enable per demux
      for (int i = 0; i < 8; i++) begin : gen_write_inner_loop

        // Each demux maps 8 mdcfg registers, so the j (outer loop variable) is multiplied by 8 and i (inner loop variable) is added to get the register index
        mdcfg_reg_index = (j << 3) + i;

        // Check if MDCFG register exist and then generate its SW write valid signal. MD_NUM indicates the supported number of MDCFG registers
        // so mdcfg_reg_index should always be less than MD_NUM
        if (mdcfg_reg_index < int'(CFG.MD_NUM)) begin : gen_valid_mdcfg_write

          // Determine the register/fields to write based on mdcfg_reg_demux_sel_q (address bits [4:2]) and corrpsonding demux enable signal
          if ((mdcfg_reg_demux_sel_q == i[2:0]) && mdcfg_demux_enable[j]) begin

            // Drive SW write enable signal for selected register if it is not locked
            mdcfg_t_swen[mdcfg_reg_index] = is_write_valid;
          end

          // Drive SW write enable signal zero when demux is not enabled
          else begin
            mdcfg_t_swen[mdcfg_reg_index] = 1'b0;
          end
        end
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mdcfg_reg_write_valid_q <= 1'b0;
      mdcfg_reg_swdata_q      <= '0;
      mdcfg_reg_demux_sel_q   <= '0;
      mdcfg_selected_demux_q  <= '0;
    end
    else begin
      mdcfg_reg_write_valid_q <= mdcfg_reg_write_valid;
      mdcfg_reg_swdata_q      <= mdcfg_reg_swdata;
      mdcfg_reg_demux_sel_q   <= mdcfg_reg_demux_sel;
      mdcfg_selected_demux_q  <= mdcfg_selected_demux;
    end
  end

  //****************************************************************************************************
  // MDCFG REGISTERS
  //****************************************************************************************************

  // Generate MDCFG registers based on MD_NUM value
  for (genvar curr_index = 0; curr_index < int'(CFG.MD_NUM); curr_index++) begin : gen_mdcfg_regs

    // ########### MDCFG ###########
    regfield #(
      .DW      (16),
      .SWACCESS("RW"),
      .RESVAL  ('0)
    ) u_mdcfg_t
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (mdcfg_t_swen[curr_index]),
      .swdata  (mdcfg_t_swdata[curr_index]),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (mdcfg_table[curr_index].t)
    );
  end

  // If MD_NUM is less than 63, generate rest of the mdcfg registers hardwired zero
  for (genvar curr_index = int'(CFG.MD_NUM); curr_index < int'(63); curr_index++) begin : gen_mdcfg_regs_hardwired_zeros
    assign mdcfg_table[curr_index].t = '0;
  end

endmodule
