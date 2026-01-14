///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Gull Ahmed <gull.ahmed@10xengineers.ai>
/// Date Created: 29-June-2025
/// Description: This Write Channel FSM controls the AXI Write Address
/// and write data channel. This FSM sends the write data request which
/// could be single/Burst Transfer on the AXI write channel, This FSM controls
/// that next transaction on aw channel should be sent only after previous
/// transaction's data is sent. This block is submodule of Slave request
/// Manager block.
///////////////////////////////////////////////////////////////////////////

module axi_write_chnl_controller
  import config_iopmp_pkg::MAX_BURST_LEN;
  import config_iopmp_pkg::MAX_TRANS;
  import iopmp_axi_pkg::w_channel_t;
  (
  // Clock and Reset
  input  logic                             clk,                   // System clock
  input  logic                             rst_n,                 // Active-low reset

  // AW Channel Inputs
  input  logic                             eAwValid,              // AW channel valid signal
  input  logic                             awaddr2,               // AW address bit [2], used for strobe generation in MSI
  input  logic                             msi_vld,               // MSI valid signal (from aw_id[5])
  input  logic [$clog2(MAX_TRANS)-1:0]     wd_tag,                // Tag from AW user field
  input  logic                             aw_chnl_hs,            // AW handshake signal (eAwValid && iAwReady)
  input  logic                             burst_trnsfr,          // Indicates if this is a burst transfer

  // W Channel Inputs
  input  logic                             iWrReady,              // Slave W channel is Ready
  output logic                             eWrValid,              // Valid signal for W channel
  output w_channel_t                       eWrChannel,            // Transaction out for Write Channel

  // Priority Arbiter 3 Valid Signals
  input  logic                             msi_req_buf_empty,     // MSI Buffer Status
  input  logic                             mst_wrreq_buf_empty,   // Master WRREQ Buffer Status
  output logic [1:0]                       pr_arb3_vld,           // Arbiter 3 Valid

  // Register File Manager  <==>  Slave Request Manager
  input  logic [10:0]                      msi_data,              // MSI Data from Register File

  // Master Write Data Buffer Control
  input  logic                             mst_wd_buf_vld,        // Write data valid from buffer
  input  w_channel_t                       mst_wd_buf_data,       // Read data from selected way/index of the Master Write Data Buffer
  output logic [MAX_BURST_LEN-1:0]         mst_wd_buf_rden,       // One-hot read enable vector (per beat)
  output logic [$clog2(MAX_BURST_LEN)-1:0] mst_wd_buf_rd_index,   // Beat index for current burst
  output logic [$clog2(MAX_TRANS)-1:0]     mst_wd_buf_raddr       // Buffer address (transaction tag)
);

  //------------------------------------
  // Internal Signals Declarations
  //------------------------------------
  logic [$clog2(MAX_TRANS)-1:0] wd_tag_q, wd_tag_n;                            // Current and next WD tag
  logic [$clog2(MAX_BURST_LEN)-1:0]       mst_wd_buf_rd_index_n;                         // Next beat index
  logic                                   is_wd_buf_data_pndg_n, is_wd_buf_data_pndg_q;  // Data pending status
  logic                                   msi_req_n, msi_req_q;                          // MSI request flags
  logic                                   awaddr2to2_n, awaddr2to2_q;                    // aw_addr[2] bit flopped
  logic                                   aw_chnl_hs_done_n, aw_chnl_hs_done_q;          // AW channel handshake complete
  logic                                   last_transfer;                                 // Indicates final beat of current write burst
  logic                                   w_chnl_hs;                                     // Write Data Channel (Ready + Valid) Handshake

  //--------------------------------------------------------------------------
  // Write Address and Data Channel FSM
  //--------------------------------------------------------------------------
  enum logic [1:0] {
    IDLE           = 2'b00,     // IDLE State
    WAIT_AW_HS     = 2'b01,     // Wait for AW Channel Handshake
    WAIT_W_HS      = 2'b10,     // Wait for W Channel Handshake
    BURST_TRANSFER = 2'b11      // To Handle Burst Transfer
  } axi_wr_state, axi_wr_state_n;

  assign w_chnl_hs     = iWrReady  & eWrValid;                  // Write Data Channel (Ready + Valid) Handshake
  assign last_transfer = w_chnl_hs & eWrChannel.w_last;         // Indicates final beat of current write burst

  //--------------------------------------------------------------------------
  // Arbiter 3 Valid Control
  // aw channel should be valid until the handshake is successful.
  // - It's possible that Data is accepted before Address from Slave
  //   when aw transaction is valid, so IOPMP starts sending data
  //   and wait for the aw handshake.
  // - In this Case, the is_wd_buf_data_pndg_q flag could be set to 1
  //   if it's a burst transfer, which leads to reset the pr_arb3_vld = 0,
  //   means aw_channel valid will be low even without handshake
  // - To Keep aw_channel valid until aw_channel handshake is successful,
  //    we use aw_chnl_hs_done_q signal.
  // The aw_channel valid should be low until the burst data transfer of the
  // corresponding aw_channel transaction is completed, to control this we
  // are using is_wd_buf_data_pndg_q flag. Set means data is pending.
  //--------------------------------------------------------------------------
  always_comb begin : pr_arb3_ctrl
    pr_arb3_vld[0] = aw_chnl_hs_done_q ? !msi_req_buf_empty && !is_wd_buf_data_pndg_q :
                                         !msi_req_buf_empty;
    pr_arb3_vld[1] = aw_chnl_hs_done_q ? !mst_wrreq_buf_empty && !is_wd_buf_data_pndg_q :
                                         !mst_wrreq_buf_empty;
  end

  //--------------------------------------------------------------------------
  // AXI Write Transaction Controller
  // - Controls write data issue to the AXI W channel
  // - Reads from Master Write Data Buffer based on AW info
  // - Supports burst and single-beat transactions
  // - Handles MSI write logic and write channel handshaking
  //--------------------------------------------------------------------------
  always_comb begin : SendWriteTransaction
    // Default signal assignments
    eWrValid              = '0;
    mst_wd_buf_rden       = 16'h1 << mst_wd_buf_rd_index;                 // One-hot read enable
    is_wd_buf_data_pndg_n = is_wd_buf_data_pndg_q;
    axi_wr_state_n        = axi_wr_state;
    wd_tag_n              = wd_tag_q;
    msi_req_n             = msi_req_q;
    awaddr2to2_n          = awaddr2to2_q;
    aw_chnl_hs_done_n     = aw_chnl_hs_done_q;
    eWrChannel            = mst_wd_buf_data;                              // For non-MSI requests, forward pre-buffered master write data

    // In IDLE state, Extracted aw_user[10:6] bits are used as address else flopped wd_tag_q
    mst_wd_buf_raddr      = (axi_wr_state == IDLE) ? wd_tag : wd_tag_q;

    // If W channel handshake occurs:
    //   -> Reset index on last beat
    //   -> Else increment
    mst_wd_buf_rd_index_n = w_chnl_hs ? (eWrChannel.w_last ? '0 : mst_wd_buf_rd_index + 16'h1 ) :
                                        mst_wd_buf_rd_index;              // Else, hold current index

    case (axi_wr_state)
      //=======================================================================
      // IDLE State
      // - Wait for AW+W channel handshake to initiate transaction
      // - If burst, setup tag and tracking info for future beats
      //=======================================================================
      IDLE: begin
        eWrValid              = eAwValid & (msi_vld || mst_wd_buf_vld);  // Assert write valid only if AW is valid and either msi or wd data is available in buffer
        is_wd_buf_data_pndg_n = burst_trnsfr;                            // Set data pending flag if burst transfer is detected (AWLEN > 0)
        wd_tag_n              = wd_tag;                                  // Capture tag from AWUSER field (used to index WD buffer)
        aw_chnl_hs_done_n     = aw_chnl_hs && burst_trnsfr;              // Flag AW channel handshake completion if burst transfer initiated, Used to Control Arb3

        if (msi_vld) begin
          awaddr2to2_n      = awaddr2 && !w_chnl_hs;                                     // Capture aw_addr[2] if W handshake did not occur (used for MSI strobes)
          msi_req_n         = !w_chnl_hs;                                                // Capture MSI request bit (aw_id[5]) if W handshake did not occur
          eWrChannel.w_data = awaddr2 ? {21'b0, msi_data, 32'b0} : {53'b0, msi_data};    // Write Data Generation
          eWrChannel.w_last = 1'b1;                                                      // MSI write is always a single-beat write
          eWrChannel.w_user = '0;                                                        // Clear user field for MSI writes (not used)

          // Generate write strobe:
          //  Use AW address bit [2] to decide upper/lower half enable
          //  eWrChannel.w_strb = awaddr2 ? 8'hFFFF0000 : 8'h0000FFFF;
          eWrChannel.w_strb = {{4{awaddr2}}, {4{!awaddr2}}};
        end

        // Next state logic based on AW/W handshake combination
        unique case ({aw_chnl_hs, w_chnl_hs})
          2'b00: axi_wr_state_n = IDLE;                            // No handshake
          2'b01: axi_wr_state_n = WAIT_AW_HS;                      // W only
          2'b10: axi_wr_state_n = WAIT_W_HS;                       // AW only
          2'b11: axi_wr_state_n = burst_trnsfr ? BURST_TRANSFER    // Both
                                               : IDLE;
        endcase
      end

      //=======================================================================
      // WAIT_AW_HS State
      // - AW is pending, wait for its handshake
      // - Continue W transfer if data is available
      //=======================================================================
      WAIT_AW_HS: begin
        eWrValid              = mst_wd_buf_vld && is_wd_buf_data_pndg_q;     // Assert W valid if data is pending and available in buffer
        is_wd_buf_data_pndg_n = !last_transfer && is_wd_buf_data_pndg_q;     // Maintain data pending flag until last transfer

        // Update AW handshake done flag only if AW handshake happens
        aw_chnl_hs_done_n = aw_chnl_hs ? (!last_transfer && is_wd_buf_data_pndg_q) :
                                         aw_chnl_hs_done_q;
        // If AW handshake occurs:
        //   -> Go to BURST_TRANSFER if more data is pending
        //   -> Else return to IDLE
        // Else, stay in current state
        axi_wr_state_n = aw_chnl_hs ? ((!last_transfer && is_wd_buf_data_pndg_q) ? BURST_TRANSFER : IDLE) :
                                      axi_wr_state;
      end

      //=======================================================================
      // WAIT_W_HS State
      // - W is pending, wait for W channel to accept first beat
      // - MSI and AW addr info retained
      //=======================================================================
      WAIT_W_HS: begin
        eWrValid          = msi_req_q || mst_wd_buf_vld;                                   // Assert W valid if either MSI write is pending or data is available in buffer
        msi_req_n         = !(w_chnl_hs && !is_wd_buf_data_pndg_q) && msi_req_q;           // Clear MSI request flag only if W handshake occurred and no more data is pending
        awaddr2to2_n      = !(w_chnl_hs && !is_wd_buf_data_pndg_q) && awaddr2to2_q;        // Clear awaddr2to2_q flag under same condition as above
        aw_chnl_hs_done_n = w_chnl_hs ? is_wd_buf_data_pndg_q : aw_chnl_hs_done_q;         // Update AW handshake done flag if W handshake occurs and more data is pending

        if (msi_req_q) begin
          eWrChannel.w_data = awaddr2to2_q ? {21'b0, msi_data, 32'b0} : {53'b0, msi_data}; // Write Data Generation
          eWrChannel.w_last = 1'b1;                                                        // MSI write is always a single-beat write
          eWrChannel.w_user = '0;                                                          // Clear user field for MSI writes (not used)

          // Generate write strobe:
          // - If msi_req_q is set, use awaddr2to2_q to decide upper/lower half enable
          // - Otherwise, use AW address bit [2]
          eWrChannel.w_strb = {{4{awaddr2to2_q}}, {4{!awaddr2to2_q}}};
        end

        // Next state: if W handshake occurs
        //   -> go to BURST_TRANSFER if more data pending
        //   -> else go to IDLE
        // Else, stay in current state
        axi_wr_state_n = w_chnl_hs ? (is_wd_buf_data_pndg_q ? BURST_TRANSFER : IDLE) :
                                     axi_wr_state;
      end

      //=======================================================================
      // BURST_TRANSFER State
      // - Continue sending burst data beats
      // - Exit on last beat
      //=======================================================================
      BURST_TRANSFER: begin
        eWrValid              = mst_wd_buf_vld;                            // Assert W valid if data is available in the write data buffer
        aw_chnl_hs_done_n     = !last_transfer && aw_chnl_hs_done_q;       // Clear AW handshake done flag on last transfer, otherwise retain
        is_wd_buf_data_pndg_n = !last_transfer && is_wd_buf_data_pndg_q;   // Clear data pending flag on last transfer, otherwise retain
        axi_wr_state_n        = last_transfer ? IDLE : BURST_TRANSFER;     // Transition to IDLE on last beat, otherwise stay in BURST_TRANSFER
      end
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      axi_wr_state          <= IDLE;
      mst_wd_buf_rd_index   <= '0;
      wd_tag_q              <= '0;
      is_wd_buf_data_pndg_q <= '0;
      msi_req_q             <= '0;
      awaddr2to2_q          <= '0;
      aw_chnl_hs_done_q     <= '0;
    end
    else begin
      wd_tag_q              <= wd_tag_n;
      msi_req_q             <= msi_req_n;
      awaddr2to2_q          <= awaddr2to2_n;
      axi_wr_state          <= axi_wr_state_n;
      aw_chnl_hs_done_q     <= aw_chnl_hs_done_n;
      is_wd_buf_data_pndg_q <= is_wd_buf_data_pndg_n;
      mst_wd_buf_rd_index   <= mst_wd_buf_rd_index_n;
    end
  end

endmodule