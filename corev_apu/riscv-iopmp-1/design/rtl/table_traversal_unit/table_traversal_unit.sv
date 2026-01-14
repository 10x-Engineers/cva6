///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 11-June-2025
/// Description: This module implements the Table Traversal Unit (TTU)
/// responsible for enforcing access control based on IOPMP configuration.
/// Checks if IOPMP is enabled. If disabled, it bypasses transaction checks.
/// When IOPMP is enabled, the TTU inspects incoming transactions to:
///   1. Validate the RRID; transactions with invalid RRIDs are flagged
///      as errors.
///   2. Verify whether the transaction type (e.g., write or instruction
///      fetch) is permitted for the RRID.
/// Upon successful validation, the TTU reads the SRCMD table and performs
/// a lookup in the MDCFG table to determine the associated entries. It
/// sets the entry_present_or and md_rw_perm_repl vectors for these entries, which
/// are later used by the Rule Analyzer Pipeline for address and permission
/// checking.
///////////////////////////////////////////////////////////////////////////

module table_traversal_unit
  import execution_pipeline_pkg::*;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;
  import iopmp_axi_pkg::transaction_t;
  import rfm_pkg::rfm_ttu_t;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                          clk,                  // Clock Rising Edge
  input  logic                          rst_n,                // Reset Active Low

  // Axi Master Request Manager  ==>  Table Traversal Unit
  input  operation_e                    rap_operation,        // Operation to be perfomred in Table Traversal Unit
  input  transaction_t                  transaction_i,        // AXI to TTU transaction

  // Register File Manager  ==>  Table Traversal Unit
  input  rfm_ttu_t                      rfm_ttu,              // SRCMD Table, MDCFG Table and Config registers data

  // Table Traversal Unit  ==> Rule_Analyzer_Pipeline
  output logic [CFG.ENTRY_NUM-1:0]      entrypresent_or,      // Indicates the entries to be checked in Rule Analyzer Pipeline
  output logic [CFG.ENTRY_NUM-1:0][1:0] mdrwperm_repl,        // Indicates the RW permission for entries that will be matched in Rule Analyzer Pipeline
  output transaction_t                  transaction_o,        // TTU to RAP AXI transaction
  output logic [AXI_ADDR_WIDTH-1:0]     trans_end_addr,       // Transaction end Address
  output operation_e                    ttu_rapo,             // TTU to RAP operation
  output errorType_t                    ttu_rap_err_info      // Error information encountered in TTU
);

  // Parameter defining the number of TTU stages where each stage handles up to 21 entries
  // Adding 20 to CFG.MD_NUM ensures we round up the division result (i.e., ceiling division) to get correct number of stages
  localparam NUM_TTU_STAGES = (CFG.MD_NUM + 20)/21;

  //###############################
  // Internal Signals Declarations
  //###############################

  operation_e            ttu_operation;       // Indicates operation evaluated inside TTU
  errorType_t            ttu_err_info;        // Indicates error information encountered inside TTU
  logic [CFG.MD_NUM-1:0] mdpresent;           // Indicates the associated MDs with the transaction
  logic [CFG.MD_NUM-1:0] mdrperm;             // Holds SRCMD_R(H) registers value when SRCMD Format 0 and SPS Extension is enabled
  logic [CFG.MD_NUM-1:0] mdwperm;             // Holds SRCMD_W(H) registers value when SRCMD Format 0 and SPS Extension is enabled

  // This module checks whether IOPMP is enabled or not; if enabled, validates RRID and check if write/instruction-fetch accesses are allowed
  // Otherwise, transaction bypasses IOPMP. Any incoming transaction clearing all the above checks is passed to srcmd_table_traversal module for SCRMD Table Lookup
  ttu_checks #(
    .CFG(CFG)
  ) ttu_checks
  (
    // Axi Master Request Manager ==> TTU Checks
    .rap_operation    (rap_operation),                    // Operation to be perfomred in Table Traversal Unit
    .is_w_access      (transaction_i.w),                  // Incoming transaction wants a write access
    .is_x_access      (transaction_i.x),                  // Inocming transaction wants an instruction fetch access
    .transaction_rrid (transaction_i.rrid[5:0]),          // AXI transaction RRID to determine RRID validity

    // Register File Manager ==> TTU Checks
    .hwcfg0_chk_x     (rfm_ttu.hwcfg0_chk_x),             // Indicates if checking an instruction fetch access is allowed
    .hwcfg0_no_x      (rfm_ttu.hwcfg0_no_x),              // Indicates if no instruction fetch access is allowed (applicable only if hwcfg0.chk_x is 1)
    .hwcfg0_no_w      (rfm_ttu.hwcfg0_no_w),              // Indicates if no write access if allowed
    .hwcfg0_enable    (rfm_ttu.hwcfg0_enable),            // Indicates if IOPMP is enabled to check the transaction
    .hwcfg1_rrid_num  (rfm_ttu.hwcfg1_rrid_num),          // Indicates the supported value of RRIDs

    // TTU Checks ==> SRCMD Table Traversal/MDCFG Top Wrapper
    .ttu_operation    (ttu_operation),			              // Indicates operation evaluated inside TTU
    .ttu_err_info     (ttu_err_info)				              // Records error information encountered inside TTU
  );

  // Traverse the SRCMD Table and extract the associated MDs and corresponding RW permission for the associated MDs, when ttu_operation is set to SEARCH
  srcmd_table_traversal #(
    .CFG(CFG)
  ) srcmd_table_traversal
  (
    // Axi Master Request Manager ==> SRCMD Table Traversal
    .transaction_rrid (transaction_i.rrid[5:0]),            // AXI transaction RRID required for SRCMD Table indexing

    // Register File Manager ==> SRCMD Table Traversal
    .srcmd_table_0    (rfm_ttu.srcmd_table_0),              // SRCMD Table contains SRCMD_EN/SRCMD_ENH when SRCMD Format is 0 and
                                                            // if Secondary Permission Setting is enabled it also contains SRCMD_R/SRCMD_RH and SRCMD_W/SRCMD_WH registers

    // SRCMD Table Traversal ==> MDCFG Table Traversal
    .mdpresent        (mdpresent),                          // Indicates the associated MDs with the transaction
    .mdrperm          (mdrperm),                            // SRCMD_R(H) registers value when SRCMD Format 0 and SPS Extension is enabled
    .mdwperm          (mdwperm)   					                // SRCMD_W(H) registers value when SRCMD Format 0 and SPS Extension is enabled
  );


  //****************************************************************************************************
  // MDCFG Format 0
  //****************************************************************************************************

  // When MDCFG Format is 0, MDCFG Table is traversed to find associated entries and corresponding RW permissions
  if (CFG.MDCFG_FMT_0) begin : gen_mdcfg_fmt_0
    mdcfg_fmt_0 #(
      .CFG(CFG),
      .NUM_TTU_STAGES(NUM_TTU_STAGES)
    ) mdcfg_fmt_0
    (
      .clk                 (clk),                                 // Clock Rising Edge
      .rst_n               (rst_n),                               // Reset Active Low

      // Axi Master Request Manager ==> MDCFG FMT 0
      .transaction_i       (transaction_i),                       // AXI transaction

      // TTU Checks ==> MDCFG FMT 0
      .ttu_operation       (ttu_operation),                       // Operation evaluated inside Table Traversal Unit
      .ttu_err_info	       (ttu_err_info),		                    // Error information encountered inside TTU

      // Register File Manager ==> MDCFG FMT 0
      .mdcfg_table         (rfm_ttu.mdcfg),                       // MDCFG Table required when MDCFG Format is 0
      .srcmd_table_2       (rfm_ttu.srcmd_table_2),               // SRCMD Table contain srcmd_perm/srcmd_permh in SRCMD Format 2

      // SRCMD Table Traversal ==> MDCFG FMT 0
      .mdpresent           (mdpresent),                           // Indicates the associated MDs with the transaction
      .mdrperm             (mdrperm),                             // SRCMD_R(H) registers value when SRCMD Format is 0 and SPS Extension is enabled
      .mdwperm             (mdwperm),    					                // SRCMD_W(H) registers value when SRCMD Format is 0 and SPS Extension is enabled

      // MDCFG FMT 0 ==> Rule_Analyzer_Pipeline
      .entrypresent_or     (entrypresent_or),                     // Indicates the entries to be checked in Rule Analyzer Pipeline
      .mdrwperm_repl       (mdrwperm_repl),                       // Indicates the RW permission for entries that will be matched in Rule Analyzer Pipeline
      .transaction_o       (transaction_o),                       // TTU to RAP AXI transaction
      .trans_end_addr      (trans_end_addr),                      // Transaction end Address
      .ttu_rapo            (ttu_rapo),                            // TTU to RAP operation
      .rap_err_info        (ttu_rap_err_info)                     // Error information encountered in TTU
    );
  end

  //****************************************************************************************************
  // MDCFG Format 1
  //****************************************************************************************************

  // When MDCFG Format is 1, there is no physical MDCFG Table instead each MD has k (hwcfg0.md_entry_num + 1) entries
  // associated with it and hwcfg0.md_entry_num is non-programmable
  if (CFG.MDCFG_FMT_1) begin : gen_mdcfg_fmt_1
    mdcfg_fmt_1 #(
      .CFG(CFG),
      .NUM_TTU_STAGES(NUM_TTU_STAGES)
    ) mdcfg_fmt_1
    (
      .clk                 (clk),                       // Clock Rising Edge
      .rst_n               (rst_n),                     // Reset Active Low

      // Axi Master Request Manager ==> MDCFG FMT 1
      .transaction_i       (transaction_i),             // AXI transaction

      // TTU Checks ==> MDCFG FMT 1
      .ttu_operation       (ttu_operation),             // Operation evaluated inside Table Traversal Unit
      .ttu_err_info	       (ttu_err_info),		          // Error information encountered inside TTU

      // Register File Manager ==> MDCFG FMT 1
      .srcmd_table_2       (rfm_ttu.srcmd_table_2),     // SRCMD Table contain srcmd_perm/srcmd_permh in SRCMD Format 2

      // SRCMD Table Traversal ==> MDCFG FMT 1
      .mdpresent           (mdpresent),                 // Indicates the associated MDs with the transaction
      .mdrperm             (mdrperm),                   // SRCMD_R(H) registers value when SRCMD Format is 0 and SPS Extension is enabled
      .mdwperm             (mdwperm),    					      // SRCMD_W(H) registers value when SRCMD Format is 0 and SPS Extension is enabled

      // MDCFG FMT 1 ==> Rule_Analyzer_Pipeline
      .entrypresent_or     (entrypresent_or),           // Indicates the entries to be checked in Rule Analyzer Pipeline
      .mdrwperm_repl       (mdrwperm_repl),             // Indicates the RW permission for entries that will be matched in Rule Analyzer Pipeline
      .transaction_o       (transaction_o),             // TTU to RAP AXI transaction
      .trans_end_addr      (trans_end_addr),            // Transaction end Address
      .ttu_rapo            (ttu_rapo),                  // TTU to RAP operation
      .rap_err_info        (ttu_rap_err_info)           // Error information encountered in TTU
    );
  end

  //****************************************************************************************************
  // MDCFG Format 2
  //****************************************************************************************************

  // When MDCFG Format is 2, there is no physical MDCFG Table instead each MD has k (hwcfg0.md_entry_num + 1) entries
  // associated with it but hwcfg0.md_entry_num is programmable
  if (CFG.MDCFG_FMT_2) begin : gen_mdcfg_fmt_2
    mdcfg_fmt_2 #(
      .CFG(CFG),
      .NUM_TTU_STAGES(NUM_TTU_STAGES)
    ) mdcfg_fmt_2
    (
      .clk                 (clk),                                 // Clock Rising Edge
      .rst_n               (rst_n),                               // Reset Active Low

      // Axi Master Request Manager ==> MDCFG FMT 2
      .transaction_i       (transaction_i),                       // AXI transaction

      // TTU Checks ==> MDCFG FMT 2
      .ttu_operation       (ttu_operation),                       // Operation evaluated inside Table Traversal Unit
      .ttu_err_info	       (ttu_err_info),		                    // Error information encountered inside TTU

      // Register File Manager ==> MDCFG FMT 2
      .hwcfg0_md_entry_num (rfm_ttu.hwcfg0_md_entry_num),         // hwcfg0.md_entry_num + 1 indicates the number of entries associated with an MD when MDCFG Format is 2
      .srcmd_table_2       (rfm_ttu.srcmd_table_2),               // SRCMD Table contain srcmd_perm/srcmd_permh in SRCMD Format 2

      // SRCMD Table Traversal ==> MDCFG FMT 2
      .mdpresent           (mdpresent),                           // Indicates the associated MDs with the transaction
      .mdrperm             (mdrperm),                             // SRCMD_R(H) registers value when SRCMD Format is 0 and SPS Extension is enabled
      .mdwperm             (mdwperm),    					                // SRCMD_W(H) registers value when SRCMD Format is 0 and SPS Extension is enabled

      // MDCFG FMT 2 ==> Rule_Analyzer_Pipeline
      .entrypresent_or     (entrypresent_or),                     // Indicates the entries to be checked in Rule Analyzer Pipeline
      .mdrwperm_repl       (mdrwperm_repl),                       // Indicates the RW permission for entries that will be matched in Rule Analyzer Pipeline
      .transaction_o       (transaction_o),                       // TTU to RAP AXI transaction
      .trans_end_addr      (trans_end_addr),                      // Transaction end Address
      .ttu_rapo            (ttu_rapo),                            // TTU to RAP operation
      .rap_err_info        (ttu_rap_err_info)                     // Error information encountered in TTU
    );
  end

endmodule