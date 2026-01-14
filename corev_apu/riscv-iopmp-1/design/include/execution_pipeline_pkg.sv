///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 15-Jan-2025
/// Description: This package contains all the enum/struct used in execution
/// pipeline.
///////////////////////////////////////////////////////////////////////////

package execution_pipeline_pkg;

  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;
  import iopmp_axi_pkg::transaction_t;

  // Enumerates specific match and error statuses for transactions
  typedef enum logic [3:0] {
    NO_ERROR                = 4'b0000,          // No error
    ILLEGAL_READ_ACCESS     = 4'b0001,          // Illegal read access attempted
    ILLEGAL_WRITE_ACCESS    = 4'b0010,          // Illegal write access attempted
    ILLEGAL_INSTR_FETCH     = 4'b0011,          // Illegal instruction fetch attempted
    PARTIAL_HIT_ON_PRIORITY = 4'b0100,          // Partial hit on a priority entry
    NOT_HIT_ANY_RULE        = 4'b0101,          // No rule matched the transaction
    UNKNOWN_RRID            = 4'b0110,          // Unknown requester ID in transaction
    STALLED_TRANSACTION     = 4'b0111,          // Error due to a stalled transaction
    USER_DEFINE_ERROR_1     = 4'b1110,          // User define error
    USER_DEFINE_ERROR_2     = 4'b1111           // User define error
  } errorType_t;

  typedef enum logic [2:0] {
    READ_ACCESS  = 3'b001,
    WRITE_ACCESS = 3'b010,
    INSTR_FETCH  = 3'b100
  } access_e;

  typedef enum logic [1:0] {
    NOP     = 2'b00,
    MATCHED = 2'b01,
    SEARCH  = 2'b10,
    ERROR   = 2'b11
  } operation_e;

  typedef struct packed {
    transaction_t                     transaction;
    logic [AXI_ADDR_WIDTH-1:0]        trans_end_addr;
    operation_e                       operation;
    logic [4:0]                       err_info;
    logic [CFG.ENTRY_NUM-1:0]         entrypresent_or;
    logic [CFG.ENTRY_NUM-1:0][1:0]    mdrwperm_repl;
    logic [$clog2(CFG.ENTRY_NUM)-1:0] err_entry_index;
  } rap_t;

  typedef struct packed {
		logic [4:0]                       err_info;
		logic [$clog2(CFG.ENTRY_NUM)-1:0] err_entry_index;
  } error_info_t;

endpackage