///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Gull Ahmed <gull.ahmed@10xengineers.ai>
/// Date Created: 16-August-2025
/// Description: It classifies each transaction as success or error,
// and drives the corresponding outputs:
// - Error responses to the Master Response Manager,
// - Valid requests to the Slave Request Manager,
// - Transaction/error info to the Error & Interrupt Controller.
// Optional capture of the failing rule index is supported.
///////////////////////////////////////////////////////////////////////////

module response_generator
  import execution_pipeline_pkg::*;
  import config_iopmp_pkg::MAX_BURST_LEN;
#(
  parameter ERROR_CAPTURE_EN = 0
) (
  // Input from Execution Pipeline
  input  rap_t                             rap_stage,         // Final stage output bundle from Rule Analyzer Pipeline

  // Outputs to Master Response Manager (Error/Response Path)
  output logic                             rap_rd_err_valid,  // Valid signal for read error response
  output iopmp_axi_pkg::r_channel_t              rap_rd_err_req,    // Read error response payload
  output logic [$clog2(MAX_BURST_LEN)-1:0] ar_len,            // Captured ARLEN for error reporting
  output logic                             rap_wr_err_valid,  // Valid signal for write error response
  output iopmp_axi_pkg::slv_b_channel_t          rap_wr_err_req,    // Write error response payload

  // Outputs to Slave Request Manager (Pass-Through Path)
  output logic                             rap_rd_valid,      // Valid signal for successful read request
  output iopmp_axi_pkg::ar_channel_t             rap_rd_req,        // Forwarded read request payload
  output logic                             rap_wr_valid,      // Valid signal for successful write request
  output iopmp_axi_pkg::slv_aw_channel_t         rap_wr_trans,      // Forwarded write request payload

  // Outputs to Error and Interrupt Controller (EIC)
  output iopmp_axi_pkg::transaction_t            rap_eic_trans,     // Transaction metadata forwarded to EIC
  output logic                             rap_eic_valid,     // Error indication for EIC
  output error_info_t                      rap_eic_error_info // Error info bundle for EIC
);

  // Internal control signals
  logic is_resp_error, is_resp_success;

  //---------------------------------------------
  // Response classification
  //---------------------------------------------
  // An error response occurs when the pipeline result is SEARCH or ERROR
  assign is_resp_error = rap_stage.operation[1];

  // A successful response occurs when the pipeline result is MATCHED
  assign is_resp_success = (rap_stage.operation == MATCHED);

  //---------------------------------------------
  // Error and Interrupt Controller (EIC) outputs
  //---------------------------------------------

  if (ERROR_CAPTURE_EN) begin : gen_err_info

    assign rap_eic_trans = rap_stage.transaction;
    assign rap_eic_valid = is_resp_error;

    // If a SEARCH completed without matching any rule, report "NOT_HIT_ANY_RULE"
    assign rap_eic_error_info.err_info = ((rap_stage.operation == SEARCH) && (!(|rap_stage.err_info))) ?
                                         {NOT_HIT_ANY_RULE,1'b0} : rap_stage.err_info;

    // Capture the index of the rule that generated the error
    assign rap_eic_error_info.err_entry_index = rap_stage.err_entry_index;
  end
  else begin : gen_err_info_hardwired_zeros

    assign rap_eic_trans      = '0;
    assign rap_eic_valid      = 1'b0;
    assign rap_eic_error_info = '0;
  end

  //---------------------------------------------
  // Valid signal generation (read/write + success/error)
  //---------------------------------------------
  assign rap_rd_err_valid = (rap_stage.transaction.r || rap_stage.transaction.x) && is_resp_error;   // Read error
  assign rap_wr_err_valid = rap_stage.transaction.w && is_resp_error;                                // Write error
  assign rap_rd_valid     = (rap_stage.transaction.r || rap_stage.transaction.x) && is_resp_success; // Read success
  assign rap_wr_valid     = rap_stage.transaction.w && is_resp_success;                              // Write success

  //---------------------------------------------
  // Write Error Response to Master Response Manager
  //---------------------------------------------
  assign rap_wr_err_req.b_id   = rap_stage.transaction.id;
  assign rap_wr_err_req.b_user = rap_stage.transaction.rrid;
  assign rap_wr_err_req.b_resp = 2'b10; // SLVERR

  //---------------------------------------------
  // Read Error Response to Master Response Manager
  //---------------------------------------------
  assign ar_len                = rap_stage.transaction.len;
  assign rap_rd_err_req.r_id   = rap_stage.transaction.id[4:0];
  assign rap_rd_err_req.r_user = rap_stage.transaction.rrid[5:0];
  assign rap_rd_err_req.r_data = '0;      // No data on error
  assign rap_rd_err_req.r_resp = 2'b10;   // SLVERR
  assign rap_rd_err_req.r_last = !(|rap_stage.transaction.len);

  //---------------------------------------------
  // Write Request to Slave Request Manager (pass-through)
  //---------------------------------------------
  assign rap_wr_trans.aw_id     = rap_stage.transaction.id;
  assign rap_wr_trans.aw_addr   = rap_stage.transaction.addr;
  assign rap_wr_trans.aw_len    = {4'b0, rap_stage.transaction.len};
  assign rap_wr_trans.aw_size   = {1'b0, rap_stage.transaction.size};
  assign rap_wr_trans.aw_burst  = {1'b0, rap_stage.transaction.burst};
  assign rap_wr_trans.aw_lock   = rap_stage.transaction.axlock;
  assign rap_wr_trans.aw_cache  = '0;
  assign rap_wr_trans.aw_prot   = '0;
  assign rap_wr_trans.aw_qos    = '0;
  assign rap_wr_trans.aw_region = '0;
  assign rap_wr_trans.aw_user   = rap_stage.transaction.rrid;

  //---------------------------------------------
  // Read Request to Slave Request Manager (pass-through)
  //---------------------------------------------
  assign rap_rd_req.ar_id     = rap_stage.transaction.id[4:0];
  assign rap_rd_req.ar_addr   = rap_stage.transaction.addr;
  assign rap_rd_req.ar_len    = {4'b0, rap_stage.transaction.len};
  assign rap_rd_req.ar_size   = {1'b0, rap_stage.transaction.size};
  assign rap_rd_req.ar_burst  = {1'b0, rap_stage.transaction.burst};
  assign rap_rd_req.ar_lock   = rap_stage.transaction.axlock;
  assign rap_rd_req.ar_cache  = '0;
  assign rap_rd_req.ar_prot   = {!rap_stage.transaction.r,2'b00}; // Encode prot[2] as read/exe access
  assign rap_rd_req.ar_qos    = '0;
  assign rap_rd_req.ar_region = '0;
  assign rap_rd_req.ar_user   = rap_stage.transaction.rrid[5:0];

endmodule