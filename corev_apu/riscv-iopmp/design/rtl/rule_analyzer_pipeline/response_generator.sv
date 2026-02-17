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
  import config_iopmp_pkg::ENTRY_NUM;
#(
  parameter ERROR_CAPTURE_EN = 0
) (
  // Input from Execution Pipeline
  input  operation_e                       operation,
  input  logic [4:0]                       err_info,
  input  logic [$clog2(ENTRY_NUM)-1:0] 	   err_entry_index,   // Final stage output bundle from Rule Analyzer Pipeline
  input  iopmp_axi_pkg::transaction_t      transaction,

  // Outputs to Master Response Manager (Error/Response Path)
  output logic                             rap_rd_err_valid,  // Valid signal for read error response
  output iopmp_axi_pkg::r_channel_t        rap_rd_err_req,    // Read error response payload
  output logic [$clog2(MAX_BURST_LEN)-1:0] ar_len,            // Captured ARLEN for error reporting
  output logic                             rap_wr_err_valid,  // Valid signal for write error response
  output iopmp_axi_pkg::slv_b_channel_t    rap_wr_err_req,    // Write error response payload

  // Outputs to Slave Request Manager (Pass-Through Path)
  output logic                             rap_rd_valid,      // Valid signal for successful read request
  output iopmp_axi_pkg::ar_channel_t       rap_rd_req,        // Forwarded read request payload
  output logic                             rap_wr_valid,      // Valid signal for successful write request
  output iopmp_axi_pkg::slv_aw_channel_t   rap_wr_trans,      // Forwarded write request payload

  // Outputs to Error and Interrupt Controller (EIC)
  output iopmp_axi_pkg::transaction_t      rap_eic_trans,     // Transaction metadata forwarded to EIC
  output logic                             rap_eic_valid,     // Error indication for EIC
  output error_info_t                      rap_eic_error_info // Error info bundle for EIC
);

  // Internal control signals
  logic is_resp_error, is_resp_success;

  //---------------------------------------------
  // Response classification
  //---------------------------------------------
  // An error response occurs when the pipeline result is SEARCH or ERROR
  assign is_resp_error = operation[1];

  // A successful response occurs when the pipeline result is MATCHED
  assign is_resp_success = (operation == MATCHED);

  //---------------------------------------------
  // Error and Interrupt Controller (EIC) outputs
  //---------------------------------------------

  if (ERROR_CAPTURE_EN) begin : gen_err_info

    assign rap_eic_trans = transaction;
    assign rap_eic_valid = is_resp_error;

    // If a SEARCH completed without matching any rule, report "NOT_HIT_ANY_RULE"
    assign rap_eic_error_info.err_info = ((operation == SEARCH) && (!(|err_info))) ?
                                         {NOT_HIT_ANY_RULE,1'b0} : err_info;

    // Capture the index of the rule that generated the error
    assign rap_eic_error_info.err_entry_index = err_entry_index;
  end
  else begin : gen_err_info_hardwired_zeros

    assign rap_eic_trans      = '0;
    assign rap_eic_valid      = 1'b0;
    assign rap_eic_error_info = '0;
  end

  //---------------------------------------------
  // Valid signal generation (read/write + success/error)
  //---------------------------------------------
  assign rap_rd_err_valid = (transaction.r || transaction.x) && is_resp_error;    // Read error
  assign rap_wr_err_valid = transaction.w && is_resp_error;                       // Write error
  assign rap_rd_valid     = (transaction.r || transaction.x) && is_resp_success;  // Read success
  assign rap_wr_valid     = transaction.w && is_resp_success;                     // Write success

  //---------------------------------------------
  // Write Error Response to Master Response Manager
  //---------------------------------------------
  assign rap_wr_err_req.b_id   = {1'b0, transaction.id};
  assign rap_wr_err_req.b_user = transaction.rrid;
  assign rap_wr_err_req.b_resp = 2'b10; // SLVERR

  //---------------------------------------------
  // Read Error Response to Master Response Manager
  //---------------------------------------------
  assign ar_len                = transaction.len;
  assign rap_rd_err_req.r_id   = transaction.id[4:0];
  assign rap_rd_err_req.r_user = transaction.rrid[5:0];
  assign rap_rd_err_req.r_data = '0;      // No data on error
  assign rap_rd_err_req.r_resp = 2'b10;   // SLVERR
  assign rap_rd_err_req.r_last = !(|transaction.len);

  //---------------------------------------------
  // Write Request to Slave Request Manager (pass-through)
  //---------------------------------------------
  assign rap_wr_trans.aw_id     = {1'b0, transaction.id};
  assign rap_wr_trans.aw_addr   = transaction.addr;
  assign rap_wr_trans.aw_len    = {4'b0, transaction.len};
  assign rap_wr_trans.aw_size   = {1'b0, transaction.size};
  assign rap_wr_trans.aw_burst  = {1'b0, transaction.burst};
  assign rap_wr_trans.aw_lock   = transaction.axlock;
  assign rap_wr_trans.aw_cache  = '0;
  assign rap_wr_trans.aw_prot   = '0;
  assign rap_wr_trans.aw_qos    = '0;
  assign rap_wr_trans.aw_region = '0;
  assign rap_wr_trans.aw_user   = transaction.rrid;

  //---------------------------------------------
  // Read Request to Slave Request Manager (pass-through)
  //---------------------------------------------
  assign rap_rd_req.ar_id     = transaction.id[4:0];
  assign rap_rd_req.ar_addr   = transaction.addr;
  assign rap_rd_req.ar_len    = {4'b0, transaction.len};
  assign rap_rd_req.ar_size   = {1'b0, transaction.size};
  assign rap_rd_req.ar_burst  = {1'b0, transaction.burst};
  assign rap_rd_req.ar_lock   = transaction.axlock;
  assign rap_rd_req.ar_cache  = '0;
  assign rap_rd_req.ar_prot   = {!transaction.r,2'b00}; // Encode prot[2] as read/exe access
  assign rap_rd_req.ar_qos    = '0;
  assign rap_rd_req.ar_region = '0;
  assign rap_rd_req.ar_user   = transaction.rrid[5:0];

endmodule
