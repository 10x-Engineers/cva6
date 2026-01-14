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
/// Description: This module checks if IOPMP is enabled. If disabled,
/// it bypasses transaction checks.
/// When IOPMP is enabled, the TTU inspects incoming transactions to:
///   1. Validate the RRID; transactions with invalid RRIDs are flagged
///      as errors.
///   2. Verify whether the transaction type (e.g., write or instruction
///      fetch) is permitted for the RRID.
/// On passing all the checks, it triggers srcmd_table_traversal module to
/// traverse the SRCMD Table to find the associated MDs and RW permissions.
///////////////////////////////////////////////////////////////////////////

module ttu_checks
  import execution_pipeline_pkg::*;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  // Axi Master Request Manager ==> TTU Checks
  input  operation_e rap_operation,        // Operation to be perfomred in Table Traversal Unit
  input  logic       is_w_access,          // Incoming transaction wants a write access
  input  logic       is_x_access,          // Inocming transaction wants an instruction fetch access
  input  logic [5:0] transaction_rrid,     // AXI transaction RRID to determine RRID validity

  // Register File Manager ==> TTU Checks
  input  logic       hwcfg0_chk_x,         // Indicates if checking an instruction fetch access is allowed
  input  logic       hwcfg0_no_x,          // Indicates if no instruction fetch access is allowed (applicable only if hwcfg0.chk_x is 1)
  input  logic       hwcfg0_no_w,          // Indicates if no write access if allowed
  input  logic       hwcfg0_enable,        // Indicates if IOPMP is enabled to check the transaction
  input  logic [6:0] hwcfg1_rrid_num,      // Indicates the supported value of RRIDs

  // TTU Checks ==> SRCMD Table Traversal/MDCFG Top Wrapper
  output operation_e ttu_operation,			  // Indicates operation evaluated inside TTU
  output errorType_t ttu_err_info				  // Records error information encountered inside TTU
);

  //###############################
  // Internal Signals Declarations
  //###############################

  logic no_write_access;				  // Indicates write access in not allowed if hwcfg0.no_w is 1
  logic no_instr_fetch_access;	  // Indicates instruction fetch access is not allowed if hwcfg0.no_x is 1 when hwcfg0.ckh_x is 1

  assign no_write_access       = is_w_access && hwcfg0_no_w;                     // Write accesses gives error when hwcfg0.no_w 1
  assign no_instr_fetch_access = is_x_access && hwcfg0_no_x && hwcfg0_chk_x;     // Instruction fetch accesses gives error when hwcfg0.no_x 1 and hwcfg0.chk_x is 1

  //****************************************************************************************************
  // Table Traversal Unit Checks
  // This block checks whether IOPMP is enabled or not; if enabled, validates RRID and check if
  // write/instruction-fetch accesses are allowed. Otherwise, transaction bypasses IOPMP
  // Any incoming transaction clearing all the above checks is passed to srcmd_table_traversal
  // module for SCRMD Table Lookup
  //****************************************************************************************************
  always_comb begin

    // The incoming transaction will be checked in TTU when operation from AXI Master Request Manager is SEARCH
    if (rap_operation == SEARCH) begin

      ttu_err_info = NO_ERROR;  // Initially set ttu_err_info to NO_ERROR

      // IOPMP checks the incoming transaction when hwcfg0.enable is set to 1; otherwise, the transaction bypasses the IOPMP
      if (hwcfg0_enable) begin

        // If IOPMP configured not to permit the write access or instruction fetch access and the incoming transaction
        // wants either a write access or instruction fetch access then marked the transaction as error with NOT HIT ANY RULE error type
        if (no_write_access || no_instr_fetch_access) begin
          ttu_operation = ERROR;
          ttu_err_info  = NOT_HIT_ANY_RULE;
        end

        // Checks the incoming transaction rrid, if it lies in valid range, perform srcmd and mdcfg table lookup
        // otherwise mark the transaction as error with UNKNOWN RRID error type
        else if (transaction_rrid >= hwcfg1_rrid_num) begin

          // If IOPMP is configured for Source Enforcement mode, then the RRID check on the incoming transaction is omitted
          // and srcmd and mdcfg table are looked up and entries are searched to match address and permissions
          if (CFG.SE_EN) begin : source_enforcement_enabled
            ttu_operation = SEARCH;
          end

          // If IOPMP is not configured for Source Enforcement mode, then transaction is marked as error with UNKNOWN RRID error type
          else begin : source_enforcement_disabled
            ttu_operation = ERROR;
            ttu_err_info  = UNKNOWN_RRID;
          end
        end

        // If incoming transaction does not violate any configuration settings, then the transaction is marked to
        // search the entries for address and permissions match
        else
          ttu_operation = SEARCH;
      end

      // Mark the transaction as MATCHED to bypass the Exection Pipeline as IOPMP is disabled (hwcfg0.enable == 1'b0)
      else
        ttu_operation = MATCHED;
    end

    // If the rap_operation from AXI Master Request Manager is not SEARCH, then pass the operation as received and set the error information to NO_ERROR
    else begin
      ttu_operation = rap_operation;
      ttu_err_info  = NO_ERROR;
    end
  end

endmodule