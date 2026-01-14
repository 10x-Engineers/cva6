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
/// Description:
///////////////////////////////////////////////////////////////////////////

module error_record_windows
  import rfm_pkg::err_mfr_t;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic        clk,                       // Clock Rising Edge
  input  logic        rst_n,                     // Reset Active Low

  // ERROR REPORTING Registers ==> Error Record Window
  input  err_mfr_t    err_mfr_reg,               // Read ERR_MFR register

  // Base Registers ==> Error Record Window
  input  logic        err_mfr_read_legal,        // Indicates a read request on err_mfr register

  // Error and Interrupt Control ==> Error Record Window
  input  logic        eic_rfm_valid,             // Indicates that a subsequent violation has occured and set the window index pointed by eic_rfm_err_rrid
  input  logic [5:0]  eic_rfm_err_rrid,          // Indicates RRID for subsequent violations to set the corresponding index in window

  // Error Record Window ==> ERROR REPORTING Registers
  output logic        err_info_svc_hwen,         // ERR_INFO.svc HW write enable signal
  output logic        err_info_svc_hwdata,       // ERR_INFO.svc HW write data signal
  output logic        err_mfr_svs_hwen,          // ERR_MFR.svs HW write enable signal
  output logic        err_mfr_svs_hwdata,        // ERR_MFR.svs HW write data signal
  output logic [15:0] err_mfr_svw_hwdata,        // ERR_MFR.svw HW write enable signal
  output logic        err_mfr_svw_hwen,          // ERR_MFR.svw HW write data signal
  output logic [11:0] err_mfr_svi_hwdata,        // ERR_MFR.svi HW write enable signal
  output logic        err_mfr_svi_hwen,          // ERR_MFR.svi HW write data signal

  output logic [31:0] err_mfr_rdata              // ERR_MFR register HW write data
);

  localparam SVW_ARRAY_SIZE = ((CFG.RRID_NUM + 15)/16);   // Indicates the number of error record windows based on RRIDs

  //###############################
  // Internal Signals Declarations
  //###############################

  // Window Index Signals
  logic [SVW_ARRAY_SIZE-1:0][11:0] idx;

  // Reduction OR of each SVW Array window
  logic [SVW_ARRAY_SIZE-1:0] reduction_or_svw_array;

  // Error record windows for subsequent violations for each RRID
  logic [SVW_ARRAY_SIZE-1:0][15:0] svw_array_n, svw_array_q;

  //****************************************************************************************************
  // Handle read request on ERR_MFR
  //****************************************************************************************************

  // Generate the error window indexes only when SVW_ARRAY_SIZE is greater than 1 i.e. when there is more than 1 error window
  if (SVW_ARRAY_SIZE > 1) begin : gen_window_indexes

    // Generate err_mfr windows indexes and corresponding valid bit
    for (genvar i = 0; i < SVW_ARRAY_SIZE; i++) begin : gen_legal_value_indexes

      // Once the last available window is scanned, the next window to be scanned is the first record window (index is 0)
      assign idx[i] = ((err_mfr_reg.svi + i) < SVW_ARRAY_SIZE) ?
                      (err_mfr_reg.svi + i) : ((err_mfr_reg.svi + i) - SVW_ARRAY_SIZE);   // Index of the window to scan
    end
  end

  // HW write enable when there is a read request on err_mfr
  assign err_mfr_svi_hwen = err_mfr_read_legal;
  assign err_mfr_svw_hwen = err_mfr_read_legal;
  assign err_mfr_svs_hwen = err_mfr_read_legal || err_mfr_reg.svs;     // Clear the err_mfr.svs bit when the error window indexed by err_mfr.svi is cleared

  always_comb begin

    // Hold the current value of error record windows
    svw_array_n = svw_array_q;

    // Handle the write on error window when the window pointed by err_mfr.svi is cleared as there was a read request on err_mfr register
    if (eic_rfm_valid && err_mfr_reg.svs) begin
      svw_array_n[err_mfr_reg.svi]                              = '0;     // First clear the window pointed by err_mfr_reg.svi
      svw_array_n[eic_rfm_err_rrid[5:4]][eic_rfm_err_rrid[3:0]] = 1'b1;   // Set the bit in the error window corresponding to eic_rfm_err_rrid
    end

    // Set the window index using rrid
    else if(eic_rfm_valid)
      svw_array_n[eic_rfm_err_rrid[5:4]][eic_rfm_err_rrid[3:0]] = 1'b1;

    // Clear the window indexed by svi when subsequent violation is found
    else if (err_mfr_reg.svs)
      svw_array_n[err_mfr_reg.svi] = '0;

    // Update err_info.svc based on window's content
    err_info_svc_hwen   = eic_rfm_valid || err_mfr_reg.svs;
    err_info_svc_hwdata = |svw_array_n;
  end

  // Generate window scan logic for 4 error windows when SVW_ARRAY_SIZE is 4 (i.e. when RRID_NUM is <= 64)
  if (SVW_ARRAY_SIZE == 4) begin : gen_4_error_windows

    always_comb begin

      // Generate reduction OR of each SVW Array window
      for (int i = 0; i < SVW_ARRAY_SIZE; i++) begin

        // Reduction OR of each SVW Array window
        reduction_or_svw_array[i] = |svw_array_n[idx[i]];
      end

      unique case (reduction_or_svw_array) inside

        // If the window pointed by err_mfr_reg.svi has recorded an error then update the err_mfr register with the value of record window and its index
        4'b???1: begin
          err_mfr_svi_hwdata = idx[0];
          err_mfr_svw_hwdata = svw_array_n[idx[0]];
          err_mfr_svs_hwdata = 1'b1;
        end

        // If the window pointed by err_mfr_reg.svi has no error then search the next window. If window pointed by err_mfr_reg.svi+1 has recorded an error
        // then update the err_mfr register with the value of record window and its index
        4'b??10: begin
          err_mfr_svi_hwdata = idx[1];
          err_mfr_svw_hwdata = svw_array_n[idx[1]];
          err_mfr_svs_hwdata = 1'b1;
        end

        // If the window pointed by err_mfr_reg.svi or err_mfr_reg.svi+1 has no error then search the next window. If window pointed by err_mfr_reg.svi+2 has
        // recorded an error then update the err_mfr register with the value of record window and its index
        4'b?100: begin
          err_mfr_svi_hwdata = idx[2];
          err_mfr_svw_hwdata = svw_array_n[idx[2]];
          err_mfr_svs_hwdata = 1'b1;
        end

        // If the window pointed by err_mfr_reg.svi or err_mfr_reg.svi+1 or err_mfr_reg.svi+2 has no error then search the next window. If window pointed by
        // err_mfr_reg.svi+3 has recorded an error then update the err_mfr register with the value of record window and its index
        4'b1000: begin
          err_mfr_svi_hwdata = idx[3];
          err_mfr_svw_hwdata = svw_array_n[idx[3]];
          err_mfr_svs_hwdata = 1'b1;
        end

        default: begin
          err_mfr_svi_hwdata = err_mfr_reg.svi;
          err_mfr_svw_hwdata = '0;
          err_mfr_svs_hwdata = 1'b0;
        end
      endcase

    end
  end

  // Generate window scan logic for 3 error windows when SVW_ARRAY_SIZE is 3 (i.e. when RRID_NUM is <= 48)
  if (SVW_ARRAY_SIZE == 3) begin : gen_3_error_windows

    always_comb begin

      // Generate reduction OR of each SVW Array window
      for (int i = 0; i < SVW_ARRAY_SIZE; i++) begin

        // Reduction OR of each SVW Array window
        reduction_or_svw_array[i] = |svw_array_n[idx[i]];
      end

      unique case (reduction_or_svw_array) inside

        // If the window pointed by err_mfr_reg.svi has recorded an error then update the err_mfr register with the value of record window and its index
        3'b??1: begin
          err_mfr_svi_hwdata = idx[0];
          err_mfr_svw_hwdata = svw_array_n[idx[0]];
          err_mfr_svs_hwdata = 1'b1;
        end

        // If the window pointed by err_mfr_reg.svi has no error then search the next window. If window pointed by err_mfr_reg.svi+1 has recorded an error
        // then update the err_mfr register with the value of record window and its index
        3'b?10: begin
          err_mfr_svi_hwdata = idx[1];
          err_mfr_svw_hwdata = svw_array_n[idx[1]];
          err_mfr_svs_hwdata = 1'b1;
        end

        // If the window pointed by err_mfr_reg.svi or err_mfr_reg.svi+1 has no error then search the next window. If window pointed by err_mfr_reg.svi+2 has
        // recorded an error then update the err_mfr register with the value of record window and its index
        3'b100: begin
          err_mfr_svi_hwdata = idx[2];
          err_mfr_svw_hwdata = svw_array_n[idx[2]];
          err_mfr_svs_hwdata = 1'b1;
        end

        default: begin
          err_mfr_svi_hwdata = err_mfr_reg.svi;
          err_mfr_svw_hwdata = '0;
          err_mfr_svs_hwdata = 1'b0;
        end
      endcase

    end
  end

  // Generate window scan logic for 2 error windows when SVW_ARRAY_SIZE is 2 (i.e. when RRID_NUM is <= 32)
  if (SVW_ARRAY_SIZE == 2) begin : gen_2_error_windows

    always_comb begin

      // Generate reduction OR of each SVW Array window
      for (int i = 0; i < SVW_ARRAY_SIZE; i++) begin

        // Reduction OR of each SVW Array window
        reduction_or_svw_array[i] = |svw_array_n[idx[i]];
      end

      unique case (reduction_or_svw_array) inside

        // If the window pointed by err_mfr_reg.svi has recorded an error then update the err_mfr register with the value of record window and its index
        2'b?1: begin
          err_mfr_svi_hwdata = idx[0];
          err_mfr_svw_hwdata = svw_array_n[idx[0]];
          err_mfr_svs_hwdata = 1'b1;
        end

        // If the window pointed by err_mfr_reg.svi has no error then search the next window. If window pointed by err_mfr_reg.svi+1 has recorded an error
        // then update the err_mfr register with the value of record window and its index
        2'b10: begin
          err_mfr_svi_hwdata = idx[1];
          err_mfr_svw_hwdata = svw_array_n[idx[1]];
          err_mfr_svs_hwdata = 1'b1;
        end

        default: begin
          err_mfr_svi_hwdata = err_mfr_reg.svi;
          err_mfr_svw_hwdata = '0;
          err_mfr_svs_hwdata = 1'b0;
        end
      endcase

    end
  end

  // Generate window scan logic for 1 error windows when SVW_ARRAY_SIZE is 1 (i.e. when RRID_NUM is <= 16)
  if (SVW_ARRAY_SIZE == 1) begin : gen_1_error_windows
    assign err_mfr_svi_hwdata = '0;
    assign err_mfr_svw_hwdata = svw_array_n[0];
    assign err_mfr_svs_hwdata = (|svw_array_n[0]);
  end

  assign err_mfr_rdata = {err_mfr_svs_hwdata, 3'b000, err_mfr_svi_hwdata, err_mfr_svw_hwdata};

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      svw_array_q <= '0;
    else
      svw_array_q <= svw_array_n;
  end

endmodule