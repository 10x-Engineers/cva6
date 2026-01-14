///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 31-Jan-2025
/// Description: Performs parallel address and permission checks across 8
/// IOPMP entries. Based on the input transaction and entry configurations,
/// it detects matches or access errors and updates the output transaction
/// accordingly. Supports configurable priority or non-priority encoding as
/// per system settings.
///////////////////////////////////////////////////////////////////////////

module match_8_entry
  import execution_pipeline_pkg::*;
  import rfm_pkg::entry_cfg_t;
  import rfm_pkg::entry_addr_t;
  import rfm_pkg::entry_addrh_t;
  import rfm_pkg::entry_array_t;
#(
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default,
  parameter START_ENRTY = 0,
  parameter END_ENRTY   = 0
) (
  input  logic                                   clk,
  input  logic                                   rst_n,

  input  rap_t                                   rap_stage_i,

  // Entry Array Registers
  input  entry_array_t [7:0]                     entry_table,
  input  entry_addr_t                            prev_entry_addr,   // Previous entry's address
  input  entry_addrh_t                           prev_entry_addrh,  // Previous entry's higher address

  input  logic [END_ENRTY-START_ENRTY-1:0] [5:0] napot_size,        // Napot size calculated in RFM
  input  logic [END_ENRTY-START_ENRTY-1:0]       prio_entry,        // Priority entry vector calculated in RFM
  input  logic [END_ENRTY-START_ENRTY-1:0]       valid_range,       // Valid range vector calculated in RFM

  output rap_t                                   rap_stage_o
);

  // Per Entry Results
  operation_e [END_ENRTY-START_ENRTY-1 : 0] entry_operation;
  logic [END_ENRTY-START_ENRTY-1 : 0] [4:0] entry_err_info;

  // Encoded results
  operation_e                               operation;
  logic [4:0]                               err_info;
  logic [$clog2(CFG.ENTRY_NUM)-1:0]         err_entry_index;

  // Generate match_entry instances for each configured entry index
  generate
    for (genvar curr_index = START_ENRTY; curr_index < END_ENRTY; curr_index++) begin : gen_match_entry

      // Compute local index within the entry_table slice
      localparam int LOCAL_IDX = curr_index - START_ENRTY;
      localparam int LOCAL_IDX_PREV = LOCAL_IDX - 1;

      match_entry #(
        .CFG         (CFG)
      ) match_entry_inst (
        .entry_cfg        (entry_table[LOCAL_IDX].entry_cfg),
        .entry_addr       (entry_table[LOCAL_IDX].entry_addr.addr),
        .entry_addrh      (entry_table[LOCAL_IDX].entry_addrh.addrh),

        // Handle wraparound at START_ENTRY
        .prev_entry_addr  ((curr_index == START_ENRTY) ? prev_entry_addr  : entry_table[LOCAL_IDX_PREV].entry_addr.addr),
        .prev_entry_addrh ((curr_index == START_ENRTY) ? prev_entry_addrh : entry_table[LOCAL_IDX_PREV].entry_addrh.addrh),

        // Metadata from RFM and TTU
        .napot_size       (napot_size[LOCAL_IDX]),
        .transaction      (rap_stage_i.transaction),
        .trans_end_addr   (rap_stage_i.trans_end_addr),
        .check_entry      (rap_stage_i.entrypresent_or[curr_index]),
        .entry_perms      (rap_stage_i.mdrwperm_repl[curr_index]),
        .is_prio_entry    (prio_entry[LOCAL_IDX]),
        .is_valid_range   (valid_range[LOCAL_IDX]),

        // Outputs
        .operation        (entry_operation[curr_index[2:0]]),
        .err_info         (entry_err_info[curr_index[2:0]])
      );
    end
  endgenerate

  // Consolidate per-entry results through encoder
  encoder #(
    .CFG         (CFG),
    .START_ENRTY (START_ENRTY),
    .END_ENRTY   (END_ENRTY)
  ) encoder (
    .entry_operation   (entry_operation),
    .entry_err_info    (entry_err_info),

    .operation_i       (rap_stage_i.operation),
    .err_info_i        (rap_stage_i.err_info),
    .err_entry_index_i (rap_stage_i.err_entry_index),
    .prio_entries      (prio_entry),

    .operation_o       (operation),
    .err_info_o        (err_info),
    .err_entry_index_o (err_entry_index)
  );

  // Pipeline register update
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rap_stage_o.transaction     <= '0;
      rap_stage_o.trans_end_addr  <= '0;
      rap_stage_o.entrypresent_or <= '0;
      rap_stage_o.operation       <= NOP;
      rap_stage_o.err_info        <= '0;
      rap_stage_o.mdrwperm_repl   <= '0;
      rap_stage_o.err_entry_index <= '0;
		end
    else begin
      rap_stage_o.transaction     <= rap_stage_i.transaction;
      rap_stage_o.trans_end_addr  <= rap_stage_i.trans_end_addr;
      rap_stage_o.entrypresent_or <= rap_stage_i.entrypresent_or;
      rap_stage_o.operation       <= operation;
      rap_stage_o.err_info        <= err_info;
      rap_stage_o.mdrwperm_repl   <= rap_stage_i.mdrwperm_repl;
      rap_stage_o.err_entry_index <= err_entry_index;
    end
  end

endmodule