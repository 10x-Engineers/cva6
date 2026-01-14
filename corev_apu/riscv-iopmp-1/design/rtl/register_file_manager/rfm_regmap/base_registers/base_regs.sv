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

module base_regs
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import rfm_pkg::change_state_e;
  import rfm_pkg::rfm_eic_t;
  import rfm_pkg::eic_rfm_t;
  import rfm_pkg::info_reg_t;
  import rfm_pkg::prog_prot_reg_t;
  import rfm_pkg::config_prot_reg_t;
  import rfm_pkg::err_rpt_reg_t;
  import rfm_pkg::srcmd_table_0_t;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default,

  // Inidcates the implementation status of an MD (1 bit per MD) based on read-only field hwcfg0.md_num
  parameter logic [62:0] MD_NUM_MASK = 0
) (
  input  logic                              clk,                          // Clock Rising Edge
  input  logic                              rst_n,                        // Reset Active Low

  // AHB-LITE Interface ==> Regmap
  input  logic [2:0]                        base_reg_demux_sel,           // BASE register write path demux select signal
  input  logic [AHB_LITE_DATA_WIDTH-1:0]    base_reg_swdata,              // Write data for write request

  // Address Check ==> Base Registers
  input  logic                              info_legal,                   // Indicates whether incoming address belongs to a legal INFO register
  input  logic                              prog_prot_legal,              // Indicates whether incoming address belongs to a legal PROGRAMMING PROTECTION register
  input  logic                              config_prot_legal,            // Indicates whether incoming address belongs to a legal CONFIGURATION PROTECTION register
  input  logic                              err_rpt_legal,                // Indicates whether incoming address belongs to a legal ERROR REPORTING register

  // Regmap ==> Base Registers
  input  logic                              base_reg_write_valid,         // Base register write valid signal
  input  logic                              err_mfr_read_legal,           // Indicates read request on err_mfr register

  // SRCMD Registers ==> Base Registers
  input  [CFG.RRID_NUM-1:0][CFG.MD_NUM-1:0] srcmd_en_enh,                // SRCMD Table in SRCMD Format 0 required to handle the RRID stall

  // Base Registers <==> Error and Interrupt Control
  input  eic_rfm_t                          eic_rfm,                      // Write enables and Data to write on error registers from EIC in case error has occured
  input  logic                              eic_rfm_valid,                // Indicates that a subsequent violation has occured and set the window index pointed by eic_rfm_err_rrid
  input  logic [5:0]                        eic_rfm_err_rrid,             // Indicates RRID for subsequent violations to set the corresponding index in window

  // Base Registers ==> Regmap
  output info_reg_t                         info_reg,                     // INFO Registers
  output prog_prot_reg_t                    prog_prot_reg,                // PROGRAMMING PROTECTION Registers
  output config_prot_reg_t                  config_prot_reg,              // CONFIGURATION PROTECTION Registers
  output err_rpt_reg_t                      err_rpt_reg,                  // ERROR REPORTING Registers

  // Base Registers ==> AXI Master Request Manager
  output change_state_e                     change_state,                 // Indicates the Master Request Manager about the IOPMP state transition.
  output logic [CFG.RRID_NUM-1:0]           rrid_stall,                   // Stall signal required in AXI Master Request Manager to determine whether to stall the transaction for specific RRID or not.

  output logic [AHB_LITE_DATA_WIDTH-1:0]    err_mfr_rdata                 // ERR_MFR value on read
);

  //###############################
  // Internal Signals Declarations
  //###############################

  logic [AHB_LITE_DATA_WIDTH-1:0] base_reg_swdata_q;
  logic                           base_reg_write_valid_q;
  logic [2:0]                     base_reg_demux_sel_q;
  logic                           err_info_svc_hwen;          // ERR_INFO.svc HW write enable signal
  logic                           err_info_svc_hwdata;        // ERR_INFO.svc HW write data signal
  logic                           err_mfr_svs_hwen;           // ERR_MFR.svs HW write enable signal
  logic                           err_mfr_svs_hwdata;         // ERR_MFR.svs HW write data signal
  logic [15:0]                    err_mfr_svw_hwdata;         // ERR_MFR.svw HW write enable signal
  logic                           err_mfr_svw_hwen;           // ERR_MFR.svw HW write data signal
  logic [11:0]                    err_mfr_svi_hwdata;         // ERR_MFR.svi HW write enable signal
  logic                           err_mfr_svi_hwen;           // ERR_MFR.svi HW write data signal

  info_regs #(
    .CFG(CFG)
  ) info_regs
  (
    .clk                  (clk),                        // Clock Rising Edge
    .rst_n                (rst_n),                      // Reset Active Low

    // Address Check ==> INFO Registers
    .info_legal           (info_legal),                 // Indicates whether incoming address belongs to a legal INFO register

    // Base Registers ==> INFO Registers
    .info_reg_demux_sel   (base_reg_demux_sel_q),       // INFO register write path demux select signal
    .info_reg_write_valid (base_reg_write_valid_q),     // Write valid signal for INFO register
    .info_reg_swdata      (base_reg_swdata_q),          // Write data for INFO registers

    // INFO Registers ==> Base Registers
    .info_reg             (info_reg)                    // INFO Registers
  );

  prog_prot_regs #(
    .CFG(CFG),
    .MD_NUM_MASK(MD_NUM_MASK)
  ) prog_prot_regs
  (
    .clk                       (clk),                               // Clock Rising Edge
    .rst_n                     (rst_n),                             // Reset Active Low

    // Address Check ==> PROGRAMMING PROTECTION Registers
    .prog_prot_legal           (prog_prot_legal),                   // Indicates whether incoming address belongs to a legal PROGRAMMING PROTECTION register

    // Base Registers ==> PROGRAMMING PROTECTION Registers
    .prog_prot_reg_demux_sel   (base_reg_demux_sel_q),              // PROGRAMMING PROTECTION register write path demux select signal
    .prog_prot_reg_write_valid (base_reg_write_valid_q),            // Write valid signal for PROGRAMMING PROTECTION register
    .prog_prot_reg_swdata      (base_reg_swdata_q),                 // Write data for PROGRAMMING PROTECCTION registers

    // INFO Registers ==> PROGRAMMING PROTECTION Registers
    .hwcfg1_rrid_num           (info_reg.hwcfg1.rrid_num[6:0]),     // Indicates the number of supported RRIDs

    // SRCMD Format 0 Registers ==> PROGRAMMING PROTECTION Registers
    .srcmd_en_enh              (srcmd_en_enh),                      // SRCMD Table in SRCMD Format 0 required to handle the RRID stall

    // PROGRAMMING PROTECTION Registers ==> AXI Master Request Manager
    .change_state              (change_state),                      // Indicates the Master Request Manager about the IOPMP state transition
    .rrid_stall                (rrid_stall),                        // Stall signal required in AXI Master Request Manager to determine whether to stall the transaction for specific RRID or not

    .prog_prot_reg             (prog_prot_reg)                      // PROGRAMMING PROTECTION Registers
  );

  config_prot_regs #(
    .CFG(CFG),
    .MD_NUM_MASK(MD_NUM_MASK)
  ) config_prot_regs
  (
    .clk                         (clk),                               // Clock Rising Edge
    .rst_n                       (rst_n),                             // Reset Active Low

    // Address Check ==> CONFIGURATION PROTECTION Registers
    .config_prot_legal           (config_prot_legal),                 // Indicates whether incoming address belongs to a legal CONFIGURATION PROTECTION register

    // Base Registers ==> CONFIGURATION PROTECTION Registers
    .config_prot_reg_demux_sel   (base_reg_demux_sel_q),              // CONFIGURATION PROTECTION register write path demux select signal
    .config_prot_reg_write_valid (base_reg_write_valid_q),            // Write valid signal for CONFIGURATION PROTECTION register
    .config_prot_reg_swdata      (base_reg_swdata_q),                 // Write data for CONFIGURATION PROTECTION registers

    // INFO Registers ==> CONFIGURATION PROTECTION Registers
    .hwcfg0_md_num               (info_reg.hwcfg0.md_num),            // Indicates the number of supported MDs
    .hwcfg1_entry_num            (info_reg.hwcfg1.entry_num[7:0]),    // Indicates the number of supported priority entries

    // CONFIGURATION PROTECTION Registers ==> Regamp
    .config_prot_reg             (config_prot_reg)                    // CONFIGURATION PROTECTION Registers
  );

  err_rpt_regs #(
    .CFG(CFG)
  ) err_rpt_regs
  (
    .clk                     (clk),                               // Clock Rising Edge
    .rst_n                   (rst_n),                             // Reset Active Low

    // Address Check ==> ERROR REPORTING Registers
    .err_rpt_legal           (err_rpt_legal),                     // Indicates whether incoming address belongs to a legal ERROR REPORTING register

    // Base Registers ==> ERROR REPORTING Registers
    .err_rpt_reg_demux_sel   (base_reg_demux_sel_q),              // ERROR REPORTING register write path demux select signal
    .err_rpt_reg_write_valid (base_reg_write_valid_q),            // Write valid signal for ERROR REPORTING register
    .err_rpt_reg_swdata      (base_reg_swdata_q),                 // Write data for ERROR REPORTING registers

    // Error and Interrupt Control ==> ERROR REPORTING Registers
    .eic_rfm                 (eic_rfm),                           // Write enables and Data to write on error registers from EIC in case error has occured

    // Error Record Window ==> ERROR REPORTING Registers
    .err_info_svc_hwen       (err_info_svc_hwen),                 // ERR_INFO.svc HW write enable signal
    .err_info_svc_hwdata     (err_info_svc_hwdata),               // ERR_INFO.svc HW write data signal
    .err_mfr_svs_hwen        (err_mfr_svs_hwen),                  // ERR_MFR.svs HW write enable signal
    .err_mfr_svs_hwdata      (err_mfr_svs_hwdata),                // ERR_MFR.svs HW write data signal
    .err_mfr_svw_hwen        (err_mfr_svw_hwen),                  // ERR_MFR.svw HW write enable signal
    .err_mfr_svw_hwdata      (err_mfr_svw_hwdata),                // ERR_MFR.svw HW write data signal
    .err_mfr_svi_hwen        (err_mfr_svi_hwen),                  // ERR_MFR.svi HW write enable signal
    .err_mfr_svi_hwdata      (err_mfr_svi_hwdata),                // ERR_MFR.svi HW write data signal

    // ERROR REPORTING Registers ==> Base Registers
    .err_rpt_reg             (err_rpt_reg)                        // ERROR REPORTING Registers
  );

  if (CFG.ERROR_CAPTURE_EN && CFG.MFR_EN) begin : gen_err_record_windows
    error_record_windows #(
      .CFG(CFG)
    ) error_record_windows
    (
      .clk                 (clk),                               // Clock Rising Edge
      .rst_n               (rst_n),                             // Reset Active Low

      // ERROR REPORTING Registers ==> Error Record Window
      .err_mfr_reg         (err_rpt_reg.err_mfr),               // Read ERR_MFR register

      // Base Registers ==> Error Record Window
      .err_mfr_read_legal  (err_mfr_read_legal),                // Indicates a read request on err_mfr register

      // Error and Interrupt Control ==> Error Record Window
      .eic_rfm_valid       (eic_rfm_valid),                     // Indicates that a subsequent violation has occured and set the window index pointed by eic_rfm_err_rrid
      .eic_rfm_err_rrid    (eic_rfm_err_rrid),                  // Indicates RRID for subsequent violations to set the corresponding index in window

      // Error Record Window ==> ERROR REPORTING Registers
      .err_info_svc_hwen   (err_info_svc_hwen),                 // ERR_INFO.svc HW write enable signal
      .err_info_svc_hwdata (err_info_svc_hwdata),               // ERR_INFO.svc HW write data signal
      .err_mfr_svs_hwen    (err_mfr_svs_hwen),                  // ERR_MFR.svs HW write enable signal
      .err_mfr_svs_hwdata  (err_mfr_svs_hwdata),                // ERR_MFR.svs HW write data signal
      .err_mfr_svw_hwen    (err_mfr_svw_hwen),                  // ERR_MFR.svw HW write enable signal
      .err_mfr_svw_hwdata  (err_mfr_svw_hwdata),                // ERR_MFR.svw HW write data signal
      .err_mfr_svi_hwen    (err_mfr_svi_hwen),                  // ERR_MFR.svi HW write enable signal
      .err_mfr_svi_hwdata  (err_mfr_svi_hwdata),                // ERR_MFR.svi HW write data signal

      .err_mfr_rdata       (err_mfr_rdata)                      // ERR_MFR register HW write data
    );
  end
  else begin : drive_mfr_data_zero

    assign err_info_svc_hwen   = 1'b0;
    assign err_info_svc_hwdata = 1'b0;
    assign err_mfr_svs_hwen    = 1'b0;
    assign err_mfr_svs_hwdata  = 1'b0;
    assign err_mfr_svw_hwen    = 1'b0;
    assign err_mfr_svw_hwdata  = '0;
    assign err_mfr_svi_hwen    = 1'b0;
    assign err_mfr_svi_hwdata  = '0;
    assign err_mfr_rdata       = '0;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      base_reg_write_valid_q <= 1'b0;
      base_reg_swdata_q      <= '0;
      base_reg_demux_sel_q   <= '0;
    end
    else begin
      base_reg_write_valid_q <= base_reg_write_valid;
      base_reg_swdata_q      <= base_reg_swdata;
      base_reg_demux_sel_q   <= base_reg_demux_sel;
    end
  end

endmodule