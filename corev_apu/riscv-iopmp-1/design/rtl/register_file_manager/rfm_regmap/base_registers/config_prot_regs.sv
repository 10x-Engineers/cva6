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

module config_prot_regs
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import rfm_pkg::config_prot_reg_t;
  import rfm_pkg::IOPMP_MDLCK;
  import rfm_pkg::IOPMP_MDLCKH;
  import rfm_pkg::IOPMP_MDCFGLCK;
  import rfm_pkg::IOPMP_ENTRYLCK;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default,

  // Inidcates the implementation status of an MD (1 bit per MD) based on read-only field hwcfg0.md_num
  parameter logic [62:0] MD_NUM_MASK = 0
) (
  input  logic                           clk,                               // Clock Rising Edge
  input  logic                           rst_n,                             // Reset Active Low

  // Address Check ==> CONFIGURATION PROTECTION Registers
  input  logic                           config_prot_legal,                 // Indicates whether incoming address belongs to a legal CONFIGURATION PROTECTION register

  // Base Registers ==> CONFIGURATION PROTECTION Registers
  input  logic [2:0]                     config_prot_reg_demux_sel,         // CONFIGURATION PROTECTION register write path demux select signal
  input  logic                           config_prot_reg_write_valid,       // CONFIGURATION PROTECTION register Write valid signal
  input  logic [AHB_LITE_DATA_WIDTH-1:0] config_prot_reg_swdata,            // Write data for CONFIGURATION PROTECTION registers

  // INFO Registers ==> CONFIGURATION PROTECTION Registers
  input  logic [5:0]                     hwcfg0_md_num,                     // Indicates the number of supported MDs
  input  logic [7:0]                     hwcfg1_entry_num,                  // Indicates the number of supported entries

  // CONFIGURATION PROTECTION Registers ==> Regamp
  output config_prot_reg_t               config_prot_reg                    // CONFIGURATION PROTECTION Registers
);

  //###############################
  // Internal Signals Declarations
  //###############################

  // Registers/Fields SW write enable and write data signals
  logic        mdlck_l_swdata;
  logic        mdlck_l_swen;
  logic [30:0] mdlck_md_swdata;
  logic        mdlck_md_swen;
  logic [31:0] mdlckh_mdh_swdata;
  logic        mdlckh_mdh_swen;
  logic        mdcfglck_l_swdata;
  logic        mdcfglck_l_swen;
  logic [5:0]  mdcfglck_f_swdata;
  logic        mdcfglck_f_swen;
  logic        entrylck_l_swdata;
  logic        entrylck_l_swen;
  logic [15:0] entrylck_f_swdata;
  logic        entrylck_f_swen;

  //****************************************************************************************************
  // Registers/Fields SW Write Data Signals
  //****************************************************************************************************

  // MDLCK MDLCKH Registers/Fields SW Write Data Signal
  if ((CFG.SRCMD_FMT_0 || CFG.SRCMD_FMT_2) && CFG.IMP_MDLCK) begin : gen_mdlck_mdlckh_swdata
    assign mdlck_l_swdata = config_prot_reg_swdata[0];

    // The fields MDSTALLH.mdh[m] is writable only if MD m is supported
    assign mdlck_md_swdata = config_prot_reg_swdata[31:1] & MD_NUM_MASK[30:0];

    // The fields MDSTALLH.mdh[m] is writable only if MD m is supported
    assign mdlckh_mdh_swdata = config_prot_reg_swdata & MD_NUM_MASK[62:31];
  end
  else if ((CFG.SRCMD_FMT_0 || CFG.SRCMD_FMT_2) && (!CFG.IMP_MDLCK)) begin : drive_mdlck_mdlckh_swdata_zero
    assign mdlck_l_swdata    = 1'b0;
    assign mdlck_md_swdata   = '0;
    assign mdlckh_mdh_swdata = '0;
  end

  // MDCFGLCK Register Fields SW Write Data Signals
  if (CFG.MDCFG_FMT_0 && CFG.IMP_MDCFGLCK) begin : gen_mdcfglck_swdata
    assign mdcfglck_l_swdata = config_prot_reg_swdata[0];

    // On write, the field mdcfglck.f only accepts the value larger than the previous value until the next reset cycle; otherwise, there is no effect.
    // The maximum supported value that can be written in mdcfglck.f field is determined by supported number of MDs given by hwcfg0.md_num
    assign mdcfglck_f_swdata = ((config_prot_reg_swdata[6:1] < config_prot_reg.mdcfglck.f) ?
                               config_prot_reg.mdcfglck.f :   // Retain the old data
                               ((config_prot_reg_swdata[6:1] <= hwcfg0_md_num) ?
                               config_prot_reg_swdata[6:1] :  // Write new data
                               hwcfg0_md_num));               // Configure to maximum supported value
  end
  else if (CFG.MDCFG_FMT_0 && (!CFG.IMP_MDCFGLCK)) begin : drive_mdcfglck_swdata_zero
    assign mdcfglck_l_swdata = 1'b0;
    assign mdcfglck_f_swdata = '0;
  end

  // ENTRYLCK Register Fields SW Write Data Signals
  if (CFG.IMP_ENTRYLCK) begin : gen_entrylck_swdata
    assign entrylck_l_swdata = config_prot_reg_swdata[0];

    // On write, the field entrylck.f only accepts the value larger than the previous value until the next reset cycle; otherwise, there is no effect.
    // The maximum supported value that can be written in entrylck.f field is determined by supported number of entries given by hwcfg1.entry_num
    assign entrylck_f_swdata = ((config_prot_reg_swdata[16:1] < config_prot_reg.entrylck.f) ?
                               config_prot_reg.entrylck.f :       // Retain the old data
                               (((!(|config_prot_reg_swdata[16:9])) && (config_prot_reg_swdata[8:1] <= hwcfg1_entry_num)) ?
                               config_prot_reg_swdata[16:1] :     // Write new data
                               {{8{1'b0}}, hwcfg1_entry_num}));   // Configure to maximum supported value
  end
  else begin : drive_entrylck_swdata_zero
    assign entrylck_l_swdata = 1'b0;
    assign entrylck_f_swdata = '0;
  end

  //****************************************************************************************************
  // DEMUX for Registers/Fields SW Write Enable Signals
  //****************************************************************************************************
  always_comb begin

    // The signal config_prot_legal act as an enable signal to CONFIGURATION PROTECTION registers demux
    // When high it indicates demux is enabled and determine the CONFIGURATION PROTECTION register/fields to write based on config_prot_legal signal
    if (config_prot_legal) begin

      // Drive all SW write enable signals of CONFIGURATION PROTECTION registers/fields low before matching any case
      // The case statement only handles the SW write enable signal for the particular register/fields it matches
      mdlck_l_swen    = 1'b0;
      mdlck_md_swen   = 1'b0;
      mdlckh_mdh_swen = 1'b0;
      mdcfglck_l_swen = 1'b0;
      mdcfglck_f_swen = 1'b0;
      entrylck_l_swen = 1'b0;
      entrylck_f_swen = 1'b0;

      // Determine the CONFIGURATION PROTECTION register/fields to write based on config_prot_legal signal
      unique case (config_prot_reg_demux_sel)

        IOPMP_MDLCK: begin

          // Drive MDLCK register fields sw write enables
          mdlck_l_swen  = (CFG.SRCMD_FMT_0 || CFG.SRCMD_FMT_2) && CFG.IMP_MDLCK && config_prot_reg_write_valid;   // MDLCK register is writable only if mdlck.l is zero
          mdlck_md_swen = mdlck_l_swen && (!config_prot_reg.mdlck.l);
        end

        IOPMP_MDLCKH: begin

          // Drive MDLCKH register sw write enables
          mdlckh_mdh_swen = (CFG.SRCMD_FMT_0 || CFG.SRCMD_FMT_2) && CFG.IMP_MDLCK && (!config_prot_reg.mdlck.l) && config_prot_reg_write_valid;   // MDLCKH register is writable only if mdlck.l is zero
        end

        IOPMP_MDCFGLCK: begin

          // Drive MDCCFGLCK register fields sw write enables
          mdcfglck_l_swen = CFG.MDCFG_FMT_0 && CFG.IMP_MDCFGLCK && config_prot_reg_write_valid;    // MDCFGLCK register is writable only if mdcfglck.l is zero
          mdcfglck_f_swen = mdcfglck_l_swen && (!config_prot_reg.mdcfglck.l);
        end

        IOPMP_ENTRYLCK: begin

          // Drive ENTRYLCK register fields sw write enables
          entrylck_l_swen = CFG.IMP_ENTRYLCK && config_prot_reg_write_valid;   // ENTRYLCK register is writable only if entrylck.l is zero
          entrylck_f_swen = entrylck_l_swen && (!config_prot_reg.entrylck.l);
        end

        default: ;
      endcase
    end

    // Drive all SW enable signals of CONFIGURATION PROTECTION registers/fields low as config_prot_legal is low
    else begin
      mdlck_l_swen      = 1'b0;
      mdlck_md_swen     = 1'b0;
      mdlckh_mdh_swen   = 1'b0;
      mdcfglck_l_swen   = 1'b0;
      mdcfglck_f_swen   = 1'b0;
      entrylck_l_swen   = 1'b0;
      entrylck_f_swen   = 1'b0;
    end
  end

  //****************************************************************************************************
  // CONFIGURATION PROTECTION REGISTERS
  //****************************************************************************************************

  if (CFG.SRCMD_FMT_0 || CFG.SRCMD_FMT_2) begin : gen_mdlck_mdlckh_regs

    // ########### MDLCK ###########
    regfield #(
      .DW      (1),
      .SWACCESS("W1SS"),
      .RESVAL  (!CFG.IMP_MDLCK)
    ) u_mdlck_l
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (mdlck_l_swen),
      .swdata  (mdlck_l_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (config_prot_reg.mdlck.l)
    );

    regfield #(
      .DW      (31),
      .SWACCESS("RW"),
      .RESVAL  ('0)
    ) u_mdlck_md
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (mdlck_md_swen),
      .swdata  (mdlck_md_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (config_prot_reg.mdlck.md)
    );

    // ########### MDLCKH ###########
    regfield #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  ('0)
    ) u_mdlckh_mdh
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (mdlckh_mdh_swen),
      .swdata  (mdlckh_mdh_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (config_prot_reg.mdlckh.mdh)
    );
  end
  else begin : gen_mdlck_mdlckh_reg_hardwired_zero
    assign config_prot_reg.mdlck  = '0;
    assign config_prot_reg.mdlckh = '0;
  end

  if (CFG.MDCFG_FMT_0) begin : gen_mdcfglck_reg

    // ########### MDCFGLCK ###########
    regfield #(
      .DW      (1),
      .SWACCESS("W1SS"),
      .RESVAL  (!CFG.IMP_MDCFGLCK)
    ) u_mdcfglck_l
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (mdcfglck_l_swen),
      .swdata  (mdcfglck_l_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (config_prot_reg.mdcfglck.l)
    );

    regfield #(
      .DW      (6),
      .SWACCESS("RW"),
      .RESVAL  (CFG.MDCFGLCK_F)
    ) u_mdcfglck_f
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (mdcfglck_f_swen),
      .swdata  (mdcfglck_f_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (config_prot_reg.mdcfglck.f)
    );
  end
  else begin : gen_mdcfglck_reg_hardwired_zero
    assign config_prot_reg.mdcfglck = '0;
  end

  // ########### ENTRYLCK ###########
  regfield #(
    .DW      (1),
    .SWACCESS("W1SS"),
    .RESVAL  (!CFG.IMP_ENTRYLCK)
  ) u_entrylck_l
  (
    .clk     (clk),
    .rst_n   (rst_n),

    .swen    (entrylck_l_swen),
    .swdata  (entrylck_l_swdata),

    .hwen    (1'b0),
    .hwdata  ('0),

    .hwrdata (config_prot_reg.entrylck.l)
  );

  regfield #(
    .DW      (16),
    .SWACCESS("RW"),
    .RESVAL  (CFG.ENTRYLCK_F)
  ) u_entrylck_f
  (
    .clk     (clk),
    .rst_n   (rst_n),

    .swen    (entrylck_f_swen),
    .swdata  (entrylck_f_swdata),

    .hwen    (1'b0),
    .hwdata  ('0),

    .hwrdata (config_prot_reg.entrylck.f)
  );

endmodule