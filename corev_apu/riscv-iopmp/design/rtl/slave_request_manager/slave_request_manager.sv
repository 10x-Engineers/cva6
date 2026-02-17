///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Gull Ahmed <gull.ahmed@10xengineers.ai>
/// Date Created: 2-Jan-2025
/// Description: This block is the interface of AXI4 IP. AXI4 Interface
/// uses independent read and write channels to send read/write requests.
/// This block Sends AR (read), AW (write address), and W (write data)
/// transactions On requestor Interface. Read/Write Transaction is
/// received from Rule Analyzer Pipeline block, Write transaction data is
/// extracted from Master Write Data Buffer based on the tag.
///////////////////////////////////////////////////////////////////////////

module slave_request_manager
  import config_iopmp_pkg::MAX_BURST_LEN;
  import config_iopmp_pkg::AXI_DATA_WIDTH;
  import config_iopmp_pkg::MAX_TRANS;
  import config_iopmp_pkg::ERROR_CAPTURE_EN;
  import config_iopmp_pkg::MSI_EN;
  import iopmp_axi_pkg::slv_aw_channel_t;
  import iopmp_axi_pkg::ar_channel_t;
  import iopmp_axi_pkg::w_channel_t;
  (
  input  logic                             clk,
  input  logic                             rst_n,

  // Requester Interface Write Address Channel
  input  logic                             iAwReady,
  output logic                             eAwValid,
  output slv_aw_channel_t                  eAwChannel,

  // Requester Interface Read Address Channel
  input  logic                             iArReady,
  output logic                             eArValid,
  output ar_channel_t                      eArChannel,

  // Requester Interface Write Data Channel
  input  logic                             iWrReady,
  output logic                             eWrValid,
  output w_channel_t                       eWrChannel,

  // Rule Analyzer Pipeline  <==> Master RREQ Buffer
  input  logic                             rap_rd_valid,         // Read Transaction is Valid
  input  ar_channel_t                      rap_rd_req,           // Read Transaction from RAP

  // Rule Analyzer Pipeline  <==>  Master WREQ Buffer
  input  logic                             rap_wr_valid,         // Write Transaction is Valid
  input  slv_aw_channel_t                  rap_wr_trans,         // Write Transaction from RAP

  // Error Interrupt Controller  <==>  MSI Request Buffer
  input  logic                             eic_msi_valid,        // MSI Write Request is Valid
  input  slv_aw_channel_t                  eic_msi_trans,        // MSI Write Transaction from EIC

  // Register File Manager  <==>  Slave Request Manager
  input  logic [10:0]                      msi_data,             // MSI Data from Register File

  // Slave Request Manager <==> Master Request Manager
  input  logic                             mst_wd_buf_vld,       // Valid indicating read data is valid
  input  w_channel_t                       mst_wd_buf_data,      // Read data from selected way/index of the Master Write Data Buffer
  output logic [MAX_BURST_LEN-1:0]         mst_wd_buf_rden,      // Read enable vector for Master Write Data Buffer (1-bit per burst beat)
  output logic [$clog2(MAX_BURST_LEN)-1:0] mst_wd_buf_rd_index,  // Beat-level index within the selected transaction (0 to MAX_BURST_LEN-1)
  output logic [$clog2(MAX_TRANS)-1:0]     mst_wd_buf_raddr      // Transaction-level address to select which buffer entry to access
);

  //###############################
  // Internal Signals Declarations
  //###############################

  //--------------------------------------------------------------------------
  // MSI Request Buffer
  //--------------------------------------------------------------------------
  logic            msi_req_buf_rd_en;      // Read enable
  logic            msi_req_buf_full;       // Full flag
  logic            msi_req_buf_empty;      // Empty flag
  slv_aw_channel_t msi_req_buf_rd_data;    // Output data

  //--------------------------------------------------------------------------
  // Master Write Request (WREQ) Buffer
  //--------------------------------------------------------------------------
  logic         mst_wrreq_buf_rd_en;       // Read enable
  logic         mst_wrreq_buf_full;        // Full flag
  logic         mst_wrreq_buf_empty;       // Empty flag
  slv_aw_channel_t mst_wrreq_buf_rd_data;  // Output data

  //--------------------------------------------------------------------------
  // Master Read Request (RREQ) Buffer
  //--------------------------------------------------------------------------
  logic         mst_rreq_full;             // Full flag
  logic         mst_rreq_empty;            // Empty flag

  //--------------------------------------------------------------------------
  // Priority Arbiter 3 Control Signals
  //--------------------------------------------------------------------------
  logic            [1:0] pr_arb3_rdy;      // Grant signals from arbiter
  logic            [1:0] pr_arb3_vld;      // Valid inputs to arbiter
  slv_aw_channel_t [1:0] pr_arb3_req;      // Request payloads to arbiter

  //--------------------------------------------------------------------------
  // Master Write Request Buffer Instance
  //--------------------------------------------------------------------------
  iopmp_fifo #(
    .FALL_THROUGH (1),
    .DATA_WIDTH ($bits(slv_aw_channel_t)),
    .DEPTH      (MAX_TRANS)
  ) mst_wreq_buf (
    .clk_i      (clk),
    .rst_ni     (rst_n),
    .full_o     (mst_wrreq_buf_full),
    .empty_o    (mst_wrreq_buf_empty),
    .data_i     (rap_wr_trans),           // Write Transaction from EIC block
    .push_i     (rap_wr_valid),           // Write Transaction is valid
    .data_o     (mst_wrreq_buf_rd_data),
    .pop_i      (mst_wrreq_buf_rd_en)
  );

  if (ERROR_CAPTURE_EN && MSI_EN) begin : generate_msi_buf
    //--------------------------------------------------------------------------
    // MSI Request Buffer Instance
    //--------------------------------------------------------------------------
    iopmp_fifo #(
      .FALL_THROUGH (1),
      .DATA_WIDTH   ($bits(slv_aw_channel_t)),
      .DEPTH        (1)
    ) msi_req_buf (
      .clk_i      (clk),
      .rst_ni     (rst_n),
      .full_o     (msi_req_buf_full),
      .empty_o    (msi_req_buf_empty),
      .data_i     (eic_msi_trans),          // MSI Write Transaction from EIC block
      .push_i     (eic_msi_valid),          // MSI Write Transaction is valid
      .data_o     (msi_req_buf_rd_data),
      .pop_i      (msi_req_buf_rd_en)
    );

    //---------------------------------------------------------------------------------------
    // Priority Arbiter 3 Control Logic
    // - Controls Write Request Buffers (MSI Write Buffer has highest priority)
    // - pr_arb3_vld[0] connects to the MSI Request Buffer
    // - pr_arb3_vld[1] connects to the Master Write Request Buffer
    // - pr_arb3_req carries the request payloads to the arbiter
    // - Read enables are asserted based on arbiter grant signals
    // - New AW Transaction will only be sent, once previous one's data
    //   burst is completed
    // - This Arbiter Controls that while burst transfer, no new
    //   request should be granted by Arbiter
    //---------------------------------------------------------------------------------------
    always_comb begin : pr_arb3_ctrl
      // Arbiter Valid signals are controlled from axi write controller

      // Assign request payloads from corresponding buffer outputs
      pr_arb3_req[0] = msi_req_buf_rd_data;
      pr_arb3_req[1] = mst_wrreq_buf_rd_data;

      // Enable read from the selected buffer based on arbiter grant
      msi_req_buf_rd_en   = pr_arb3_rdy[0];     // pr_arb3_vld[0] connects to the MSI Request Buffer
      mst_wrreq_buf_rd_en = pr_arb3_rdy[1];     // pr_arb3_vld[1] connects to the Master Write Request Buffer
    end

    //--------------------------------------------------------------------------
    // Priority Arbiter 3 Instance (MSI has highest priority)
    //--------------------------------------------------------------------------
    rr_arbiter #(
      .NUMIN    (2),
      .DATATYPE (slv_aw_channel_t),
      .EXT_PRI  (1'b1)
    ) pr_arb3 (
      .clk           (clk),
      .rst_n         (rst_n),
      .pri           (2'b01),
      .valid_req     (pr_arb3_vld),
      .in_req_gnt    (pr_arb3_rdy),
      .reqs          (pr_arb3_req),
      .out_req_gnt   (iAwReady),
      .req_gnt_valid (eAwValid),
      .req_gnt       (eAwChannel)
    );
  end
  else begin : error_capture_disable
    assign eAwValid            = pr_arb3_vld[1];
    assign eAwChannel          = mst_wrreq_buf_rd_data;
    assign mst_wrreq_buf_rd_en = eAwValid & iAwReady;
  end

  //--------------------------------------------------------------------------
  // Master Read Request Buffer Instance
  //--------------------------------------------------------------------------

  assign eArValid = !mst_rreq_empty;   // Read Request Buffer has valid transaction

  iopmp_fifo #(
    .FALL_THROUGH (1),
    .DATA_WIDTH ($bits(ar_channel_t)),
    .DEPTH      (MAX_TRANS)
  ) mst_rreq_buf (
    .clk_i      (clk),
    .rst_ni     (rst_n),
    .full_o     (mst_rreq_full),
    .empty_o    (mst_rreq_empty),
    .data_i     (rap_rd_req),           // Read Transaction from RAP block
    .push_i     (rap_rd_valid),         // Read Transaction is valid
    .data_o     (eArChannel),           // Data for AR channel
    .pop_i      (eArValid && iArReady)  // POP Data on AR channel Handshake
  );

  //--------------------------------------------------------------------------
  // AXI Write Channel Controller Instance
  // Controls coordination between AW and W channels for AXI write transactions.
  // Handles MSI tagging, burst detection, buffer index updates, and flow control.
  //--------------------------------------------------------------------------
  axi_write_chnl_controller axi_write_chnl_controller (
    // Clock and Reset
    .clk                 (clk),                                                         // System clock
    .rst_n               (rst_n),                                                       // Active-low reset

    // AW Channel Signals Used inside the Controller
    .eAwValid            (eAwValid),                                                    // AW channel valid signal from master
    .awaddr2             (eAwChannel.aw_addr[2]),                                       // AW address bit [2], used for MSI strobe generation
    .msi_vld             ((ERROR_CAPTURE_EN && MSI_EN) ? eAwChannel.aw_id[5] : 1'b0),   // Indicates this is an MSI transaction
    .wd_tag              (eAwChannel.aw_user[10:6]),                                    // Tag field from AW user bits for buffer access
    .aw_chnl_hs          (iAwReady && eAwValid),                                        // AW handshake: master valid + slave ready
    .burst_trnsfr        (eAwValid && (|eAwChannel.aw_len)),                            // Burst transfer active if AW is valid and burst length > 0

    // W Channel Signals used inside the Controller
    .iWrReady            (iWrReady),                                                    // Write Data Channel Ready
    .eWrValid            (eWrValid),                                                    // W channel valid signal to slave
    .eWrChannel          (eWrChannel),

    // Priority Arbiter 3 Valid Signals
    .msi_req_buf_empty   ((ERROR_CAPTURE_EN && MSI_EN) ? msi_req_buf_empty : 1'b0),     // MSI Buffer Status
    .mst_wrreq_buf_empty (mst_wrreq_buf_empty),                                         // Master WRREQ Buffer Status
    .pr_arb3_vld         (pr_arb3_vld),                                                 // Arbiter 3 Valid

    // Register File Manager  <==>  Slave Request Manager
    .msi_data            (msi_data),                                                    // MSI Data from Register File

    // Master Write Data Buffer Control
    .mst_wd_buf_vld      (mst_wd_buf_vld),                                              // Indicates write data is available in the buffer
    .mst_wd_buf_data     (mst_wd_buf_data),                                             // Read data from selected way/index of the Master Write Data Buffer
    .mst_wd_buf_rden     (mst_wd_buf_rden),                                             // Read enable vector for Master WD buffer (one-hot per beat)
    .mst_wd_buf_rd_index (mst_wd_buf_rd_index),                                         // Beat-level index (0 to 15)
    .mst_wd_buf_raddr    (mst_wd_buf_raddr)                                             // Transaction-level address for Master WD buffer
  );

endmodule
