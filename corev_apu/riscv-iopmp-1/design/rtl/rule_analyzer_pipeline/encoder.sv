///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Gull Ahmed <gull.ahmed@10xengineers.ai>
/// Date Created: 15-July-2025
/// Description:  This module implements the final decision logic for
/// selecting a matched IOPMP entry from a set of evaluated entries. It
/// gives priority to high-priority entries if they report MATCHED or ERROR
/// operations. In the absence of such entries, it considers non-priority
/// entries with MATCHED status else sends SEARCH operation.
///////////////////////////////////////////////////////////////////////////

module encoder
  import execution_pipeline_pkg::*;
#(
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default,
  parameter START_ENRTY = 0,
  parameter END_ENRTY   = 0
) (
  input  operation_e [END_ENRTY-START_ENRTY-1:0] entry_operation,         // Operation result from each entry (MATCHED, SEARCH, ERROR, NOP)
  input  logic [END_ENRTY-START_ENRTY-1:0][4:0]  entry_err_info,          // Error information associated with each entry
  input  operation_e                             operation_i,             // Default operation if no entry matches
  input  logic [4:0]                             err_info_i,              // Default error info
  input  logic [$clog2(CFG.ENTRY_NUM)-1:0]       err_entry_index_i,       // Default error index (from earlier stage)
  input  logic [END_ENRTY-START_ENRTY-1:0]       prio_entries,            // Indicates which entries are priority
  output operation_e                             operation_o,             // Final selected operation
  output logic [4:0]                             err_info_o,              // Final error info
  output logic [$clog2(CFG.ENTRY_NUM)-1:0]       err_entry_index_o        // Final error entry index
);

  // Internal signals
  logic [END_ENRTY-START_ENRTY-1:0] record_intr_supr_bit;     // Tracks interrupt suppression bits from all entries
  logic [END_ENRTY-START_ENRTY-1:0] match_p;                  // Priority entry that is not in SEARCH state
  logic [END_ENRTY-START_ENRTY-1:0] read_vec;
  logic [END_ENRTY-START_ENRTY-1:0] match_np;                 // Indicates non-priority entries with MATCHED state
  logic [END_ENRTY-START_ENRTY-1:0] catch_np_error;           // Records ERROR state from non-priority entries if error capture is enabled
  logic [2:0]                       selected_index;           // Selected entry index from lower half (0-3 or 0-7 depending on bits)
  logic                             is_p_match;               // Set if any priority entry reports non-SEARCH result
  logic                             is_np_match;              // Set if any non-priority entry reports MATCHED result
  logic                             is_supress;               // Set if any interrupt suppression bit is set
  operation_e                       prio_entry_op;            // Operation result from selected entry
  logic [4:0]                       entry_err;                // Error info from selected entry

  // Reduction ORs for detection logic
  assign is_p_match  = |match_p;
  assign is_np_match = |match_np;
  assign is_supress  = |record_intr_supr_bit;

  always_comb begin

    // Default/reset assignments
    record_intr_supr_bit = '0;
    selected_index       = 3'd0;
    prio_entry_op        = SEARCH;
    entry_err            = '0;
    match_p              = '0;
    match_np             = '0;
    catch_np_error       = '0;

    // Loop through all entries to populate flags
    for (int index = '0; index < (END_ENRTY-START_ENRTY); index++) begin

      // Extract interrupt suppression bit (LSB of error info)
      record_intr_supr_bit[index] = entry_err_info[index][0];

      // Priority match: if operation is not SEARCH and it's a priority entry
      match_p[index] = entry_operation[index][0] & prio_entries[index];

      // Non-priority matched: operation is MATCHED
      match_np[index] = (entry_operation[index] == MATCHED);

      // Non-priority error: record only if error capture is enabled
      catch_np_error[index] = (CFG.ERROR_CAPTURE_EN) ? ((&entry_operation[index]) & (!prio_entries[index])) : 1'b0;
    end

    // Priority encoder logic: selects the first (highest priority) entry with a match or error
    unique case (match_p | catch_np_error) inside

      8'b???????1: begin
        selected_index = 3'd0;
        prio_entry_op  = entry_operation[0];
        entry_err      = entry_err_info[0];
      end
      8'b??????10: if (1 < (END_ENRTY-START_ENRTY)) begin
        selected_index = 3'd1;
        prio_entry_op  = entry_operation[1];
        entry_err      = entry_err_info[1];
      end
      8'b?????100: if (2 < (END_ENRTY-START_ENRTY)) begin
        selected_index = 3'd2;
        prio_entry_op  = entry_operation[2];
        entry_err      = entry_err_info[2];
      end
      8'b????1000: if (3 < (END_ENRTY-START_ENRTY)) begin
        selected_index = 3'd3;
        prio_entry_op  = entry_operation[3];
        entry_err      = entry_err_info[3];
      end
      8'b???10000: if (4 < (END_ENRTY-START_ENRTY)) begin
        selected_index = 3'd4;
        prio_entry_op  = entry_operation[4];
        entry_err      = entry_err_info[4];
      end
      8'b??100000: if (5 < (END_ENRTY-START_ENRTY)) begin
        selected_index = 3'd5;
        prio_entry_op  = entry_operation[5];
        entry_err      = entry_err_info[5];
      end
      8'b?1000000: if (6 < (END_ENRTY-START_ENRTY)) begin
        selected_index = 3'd6;
        prio_entry_op  = entry_operation[6];
        entry_err      = entry_err_info[6];
      end
      8'b10000000: if (7 < (END_ENRTY-START_ENRTY)) begin
        selected_index = 3'd7;
        prio_entry_op  = entry_operation[7];
        entry_err      = entry_err_info[7];
      end
    endcase

    // Output decision based on whether any entry matched and input operation state
    if (operation_i == SEARCH) begin

      if (is_p_match) begin

        // Priority entry takes precedence
        operation_o = prio_entry_op;
        err_info_o  = (CFG.ERROR_CAPTURE_EN) ? entry_err : '0;
      end
      else begin

        // If no priority match, evaluate non-priority result
        operation_o = (is_np_match) ? MATCHED : SEARCH;

        // Capture suppression bit if applicable
        err_info_o = (CFG.ERROR_CAPTURE_EN & (!is_np_match)) ? {entry_err[4:1], is_supress} : '0;
      end

      // Set index of selected entry for error reporting
      err_entry_index_o = (CFG.ERROR_CAPTURE_EN) ? {START_ENRTY[7:3], selected_index} : '0;
    end
    else begin

      // If operation_i is already determined, use it directly
      operation_o       = operation_i;
      err_info_o        = err_info_i;
      err_entry_index_o = (CFG.ERROR_CAPTURE_EN) ? err_entry_index_i : '0;
    end
  end

endmodule