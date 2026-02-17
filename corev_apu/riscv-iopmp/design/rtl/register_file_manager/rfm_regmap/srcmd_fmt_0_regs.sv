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

module srcmd_fmt_0_regs
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import rfm_pkg::srcmd_table_0_t;
  import rfm_pkg::IOPMP_SRCMD_EN;
  import rfm_pkg::IOPMP_SRCMD_ENH;
  import rfm_pkg::IOPMP_SRCMD_R;
  import rfm_pkg::IOPMP_SRCMD_RH;
  import rfm_pkg::IOPMP_SRCMD_W;
  import rfm_pkg::IOPMP_SRCMD_WH;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default,

  // Inidcates the implementation status of an MD (1 bit per MD) based on read-only field hwcfg0.md_num
  parameter logic [62:0] MD_NUM_MASK = 0
) (
  input  logic                           clk,                    // Clock Rising Edge
  input  logic                           rst_n,                  // Reset Active Low

  // AHB-LITE Interface ==> SRCMD Format 0 Registers
  input  logic [5:0]                     srcmd_selected_demux,   // SRCMD demux to select
  input  logic [2:0]                     srcmd_reg_demux_sel,    // SRCMD register write path demux select signal
  input  logic [AHB_LITE_DATA_WIDTH-1:0] srcmd_reg_swdata,       // Write data for SRCMD TABLE registers

  // Address Check ==> Regmap
  input  logic                           srcmd_legal,            // Indicates whether incoming address belongs to a legal register in SRCMD region section 1

  // Regmap ==> SRCMD TABLE Registers
  input  logic                           srcmd_reg_write_valid,  // SRCMD TABLE register write valid signal

  // Base Registers ==> SRCMD Format 0 Registers
  input  logic [30:0]                    mdlck_md,               // MDLCK indicates which MDs are locked in the SRCMD Table lower registers
  input  logic [31:0]                    mdlckh_mdh,             // MDLCKH indicates which MDs are locked in the SRCMD Table upper registers

  // SRCMD Format 0 Registers ==> Regmap
  output srcmd_table_0_t [63:0]          srcmd_table_0           // SRCMD TABLE registers struct required in TTU for srcmd table traversal
);

  localparam RRID_NUM_BY_8 = ((int'(CFG.RRID_NUM) + 7)/8);

  //###############################
  // Internal Signals Declarations
  //###############################

  logic                           is_write_allowed;
  logic [CFG.RRID_NUM-1:0]        srcmd_demux_enable;
  logic [RRID_NUM_BY_8-1:0]       srcmd_reg_write_valid_q, srcmd_legal_q;
  logic [RRID_NUM_BY_8-1:0][2:0]  srcmd_reg_demux_sel_q;
  logic [RRID_NUM_BY_8-1:0][5:0]  srcmd_selected_demux_q;
  logic [AHB_LITE_DATA_WIDTH-1:0] srcmd_en_reg_swdata_q, srcmd_enh_reg_swdata_q, srcmd_rh_reg_swdata_q, srcmd_wh_reg_swdata_q;
  logic [AHB_LITE_DATA_WIDTH-2:0] srcmd_r_reg_swdata_q, srcmd_w_reg_swdata_q;
  int                             srcmd_reg_index;

  // Registers/Fields SW write enable and write data signals
  logic [CFG.RRID_NUM-1:0]       srcmd_en_l_swdata;
  logic [CFG.RRID_NUM-1:0]       srcmd_en_l_swen;
  logic [CFG.RRID_NUM-1:0][30:0] srcmd_en_md_swdata;
  logic [CFG.RRID_NUM-1:0]       srcmd_en_md_swen;
  logic [CFG.RRID_NUM-1:0][31:0] srcmd_enh_swdata;
  logic [CFG.RRID_NUM-1:0]       srcmd_enh_swen;
  logic [CFG.RRID_NUM-1:0][30:0] srcmd_r_swdata;
  logic [CFG.RRID_NUM-1:0]       srcmd_r_swen;
  logic [CFG.RRID_NUM-1:0][31:0] srcmd_rh_swdata;
  logic [CFG.RRID_NUM-1:0]       srcmd_rh_swen;
  logic [CFG.RRID_NUM-1:0][30:0] srcmd_w_swdata;
  logic [CFG.RRID_NUM-1:0]       srcmd_w_swen;
  logic [CFG.RRID_NUM-1:0][31:0] srcmd_wh_swdata;
  logic [CFG.RRID_NUM-1:0]       srcmd_wh_swen;

  //****************************************************************************************************
  // Generate DEMUX enable signals for SRCMD Format 0
  //****************************************************************************************************
  generate

    // The outer loop divides the number of SRCMD demuxes into a block of 8 demuxes as 1 flop of srcmd_selected_demux_q and srcmd_legal_q
    // should not drive more than 8 demuxes enable signal
    for (genvar j = 0; j < RRID_NUM_BY_8; j++) begin : gen_demux_enable_outer_loop

      // The inner loop generates 8 demux enable signal based on srcmd_selected_demux_q and srcmd_legal_q
      for (genvar i = 0; i < 8; i++) begin : gen_demux_enable_inner_loop

        // Each demux maps 1 SRCMD register block (containing SRCMD_EN, SRCMD_ENH, ..., SRCMD_WH), so the j (outer loop variable)
        // is multiplied by 8 and i (inner loop variable) is added to get the block index.
        // RRID_NUM indicates the supported number of SRCMD registers so ((j << 3) + i) should always be less than RRID_NUM
        if (((j << 3) + i) < int'(CFG.RRID_NUM)) begin : valid_srcmd_index

          // Determine the srcmd demux to select based on srcmd_selected_demux_q (address bit [10:5]) signal and qualify it with
          // srcmd_legal_q signal to generate demux enable signals
          assign srcmd_demux_enable[(j << 3) + i] = srcmd_legal_q[j] && (srcmd_selected_demux_q[j][2:0] == i) && (srcmd_selected_demux_q[j][5:3] == j);
        end
      end
    end
  endgenerate

  //****************************************************************************************************
  // Registers/Fields SW write data signals for SRCDM Format 0
  //****************************************************************************************************
  for (genvar s_reg_index = 0; s_reg_index < int'(CFG.RRID_NUM); s_reg_index++) begin : gen_srcmd_regs_swdata

    assign srcmd_en_l_swdata[s_reg_index] = srcmd_en_reg_swdata_q[0];

    // Write on SRCMD Table registers/fields is dependent on MDLCK, MDLKCH if IMP_MDLCK is 1
    if (CFG.IMP_MDLCK) begin : gen_mdlck_dependent_swdata

      // For MD 0 < m < 31, MDLCK.md[m] locks SRCMD_EN(s).md[m] for all existing RRID s. The fields SRCMD_EN(s).md[m] are not writable if MD m is not supported
      assign srcmd_en_md_swdata[s_reg_index] = (((srcmd_en_reg_swdata_q[31:1] & ~mdlck_md) | (srcmd_table_0[s_reg_index].srcmd_en.md & mdlck_md)) & MD_NUM_MASK[30:0]);

       // For MD m > 30, MDLCKH.mdh[m] locks SRCMD_ENH(s).mdh[m] for all existing RRID s. The fields SRCMD_ENH(s).mdh[m] are not writable if MD m is not supported
      assign srcmd_enh_swdata[s_reg_index]   = (((srcmd_enh_reg_swdata_q & ~mdlckh_mdh) | (srcmd_table_0[s_reg_index].srcmd_enh.mdh & mdlckh_mdh)) & MD_NUM_MASK[62:31]);

      if (CFG.SPS_EN) begin : gen_sps_regs_swdata_0

        // For MD 0 < m < 31, MDLCK.md[m] locks SRCMD_R(s).md[m] for all existing RRID s. The fields SRCMD_R(s).md[m] are not writable if MD m is not supported
        assign srcmd_r_swdata[s_reg_index]  = (((srcmd_r_reg_swdata_q & ~mdlck_md) | (srcmd_table_0[s_reg_index].srcmd_r.md & mdlck_md)) & MD_NUM_MASK[30:0]);

         // For MD m > 30, MDLCKH.mdh[m] locks SRCMD_RH(s).mdh[m] for all existing RRID s. The fields SRCMD_RH(s).mdh[m] are not writable if MD m is not supported
        assign srcmd_rh_swdata[s_reg_index] = (((srcmd_rh_reg_swdata_q & ~mdlckh_mdh) | (srcmd_table_0[s_reg_index].srcmd_rh.mdh & mdlckh_mdh)) & MD_NUM_MASK[62:31]);

        // For MD 0 < m < 31, MDLCK.md[m] locks SRCMD_W(s).md[m] for all existing RRID s. The fields SRCMD_W(s).md[m] are not writable if MD m is not supported
        assign srcmd_w_swdata[s_reg_index]  = (((srcmd_w_reg_swdata_q & ~mdlck_md) | (srcmd_table_0[s_reg_index].srcmd_w.md & mdlck_md)) & MD_NUM_MASK[30:0]);

         // For MD m > 30, MDLCKH.mdh[m] locks SRCMD_WH(s).mdh[m] for all existing RRID s. The fields SRCMD_WH(s).mdh[m] are not writable if MD m is not supported
        assign srcmd_wh_swdata[s_reg_index] = (((srcmd_wh_reg_swdata_q & ~mdlckh_mdh) | (srcmd_table_0[s_reg_index].srcmd_wh.mdh & mdlckh_mdh)) & MD_NUM_MASK[62:31]);
      end
    end

    // Write on SRCMD Table registers/fields is independent of MDLCK or MDLCKH if IMP_MDLCK is 0
    else begin : gen_mdlck_independent_swdata

      // The fields SRCMD_EN(s).md[m] are not writable if MD m is not supported
      assign srcmd_en_md_swdata[s_reg_index] = srcmd_en_reg_swdata_q[31:1] & MD_NUM_MASK[30:0];

      // The fields SRCMD_ENH(s).md[m] are not writable if MD m is not supported
      assign srcmd_enh_swdata[s_reg_index]   = srcmd_enh_reg_swdata_q & MD_NUM_MASK[62:31];

      if (CFG.SPS_EN) begin : gen_sps_regs_swdata_1

        // The fields SRCMD_R(s).md[m] are not writable if MD m is not supported
        assign srcmd_r_swdata[s_reg_index]  = srcmd_r_reg_swdata_q & MD_NUM_MASK[30:0];

        // The fields SRCMD_RH(s).md[m] are not writable if MD m is not supported
        assign srcmd_rh_swdata[s_reg_index] = srcmd_rh_reg_swdata_q & MD_NUM_MASK[62:31];

        // The fields SRCMD_W(s).md[m] are not writable if MD m is not supported
        assign srcmd_w_swdata[s_reg_index]  = srcmd_w_reg_swdata_q & MD_NUM_MASK[30:0];

        // The fields SRCMD_WH(s).md[m] are not writable if MD m is not supported
        assign srcmd_wh_swdata[s_reg_index] = srcmd_wh_reg_swdata_q & MD_NUM_MASK[62:31];
      end
    end
  end

  //****************************************************************************************************
  // DEMUX for Registers/Fields SW Write Enable Signals for SRCMD Format 0
  //****************************************************************************************************
  always_comb begin : srcmd_fmt_0_write_path

    // The outer loop divides the number of SRCMD demuxes into a block of 8 demuxes as 1 write valid signal should drive not more than 64 registers
    for (int j = 0; j < RRID_NUM_BY_8; j++) begin : gen_write_outer_loop

      // The inner loop generates 8 instances of SRCMD register block sw write enable signals per demux
      for (int i = 0; i < 8; i++) begin : gen_write_inner_loop

        // Each demux maps 1 SRCMD register block (containing SRCMD_EN, SRCMD_ENH, ..., SRCMD_WH), so the j (outer loop variable) is multiplied by 8 and i (inner loop variable) is added to get the block index
        srcmd_reg_index = (j << 3) + i;

        // Check if SRCMD registers exist for srcmd_reg_index and then generate its SW write valid signal.
        // RRID_NUM indicates the supported number of SRCMD registers so srcmd_reg_index should always be less than RRID_NUM
        if (srcmd_reg_index < int'(CFG.RRID_NUM)) begin : gen_valid_srcmd_index_write

          // Determine SRCMD(s) registers write based on corresponding SRCMD_EN(s).l bit
          // SRCMD_EN(s), SRCMD_ENH(s), ..., SRCMD_WH(s) are locked if SRCMD_EN(s).l is asserted
          is_write_allowed = (!srcmd_table_0[srcmd_reg_index].srcmd_en.l) && srcmd_reg_write_valid_q[j];

          // The signal srcmd_demux_enable act as an enable signal to SRCMD demux
          // When high it indicates demux is enabled and determine the SRCMD register/fields to write based on srcmd_reg_demux_sel_q signal
          if (srcmd_demux_enable[srcmd_reg_index]) begin : gen_write_demux_enable

            // Drive the SW write enable signals of SRCMD registers/fields indexed by srcmd_reg_index low before matching any case
            // The case statement only handles the SW write enable signal for the particular register/fields it matches
            srcmd_en_l_swen[srcmd_reg_index]  = 1'b0;
            srcmd_en_md_swen[srcmd_reg_index] = 1'b0;
            srcmd_enh_swen[srcmd_reg_index]   = 1'b0;
            srcmd_r_swen[srcmd_reg_index]     = 1'b0;
            srcmd_rh_swen[srcmd_reg_index]    = 1'b0;
            srcmd_w_swen[srcmd_reg_index]     = 1'b0;
            srcmd_wh_swen[srcmd_reg_index]    = 1'b0;

            // Determine the register/fields to write based on corrpsonding srcmd_reg_demux_sel_q (address bit [4:2])
            unique case (srcmd_reg_demux_sel_q[j])

              IOPMP_SRCMD_EN: begin

                // Drive SRCMD_EN(s) register/fields sw write enables
                srcmd_en_l_swen[srcmd_reg_index]  = is_write_allowed;
                srcmd_en_md_swen[srcmd_reg_index] = is_write_allowed;
              end

              IOPMP_SRCMD_ENH: begin

                // Drive SRCMD_ENH(s) register sw write enable
                srcmd_enh_swen[srcmd_reg_index] = is_write_allowed;
              end

              IOPMP_SRCMD_R: if (CFG.SPS_EN) begin : gen_srcmd_r_write

                // Drive SRCMD_R(s) register sw write enable
                srcmd_r_swen[srcmd_reg_index] = is_write_allowed;
              end

              IOPMP_SRCMD_RH: if (CFG.SPS_EN) begin : gen_srcmd_rh_write

                // Drive SRCMD_RH(s) register sw write enable
                srcmd_rh_swen[srcmd_reg_index] = is_write_allowed;
              end

              IOPMP_SRCMD_W: if (CFG.SPS_EN) begin : gen_srcmd_w_write

                // Drive SRCMD_W(s) register sw write enable
                srcmd_w_swen[srcmd_reg_index] = is_write_allowed;
              end

              IOPMP_SRCMD_WH: if (CFG.SPS_EN) begin : gen_srcmd_wh_write

                // Drive SRCMD_WH(s) register sw write enable
                srcmd_wh_swen[srcmd_reg_index] = is_write_allowed;
              end
              default: ;
            endcase
          end

          // Drive SW write enable signals zero when demux is not enabled
          else begin : gen_write_demux_disable
            srcmd_en_l_swen[srcmd_reg_index]  = 1'b0;
            srcmd_en_md_swen[srcmd_reg_index] = 1'b0;
            srcmd_enh_swen[srcmd_reg_index]   = 1'b0;
            srcmd_r_swen[srcmd_reg_index]     = 1'b0;
            srcmd_rh_swen[srcmd_reg_index]    = 1'b0;
            srcmd_w_swen[srcmd_reg_index]     = 1'b0;
            srcmd_wh_swen[srcmd_reg_index]    = 1'b0;
          end
        end
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      srcmd_reg_write_valid_q <= '0;
      srcmd_en_reg_swdata_q   <= '0;
      srcmd_enh_reg_swdata_q  <= '0;
      if (CFG.SPS_EN) begin : sps_regs_write_data_0
        srcmd_r_reg_swdata_q  <= '0;
        srcmd_rh_reg_swdata_q <= '0;
        srcmd_w_reg_swdata_q  <= '0;
        srcmd_wh_reg_swdata_q <= '0;
      end
      srcmd_reg_demux_sel_q   <= '0;
      srcmd_selected_demux_q  <= '0;
      srcmd_legal_q           <= '0;
    end
    else begin
      srcmd_reg_write_valid_q <= {RRID_NUM_BY_8{srcmd_reg_write_valid}};
      srcmd_en_reg_swdata_q   <= srcmd_reg_swdata;
      srcmd_enh_reg_swdata_q  <= srcmd_reg_swdata;
      if (CFG.SPS_EN) begin : sps_regs_write_data_1
        srcmd_r_reg_swdata_q  <= srcmd_reg_swdata[31:1];
        srcmd_rh_reg_swdata_q <= srcmd_reg_swdata;
        srcmd_w_reg_swdata_q  <= srcmd_reg_swdata[31:1];
        srcmd_wh_reg_swdata_q <= srcmd_reg_swdata;
      end
      srcmd_reg_demux_sel_q   <= {RRID_NUM_BY_8{srcmd_reg_demux_sel}};
      srcmd_selected_demux_q  <= {RRID_NUM_BY_8{srcmd_selected_demux}};
      srcmd_legal_q           <= {RRID_NUM_BY_8{srcmd_legal}};
    end
  end

  //****************************************************************************************************
  // SRCMD TABLE REGISTERS WHEN SRCMD FORMAT IS 0
  //****************************************************************************************************

  // Generate SRCMD registers based on RRID_NUM value when SRCMD Format is 0
  for (genvar curr_index = 0; curr_index < int'(CFG.RRID_NUM); curr_index++) begin : gen_srcmd_fmt_0_regs

    // ########### SRCMD_EN ###########
    regfield #(
      .DW      (1),
      .SWACCESS("W1SS"),
      .RESVAL  (1'b0)
    ) u_srcmd_en_l
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (srcmd_en_l_swen[curr_index]),
      .swdata  (srcmd_en_l_swdata[curr_index]),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (srcmd_table_0[curr_index].srcmd_en.l)
    );

    regfield #(
      .DW      (31),
      .SWACCESS("RW"),
      .RESVAL  ('0)
    ) u_srcmd_en_md
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (srcmd_en_md_swen[curr_index]),
      .swdata  (srcmd_en_md_swdata[curr_index]),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (srcmd_table_0[curr_index].srcmd_en.md)
    );

    // ########### SRCMD_ENH ###########
    regfield #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  ('0)
    ) u_srcmd_enh
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (srcmd_enh_swen[curr_index]),
      .swdata  (srcmd_enh_swdata[curr_index]),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (srcmd_table_0[curr_index].srcmd_enh.mdh)
    );

    // SRCMD_R, SRCMD_RH, SRCMD_W, SRCMD_WH registers are avaiable only if SPS_EN is 1
    if (CFG.SPS_EN) begin : gen_sps_regs

      // ########### SRCMD_R ###########
      regfield #(
        .DW      (31),
        .SWACCESS("RW"),
        .RESVAL  ('0)
      ) u_srcmd_r_md
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (srcmd_r_swen[curr_index]),
        .swdata  (srcmd_r_swdata[curr_index]),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (srcmd_table_0[curr_index].srcmd_r.md)
      );

      // ########### SRCMD_RH ###########
      regfield #(
        .DW      (32),
        .SWACCESS("RW"),
        .RESVAL  ('0)
      ) u_srcmd_rh
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (srcmd_rh_swen[curr_index]),
        .swdata  (srcmd_rh_swdata[curr_index]),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (srcmd_table_0[curr_index].srcmd_rh.mdh)
      );

      // ########### SRCMD_W ###########
      regfield #(
        .DW      (31),
        .SWACCESS("RW"),
        .RESVAL  ('0)
      ) u_srcmd_w_md
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (srcmd_w_swen[curr_index]),
        .swdata  (srcmd_w_swdata[curr_index]),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (srcmd_table_0[curr_index].srcmd_w.md)
      );

      // ########### SRCMD_WH ###########
      regfield #(
        .DW      (32),
        .SWACCESS("RW"),
        .RESVAL  ('0)
      ) u_srcmd_wh
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (srcmd_wh_swen[curr_index]),
        .swdata  (srcmd_wh_swdata[curr_index]),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (srcmd_table_0[curr_index].srcmd_wh.mdh)
      );
    end
    else begin : gen_sps_regs_hardwired_zeros
      assign srcmd_table_0[curr_index].srcmd_r.md   = '0;
      assign srcmd_table_0[curr_index].srcmd_rh.mdh = '0;
      assign srcmd_table_0[curr_index].srcmd_w.md   = '0;
      assign srcmd_table_0[curr_index].srcmd_wh.mdh = '0;
    end
  end

  // Generate SRCMD registers based on RRID_NUM value when SRCMD Format is 0
  for (genvar curr_index = int'(CFG.RRID_NUM); curr_index < int'(64); curr_index++) begin : gen_srcmd_regs_hardwired_zeros
    assign srcmd_table_0[curr_index].srcmd_en     = '0;
    assign srcmd_table_0[curr_index].srcmd_enh    = '0;
    assign srcmd_table_0[curr_index].srcmd_r.md   = '0;
    assign srcmd_table_0[curr_index].srcmd_rh.mdh = '0;
    assign srcmd_table_0[curr_index].srcmd_w.md   = '0;
    assign srcmd_table_0[curr_index].srcmd_wh.mdh = '0;
  end

endmodule
