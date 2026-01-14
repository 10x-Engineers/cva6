///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 27-June-2025
/// Description: This module implements the register map of the IOPMP and
/// manages register read and write operations. Register read access is
/// controlled through mux selects in a single cycle and write access is
/// controlled via special demuxes having an enable signal and route
/// corresponsing write valid signals to register accurately. It ensures
/// correct register interface behavior in coordination with the AHB-Lite
/// bus and provides register data to internal functional units such as
/// TTU, RAP, EIC and AXI Master and Slave Request Manager.
///////////////////////////////////////////////////////////////////////////

module regmap
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import rfm_pkg::rfm_ttu_t;
  import rfm_pkg::rfm_rap_t;
  import rfm_pkg::rfm_eic_t;
  import rfm_pkg::eic_rfm_t;
  import rfm_pkg::change_state_e;
  import rfm_pkg::iopmp_reg_t;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                           clk,                   // Clock Rising Edge
  input  logic                           rst_n,                 // Reset Active Low

  // Address Check ==> Regmap
  input  logic                           is_addr_legal,         // Indicates address is legal or illegal
  input  logic                           base_reg_legal,        // Indicates whether incoming address belongs to a legal register in BASE region section 1
  input  logic                           info_legal,            // Indicates whether incoming address belongs to a legal INFO register
  input  logic                           prog_prot_legal,       // Indicates whether incoming address belongs to a legal PROGRAMMING PROTECTION register
  input  logic                           config_prot_legal,     // Indicates whether incoming address belongs to a legal CONFIGURATION PROTECTION register
  input  logic                           err_rpt_legal,         // Indicates whether incoming address belongs to a legal ERROR REPORTING register
  input  logic                           mdcfg_legal,           // Indicates whether incoming address belongs to MDCFG region section 1
  input  logic                           srcmd_legal,           // Indicates whether incoming address belongs to a legal register in SRCMD region section 1
  input  logic                           entry_array_legal,     // Indicates whether incoming address is legal or not in entry array

  // AHB-LITE Interface ==> Regmap
  input  logic [8:0]                     req_offset_addr,       // Incoming request offset address bit[10:2]
  input  logic                           req_access_type,       // Indicates whether the incoming request wants a write access (logic high) or read access (logic low)
  input  logic [AHB_LITE_DATA_WIDTH-1:0] req_wdata,             // Write data for write request

  // Regmap <==> Error and Interrupt Control
  input  eic_rfm_t                       eic_rfm,               // Write enables and Data to write on error registers from EIC in case error has occured
  input  logic                           eic_rfm_valid,         // Indicates that a subsequent violation has occured and set the window index pointed by eic_rfm_err_rrid
  input  logic [5:0]                     eic_rfm_err_rrid,      // Indicates RRID for subsequent violations to set the corresponding index in window
  output rfm_eic_t                       rfm_eic,               // Register data required in EIC to determine whether to generate interrupt, log error in error registers or record subsequest violations

  // Regmap ==> Table Traversal Unit
  output rfm_ttu_t                       rfm_ttu,               // Registers data required in TTU for Table Lookup

  // Regmap ==> Rule Analyzer Pipeline
  output rfm_rap_t                       rfm_rap,               // Registers data required in RAP for address and permission matches

  // Regmap ==> AXI Master Request Manager
  output change_state_e                  change_state,          // Indicates the Master Request Manager about the state transition
  output logic [CFG.RRID_NUM-1:0]        rrid_stall,            // Stall signal required in AXI Master Request Manager to determine whether to stall the transaction for specific RRID or not

  // Regmap ==> Slave Request Manager
  output logic [10:0]                    msi_data,              // The data to trigger MSI

  // Regmap ==> Response Generation
  output logic [AHB_LITE_DATA_WIDTH-1:0] ahb_hrdata             // Register data on read read request
);

  localparam logic [62:0] MD_NUM_MASK = ~('1 << CFG.MD_NUM);  // Inidcates the implementation status of an MD (1 bit per MD) based on read-only field hwcfg0.md_num
  localparam logic [CFG.ENTRY_NUM-1:0] PRIO_ENTRY_MASK = ~('1 << CFG.PRIO_ENTRY);   // Indicates the priority status of an entry (1 bit per entry) based on configured value

  //###############################
  // Internal Signals Declarations
  //###############################

  iopmp_reg_t                              iopmp_reg;
  logic                                    write_valid, base_reg_write_valid, mdcfg_reg_write_valid, srcmd_reg_write_valid, entry_array_reg_write_valid;
  logic [AHB_LITE_DATA_WIDTH-1:0]          err_mfr_rdata;
  logic [CFG.ENTRY_NUM-1:0][5:0]           napot_size;
  logic [CFG.ENTRY_NUM-1:0]                valid_range_vec;
  logic                                    err_mfr_read_legal;
  logic [47:0]                             prio_entry;
  logic [CFG.ENTRY_NUM-1:0]                prio_entry_vec;
  logic [CFG.RRID_NUM-1:0][CFG.MD_NUM-1:0] srcmd_en_enh;

  assign write_valid = req_access_type && is_addr_legal;    // On a write request, write_valid will be high only when address is legal

  // Determine the read request on err_mfr register when ERROR_CAPTURE_EN and MFR_EN is enabled
  assign err_mfr_read_legal = err_rpt_legal && is_addr_legal && (!req_access_type) && (req_offset_addr[2:0] == 3'b101) && CFG.ERROR_CAPTURE_EN && CFG.MFR_EN;

  // If IOPMP supports programmable priority entry feature, then prio_entry_vec is calculated from the hwcfg2.prio_entry
  // at run time. Otherwise, prio_entry_vec is generated at compile time using configured value
  if (CFG.PRIENT_PROG) begin : gen_programmable_prio_entry_vector
    assign prio_entry     = ~({48{1'b1}} << iopmp_reg.info_reg.hwcfg2.prio_entry[5:0]);
    assign prio_entry_vec = {{(CFG.ENTRY_NUM-48){1'b0}}, prio_entry};
  end
  else begin : gen_prio_entry_vector_constant
    assign prio_entry_vec = PRIO_ENTRY_MASK;
  end

  // Level 1 flop for the write path
  always_ff @(posedge clk or negedge rst_n) begin : write_valid_l1_flops
    if (!rst_n) begin
      base_reg_write_valid        <= 1'b0;
      mdcfg_reg_write_valid       <= 1'b0;
      srcmd_reg_write_valid       <= 1'b0;
      entry_array_reg_write_valid <= 1'b0;
    end
    else begin
      base_reg_write_valid        <= write_valid;
      mdcfg_reg_write_valid       <= write_valid;
      srcmd_reg_write_valid       <= write_valid;
      entry_array_reg_write_valid <= write_valid;
    end
  end

  if (CFG.SRCMD_FMT_0) begin : drive_srcmd_en_enh
    for (genvar index = 0; index < CFG.RRID_NUM; index = index+1) begin : gen_srcmd_en_enh
      assign srcmd_en_enh[index] = {iopmp_reg.srcmd_table.srcmd_table_0[index].srcmd_enh.mdh, iopmp_reg.srcmd_table.srcmd_table_0[index].srcmd_en.md};
    end
  end
  else begin : srcmd_en_enh_zero
    assign srcmd_en_enh = '0;
  end

  // Base Registers module instance
  base_regs #(
    .CFG(CFG),
    .MD_NUM_MASK(MD_NUM_MASK)
  ) base_regs
  (
    .clk                  (clk),                              // Clock Rising Edge
    .rst_n                (rst_n),                            // Reset Active Low

    // AHB-LITE Interface ==> Base Registers
    .base_reg_demux_sel   (req_offset_addr[2:0]),             // BASE register write path demux select signal
    .base_reg_swdata      (req_wdata),                        // Write data for write request

    // Address Check ==> Base Registers
    .info_legal           (info_legal),                       // Indicates whether incoming address belongs to a legal INFO register
    .prog_prot_legal      (prog_prot_legal),                  // Indicates whether incoming address belongs to a legal PROGRAMMING PROTECTION register
    .config_prot_legal    (config_prot_legal),                // Indicates whether incoming address belongs to a legal CONFIGURATION PROTECTION register
    .err_rpt_legal        (err_rpt_legal),                    // Indicates whether incoming address belongs to a legal ERROR REPORTING register

    // Regmap ==> Base Registers
    .base_reg_write_valid (base_reg_write_valid),             // Base register write valid signal
    .err_mfr_read_legal   (err_mfr_read_legal),               // Indicates read request on err_mfr register

    // SRCMD Registers ==> Base Registers
    .srcmd_en_enh         (srcmd_en_enh),                     // SRCMD Table in SRCMD Format 0 required to handle the RRID stall

    // Base Registers <==> Error and Interrupt Control
    .eic_rfm              (eic_rfm),                          // Write enables and Data to write on error registers from EIC in case error has occured
    .eic_rfm_valid        (eic_rfm_valid),                    // Indicates that a subsequent violation has occured and set the window index pointed by eic_rfm_err_rrid
    .eic_rfm_err_rrid     (eic_rfm_err_rrid),                 // Indicates RRID for subsequent violations to set the corresponding index in window

    // Base Registers ==> Regmap
    .info_reg             (iopmp_reg.info_reg),               // INFO Registers
    .prog_prot_reg        (iopmp_reg.prog_prot_reg),          // PROGRAMMING PROTECTION Registers
    .config_prot_reg      (iopmp_reg.config_prot_reg),        // CONFIGURATION PROTECTION Registers
    .err_rpt_reg          (iopmp_reg.err_rpt_reg),            // ERROR REPORTING Registers

    // Base Registers ==> AXI Master Request Manager
    .change_state         (change_state),                     // Indicates the Master Request Manager about the state transition
    .rrid_stall           (rrid_stall),                       // Stall signal required in AXI Master Request Manager to determine whether to stall the transaction for specific RRID or not

    // Base Registers ==> Read Register
    .err_mfr_rdata        (err_mfr_rdata)                     // ERR_MFR read data
  );

  if (CFG.MDCFG_FMT_0) begin : gen_mdcfg_fmt_0_write_path

    // MDCFG Registers module instance
    mdcfg_regs #(
      .CFG(CFG)
    ) mdcfg_regs
    (
      .clk                   (clk),                                         // Clock Rising Edge
      .rst_n                 (rst_n),                                       // Reset Active Low

      // AHB-LITE Interface ==> MDCFG Registers
      .mdcfg_selected_demux  (req_offset_addr[5:3]),                        // MDCFG demux to select
      .mdcfg_reg_demux_sel   (req_offset_addr[2:0]),                        // MDCFG register write path demux select signal
      .mdcfg_reg_swdata      (req_wdata),                                   // Write data for write request

      // Address Check ==> MDCFG Registers
      .mdcfg_legal           (mdcfg_legal),                                 // Indicates whether incoming address belongs to MDCFG region section 1

      // Regmap ==> MDCFG Registers
      .mdcfg_reg_write_valid (mdcfg_reg_write_valid),                       // MDCFG register write valid signal

      // Base Registers ==> MDCFG Registers
      .mdcfglck_f            (iopmp_reg.config_prot_reg.mdcfglck.f),        // Indicates the number of locked mdcfg registers
      .hwcfg1_entry_num      (iopmp_reg.info_reg.hwcfg1.entry_num[7:0]),    // Indicates the number of supoorted entries

      // MDCFG Registers ==> Regmap
      .mdcfg_table           (iopmp_reg.mdcfg_table)                        // MDCFG registers
    );
  end
  else begin : drive_mdcfg_table_data_zero

    assign iopmp_reg.mdcfg_table = '0;
  end

  // SRCMD TABLE contains SRCMD_EN, SRCMD_ENH and SPS Extension (SRCMD_R, SRCMD_RH, SRCMD_W and SRCMD_WH registers) registers in SRCMD Format 0
  if (CFG.SRCMD_FMT_0) begin : gen_srcmd_fmt_0_write_path

    // SRCMD Format 0 Registers module instance
    srcmd_fmt_0_regs #(
      .CFG(CFG),
      .MD_NUM_MASK(MD_NUM_MASK)
    ) srcmd_fmt_0_regs
    (
      .clk                   (clk),                                   // Clock Rising Edge
      .rst_n                 (rst_n),                                 // Reset Active Low

      // AHB-LITE Interface ==> SRCMD Format 0 Registers
      .srcmd_selected_demux  (req_offset_addr[8:3]),                  // SRCMD demux to select
      .srcmd_reg_demux_sel   (req_offset_addr[2:0]),                  // SRCMD register write path demux select signal
      .srcmd_reg_swdata      (req_wdata),                             // Write data for write request

      // Address Check ==> SRCMD Format 0 Registers
      .srcmd_legal           (srcmd_legal),                           // Indicates whether incoming address belongs to a legal register in SRCMD region section 1

      // Regmap ==> SRCMD Format 0 Registers
      .srcmd_reg_write_valid (srcmd_reg_write_valid),                 // SRCMD TABLE register write valid signal

      // Base Registers ==> SRCMD Format 0 Registers
      .mdlck_md              (iopmp_reg.config_prot_reg.mdlck.md),    // MDLCK indicates which MDs are locked in the SRCMD Table lower registers
      .mdlckh_mdh            (iopmp_reg.config_prot_reg.mdlckh.mdh),  // MDLCKH indicates which MDs are locked in the SRCMD Table upper registers

      // SRCMD Format 0 Registers ==> Regmap
      .srcmd_table_0         (iopmp_reg.srcmd_table.srcmd_table_0)    // SRCMD TABLE registers
    );

    assign iopmp_reg.srcmd_table.srcmd_table_2 = '0;
  end

  // SRCMD TABLE contains SRCMD_PERM, SRCMD_PERMH registers in SRCMD Format 2
  else if (CFG.SRCMD_FMT_2) begin : gen_srcmd_fmt_2_write_path

    // SRCMD Format 2 Registers module instance
    srcmd_fmt_2_regs #(
      .CFG(CFG)
    ) srcmd_fmt_2_regs
    (
      .clk                   (clk),                                   // Clock Rising Edge
      .rst_n                 (rst_n),                                 // Reset Active Low

      // AHB-LITE Interface ==> SRCMD Format 2 Registers
      .srcmd_selected_demux  (req_offset_addr[8:3]),                  // SRCMD demux to select
      .srcmd_reg_demux_sel   (req_offset_addr[2:0]),                  // SRCMD register write path demux select signal
      .srcmd_reg_swdata      (req_wdata),                             // Write data for write request

      // Address Check ==> SRCMD Format 2 Registers
      .srcmd_legal           (srcmd_legal),                           // Indicates whether incoming address belongs to a legal register in SRCMD region section 1

      // Regmap ==> SRCMD Format 2 Registers
      .srcmd_reg_write_valid (srcmd_reg_write_valid),                 // SRCMD TABLE register write valid signal

      // Base Registers ==> SRCMD Format 2 Registers
      .mdlck_md              (iopmp_reg.config_prot_reg.mdlck.md),    // MDLCK.md[m] indicates that SRCMD_PERM(m), SRCMD_PERMH(m) is locked where 0 <= m <= 30
      .mdlckh_mdh            (iopmp_reg.config_prot_reg.mdlckh.mdh),  // MDLCKH.mdh[m] indicates that SRCMD_PERM(m), SRCMD_PERMH(m) is locked where 30 < m <= 62

      // SRCMD Format 2 Registers ==> Regmap
      .srcmd_table_2         (iopmp_reg.srcmd_table.srcmd_table_2)    // SRCMD TABLE registers
    );

    assign iopmp_reg.srcmd_table.srcmd_table_0 = '0;
  end
  else begin : drive_srcmd_table_data_zero

    assign iopmp_reg.srcmd_table.srcmd_table_0 = '0;
    assign iopmp_reg.srcmd_table.srcmd_table_2 = '0;
  end

  // ENTRY ARRAY Registers module instance
  entry_array_regs #(
    .CFG(CFG)
  ) entry_array_regs
  (
    .clk                         (clk),                                         // Clock Rising Edge
    .rst_n                       (rst_n),                                       // Reset Active Low

    // AHB-LITE Interface ==> ENTRY ARRAY Registers
    .entry_array_selected_demux  (req_offset_addr[8:3]),                        // ENTRY_ARRAY demux to select
    .entry_array_reg_demux_sel   (req_offset_addr[2:0]),                        // ENTRY ARRAY register write path demux select signal
    .entry_array_reg_swdata      (req_wdata),                                   // Write data for write request

    // Address Check ==> ENTRY ARRAY Registers
    .entry_array_legal           (entry_array_legal),                           // Indicates whether incoming address belongs to a legal register in ENTRY ARRAY region section 2

    // Regmap ==> ENTRY ARRAY Registers
    .entry_array_reg_write_valid (entry_array_reg_write_valid),                 // ENTRY ARRAY register write valid signal

    // Base Registers ==> ENTRY ARRAY Registers
    .entrylck_f                  (iopmp_reg.config_prot_reg.entrylck.f[7:0]),   // Indicates the number of locked entry array registers

    // ENTRY ARRAY Registers ==> Regmap
    .entry_array                 (iopmp_reg.entry_array),                       // ENTRY ARRAY registers
    .napot_size                  (napot_size),                                  // Calculated value of NAPOT size per entry based on 64 bit entry address
    .valid_range_vec             (valid_range_vec)                              // Each bit indicates that the entry address is greater than the previous entry address (applicable for TOR address mode)
  );

  // Read Register module instance
  read_register #(
    .CFG(CFG)
  ) read_register
  (
    // AHB-LITE Interface ==> Read Register
    .req_offset_addr   (req_offset_addr),     // Incoming request offset address bit[10:2]

    // Address Check ==> Read Register
    .is_addr_legal     (is_addr_legal),       // Indicates address is legal or illegal
    .base_reg_legal    (base_reg_legal),      // Indicates whether incoming address belongs to a legal register in BASE region section 1
    .mdcfg_legal       (mdcfg_legal),         // Indicates whether incoming address belongs to a legal register in MDCFG region section 1
    .srcmd_legal       (srcmd_legal),         // Indicates whether incoming address belongs to a legal register in SRCMD region section 1
    .entry_array_legal (entry_array_legal),   // Indicates whether incoming address belongs to a legal register in ENTRY ARRAY region section 2

    // Base Registers ==> Read Register
    .err_mfr_rdata     (err_mfr_rdata),       // ERR_MFR read data

    // Regmap ==> Read Register
    .iopmp_reg         (iopmp_reg),           // IOPMP Registers Packed Struct

    // Read Register ==> Regmap
    .ahb_hrdata        (ahb_hrdata)           // Holds registers data in case of read request
  );

  // Registers data required in EIC to determine whether to generate interrupt, log error in error registers or record subsequest violations
  assign rfm_eic = '{
    err_cfg_ie        : iopmp_reg.err_rpt_reg.err_cfg.ie,           // Enable the interrupt of the IOPMP rule violation
    err_cfg_msi_en    : iopmp_reg.err_rpt_reg.err_cfg.msi_en,       // Indicates whether the IOPMP triggers interrupt by MSI (logic high) or wired interrupt (logic low)
    err_info_v        : iopmp_reg.err_rpt_reg.err_info.v,           // Indicates whether the illegal capture recorder holds valid data. When set, further errors are not logged in the error registers
    err_info_msi_werr : iopmp_reg.err_rpt_reg.err_info.msi_werr,    // Indicates a failed write attempt to trigger an IOPMP-generated MSI. When set, no interrupt is issued and no error is logged in the error registers
    err_msiaddr       : iopmp_reg.err_rpt_reg.err_msiaddr,          // Lower 32 bit address to trigger MSI
    err_msiaddrh      : iopmp_reg.err_rpt_reg.err_msiaddrh          // Upper 20 bit address to trigger MSI
  };

  // MSI Data to Slave Request Manager
  assign msi_data = iopmp_reg.err_rpt_reg.err_cfg.msidata;          // The data to trigger MSI

  // Register data required in TTU to determine transaction validity, mdcfg and srcmd table traversal
  assign rfm_ttu = '{
    hwcfg0_chk_x        : iopmp_reg.info_reg.hwcfg0.chk_x,                // Indicates if the IOPMP implements the check of an instruction fetch. On chk_x=0, all fields of illegal instruction fetches are ignored
    hwcfg0_no_x         : iopmp_reg.info_reg.hwcfg0.no_x,                 // For chk_x=1, the IOPMP with no_x=1 always fails on an instruction fetch; otherwise, it should depend on x-bit in ENTRY_CFG(i)
    hwcfg0_no_w         : iopmp_reg.info_reg.hwcfg0.no_w,                 // Indicates if the IOPMP always fails write accesses considered as as no rule matched
    hwcfg0_enable       : iopmp_reg.info_reg.hwcfg0.enable,               // Indicates if the IOPMP checks an incoming transactions
    hwcfg1_rrid_num     : iopmp_reg.info_reg.hwcfg1.rrid_num,             // Indicates the number of supported RRIDs
    hwcfg0_md_entry_num : iopmp_reg.info_reg.hwcfg0.md_entry_num[2:0],    // In MDCFG Format 1 and 2, md_entry_num indicates each memory domain exactly has (md_entry_num + 1) entries in a memory domain
    mdcfg               : iopmp_reg.mdcfg_table,                          // MDCFG TABLE registers when MDCFG Format is 0
    srcmd_table_0       : iopmp_reg.srcmd_table.srcmd_table_0,            // SRCMD TABLE registers struct when SRCMD Format is 0
    srcmd_table_2       : iopmp_reg.srcmd_table.srcmd_table_2             // SRCMD TABLE registers struct when SRCMD Format is 2
  };

  // Register data required in RAP to match address and permissions based on addressing mode for priority and non priority entries
  assign rfm_rap = '{
    entry_table     : iopmp_reg.entry_array,   // ENTRY ARRAY registers struct
    napot_size      : napot_size,              // Calculated value of NAPOT size per entry based on 64 bit entry address
    prio_entry_vec  : prio_entry_vec,          // Indicates the priority status of an entry (1 bit per entry) based on hwcfg2.prio_entry field
    valid_range_vec : valid_range_vec          // Each bit indicates that the entry address is greater than the previous entry address (applicable for TOR address mode)
  };

endmodule