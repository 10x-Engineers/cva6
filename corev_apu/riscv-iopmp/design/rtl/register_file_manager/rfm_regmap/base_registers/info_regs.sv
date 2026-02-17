///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 20-June-2025
/// Description:
///////////////////////////////////////////////////////////////////////////

module info_regs
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import rfm_pkg::info_reg_t;
  import rfm_pkg::IOPMP_VERSION;
  import rfm_pkg::IOPMP_IMP;
  import rfm_pkg::IOPMP_HWCFG0;
  import rfm_pkg::IOPMP_HWCFG1;
  import rfm_pkg::IOPMP_HWCFG2;
  import rfm_pkg::IOPMP_ENTRY_OFFSET;
  import rfm_pkg::IOPMP_BASE_ADDR;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                           clk,                   // Clock Rising Edge
  input  logic                           rst_n,                 // Reset Active Low

  // Address Check ==> INFO Registers
  input  logic                           info_legal,            // Indicates whether incoming address belongs to a legal INFO register

  // Base Registers ==> INFO Registers
  input  logic [2:0]                     info_reg_demux_sel,    // INFO register write path demux select signal
  input  logic                           info_reg_write_valid,  // Write valid signal for INFO register
  input  logic [AHB_LITE_DATA_WIDTH-1:0] info_reg_swdata,       // Write data for INFO registers

  // INFO Registers ==> Base Registers
  output info_reg_t                      info_reg               // INFO Registers
);

  localparam logic [6:0]  MAX_MD_ENTRY_NUM_VALUE   = 7;     // hwcfg0.md_entry_num can't be greater than 7
  localparam logic [15:0] MAX_SUPPORTED_PRIO_ENTRY = 48;    // hwcfg2.prio_entry can't be greater than 48

  //###############################
  // Internal Signals Declarations
  //###############################

  // Registers/Fields SW write enable and write data signals
  logic        hwcfg0_prient_prog_swdata;
  logic        hwcfg0_prient_prog_swen;
  logic [15:0] hwcfg2_prio_entry_swdata;
  logic        hwcfg2_prio_entry_swen;
  logic [6:0]  hwcfg0_md_entry_num_swdata;
  logic        hwcfg0_md_entry_num_swen;
  logic        hwcfg0_enable_swdata;
  logic        hwcfg0_enable_swen;

  //****************************************************************************************************
  // Registers/Fields SW Write Data Signals
  //****************************************************************************************************

  // HWCFG0 Register Fields SW Write Data Signals
  assign hwcfg0_prient_prog_swdata = info_reg_swdata[7];
  assign hwcfg0_enable_swdata      = info_reg_swdata[31];

  if (CFG.MDCFG_FMT_2) begin

    // The range of legal values for hwcfg0.md_entry_num is defined by MAX_MD_ENTRY_NUM_VALUE
    assign hwcfg0_md_entry_num_swdata = (info_reg_swdata[23:17] <= MAX_MD_ENTRY_NUM_VALUE) ?
                                        info_reg_swdata[23:17] :      // Write new data
                                        MAX_MD_ENTRY_NUM_VALUE;       // Configure to maximum supported value
  end

  // HWCFG2 Register Fields SW Write Data Signal
  if (CFG.PRIENT_PROG) begin

    // The range of legal values for hwcfg2.prio_entry is defined by MAX_SUPPORTED_PRIO_ENTRY
    assign hwcfg2_prio_entry_swdata = (info_reg_swdata[15:0] <= MAX_SUPPORTED_PRIO_ENTRY) ?
                                      info_reg_swdata[15:0] :        // Write new data
                                      MAX_SUPPORTED_PRIO_ENTRY;      // Configure to maximum supported value
  end

  //****************************************************************************************************
  // DEMUX for Registers/Fields SW Write Enable Signals
  //****************************************************************************************************
  always_comb begin

    // The signal info_legal act as an enable signal to INFO registers demux
    // When high it indicates demux is enabled and determine the INFO register/fields to write based on info_reg_demux_sel signal
    if (info_legal) begin

      // Drive all SW write enable signals of INFO registers/fields low before matching any case
      // The case statement only handles the SW write enable signal for the particular register/fields it matches
      hwcfg0_prient_prog_swen  = 1'b0;
      hwcfg0_md_entry_num_swen = 1'b0;
      hwcfg0_enable_swen       = 1'b0;
      hwcfg2_prio_entry_swen   = 1'b0;

      // Determine the INFO register/fields to write based on info_reg_demux_sel signal
      unique case (info_reg_demux_sel)

        IOPMP_HWCFG0: begin

          // Drive HWCFGO register fields sw write enables
          hwcfg0_prient_prog_swen  = CFG.PRIENT_PROG && info_reg_write_valid;
          hwcfg0_md_entry_num_swen = CFG.MDCFG_FMT_2 && (!info_reg.hwcfg0.enable) && info_reg_write_valid;  // hwcfg0.md_entry_num is locked if hwcfg0.enable is 1
          hwcfg0_enable_swen       = info_reg_write_valid;
        end

        IOPMP_HWCFG2: begin

          // Drive HWCFG2 register fields sw write enables
          hwcfg2_prio_entry_swen = CFG.PRIENT_PROG && info_reg.hwcfg0.prient_prog && info_reg_write_valid;    // hwcfg2.prio_entry is programmable if hwcfg0.prient_prog is 1
        end

        default: ;
      endcase
    end

    // Drive all SW enable signals of INFO registers/fields low as info_legal is low
    else begin
      hwcfg0_prient_prog_swen  = 1'b0;
      hwcfg0_md_entry_num_swen = 1'b0;
      hwcfg0_enable_swen       = 1'b0;
      hwcfg2_prio_entry_swen   = 1'b0;
    end
  end

  //****************************************************************************************************
  // INFO REGISTERS
  //****************************************************************************************************

  // ########### VERSION ###########
  assign info_reg.version.vendor  = '0;
  assign info_reg.version.specver = '0;

  // ########### IMPLEMENTATION ###########
  assign info_reg.imp.impid = '0;

  // ########### HWCFG1 ###########
  assign info_reg.hwcfg0.mdcfg_fmt = CFG.MDCFG_FMT_2 ? 2'b10 : (CFG.MDCFG_FMT_1 ? 2'b01 : 2'b00);

  assign info_reg.hwcfg0.srcmd_fmt = CFG.SRCMD_FMT_2 ? 2'b10 : (CFG.SRCMD_FMT_1 ? 2'b01 : 2'b00);

  assign info_reg.hwcfg0.tor_en = CFG.TOR_EN;

  assign info_reg.hwcfg0.sps_en = CFG.SRCMD_FMT_0 && CFG.SPS_EN;

  assign info_reg.hwcfg0.user_cfg_en = 1'b0;              // Hardwired zero as User Configuration feature for ENTRY ARRAY is not supported

  if (CFG.PRIENT_PROG) begin : gen_prient_prog_flop
    regfield #(
      .DW      (1),
      .SWACCESS("W1CS"),
      .RESVAL  (1'b1)
    ) u_hwcfg0_prient_prog
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (hwcfg0_prient_prog_swen),
      .swdata  (hwcfg0_prient_prog_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (info_reg.hwcfg0.prient_prog)
    );
  end
  else begin : gen_prient_prog_zero
    assign info_reg.hwcfg0.prient_prog = 1'b0;
  end

  assign info_reg.hwcfg0.rrid_transl_en   = 1'b0;                   // Hardwired zero as cascading IOPMP feature is not supported
  assign info_reg.hwcfg0.rrid_transl_prog = 1'b0;                   // Hardwired zero as cascading IOPMP feature is not supported
  assign info_reg.hwcfg0.chk_x            = CFG.CHK_X;
  assign info_reg.hwcfg0.no_x             = CFG.NO_X && CFG.CHK_X;
  assign info_reg.hwcfg0.no_w             = CFG.NO_W;
  assign info_reg.hwcfg0.stall_en         = CFG.STALL_EN;
  assign info_reg.hwcfg0.peis             = CFG.PEIS;
  assign info_reg.hwcfg0.pees             = 1'b0;                   // Hardwired zero as local error suppression feature is not supported
  assign info_reg.hwcfg0.mfr_en           = CFG.MFR_EN && CFG.ERROR_CAPTURE_EN;

  if (CFG.MDCFG_FMT_2) begin : gen_md_entry_num_flop
    regfield #(
      .DW      (7),
      .SWACCESS("RW"),
      .RESVAL  (CFG.MD_ENTRY_NUM)
    ) u_hwcfg0_md_entry_num
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (hwcfg0_md_entry_num_swen),
      .swdata  (hwcfg0_md_entry_num_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (info_reg.hwcfg0.md_entry_num)
    );
  end
  else if (CFG.MDCFG_FMT_1) begin : gen_md_entry_num_constant
    assign info_reg.hwcfg0.md_entry_num = CFG.MD_ENTRY_NUM;
  end
  else begin : gen_md_entry_num_zero
    assign info_reg.hwcfg0.md_entry_num = '0;
  end

  assign info_reg.hwcfg0.md_num   = CFG.MD_NUM;
  assign info_reg.hwcfg0.addrh_en = CFG.ADDRH_EN;

  regfield #(
    .DW      (1),
    .SWACCESS("W1SS"),
    .RESVAL  (1'b0)
  ) u_hwcfg0_enable
  (
    .clk     (clk),
    .rst_n   (rst_n),

    .swen    (hwcfg0_enable_swen),
    .swdata  (hwcfg0_enable_swdata),

    .hwen    (1'b0),
    .hwdata  ('0),

    .hwrdata (info_reg.hwcfg0.enable)
  );

  // ########### HWCFG1 ###########
  assign info_reg.hwcfg1.rrid_num  = CFG.RRID_NUM;
  assign info_reg.hwcfg1.entry_num = CFG.ENTRY_NUM;

  // ########### HWCFG2 ###########
  if (CFG.PRIENT_PROG) begin : gen_prio_entry_flop
    regfield #(
      .DW      (16),
      .SWACCESS("RW"),
      .RESVAL  (CFG.PRIO_ENTRY)
    ) u_hwcfg2_prio_entry
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (hwcfg2_prio_entry_swen),
      .swdata  (hwcfg2_prio_entry_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (info_reg.hwcfg2.prio_entry)
    );
  end
  else begin : gen_prio_entry_constant
    assign info_reg.hwcfg2.prio_entry = CFG.PRIO_ENTRY;
  end

  assign info_reg.hwcfg2.rrid_transl = '0;       // Hardwired zero as cascading IOPMP feature is not supported

  // ########### ENTRYOFFSET ###########
  assign info_reg.entry_offset.offset = CFG.ENTRY_OFFSET;

  // ########### BASEADDR ###########
  assign info_reg.base_addr.base = CFG.BASE_ADDR;

endmodule
