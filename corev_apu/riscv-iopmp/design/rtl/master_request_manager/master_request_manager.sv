///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Gull Ahmed <gull.ahmed@10xengineers.ai>
/// Date Created: 28-April-2025
/// Description: This block manages the incoming requests coming over AXI4
/// Interface. AXI4 uses independent read and write channels to send read/
/// write requests simultaneously. Master Request Manager stores incoming
/// data transactions into respective buffer and forward the read address and
/// write address transactions down towards the execution pipeline for further
/// processsing.
///////////////////////////////////////////////////////////////////////////

module master_request_manager
  import config_iopmp_pkg::MAX_TRANS;
  import config_iopmp_pkg::RRID_NUM;
  import config_iopmp_pkg::MAX_BURST_LEN;
  import iopmp_axi_pkg::aw_channel_t;
  import iopmp_axi_pkg::ar_channel_t;
  import iopmp_axi_pkg::w_channel_t;
  import iopmp_axi_pkg::transaction_t;
  import execution_pipeline_pkg::operation_e;
  import execution_pipeline_pkg::SEARCH;
  import execution_pipeline_pkg::NOP;
  import rfm_pkg::change_state_e;
  import rfm_pkg::FORWARD;
  import rfm_pkg::BACKWARD;
  #(
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
)(
  input  logic                             clk,
  input  logic                             rst_n,

  // Receiver Interface Write Address Channel
  input  logic                             iAwValid,
  input  aw_channel_t                      iAwChannel,
  output logic                             eAwReady,

  // Receiver Interface Read Address Channel
  input  logic                             iArValid,
  input  ar_channel_t                      iArChannel,
  output logic                             eArReady,

  // Receiver Interface Write Data Channel
  input  logic                             iWrValid,
  input  w_channel_t                       iWrChannel,
  output logic                             eWrReady,

  // Master Request Manager <==> Register File Manager
  input  logic [RRID_NUM-1 : 0]            rrid_stall,           // RRID_STALL[s] Register Indicates about stalled RRID's
  input  change_state_e                    change_state,         // IOPMP State Machine transitions depends on this signal

  // Master Request Manager <==> Slave Request Manager
  input  logic [MAX_BURST_LEN-1:0]         mst_wd_buf_rden,      // Read enable vector for Master Write Data Buffer (1-bit per burst beat)
  input  logic [$clog2(MAX_TRANS)-1:0]     mst_wd_buf_raddr,     // Transaction-level address to select which buffer entry to access
  input  logic [$clog2(MAX_BURST_LEN)-1:0] mst_wd_buf_rd_index,  // Beat-level index within the selected transaction (0 to MAX_BURST_LEN-1)
  output w_channel_t                       mst_wd_buf_data,      // Output read data from selected way/index of the Master Write Data Buffer
  output logic                             mst_wd_buf_vld,       // Output valid indicating read data is valid

  // Master Request Manager <==> Master Response Manager
  input  logic                             clr_tag,              // When Set, the tag in tag_in register will be cleared
  input  logic [$clog2(MAX_TRANS)-1:0]     tag_in,               // The tag to be cleared

  // Master Request Manager <==> Table Traversal Unit
  output operation_e                       rap_operation,        // Operations to be performed in Table Traversal Unit
  output transaction_t                     axi_ttu_trans         // Transaction Required in Table Traversal Unit
);

  //------------------------------------
  // Internal Signals Declarations
  //------------------------------------

  //--------------------------------------------------------------------------
  // To Flop Incoming Transactions
  //--------------------------------------------------------------------------
  transaction_t wr_trans_buf_wr_data_q, trans_wr_n;   // Write transaction buffer and next value
  transaction_t rd_trans_buf_wr_data_q, trans_rd_n;   // Read transaction buffer and next value
  w_channel_t   mst_wd_buf_wr_data_q, wr_data_n;      // Write data buffer and next value

  //--------------------------------------------------------------------------
  // Handshake indicators and their next-state values
  //--------------------------------------------------------------------------
  logic         w_chnl_hs_q;            // W channel Handshake
  logic         aw_chnl_hs_q;           // AW Channel Handshake
  logic         ar_chnl_hs_q;           // AR Channel Handshake

  //--------------------------------------------------------------------------
  // Read Transaction Buffer Control Signals
  //--------------------------------------------------------------------------
  logic         rd_trans_buf_rd_en;     // Read enable
  logic         rd_trans_buf_full;      // Full status
  logic         rd_trans_buf_empty;     // Empty status
  transaction_t rd_trans_buf_rd_data;   // Output data

  //--------------------------------------------------------------------------
  // Write Transaction Buffer Control Signals
  //--------------------------------------------------------------------------
  logic         wr_trans_buf_rd_en;     // Read enable
  logic         wr_trans_buf_full;      // Full status
  logic         wr_trans_buf_empty;     // Empty status
  logic         wr_buf_can_accept;      // Buffer ready to accept new request
  transaction_t wr_trans_buf_rd_data;   // Output data

  //--------------------------------------------------------------------------
  // Stall Buffer Control Signals
  //--------------------------------------------------------------------------
  logic         stall_buf_wr_en;        // Write enable
  logic         stall_buf_rd_en;        // Read enable
  logic         stall_buf_full;         // Full status
  logic         stall_buf_empty;        // Empty status
  logic         stall_buf_data_vld;     // Output valid
  transaction_t stall_buf_rd_data;      // Output data

  //--------------------------------------------------------------------------
  // RR_Arbiter1 (Round-Robin) Control Signals
  //--------------------------------------------------------------------------
  logic         [1:0] rr_arb1_rdy;      // Ready from arbiter outputs
  logic         [1:0] rr_arb1_vld;      // Valid inputs to arbiter
  transaction_t [1:0] rr_arb1_req;      // Request payloads
  logic               arb1_arb2_vld;    // Valid output from RR to PR arbiter
  logic               rr_arb1_gnt_i;    // Grant indication
  transaction_t       arb1_arb2_trans;  // Selected transaction output

  //--------------------------------------------------------------------------
  // PR_Arbiter2 (Priority) Control Signals
  //--------------------------------------------------------------------------
  logic         [1:0] pr_arb2_rdy;      // Ready from arbiter outputs
  logic         [1:0] pr_arb2_vld;      // Valid inputs to arbiter
  transaction_t [1:0] pr_arb2_req;      // Request payloads
  logic               pr_arb2_req_o;    // Output valid
  transaction_t       pr_arb2_data_o;   // Transaction Required in Table Traversal Unit

  //--------------------------------------------------------------------------
  // IOPMP State Machine
  //--------------------------------------------------------------------------
  enum logic [1:0] {
    NORMAL = 2'b00,
    HOLD   = 2'b01,
    STALL  = 2'b10
  } iopmp_state_q, iopmp_state_n;
  logic rrid_is_stalled;                             // Indicates the current RRID is Stalled

  //--------------------------------------------------------------------------
  // Tag Generator Control Signals
  //--------------------------------------------------------------------------
  logic                         gen_tag;  // Trigger to generate a new tag
  logic [$clog2(MAX_TRANS)-1:0] wd_tag;   // Generated tag for write data tracking

  //--------------------------------------------------------------------------
  // Master WD Buffer Control Signals
  //--------------------------------------------------------------------------
  logic       [MAX_BURST_LEN-1:0] mst_wd_buf_wr_en;  // Write enable per beat
  w_channel_t [MAX_BURST_LEN-1:0] rdata;             // Write data per beat
  logic       [MAX_BURST_LEN-1:0] rdata_vld;         // Data valid per beat
  logic       [3:0]               wr_beat_cntr_n;    // Next write burst beat count
  logic       [3:0]               wr_beat_cntr_q;    // Current write burst beat count
  logic                           is_data_pndng_n;   // Next data pending flag
  logic                           is_data_pndng_q;   // Current data pending flag
  logic		  		                  wr_beat_valid;

  //########################################################################
  //          Transaction Flopping and Ready Signal Generation
  //
  // This logic handles the handshake and data capture for incoming
  // AXI4 Read and Write transactions. It performs two main functions:
  //
  // 1. Ready Signal Generation:
  //    - Controls when the module can accept transactions on the
  //      AXI write and read channels based on internal buffer status.
  //    - Ensures that both the write address and write data channels
  //      are valid in the same cycle before accepting a write.
  //
  // 2. Transaction Capture (Flopping):
  //    - Captures AXI Write Address and Write Data into internal signals
  //    - Captures AXI Read Address transactions similarly
  //    - Extracts relevant fields from each channel and packs them into
  //      internal transaction structures used by the IOPMP.
  //
  // Note:
  // - Write transaction 'w' bit is derived from AW_PROT[2].
  // - Read transaction 'r' and 'x' bits are derived from AR_PROT[2].
  // - The 11-bit `rrid` is constructed from {WD_Tag, AWUSER} for write.
  //########################################################################

  //--------------------------------------------------------------------------
  // Ready generation logic for AXI Write Channels
  //--------------------------------------------------------------------------

  // Write buffer can accept a new transaction if it's not full and both AW and W are valid
  assign wr_buf_can_accept = !wr_trans_buf_full && iAwValid && iWrValid;

  // AW channel is ready only if the buffer can accept and no pending write data
  assign eAwReady          = wr_buf_can_accept && !is_data_pndng_n;

  // W channel is ready if there's pending data to send or buffer can accept a new transaction
  assign eWrReady          = is_data_pndng_n || wr_buf_can_accept;

  // Ready for Read Address Channel
  assign eArReady          = !rd_trans_buf_full;

  // Flop transaction from Write Address channel
  assign trans_wr_n = '{
    id      : iAwChannel.aw_id,
    addr    : iAwChannel.aw_addr,
    len     : iAwChannel.aw_len[$clog2(MAX_BURST_LEN)-1:0],
    size    : iAwChannel.aw_size[1:0],
    burst   : iAwChannel.aw_burst[0],
    r       : 1'b0,
    w       : ~iAwChannel.aw_prot[2],        // AW_PROT[2] = 0 means Data Access
    x       : 1'b0,
    axlock  : iAwChannel.aw_lock,            // Store this bit, to be forwarded to Slave
    rrid    : {wd_tag, iAwChannel.aw_user}   // 11 bits {WD_Tag(5bits),RRID(6bits)}
  };

  // Flop transaction from Write Data Channel
  assign wr_data_n = iWrChannel;

  // Flop transaction from Read Address channel
  assign trans_rd_n = '{
    id      : iArChannel.ar_id,
    addr    : iArChannel.ar_addr,
    len     : iArChannel.ar_len[$clog2(MAX_BURST_LEN)-1:0],
    size    : iArChannel.ar_size[1:0],
    burst   : iArChannel.ar_burst[0],
    r       : ~iArChannel.ar_prot[2],       // AR_PROT[2] = 0 means Data Access
    w       : 1'b0,
    x       : iArChannel.ar_prot[2],        // AR_PROT[2] = 1 means Instruction Fetch Access
    axlock  : iArChannel.ar_lock,           // Store this bit, to be forwarded to Slave
    rrid    : {5'd0, iArChannel.ar_user}
  };

  //#########################################################################
  // Master Request Buffers
  //
  //    This section generates the control signals for write enables of
  //    the Master_Read_Trans Buffer and Master_Write_Trans Buffer.
  //
  //    These control signals depend on registered versions of valid/ready
  //    handshakes and buffer status flags.
  //
  //    Note: The IOPMP requires the write address and write data channels
  //    to be valid in the same clock cycle for all write transactions.
  //#########################################################################

  iopmp_fifo #(
    .FALL_THROUGH (1),
    .DATA_WIDTH ($bits(transaction_t)),
    .DEPTH      (MAX_TRANS)
  ) MasterRdTransBuf (
    .clk_i      (clk),
    .rst_ni     (rst_n),
    .full_o     (rd_trans_buf_full),
    .empty_o    (rd_trans_buf_empty),
    .data_i     (rd_trans_buf_wr_data_q),
    .push_i     (ar_chnl_hs_q),             // Push into buffer when AR handshakes happen
    .data_o     (rd_trans_buf_rd_data),
    .pop_i      (rd_trans_buf_rd_en)
  );

  iopmp_fifo #(
    .FALL_THROUGH (1),
    .DATA_WIDTH ($bits(transaction_t)),
    .DEPTH      (MAX_TRANS)
  ) MasterWrTransBuf (
    .clk_i      (clk),
    .rst_ni     (rst_n),
    .full_o     (wr_trans_buf_full),
    .empty_o    (wr_trans_buf_empty),
    .data_i     ({wr_trans_buf_wr_data_q[$bits(transaction_t)-1:11],wd_tag,wr_trans_buf_wr_data_q.rrid[5:0]}),
    .push_i     (w_chnl_hs_q && aw_chnl_hs_q), // Push into buffer when both AW and W handshakes happen together (first beat)
    .data_o     (wr_trans_buf_rd_data),
    .pop_i      (wr_trans_buf_rd_en)
  );

  //--------------------------------------------------------------------------
  // Write Data into Master_WD_Buffer and generate Tag
  //--------------------------------------------------------------------------

  // A valid write beat occurs either:
  // - when both AW and W handshakes happen together (first beat)
  // - or when W handshake occurs and more data is pending (subsequent beats)
  assign wr_beat_valid = w_chnl_hs_q && (aw_chnl_hs_q || is_data_pndng_q);

  // One-hot write enable for Master_WD_Buffer based on current burst beat count
  // e.g mst_wd_buf_wr_en = wr_beat_valid ? 16'h1 << wr_beat_cntr_q : '0
  assign mst_wd_buf_wr_en = ('b1 << wr_beat_cntr_q) & {MAX_BURST_LEN{wr_beat_valid}};

  // Generate new tag when the last beat of a burst is valid
  assign gen_tag = wr_beat_valid & mst_wd_buf_wr_data_q.w_last;

  // Indicates if more write data is pending after this beat
  assign is_data_pndng_n = wr_beat_valid ? !mst_wd_buf_wr_data_q.w_last : is_data_pndng_q;

  // Write beat counter: increment on valid beat, reset on last, otherwise hold
  assign wr_beat_cntr_n = wr_beat_valid ?
                          (mst_wd_buf_wr_data_q.w_last ? '0 : wr_beat_cntr_q + 4'h1) :
                          wr_beat_cntr_q;

  //-----------------------------------
  // Read Data From Master_WD_Buffer
  //-----------------------------------
  // assign mst_wd_buf_data = rdata[mst_wd_buf_rd_index];     // Select read data at specified beat index
  // assign mst_wd_buf_vld  = rdata_vld[mst_wd_buf_rd_index]; // Valid bit for selected beat
  logic [MAX_BURST_LEN-1 : 0] read_vec;
  logic [RRID_NUM-1 : 0] read_vec1;

  always_comb begin : read_mst_wd_buf
    mst_wd_buf_data = '0;
    mst_wd_buf_vld  = '0;
    read_vec        = 'b1 << mst_wd_buf_rd_index;

    for (int i = 0; i < MAX_BURST_LEN; i++) begin
      mst_wd_buf_data |= read_vec[i] ? rdata[i]     : '0;
      mst_wd_buf_vld  |= read_vec[i] ? rdata_vld[i] : '0;
    end
  end

  //------------------------------------------------------------------------------
  //             Master Write Data Buffer and Valid Bit Management
  //
  // - Generates number of MAX_BURST_LEN buffers (one per beat)
  // - Each buffer stores W channel data per transaction (indexed by tag)
  // - Associated valid array tracks per-beat data validity
  //------------------------------------------------------------------------------

  for (genvar i = 0; i < MAX_BURST_LEN; i++) begin : gen_master_wd_buf

    // Memory to store W channel data for beat index 'i'
    mem1r1w #(
      .WIDTH($bits(w_channel_t)),
      .DEPTH(MAX_TRANS),
      .ADDR_W($clog2(MAX_TRANS))
    ) master_wd_buf (
      .clk    (clk),
      .rst_n  (rst_n),
      .wren   (mst_wd_buf_wr_en[i]),    // Write enable for this beat
      .rden   (mst_wd_buf_rden[i]),     // Read enable for this beat
      .waddr  (wd_tag),                 // Write tag (transaction index)
      .raddr  (mst_wd_buf_raddr),       // Read address (transaction index)
      .wdata  (mst_wd_buf_wr_data_q),   // Write data
      .rdata  (rdata[i]),                // Read data output
      .initd  ()
    );

    // Valid bit array for the corresponding beat index 'i'
    vld_array #(
      .WIDTH(1),
      .DEPTH(MAX_TRANS),
      .ADDR_W($clog2(MAX_TRANS))
    ) wd_vld (
      .clk     (clk),
      .rst_n   (rst_n),
      .wren_a  (mst_wd_buf_wr_en[i]),  // Set valid when data is written
      .wren_b  (clr_tag),              // Clear valid via external clear
      .waddr_a (wd_tag),               // Write address for set
      .waddr_b (tag_in),               // Write address for clear
      .raddr   (mst_wd_buf_raddr),     // Read address
      .wdata_a (1'b1),                 // Set valid
      .wdata_b (1'b0),                 // Clear valid
      .rdata   (rdata_vld[i])          // Output valid bit
    );
  end

  //------------------------------------------------------------------------------
  //                        Write Tag Generator
  //
  // - Generates a tag (index) for storing a new write transaction
  // - Clears tag externally when transaction completes
  //------------------------------------------------------------------------------
  tag_gen #(
    .WIDTH(MAX_TRANS)
  ) wr_tag_gen (
    .clk     (clk),
    .rst_n   (rst_n),
    .gen_tag (gen_tag), // Trigger to generate new tag
    .clr_tag (clr_tag), // Trigger to clear completed tag
    .tag_in  (tag_in),  // Tag to be cleared
    .tag_out (wd_tag)   // Generated tag output
  );

  always_comb begin : rr_arb1_ctrl
    //----------------------------------------------------------------
    //                   Round Robin Arbiter 1
    //
    // - 2-input arbiter using round-robin selection policy
    // - Source 0: Read Transaction Buffer
    // - Source 1: Write Transaction Buffer
    // - Selects one transaction to forward to Priority Arbiter 2
    //----------------------------------------------------------------

    // Valid inputs to arbiter
    rr_arb1_vld[0] = !rd_trans_buf_empty;   // Source 0: Read Transaction Buffer
    rr_arb1_vld[1] = !wr_trans_buf_empty;   // Source 1: Write Transaction Buffer

    // Request data to arbiter
    rr_arb1_req[0] = rd_trans_buf_rd_data;  // Source 0 data
    rr_arb1_req[1] = wr_trans_buf_rd_data;  // Source 1 data

    // Read enables based on arbiter grant
    rd_trans_buf_rd_en = rr_arb1_rdy[0];    // Grant for Source 0
    wr_trans_buf_rd_en = rr_arb1_rdy[1];    // Grant for Source 1
  end

  // Round-Robin Arbiter Instance
  rr_arbiter #(
    .NUMIN     (2),                                         // Two request sources
    .DATATYPE  (transaction_t)                              // Struct type of transaction
  ) rr_arb1 (
    .clk           (clk),
    .rst_n         (rst_n),
    .pri           ('0),                                    // Static priority (default RR)
    .valid_req     (rr_arb1_vld),                           // Input valids
    .in_req_gnt    (rr_arb1_rdy),                           // Grant signals to sources
    .reqs          (rr_arb1_req),                           // Input transactions
    .out_req_gnt   (CFG.STALL_EN ? rr_arb1_gnt_i : 1'b1),   // Grant enable from downstream
    .req_gnt_valid (arb1_arb2_vld),                         // Output valid to next stage
    .req_gnt       (arb1_arb2_trans)                        // Selected transaction
  );

  if (CFG.STALL_EN) begin : gen_stall_logic
    //######################################################################################
    //                                IOPMP State Machine
    //
    // - Controls Priority Arbiter 2 and transaction flow to the execution pipeline
    //
    // States:
    //   NORMAL  : Forward transactions to execution pipeline; Stall Buffer has priority
    //   HOLD    : IOPMP is stalled; wait for transactions to complete in pipeline
    //   STALL   : Redirect stalled transactions to Stall Buffer; forward non-stalled
    //######################################################################################
    always_comb begin
      // Default assignments
      iopmp_state_n      = iopmp_state_q;
      pr_arb2_vld        = '0;
      pr_arb2_req[0]     = arb1_arb2_trans;       // From RR Arbiter 1
      pr_arb2_req[1]     = stall_buf_rd_data;     // From Stall Buffer
      rr_arb1_gnt_i      = '0;
      stall_buf_rd_en    = '0;
      stall_buf_wr_en    = '0;

      // Stall buffer has data if it's not empty and no RRID is stalled
      stall_buf_data_vld = !stall_buf_empty & !(|rrid_stall);

      // Check if current RRID is stalled
      // rrid_is_stalled = rrid_stall[arb1_arb2_trans.rrid];

      rrid_is_stalled = '0;
      read_vec1 = 'b1 << arb1_arb2_trans.rrid[5:0];
      for (int i = 0; i < RRID_NUM; i++)
        rrid_is_stalled |= read_vec1[i] ? rrid_stall[i] : '0;

      // State Machine
      case (iopmp_state_q)

        //--------------------------------------------------------------------------
        // NORMAL State: Regular pipeline operation
        // - Forward non-stalled transactions
        // - Prioritize Stall Buffer if it has valid data
        //--------------------------------------------------------------------------
        NORMAL: begin
          pr_arb2_vld[0]  = arb1_arb2_vld && stall_buf_empty;  // Forward RR_Arb1 only if Stall Buffer is empty
          pr_arb2_vld[1]  = stall_buf_data_vld;                // Forward from Stall Buffer if valid

          rr_arb1_gnt_i   = pr_arb2_rdy[0];                    // Grant to RR Arbiter if accepted
          stall_buf_rd_en = pr_arb2_rdy[1];                    // Read from Stall Buffer if accepted

          // Transition to HOLD when a stall condition is detected
          if (change_state == FORWARD)
            iopmp_state_n = HOLD;
        end

        //--------------------------------------------------------------------------
        // HOLD State: Wait for all transactions to exit pipeline
        // - Transition to STALL state once safe to resume
        //--------------------------------------------------------------------------
        HOLD: begin
          if (change_state == FORWARD)
            iopmp_state_n = STALL;
        end

        //--------------------------------------------------------------------------
        // STALL State: Handle incoming stalled transactions
        // - Store stalled transactions into Stall Buffer
        // - Forward non-stalled transactions directly
        //--------------------------------------------------------------------------
        STALL: begin
          stall_buf_wr_en = !stall_buf_full & rrid_is_stalled & arb1_arb2_vld; // Store if eligible
          pr_arb2_vld[0]  = arb1_arb2_vld & !rrid_is_stalled;                  // Forward only non-stalled
          rr_arb1_gnt_i   = stall_buf_wr_en || pr_arb2_rdy[0];                 // Grant if storing or accepted

          // Transition based on pipeline status
          iopmp_state_n = (change_state == FORWARD)  ? NORMAL :
                          (change_state == BACKWARD) ? HOLD   :
                                                      STALL;
        end
        default: ;
      endcase
    end

    //########################
    // Stall Buffer Instance
    //########################
    iopmp_fifo #(
      .FALL_THROUGH (1),
      .DATA_WIDTH ($bits(transaction_t)),
      .DEPTH      (MAX_TRANS*2)
    ) stall_buf (
      .clk_i      (clk),
      .rst_ni     (rst_n),
      .full_o     (stall_buf_full ),
      .empty_o    (stall_buf_empty),
      .data_i     (arb1_arb2_trans  ),
      .push_i     (stall_buf_wr_en  ),
      .data_o     (stall_buf_rd_data),
      .pop_i      (stall_buf_rd_en  )
    );

    //####################
    // Priority Arbiter 2
    //####################
    rr_arbiter #(
      .NUMIN    (2),
      .DATATYPE (transaction_t),
      .EXT_PRI  (1'b1)
    ) pr_arb2 (
      .clk           (clk),
      .rst_n         (rst_n),
      .pri           (2'b10),           // Stall Buffer has highest priority
      .valid_req     (pr_arb2_vld),
      .in_req_gnt    (pr_arb2_rdy),
      .reqs          (pr_arb2_req),
      .out_req_gnt   (1'b1),           // TTU is always Ready
      .req_gnt_valid (pr_arb2_req_o),  // REQ_O data is valid
      .req_gnt       (pr_arb2_data_o)  // Output Data
    );
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      iopmp_state_q          <= NORMAL;
      wr_trans_buf_wr_data_q <= '0;
      rd_trans_buf_wr_data_q <= '0;
      w_chnl_hs_q            <= '0;
      aw_chnl_hs_q           <= '0;
      ar_chnl_hs_q           <= '0;
      wr_beat_cntr_q         <= '0;
      mst_wd_buf_wr_data_q   <= '0;
      is_data_pndng_q        <= '0;
      rap_operation          <= NOP;
      axi_ttu_trans          <= '0;
    end
    else begin
      rd_trans_buf_wr_data_q <= trans_rd_n;
      wr_trans_buf_wr_data_q <= trans_wr_n;
      mst_wd_buf_wr_data_q   <= wr_data_n;
      w_chnl_hs_q            <= eWrReady && iWrValid;
      aw_chnl_hs_q           <= eAwReady && iAwValid;
      ar_chnl_hs_q           <= eArReady && iArValid;
      iopmp_state_q          <= iopmp_state_n;
      wr_beat_cntr_q         <= wr_beat_cntr_n;
      is_data_pndng_q        <= is_data_pndng_n;
      rap_operation          <= CFG.STALL_EN ? (pr_arb2_req_o ? SEARCH : NOP) : (arb1_arb2_vld ? SEARCH : NOP);
      axi_ttu_trans          <= CFG.STALL_EN ? pr_arb2_data_o : arb1_arb2_trans;
    end
  end

endmodule
