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
/// uses independent read and write channels to send read/write requests
/// and independent response channels for read/write responses.
///////////////////////////////////////////////////////////////////////////

module mst_resp_mgr
  import config_iopmp_pkg::MAX_BURST_LEN;
  import config_iopmp_pkg::MAX_TRANS;
  import config_iopmp_pkg::ERROR_CAPTURE_EN;
  import config_iopmp_pkg::MSI_EN;
  import iopmp_axi_pkg::b_channel_t;
  import iopmp_axi_pkg::r_channel_t;
  import iopmp_axi_pkg::slv_b_channel_t;
  (
  input  logic                             clk,
  input  logic                             rst_n,

  // Master Write Response Channel
  input  logic                             iBReady,
  output logic                             eBValid,
  output b_channel_t                       eBChannel,

  // Master Read Response Channel
  input  logic                             iRReady,
  output logic                             eRValid,
  output r_channel_t                       eRChannel,

  // Slave Read Response Channel
  input  logic                             iRValid,
  input  r_channel_t                       iRChannel,
  output logic                             eRReady,

  // Slave Write Response Channel
  input  logic                             iBValid,
  input  slv_b_channel_t                   iBChannel,
  output logic                             eBReady,

  // RAP <==> Master Response Manager
  input  logic                             rap_rd_err_valid,    // Indicates valid read error response from RAP
  input  r_channel_t                       rap_rd_err_req,      // Read error response payload
  input  logic [$clog2(MAX_BURST_LEN)-1:0] ar_len,              // Burst length of the original AR transaction

  // RAP <==> Master Response Manager
  input  logic                             rap_wr_err_valid,    // Indicates valid write error response from RAP
  input  slv_b_channel_t                   rap_wr_err_req,      // Write error response payload

  // Master Response Manager <==> Master Request Manager
  output logic                             clr_tag,             // Clear tag in write data buffer (after response)
  output logic [$clog2(MAX_TRANS)-1:0]     tag_in,              // Tag to be cleared

  // Master Response Manager <==> Error Interrupt Controller (EIC)
  output logic                             mrspm_eic_valid,     // Indicates valid MSI write response to EIC
  output logic                             mrspm_eic_trans      // Response type (e.g., 0: Success, 1: Error)
);

  //--------------------------------------------------------------------------
  // Read Error Transaction Buffer Signals
  //--------------------------------------------------------------------------
  logic rerr_resp_buf_rd_en;   // Read enable
  logic rerr_resp_buf_full;    // Buffer full flag
  logic rerr_resp_buf_empty;   // Buffer empty flag
  logic [($bits(r_channel_t) + $clog2(MAX_BURST_LEN)) - 1 : 0] rerr_resp_buf_rd_data; // Read data with burst count info

  //--------------------------------------------------------------------------
  // Slave Read Response Transaction Buffer Signals
  //--------------------------------------------------------------------------
  logic       slave_resp_buf_full;      // Buffer full flag
  logic       slave_resp_buf_empty;     // Buffer empty flag
  r_channel_t slave_resp_buf_rd_data;   // Read data (AXI R channel)

  //--------------------------------------------------------------------------
  // Write Error Transaction Buffer Signals
  //--------------------------------------------------------------------------
  logic           werr_resp_buf_full;      // Buffer full flag
  logic           werr_resp_buf_empty;     // Buffer empty flag
  slv_b_channel_t werr_resp_buf_rd_data;   // Read data (AXI B channel with extra metadata)

  //--------------------------------------------------------------------------
  // Priority Arbiter 4 (Write Response Arbiter)
  //--------------------------------------------------------------------------
  logic       [1:0] pr_arb4_rdy;        // Grant from arbiter
  logic       [1:0] pr_arb4_vld;        // Valid inputs to arbiter
  b_channel_t [1:0] pr_arb4_req;        // Write response requests

  //--------------------------------------------------------------------------
  // Priority Arbiter 5 (Read Response Arbiter)
  //--------------------------------------------------------------------------
  logic       [1:0] pr_arb5_rdy;        // Grant from arbiter
  logic       [1:0] pr_arb5_vld;        // Valid inputs to arbiter
  r_channel_t [1:0] pr_arb5_req;        // Read response requests

  //--------------------------------------------------------------------------
  // Miscellaneous
  //--------------------------------------------------------------------------
  logic [$clog2(MAX_BURST_LEN)-1:0] burst_cntr_q, burst_cntr_n; // Burst beat counter
  logic [$clog2(MAX_BURST_LEN)-1:0] rd_trnsfr_len;              // Read transaction burst length
  logic                             prio;                       // Priority select/control signal
  logic                             rd_trnsfr_done;             // Burst Transfer is completed
  logic                             burst_trnsfr;               // if set means Burst Transfer

  //--------------------------------------------------------------------------
  // Response State Machine States
  // - IDLE : Idle state
  // - SLAVE_RSP_ACTIVE: Processing slave burst response
  // - ERR_RSP_ACTIVE: Handling read error burst response
  //--------------------------------------------------------------------------
  enum logic [1:0] {
    IDLE             = 2'b00,         // Idle state
    SLAVE_RSP_ACTIVE = 2'b01,         // Slave response state for Burst Transfer
    ERR_RSP_ACTIVE   = 2'b10          // Read error response state for Burst Transfer
  } resp_state_q, resp_state_n;

  //--------------------------------------------------------------------------
  // Flopped response transactions from Slave Interface
  //--------------------------------------------------------------------------
  logic           b_chnl_hs_q;     // Write response (B channel) handshake
  logic           r_chnl_hs_q;     // Read response (R channel) handshake
  r_channel_t     r_chnl_resp_q;   // Flopped R channel response
  slv_b_channel_t b_chnl_resp_q;   // Flopped B channel response

  //--------------------------------------------------------------------------
  // R and B ready generation for Slave response
  //--------------------------------------------------------------------------
  // Ready to accept R channel response if slave response buffer is not full
  assign eRReady = !slave_resp_buf_full;

  // Always ready to accept B channel response (no backpressure)
  assign eBReady = 1'b1;

  //------------------------------------------------------------------------------
  // Tag Clear Control
  // - Clears write data tag when write response is accepted by slave
  // - Selects tag source based on grant from arbiter
  //------------------------------------------------------------------------------
  always_comb begin : ClrTag
    clr_tag = iBReady && eBValid; // Trigger tag clear on B channel handshake
    tag_in  = '0;                 // Default value

    // Selects tag to be cleared based on grant from arbiter
    if (iBReady && eBValid)
      tag_in = pr_arb4_rdy[0] ?
              werr_resp_buf_rd_data.b_user[10:6] :   // From write error buffer
              b_chnl_resp_q.b_user[10:6];            // From Slave response
  end

  if (ERROR_CAPTURE_EN && MSI_EN) begin : gen_msi_write_resp
    //------------------------------------------------------------------------------
    // MSI Write Response Detection
    // - Detects MSI-related write response and passes info to EIC
    //------------------------------------------------------------------------------
    always_comb begin : MSIWrResponse
      mrspm_eic_valid = b_chnl_hs_q && b_chnl_resp_q.b_id[5];   // Valid MSI response
      mrspm_eic_trans = (|b_chnl_resp_q.b_resp);                // Indicates error response
    end
  end
  else begin : drive_msi_write_resp_zero

    assign mrspm_eic_valid = 1'b0;
    assign mrspm_eic_trans = 1'b0;
  end

  //##############################
  // Write Error Response Buffer
  //##############################
  iopmp_fifo #(
    .FALL_THROUGH (1),
    .DATA_WIDTH ($bits(slv_b_channel_t)),
    .DEPTH      (MAX_TRANS/2)
  ) werr_resp_buf (
    .clk_i      (clk),
    .rst_ni     (rst_n),
    .full_o     (werr_resp_buf_full),
    .empty_o    (werr_resp_buf_empty),
    .data_i     (rap_wr_err_req),
    .push_i     (rap_wr_err_valid),
    .data_o     (werr_resp_buf_rd_data),
    .pop_i      (pr_arb4_rdy[0])
  );

  //------------------------------------------------------------------------------
  // Priority Arbiter 4 Control (Master Write Response)
  // - Selects between Slave B channel response and write error response
  // - Slave B channel has highest priority
  //------------------------------------------------------------------------------
  always_comb begin : pr_arb4_ctrl
    // Valid signals to arbiter
    pr_arb4_vld[0] = !werr_resp_buf_empty;                      // Source 0: Write Error Response Buffer
    pr_arb4_vld[1] = b_chnl_hs_q && !b_chnl_resp_q.b_id[5];     // Source 1: B channel (non-MSI)

    // Source 0: Write Error Response Payload
    pr_arb4_req[0].b_id   = werr_resp_buf_rd_data.b_id[4:0];    // Valid ID to be sent back to Receiver Interface
    pr_arb4_req[0].b_resp = werr_resp_buf_rd_data.b_resp;
    pr_arb4_req[0].b_user = werr_resp_buf_rd_data.b_user[5:0];  // Valid RRID bits to be sent back to Receiver Interface

    // Source 1: B Channel Response Payload (non-MSI)
    pr_arb4_req[1].b_id   = b_chnl_resp_q.b_id[4:0];            // Valid ID to be sent back to Receiver Interface
    pr_arb4_req[1].b_resp = b_chnl_resp_q.b_resp;
    pr_arb4_req[1].b_user = b_chnl_resp_q.b_user[5:0];          // Valid RRID bits to be sent back to Receiver Interface
  end

  //####################
  // Priority Arbiter 4
  //####################
  rr_arbiter #(
    .NUMIN    (2),
    .DATATYPE (b_channel_t),
    .EXT_PRI  (1'b1)
  ) pr_arb4 (
    .clk           (clk),
    .rst_n         (rst_n),
    .pri           (2'b01),
    .valid_req     (pr_arb4_vld),
    .in_req_gnt    (pr_arb4_rdy),
    .reqs          (pr_arb4_req),
    .out_req_gnt   (iBReady),
    .req_gnt_valid (eBValid),
    .req_gnt       (eBChannel)
  );


  //###########################
  // Read Response Buffers
  //###########################
  iopmp_fifo #(
    .FALL_THROUGH (1),
    .DATA_WIDTH (($bits(r_channel_t) + $clog2(MAX_BURST_LEN))),
    .DEPTH      (MAX_TRANS)
  ) rerr_resp_buf (
    .clk_i      (clk),
    .rst_ni     (rst_n),
    .full_o     (rerr_resp_buf_full),
    .empty_o    (rerr_resp_buf_empty),
    .data_i     ({ar_len, rap_rd_err_req}),
    .push_i     (rap_rd_err_valid),
    .data_o     (rerr_resp_buf_rd_data),
    .pop_i      (rerr_resp_buf_rd_en)
  );

  iopmp_fifo #(
    .FALL_THROUGH (1),
    .DATA_WIDTH ($bits(r_channel_t)),
    .DEPTH      (MAX_BURST_LEN)
  ) slave_rresp_buf (
    .clk_i      (clk),
    .rst_ni     (rst_n),
    .full_o     (slave_resp_buf_full),
    .empty_o    (slave_resp_buf_empty),
    .data_i     (r_chnl_resp_q),
    .push_i     (r_chnl_hs_q),
    .data_o     (slave_resp_buf_rd_data),
    .pop_i      (pr_arb5_rdy[1])

  );

  always_comb begin : RRespCntrlr
    //------------------------------------------------------------------------------
    // Priority Arbiter 5 Control (Master Read Response)
    // - Selects between Read Error Response Buffer and Slave Read Response Buffer
    // - Slave response has higher priority
    //------------------------------------------------------------------------------
    // Valid signals to arbiter
    pr_arb5_vld[0] = !rerr_resp_buf_empty;       // Source 0: Read Error Response
    pr_arb5_vld[1] = !slave_resp_buf_empty;      // Source 1: Slave Read Response (higher priority)

    // Request payloads to arbiter
    pr_arb5_req[0] = rerr_resp_buf_rd_data[$bits(r_channel_t) - 1 : 0];         // Extract valid data, upper bits hold ar_length
    pr_arb5_req[1] = slave_resp_buf_rd_data;

    //------------------------------------------------------------------------------
    // Read Response Controller (RRespCntrlr)
    // - Manages read responses from both slave and read error sources
    // - Handles multi-beat error responses using a burst counter
    //------------------------------------------------------------------------------

    // Default assignments
    resp_state_n        = resp_state_q;
    burst_cntr_n        = burst_cntr_q;
    prio                = 1'b1;                 // Slave read response buffer has highest priority
    rerr_resp_buf_rd_en = 1'b0;

    // Extract burst length (ar_len) from upper bits of read error buffer data
    rd_trnsfr_len       = rerr_resp_buf_rd_data[($bits(r_channel_t) + $clog2(MAX_BURST_LEN)) - 1 : $bits(r_channel_t)];

    // Read transfer is done when arbiter grants and burst counter reaches zero
    rd_trnsfr_done      = pr_arb5_rdy[0] && !(|burst_cntr_q);

    // Burst transfer is active if arbiter grants and transfer length > 0
    burst_trnsfr = pr_arb5_rdy[0] && |rd_trnsfr_len;

    case (resp_state_q)

      //--------------------------------------------------------------------------
      // IDLE: Idle state (Slave Response Buffer has HIGHEST Priority)
      // - If error response has burst > 1, transition to ERR_RSP_ACTIVE
      // - If error response is single beat, stay in IDLE
      // - If slave response is multi-beat, go to SLAVE_RSP_ACTIVE
      //--------------------------------------------------------------------------
      IDLE: begin
        // For single-beat error response, trigger read immediately
        rerr_resp_buf_rd_en = pr_arb5_rdy[0] && !burst_trnsfr;

        // Set burst counter for error response; retain if not a burst
        burst_cntr_n = burst_trnsfr ? rd_trnsfr_len - 4'h1 : burst_cntr_q;

        // Next state decision:
        // - If burst error: go to ERR_RSP_ACTIVE
        // - Else if multi-beat slave response: go to SLAVE_RSP_ACTIVE
        // - Else remain in IDLE
        resp_state_n = burst_trnsfr ? ERR_RSP_ACTIVE :
                       (pr_arb5_rdy[1] && !slave_resp_buf_rd_data.r_last) ? SLAVE_RSP_ACTIVE :
                       IDLE;
      end

      //--------------------------------------------------------------------------
      // SLAVE_RSP_ACTIVE: Handling multi-beat slave read response
      // - Return to IDLE on last beat
      //--------------------------------------------------------------------------
      SLAVE_RSP_ACTIVE: begin
        resp_state_n = (pr_arb5_rdy[1] && slave_resp_buf_rd_data.r_last) ? IDLE : SLAVE_RSP_ACTIVE;
      end

      //--------------------------------------------------------------------------
      // ERR_RSP_ACTIVE: Handling multi-beat read error response
      // - Read Error Response Buffer has HIGHEST Priority
      // - Decrement burst counter each cycle
      // - Mark r_last when it's the final beat and transition to IDLE
      //--------------------------------------------------------------------------
      ERR_RSP_ACTIVE: begin
        prio = 1'b0;  // Lower slave priority while read error burst is active

        pr_arb5_req[0].r_last = rd_trnsfr_done;                             // Assert r_last on final beat
        rerr_resp_buf_rd_en   = rd_trnsfr_done;                             // Trigger read on final beat
        resp_state_n          = rd_trnsfr_done ? IDLE : ERR_RSP_ACTIVE;     // Transition back to IDLE if done

        burst_cntr_n = pr_arb5_rdy[0] ? burst_cntr_q - 4'h1 : burst_cntr_q; // Decrement counter if arbiter grants
      end

      default: begin
        resp_state_n = IDLE;
      end
    endcase
  end

  //####################
  // Priority Arbiter 5
  //####################
  rr_arbiter #(
    .NUMIN    (2),
    .DATATYPE (r_channel_t),
    .EXT_PRI  (1'b1)
  ) pr_arb5 (
    .clk           (clk),
    .rst_n         (rst_n),
    .pri           ({1'b0,prio}),
    .valid_req     (pr_arb5_vld),
    .in_req_gnt    (pr_arb5_rdy),
    .reqs          (pr_arb5_req),
    .out_req_gnt   (iRReady),
    .req_gnt_valid (eRValid),
    .req_gnt       (eRChannel)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      resp_state_q  <= IDLE;
      burst_cntr_q  <= '1;
      b_chnl_hs_q   <= '0;
      r_chnl_hs_q   <= '0;
      r_chnl_resp_q <= '0;
      b_chnl_resp_q <= '0;
    end
    else begin
      resp_state_q  <= resp_state_n;
      burst_cntr_q  <= burst_cntr_n;
      b_chnl_hs_q   <= eBReady && iBValid;
      r_chnl_hs_q   <= eRReady && iRValid;
      r_chnl_resp_q <= iRChannel;
      b_chnl_resp_q <= iBChannel;
    end
  end

endmodule