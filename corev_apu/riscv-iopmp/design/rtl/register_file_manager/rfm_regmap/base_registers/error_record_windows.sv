///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 20-June-2025
/// Description: The module manages configurable error record windows that
/// track access violations by RRID for IOPMP. Provides hardware-controlled
/// window scanning and updating logic with priority encoding to identify
/// the first window containing active error bits.
///////////////////////////////////////////////////////////////////////////

module error_record_windows
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic        clk,                      // Clock Rising Edge
  input  logic        rst_n,                    // Reset Active Low

  // ERROR REPORTING Registers ==> Error Record Window
  input  logic [11:0] err_mfr_svi,              // Read ERR_MFR.svi value
  input  logic        err_mfr_svs,              // Read ERR_MFR.svs value

  // Base Registers ==> Error Record Window
  input  logic        err_mfr_read_legal,       // Indicates a read request on err_mfr register

  // Error and Interrupt Control ==> Error Record Window
  input  logic        eic_rfm_valid,            // Indicates that a subsequent violation has occured and set the window index pointed by eic_rfm_err_rrid
  input  logic [5:0]  eic_rfm_err_rrid,         // Indicates RRID for subsequent violations to set the corresponding index in window

  // Error Record Window ==> ERROR REPORTING Registers
  output logic        err_info_svc_hwen,        // ERR_INFO.svc HW write enable signal
  output logic        err_info_svc_hwdata,      // ERR_INFO.svc HW write data signal
  output logic        err_mfr_svs_hwen,         // ERR_MFR.svs HW write enable signal
  output logic        err_mfr_svs_hwdata,       // ERR_MFR.svs HW write data signal
  output logic [15:0] err_mfr_svw_hwdata,       // ERR_MFR.svw HW write enable signal
  output logic        err_mfr_svw_hwen,         // ERR_MFR.svw HW write data signal
  output logic [11:0] err_mfr_svi_hwdata,       // ERR_MFR.svi HW write enable signal
  output logic        err_mfr_svi_hwen,         // ERR_MFR.svi HW write data signal

  output logic [31:0] err_mfr_rdata             // ERR_MFR register HW write data
);

  localparam SVW_ARRAY_SIZE = ((int'(CFG.RRID_NUM) + 15)/16);   // Indicates the number of error record windows based on RRIDs

  //###############################
  // Internal Signals Declarations
  //###############################

  logic [SVW_ARRAY_SIZE-1:0][11:0] idx;                       // Window Index Signals
  logic [SVW_ARRAY_SIZE-1:0]       window_has_error;          // Reduction OR of each SVW Array window
  logic [SVW_ARRAY_SIZE-1:0][15:0] svw_array_n, svw_array_q;  // Error record windows for subsequent violations for each RRID
  logic [SVW_ARRAY_SIZE-1:0]       higher_priority_mask;      // Mask for higher priority windows

  //****************************************************************************************************
  // Handle read request on ERR_MFR
  //****************************************************************************************************

  // HW write enable when there is a read request on err_mfr
  assign err_mfr_svi_hwen = err_mfr_read_legal;
  assign err_mfr_svw_hwen = err_mfr_read_legal;
  assign err_mfr_svs_hwen = err_mfr_read_legal || err_mfr_svs;     // Clear the err_mfr.svs bit when the error window indexed by err_mfr.svi is cleared

  // Update err_info.svc based on window's content
  assign err_info_svc_hwen   = eic_rfm_valid || err_mfr_svs;
  assign err_info_svc_hwdata = |window_has_error;

  // Generate the error window indexes only when SVW_ARRAY_SIZE is greater than 1 i.e. when there is more than 1 error window
  if (SVW_ARRAY_SIZE > 1) begin : gen_window_indexes

    // Generate err_mfr windows indexes and corresponding valid bit
    for (genvar i = 0; i < SVW_ARRAY_SIZE; i++) begin : gen_legal_value_indexes

      // Once the last available window is scanned, the next window to be scanned is the first record window (index is 0)
      assign idx[i] = ((err_mfr_svi + i[11:0]) < SVW_ARRAY_SIZE[11:0]) ?
                      (err_mfr_svi + i[11:0]) : ((err_mfr_svi + i[11:0]) - SVW_ARRAY_SIZE[11:0]);   // Index of the window to scan
    end

    // Priority encoder for window scanning
    always_comb begin

      // Check which windows have errors
      for (int i = 0; i < SVW_ARRAY_SIZE; i++) begin
        window_has_error[i] = |svw_array_n[idx[i]];
      end

      // Default values
      err_mfr_svi_hwdata = err_mfr_svi;
      err_mfr_svw_hwdata = '0;
      err_mfr_svs_hwdata = 1'b0;

      // Parameterized priority encoder to find the first error window starting from ERR_MFR.svi
      for (int i = 0; i < SVW_ARRAY_SIZE; i++) begin

        // Create a mask for higher priority windows (windows before current index)
        higher_priority_mask = (1 << i) - 1;  // Mask for windows 0 to i-1

        // If current window has error AND no higher priority window has error
        if (window_has_error[i] && ((window_has_error & higher_priority_mask) == 0)) begin
          err_mfr_svi_hwdata = idx[i];
          err_mfr_svw_hwdata = svw_array_n[idx[i]];
          err_mfr_svs_hwdata = 1'b1;
        end
      end
    end
  end

  // When there is only 1 error window i.e. supported number of RRIDs are upto 16, then ERR_MFR.svi is always zero and ERR_MFR.svw/svi are determined based on svw_array_n[0] content
  else begin : gen_mfr_window_0

    assign err_mfr_svi_hwdata = '0;
    assign err_mfr_svw_hwdata = svw_array_n[0];
    assign err_mfr_svs_hwdata = |svw_array_n[0];
  end

  assign err_mfr_rdata = {err_mfr_svs_hwdata, 3'b000, err_mfr_svi_hwdata, err_mfr_svw_hwdata};

  //****************************************************************************************************
  // Subsequent Violation Window Update
  //****************************************************************************************************

  always_comb begin

    // Hold the current value of error record windows
    svw_array_n = svw_array_q;

    // Handle the write on error window when the window pointed by err_mfr.svi is cleared as there was a read request on err_mfr register
    if (eic_rfm_valid && err_mfr_svs) begin
      svw_array_n[err_mfr_svi]                                  = '0;     // First clear the window pointed by err_mfr_svi
      svw_array_n[eic_rfm_err_rrid[5:4]][eic_rfm_err_rrid[3:0]] = 1'b1;   // Set the bit in the error window corresponding to eic_rfm_err_rrid
    end

    // Set the window index using rrid
    else if(eic_rfm_valid)
      svw_array_n[eic_rfm_err_rrid[5:4]][eic_rfm_err_rrid[3:0]] = 1'b1;

    // Clear the window indexed by svi when subsequent violation is found
    else if (err_mfr_svs)
      svw_array_n[err_mfr_svi] = '0;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      svw_array_q <= '0;
    else
      svw_array_q <= svw_array_n;
  end

endmodule
