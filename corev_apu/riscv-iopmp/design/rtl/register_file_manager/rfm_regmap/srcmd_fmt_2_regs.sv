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

module srcmd_fmt_2_regs
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import rfm_pkg::srcmd_table_2_t;
  import rfm_pkg::IOPMP_SRCMD_PERM;
  import rfm_pkg::IOPMP_SRCMD_PERMH;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                            clk,                      // Clock Rising Edge
  input  logic                            rst_n,                    // Reset Active Low

  // AHB-LITE Interface ==> SRCMD Format 2 Registers
  input  logic [5:0]                      srcmd_selected_demux,     // SRCMD demux to select
  input  logic [2:0]                      srcmd_reg_demux_sel,      // SRCMD register write path demux select signal
  input  logic [AHB_LITE_DATA_WIDTH-1:0]  srcmd_reg_swdata,         // Write data for SRCMD TABLE registers

  // Address Check ==> Regmap
  input  logic                            srcmd_legal,              // Indicates whether incoming address belongs to a legal register in SRCMD region section 1

  // Regmap ==> SRCMD TABLE Registers
  input  logic                            srcmd_reg_write_valid,    // SRCMD TABLE register Write valid signal

  // Base Registers ==> SRCMD Format 2 Registers
  input  logic [30:0]                     mdlck_md,                 // MDLCK.md[m] indicates that SRCMD_PERM(m), SRCMD_PERMH(m) is locked where 0 <= m <= 30
  input  logic [31:0]                     mdlckh_mdh,               // MDLCKH.mdh[m] indicates that SRCMD_PERM(m), SRCMD_PERMH(m) is locked where 30 < m <= 62

  // SRCMD Format 2 Registers ==> Regmap
  output srcmd_table_2_t [62:0]           srcmd_table_2             // SRCMD TABLE registers struct required in TTU for srcmd table traversal
);

  localparam MD_NUM_BY_8 = ((int'(CFG.MD_NUM) + 7)/8);

  //###############################
  // Internal Signals Declarations
  //###############################

  logic                           is_write_allowed;
  logic [CFG.MD_NUM-1:0]          srcmd_demux_enable;
  logic [MD_NUM_BY_8-1:0]         srcmd_reg_write_valid_q, srcmd_legal_q;
  logic [MD_NUM_BY_8-1:0][2:0]    srcmd_reg_demux_sel_q;
  logic [MD_NUM_BY_8-1:0][5:0]    srcmd_selected_demux_q;
  logic [AHB_LITE_DATA_WIDTH-1:0] srcmd_perm_reg_swdata_q, srcmd_permh_reg_swdata_q;
  int                             srcmd_reg_index;

  // Registers/Fields SW write enable and write data signals
  logic [CFG.MD_NUM-1:0][31:0] srcmd_perm_swdata;
  logic [CFG.MD_NUM-1:0]       srcmd_perm_swen;
  logic [CFG.MD_NUM-1:0][31:0] srcmd_permh_swdata;
  logic [CFG.MD_NUM-1:0]       srcmd_permh_swen;

  //****************************************************************************************************
  // Generate DEMUX enable signals for SRCMD Format 2
  //****************************************************************************************************
  generate

    // The outer loop divides the number of SRCMD demuxes into a block of 8 demuxes as 1 flop of srcmd_selected_demux_q and srcmd_legal_q
    // should not drive more than 8 demuxes enable signal
    for (genvar j = 0; j < MD_NUM_BY_8; j++) begin : gen_demux_enable_outer_loop

      // The inner loop generates 8 demux enable signal based on srcmd_selected_demux_q and srcmd_legal_q
      for (genvar i = 0; i < 8; i++) begin : gen_demux_enable_inner_loop

        // Each demux maps 1 SRCMD register block (containing SRCMD_EN, SRCMD_ENH, ..., SRCMD_WH), so the j (outer loop variable)
        // is multiplied by 8 and i (inner loop variable) is added to get the block index.
        // MD_NUM indicates the supported number of SRCMD registers so ((j << 3) + i) should always be less than MD_NUM
        if ((j << 3) + i < int'(CFG.MD_NUM)) begin : valid_srcmd_index

          // Determine the srcmd demux to select based on srcmd_selected_demux_q (address bit [10:5]) signal and qualify it with
          // srcmd_legal_q signal to generate demux enable signals
          assign srcmd_demux_enable[(j << 3) + i] = srcmd_legal_q[j] && (srcmd_selected_demux_q[j][2:0] == i) && (srcmd_selected_demux_q[j][5:3] == j);
        end
      end
    end
  endgenerate

  //****************************************************************************************************
  // Registers/Fields SW write data signals for SRCDM Format 2
  //****************************************************************************************************
  for (genvar s_reg_index = 0; s_reg_index < int'(CFG.MD_NUM); s_reg_index++) begin : gen_srcmd_regs_swdata

    // SRCMD_PERM(m) SW Write Data Signals
    assign srcmd_perm_swdata[s_reg_index] = srcmd_perm_reg_swdata_q;

    // SRCMD_PERMH(m) SW Write Data Signals
    assign srcmd_permh_swdata[s_reg_index] = srcmd_permh_reg_swdata_q;
  end

  //****************************************************************************************************
  // DEMUX for Registers/Fields SW Write Enable Signals for SRCMD Format 2
  //****************************************************************************************************
  always_comb begin : srcmd_fmt_2_write_path

    // The outer loop divides the number of SRCMD demuxes into a block of 8 demuxes as 1 write valid signal should drive not more than 64 registers
    for (int j = 0; j < MD_NUM_BY_8; j++) begin : gen_write_outer_loop

      // The inner loop generates 8 instances of SRCMD register block sw write enable signals per demux
      for (int i = 0; i < 8; i++) begin : gen_write_inner_loop

        // Each demux maps 1 SRCMD register block (containing SRCMD_PERM, SRCMD_PERMH), so the j (outer loop variable) is multiplied by 8 and i (inner loop variable) is added to get the block index
        srcmd_reg_index = (j << 3) + i;

        // Check if SRCMD registers exist for srcmd_reg_index and then generate its SW write valid signal.
        // MD_NUM indicates the supported number of SRCMD registers so srcmd_reg_index should always be less than MD_NUM
        if (srcmd_reg_index < int'(CFG.MD_NUM)) begin : gen_valid_srcmd_index_write

          //****************************************************************************************************
          // Determine SRCMD register write based on MDLCK MDLCKH registers
          //****************************************************************************************************

          // Write on SRCMD Table register is determined by MDCLK MDLCKH registers if IMP_MDLCK is 1
          if (CFG.IMP_MDLCK) begin : gen_mdlck_dependent_write

            // For MD 0 <= m <= 30, MDLCK.md[m] locks both SRCMD_PERM(m) and SRCMD_PERMH(m)
            if (((srcmd_reg_index) < 32'd31))
              is_write_allowed = (!mdlck_md[srcmd_reg_index]) && srcmd_reg_write_valid_q[j];

            // For MD 31 <= m <= 62, MDLCKH.mdh[m] locks both SRCMD_PERM(m) and SRCMD_PERMH(m)
            else
              is_write_allowed = (!mdlckh_mdh[srcmd_reg_index-32'd31]) && srcmd_reg_write_valid_q[j];
          end

          // Write on SRCMD TABLE is independent of MDLCK registers when IMP_MDLCK is 0
          else begin : gen_mdlck_independent_write
            is_write_allowed = srcmd_reg_write_valid_q[j];
          end

          // The signal srcmd_demux_enable act as an enable signal to SRCMD demux
          // When high it indicates demux is enabled and determine the SRCMD register to write based on srcmd_reg_demux_sel signal
          if (srcmd_demux_enable[srcmd_reg_index]) begin : gen_write_demux_enable

            // Drive the SW write enable signals of SRCMD registers indexed by srcmd_reg_index low before matching any case
            // The case statement only handles the SW write enable signal for the particular register it matches
            srcmd_perm_swen[srcmd_reg_index]  = 1'b0;
            srcmd_permh_swen[srcmd_reg_index] = 1'b0;

            // Determine the register to write based on corrpsonding srcmd_reg_demux_sel_q (address bit [4:2])
            unique case (srcmd_reg_demux_sel_q[j])

              IOPMP_SRCMD_PERM: begin

                // Drive SRCMD_PERM(m) register sw write enable
                srcmd_perm_swen[srcmd_reg_index] = is_write_allowed;
              end

              IOPMP_SRCMD_PERMH: begin

                // Drive SRCMD_PERMH(m) register sw write enable
                srcmd_permh_swen[srcmd_reg_index] = is_write_allowed;
              end
              default: ;
            endcase
          end

          // Drive SW write enable signals zero when demux is not enabled
          else begin : gen_write_demux_disable
            srcmd_perm_swen[srcmd_reg_index]  = 1'b0;
            srcmd_permh_swen[srcmd_reg_index] = 1'b0;
          end
        end
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      srcmd_reg_write_valid_q  <= '0;
      srcmd_perm_reg_swdata_q  <= '0;
      srcmd_permh_reg_swdata_q <= '0;
      srcmd_reg_demux_sel_q    <= '0;
      srcmd_selected_demux_q   <= '0;
      srcmd_legal_q            <= '0;
    end
    else begin
      srcmd_reg_write_valid_q  <= {MD_NUM_BY_8{srcmd_reg_write_valid}};
      srcmd_perm_reg_swdata_q  <= srcmd_reg_swdata;
      srcmd_permh_reg_swdata_q <= srcmd_reg_swdata;
      srcmd_reg_demux_sel_q    <= {MD_NUM_BY_8{srcmd_reg_demux_sel}};
      srcmd_selected_demux_q   <= {MD_NUM_BY_8{srcmd_selected_demux}};
      srcmd_legal_q            <= {MD_NUM_BY_8{srcmd_legal}};
    end
  end

  //****************************************************************************************************
  // SRCMD TABLE REGISTERS WHEN SRCMD FORMAT IS 2
  //****************************************************************************************************

  // Generate SRCMD registers based on MD_NUM value when SRCMD Format is 2
  for (genvar curr_index = 0; curr_index < int'(CFG.MD_NUM); curr_index++) begin : gen_srcmd_fmt_2_regs

    // ########### SRCMD_PERM ###########
    regfield #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  ('0)
    ) u_srcmd_perm
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (srcmd_perm_swen[curr_index]),
      .swdata  (srcmd_perm_swdata[curr_index]),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (srcmd_table_2[curr_index].srcmd_perm.perm)
    );

    // ########### SRCMD_PERMH ###########
    regfield #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  ('0)
    ) u_srcmd_permh
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (srcmd_permh_swen[curr_index]),
      .swdata  (srcmd_permh_swdata[curr_index]),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (srcmd_table_2[curr_index].srcmd_permh.permh)
    );
  end

  for (genvar curr_index = int'(CFG.MD_NUM); curr_index < int'(63); curr_index++) begin : gen_srcmd_regs_hardwired_zeros
    assign srcmd_table_2[curr_index].srcmd_perm.perm   = '0;
    assign srcmd_table_2[curr_index].srcmd_permh.permh = '0;
  end

endmodule
