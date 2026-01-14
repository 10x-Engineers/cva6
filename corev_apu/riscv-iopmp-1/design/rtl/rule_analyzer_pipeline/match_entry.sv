///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Gull Ahmed <gull.ahmed@10xengineers.ai>
/// Date Created: 2-May-2025
/// Description: This module compares an AXI transaction against a specific
/// IOPMP entry to determine if the access falls within the entry's address
/// range and is allowed based on configured permissions. It calculates
/// base and end addresses based on the address type (TOR, NA4, NAPOT, OFF)
/// and performs valid range checks. Depending on the transaction type
/// (read, write, instruction fetch) and permissions, it outputs an operation
/// result and associated error information.
///////////////////////////////////////////////////////////////////////////

module match_entry
  import execution_pipeline_pkg::*;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;
  import iopmp_axi_pkg::transaction_t;
  import rfm_pkg::entry_cfg_t;
  import rfm_pkg::entry_addr_t;
  import rfm_pkg::entry_addrh_t;
#(
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                      check_entry,       // Extracted corresponding bit from ENTRYPRESENT_OR register
  input  logic [1:0]                entry_perms,       // Extracted corresponding permissions bit from MDRWPERM_REPL register
  input  logic                      is_prio_entry,     // If set means, it's a priority entry
  input  logic                      is_valid_range,    // If set means, TOR range is valid

  input  transaction_t              transaction,       // Incoming transaction coming from TTU
  input  logic [AXI_ADDR_WIDTH-1:0] trans_end_addr,    // Transaction end address calculated in TTU
  input  logic [5:0]                napot_size,        // Napot size calculated in RFM

  // Entry Array Registers
  input  entry_cfg_t                entry_cfg,         // Current Entry CFG register
  input  entry_addr_t               entry_addr,        // Current entry's address
  input  entry_addrh_t              entry_addrh,       // Current entry's higher address
  input  entry_addr_t               prev_entry_addr,   // Previous entry's address
  input  entry_addrh_t              prev_entry_addrh,  // Previous entry's higher address

  output operation_e                operation,         // Operation result: SEARCH / MATCHED / ERROR
  output logic [4:0]                err_info           // Encoded error information {upper 4 bits error type, interrupt suppression bit}
);

  //--------------------------------------------------------------------------
  // Internal signals declaration
  //--------------------------------------------------------------------------
  logic [AXI_ADDR_WIDTH-3:0] base_addr;           // To Calculate base_address (start_address) for address region
  logic [AXI_ADDR_WIDTH-3:0] end_addr;            // To Calculate end_address for address region
  logic [AXI_ADDR_WIDTH-3:0] addr_region_mask;    // addr_region_mask for NAPOT address mode
  logic                      start_addr_match;    // Transaction start address matching check
  logic                      end_addr_match;      // Transaction end address matching check
  logic                      rd_allowed;          // Read permission
  logic                      wr_allowed;          // Write permission
  logic                      ex_allowed;          // Execute (instruction fetch) permission
  logic                      partial_addr_match;  // If set, means address is partially matched
  logic                      full_addr_match;     // If set, means address is matched
  operation_e                cur_entry_operation; // Internal Signal to record operation
  logic [4:0]                cur_err_info;        // Internal Signal to record error

  //--------------------------------------------------------------------------
  // Extract Permissions
  // Determines whether the transaction type (read/write/execute) is allowed.
  // The logic adapts based on the configured SRCMD format and SPS support:
  // - Format 0: Uses config and optionally per-entry permissions (SPS).
  // - Format 1: Permissions derived only from entry config.
  // - Format 2: Allows access if either config or per-entry bits are set.
  //--------------------------------------------------------------------------
  if (CFG.SRCMD_FMT_0) begin : gen_srcmd_fmt_0_perm

    // Read allowed only if both entry_cfg.r and per-entry read bit are set
    assign rd_allowed = (CFG.SPS_EN) ? entry_cfg.r && entry_perms[0] : entry_cfg.r;

    // Write allowed only if read is allowed, entry_cfg.w is set, and per-entry read/write permission bit is also set
    assign wr_allowed = (CFG.SPS_EN) ? entry_cfg.w && entry_perms[1] : entry_cfg.w;

    // Execute allowed only if entry_cfg.x and per-entry read bit are set
    assign ex_allowed = (CFG.SPS_EN) ? entry_cfg.x && entry_perms[0] : entry_cfg.x;
  end

  //--------------------------------------------------------------------------
  // SRCMD Format 1 - Simple permission flags from entry config only
  //--------------------------------------------------------------------------
  if (CFG.SRCMD_FMT_1) begin : gen_srcmd_fmt_1_perm

    assign rd_allowed = entry_cfg.r;
    assign wr_allowed = entry_cfg.w;        // Write requires read + write permissions
    assign ex_allowed = entry_cfg.x;
  end

  //----------------------------------------------------------------------------------------------
  // SRCMD Format 2 - Permission granted if either entry cfg or per-entry permission bit is set
  //----------------------------------------------------------------------------------------------
  if (CFG.SRCMD_FMT_2) begin : gen_srcmd_fmt_2_perm

    assign rd_allowed = entry_cfg.r || entry_perms[0];   // entry cfg or per-entry permission
    assign wr_allowed = entry_cfg.w || entry_perms[1];
    assign ex_allowed = entry_cfg.x || entry_perms[0];
  end

  //--------------------------------------------------------------------------
  // Match Addr
  // Computes the region bounds for the current entry based on address type:
  // - TOR: Top of Range addressing mode
  // - NA4: Fixed 4-byte aligned region.
  // - NAPOT: Naturally aligned power-of-two region.
  // - OFF: Empty region
  // Performs start/end address matching for the transaction
  //--------------------------------------------------------------------------
  always_comb begin : match_addr
    // Default assignments
    addr_region_mask = '0;
    end_addr         = '0;

    unique case (entry_cfg.a)

      rfm_pkg::IOPMP_OFF: begin

        base_addr        = '0;
        end_addr         = '0;
        start_addr_match = '0;
        end_addr_match   = '0;
      end

      rfm_pkg::IOPMP_TOR: begin

        // Extract the Base and End addresses
        base_addr = (CFG.ADDRH_EN) ? {prev_entry_addrh, prev_entry_addr} : prev_entry_addr;
        end_addr  = (CFG.ADDRH_EN) ? {entry_addrh, entry_addr} : entry_addr;

        // Check transaction bounds against region
        start_addr_match = (CFG.TOR_EN) ? (transaction.addr[AXI_ADDR_WIDTH-1:2] >= base_addr) && is_valid_range : '0;   // Start within range
        end_addr_match   = (CFG.TOR_EN) ? (trans_end_addr[AXI_ADDR_WIDTH-1:2] < end_addr) && is_valid_range : '0;       // End within range
      end

      rfm_pkg::IOPMP_NA4: begin

        // Extract the Base Address
        base_addr = (CFG.ADDRH_EN) ? {entry_addrh, entry_addr} : entry_addr;

        // Match if transaction start/end align with base address
        // Since 4-byte access, upper bits should be same
        start_addr_match = (base_addr == transaction.addr[AXI_ADDR_WIDTH-1:2]);
        end_addr_match   = (base_addr == trans_end_addr[AXI_ADDR_WIDTH-1:2]);
      end

      rfm_pkg::IOPMP_NAPOT: begin

        addr_region_mask = {AXI_ADDR_WIDTH-2{1'b1}} << napot_size;  // Create addr_region_mask for aligned power-of-two
        base_addr        = (CFG.ADDRH_EN) ? ({entry_addrh, entry_addr} & addr_region_mask) : (entry_addr & addr_region_mask);  // Compute base address

        // Match if transaction start/end align with base address
        start_addr_match = (base_addr == (transaction.addr[AXI_ADDR_WIDTH-1:2] & addr_region_mask));
        end_addr_match   = (base_addr == (trans_end_addr[AXI_ADDR_WIDTH-1:2] & addr_region_mask));
      end
    endcase
  end

  assign full_addr_match    = start_addr_match && end_addr_match;                  // Fully enclosed in region
  assign partial_addr_match = (start_addr_match ^ end_addr_match) && is_prio_entry;  // Partial overlap on priority entry

  //--------------------------------------------------------------------------
  // Match Permission
  // Based on the transaction type, this block evaluates permission flags and
  // assigns the result to `cur_entry_operation` and `cur_err_info`.
  // In case of a partial match in a priority entry, access is denied and
  // a partial hit error is reported.
  //--------------------------------------------------------------------------
  always_comb begin : Match_Permission

    unique case ({transaction.x, transaction.w, transaction.r})

      3'b001: begin     // READ ACCESS

        cur_entry_operation = rd_allowed ? MATCHED : ERROR;
        cur_err_info        = (CFG.ERROR_CAPTURE_EN) ? (rd_allowed ? '0 : {ILLEGAL_READ_ACCESS, entry_cfg.sire}) : '0;
      end

      3'b010: begin     // WRITE ACCESS

        cur_entry_operation = wr_allowed ? MATCHED : ERROR;
        cur_err_info        = (CFG.ERROR_CAPTURE_EN) ? (wr_allowed ? '0 : {ILLEGAL_WRITE_ACCESS, entry_cfg.siwe}) : '0;
      end

      3'b100: begin     // INSTRUCTION FETCH ACCESS

        // Use instruction-fetch permission if CHK_X is enabled
        cur_entry_operation = (CFG.CHK_X) ? ex_allowed ? MATCHED : ERROR
                                          : rd_allowed ? MATCHED : ERROR;

        if (CFG.ERROR_CAPTURE_EN)

          cur_err_info = (CFG.CHK_X) ? (ex_allowed ? '0 : {ILLEGAL_INSTR_FETCH, entry_cfg.sixe})
                                     : (rd_allowed ? '0 : {ILLEGAL_READ_ACCESS, entry_cfg.sire});
        else
          cur_err_info = '0;
      end

      default: begin
        // default values
        cur_entry_operation = NOP;
        cur_err_info        = '0;
      end
    endcase

    // ------------------------------------------------------------
    // Priority Entry â€ Partial Match Handling
    // If region is partially hit and this is a priority entry,
    // override operation and raise partial hit error
    // ------------------------------------------------------------
    if (partial_addr_match) begin

      cur_entry_operation = ERROR;
      cur_err_info        = (CFG.ERROR_CAPTURE_EN) ? {PARTIAL_HIT_ON_PRIORITY, 1'b0} : '0;
    end

  end

  // Decide Operation and Error Out

  // check_entry | full_addr_match | partial_addr_match |       Operation        | Error
  // ----------- | --------------- | ------------------ | ---------------------- | -----
  //      No     |      N/A        |        N/A         |    NOP                 | all zeros
  //      Yes    |      No         |        No          |    SEARCH              | all zeros (Generally 'NOT HIT any rule' but no need to record here)
  //      Yes    |      Yes        |        No          |    cur_entry_operation | cur_err_info
  //      Yes    |      No         |        Yes         |    cur_entry_operation | cur_err_info

  assign operation = (check_entry) ? ((full_addr_match || partial_addr_match) ? cur_entry_operation : SEARCH) : NOP;
  assign err_info  = (CFG.ERROR_CAPTURE_EN && check_entry && (full_addr_match || partial_addr_match)) ? cur_err_info : '0;

endmodule
