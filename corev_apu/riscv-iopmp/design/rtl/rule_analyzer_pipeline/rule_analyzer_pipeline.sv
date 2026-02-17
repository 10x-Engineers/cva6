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
/// Description: This module implements a multi-stage rule analyzer
/// pipeline that evaluates AXI transactions against IOPMP entries using
/// cascaded match_8_entry blocks. It determines access permissions, flags
/// rule mismatches or violations, and generates either valid responses to
/// AXI Slave Request Manager on MATCH or error responses for Master Response
/// Manager and Error and Interrupt Control (EIC) blocks on ERROR.
///////////////////////////////////////////////////////////////////////////

module rule_analyzer_pipeline
  import execution_pipeline_pkg::*;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;
  import config_iopmp_pkg::MAX_BURST_LEN;
  import rfm_pkg::entry_cfg_t;
#(
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                             clk,
  input  logic                             rst_n,

  // Table Traversal Unit ==> Rule Analyzer Pipeline
  input  logic [CFG.ENTRY_NUM-1:0]         entrypresent_or,   // Indicates the entries to be checked in Rule Analyzer Pipeline
  input  logic [CFG.ENTRY_NUM-1:0][1:0]    mdrwperm_repl,     // Indicates the RW permission for entries that will be matched in Rule Analyzer Pipeline
  input  iopmp_axi_pkg::transaction_t      transaction_i,     // TTU to RAP AXI transaction
  input  logic [AXI_ADDR_WIDTH-1:0]        trans_end_addr,    // Transaction end Address
  input  operation_e                       ttu_rapo,          // TTU to RAP operation
  input  errorType_t                       ttu_rap_err_info,  // Error information encountered in TTU

  // Register File Manager ==> Rule Analyzer Pipeline
  input  rfm_pkg::rfm_rap_t                rfm_rap,

  // Rule Analyzer Pipeline ==> Master Response Manager
  output logic                             rap_rd_err_valid,  // Valid signal for read error response
  output iopmp_axi_pkg::r_channel_t        rap_rd_err_req,    // Read error response payload
  output logic [$clog2(MAX_BURST_LEN)-1:0] ar_len,            // Captured ARLEN for error reporting
  output logic                             rap_wr_err_valid,  // Valid signal for write error response
  output iopmp_axi_pkg::slv_b_channel_t    rap_wr_err_req,    // Write error response payload

  // Rule Analyzer Pipeline ==> Slave Request Manager
  output logic                             rap_rd_valid,      // Valid signal for successful read request
  output iopmp_axi_pkg::ar_channel_t       rap_rd_req,        // Forwarded read request payload
  output logic                             rap_wr_valid,      // Valid signal for successful write request
  output iopmp_axi_pkg::slv_aw_channel_t   rap_wr_trans,      // Forwarded write request payload

  // Rule Analyzer Pipeline ==> Error and Interrupt Control
  output iopmp_axi_pkg::transaction_t      rap_eic_trans,     // Transaction metadata forwarded to EIC
  output logic                             rap_eic_valid,     // Error indication for EIC
  output error_info_t                      rap_eic_error_info // Error info bundle for EIC
);

  // Generate RAP Slices based on the Entry_Num
  localparam RAP_8_INST = (CFG.ENTRY_NUM + 7)/8;

  rap_t [RAP_8_INST : 0] rap_stage;

  // Create RAP Stage 1 input of rap_t type
  assign rap_stage[0].transaction      = transaction_i;
  assign rap_stage[0].trans_end_addr   = trans_end_addr;
  assign rap_stage[0].operation        = ttu_rapo;
  assign rap_stage[0].err_info         = {ttu_rap_err_info,1'b0};     // Concatenate LSB bit
  assign rap_stage[0].entrypresent_or  = entrypresent_or;
  assign rap_stage[0].err_entry_index  = '0;
  assign rap_stage[0].mdrwperm_repl    = mdrwperm_repl;

  generate
    for (genvar curr_index = 0; curr_index < RAP_8_INST; curr_index++) begin : gen_match_8_entry

      // Compute start and end entry index for this slice
      localparam int START_ENTRY = curr_index * 8;
      localparam int END_ENTRY   = ((curr_index + 1) * 8 > CFG.ENTRY_NUM) ? int'(CFG.ENTRY_NUM) : ((curr_index + 1) * 8);

      match_8_entry #(
        .CFG              (CFG),
        .START_ENRTY      (START_ENTRY),
        .END_ENRTY        (END_ENTRY)
      ) match_8_entry_inst
      (
        .clk              (clk),
        .rst_n            (rst_n),

        // Current entry table group for this slice
        .entry_table      (rfm_rap.entry_table[END_ENTRY-1:START_ENTRY]),

        // Previous entry's address
        .prev_entry_addr  (curr_index == 0 ? '0 : rfm_rap.entry_table[START_ENTRY-1].entry_addr.addr),
        .prev_entry_addrh (curr_index == 0 ? '0 : rfm_rap.entry_table[START_ENTRY-1].entry_addrh.addrh),

        // Corresponding Flags for this slice
        .napot_size       (rfm_rap.napot_size[END_ENTRY-1:START_ENTRY]),
        .prio_entry       (rfm_rap.prio_entry_vec[END_ENTRY-1:START_ENTRY]),
        .valid_range      (rfm_rap.valid_range_vec[END_ENTRY-1:START_ENTRY]),

        // Transaction in/out chaining
        .rap_stage_i      (rap_stage[curr_index]),
        .rap_stage_o      (rap_stage[curr_index+1])
      );
    end
  endgenerate

  response_generator #(
    .ERROR_CAPTURE_EN (CFG.ERROR_CAPTURE_EN)
  ) response_generator_inst
  (
    // Execution Pipeline Last Stage Data
    .operation          (rap_stage[RAP_8_INST].operation),
    .err_info           (rap_stage[RAP_8_INST].err_info),
    .err_entry_index    (rap_stage[RAP_8_INST].err_entry_index),
    .transaction        (rap_stage[RAP_8_INST].transaction),

    // Rule Analyzer Pipeline ==> Master Response Manager
    .rap_rd_err_valid   (rap_rd_err_valid),
    .rap_rd_err_req     (rap_rd_err_req),
    .ar_len             (ar_len),
    .rap_wr_err_valid   (rap_wr_err_valid),
    .rap_wr_err_req     (rap_wr_err_req),

    // Rule Analyzer Pipeline ==> Slave Request Manager
    .rap_rd_valid       (rap_rd_valid),
    .rap_rd_req         (rap_rd_req),
    .rap_wr_valid       (rap_wr_valid),
    .rap_wr_trans       (rap_wr_trans),

    // Rule Analyzer Pipeline ==> Error and Interrupt Control
    .rap_eic_trans      (rap_eic_trans),
    .rap_eic_valid      (rap_eic_valid),
    .rap_eic_error_info (rap_eic_error_info)
  );

endmodule
