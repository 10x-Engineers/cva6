  `define MST_REQ_MGR iopmp_dut.master_req_mgr

  import iopmp_axi_pkg::*;

  //---------------------Interface Level Assertions--------------------------------------------------

  // 01. Assertion:
  assert_aw_size: assert property (
    @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eAwReady && `MST_REQ_MGR.iAwValid |-> !`MST_REQ_MGR.iAwChannel.aw_size[2])
    else $fatal (1, "Assertion Failed: aw_size greater than 3 is not supported");

  // 02. Assertion:
  assert_aw_len: assert property (
    @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eAwReady && `MST_REQ_MGR.iAwValid |-> `MST_REQ_MGR.iAwChannel.aw_len[7:4] == '0)
    else $fatal (1, "Assertion Failed: aw_len greater than 16 is not supported");

  // 03. Assertion:
  assert_aw_burst: assert property (
    @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eAwReady && `MST_REQ_MGR.iAwValid |-> !`MST_REQ_MGR.iAwChannel.aw_burst[1])
    else $fatal (1, "Assertion Failed: aw_burst should be either FIXED or INCR");

//   // 04. Assertion:
//   assert_aw_cache: assert property (
//     @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eAwReady && `MST_REQ_MGR.iAwValid |-> `MST_REQ_MGR.iAwChannel.aw_cache == '0)
//     else $fatal (1, "Assertion Failed: Device Non-bufferable Type is Supported");

  // 05. Assertion:
  assert_aw_prot: assert property (
  @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eAwReady && `MST_REQ_MGR.iAwValid |-> `MST_REQ_MGR.iAwChannel.aw_prot == '0)
  else $fatal (1, "Assertion Failed: Secure and Unpriviledge access is Supported");

  // 06. Assertion:
  assert_aw_qos: assert property (
  @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eAwReady && `MST_REQ_MGR.iAwValid |-> `MST_REQ_MGR.iAwChannel.aw_qos == '0)
  else $fatal (1, "Assertion Failed: QoS is not Supported");

  // 07. Assertion:
  assert_aw_region: assert property (
    @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eAwReady && `MST_REQ_MGR.iAwValid |-> `MST_REQ_MGR.iAwChannel.aw_region == '0)
    else $fatal (1, "Assertion Failed: Multiple region interface is not Supported");

  // 08. Assertion:
  assert_ar_size: assert property (
    @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eArReady && `MST_REQ_MGR.iArValid |-> !`MST_REQ_MGR.iArChannel.ar_size[2])
    else $fatal (1, "Assertion Failed: ar_size greater than 3 is not supported");

  // 09. Assertion:
  assert_ar_len: assert property (
    @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eArReady && `MST_REQ_MGR.iArValid |-> `MST_REQ_MGR.iArChannel.ar_len[7:4] == '0)
    else $fatal (1, "Assertion Failed: ar_len greater than 16 is not supported");

  // 10. Assertion:
  assert_ar_burst: assert property (
    @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eArReady && `MST_REQ_MGR.iArValid |-> !`MST_REQ_MGR.iArChannel.ar_burst[1])
    else $fatal (1, "Assertion Failed: ar_burst should be either FIXED or INCR");

//   // 11. Assertion:
//   assert_ar_cache: assert property (
//     @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eArReady && `MST_REQ_MGR.iArValid |-> `MST_REQ_MGR.iArChannel.ar_cache == '0)
//     else $fatal (1, "Assertion Failed: Only Device Non-bufferable Type is Supported");

  // 12. Assertion:
  assert_ar_prot: assert property (
  @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eArReady && `MST_REQ_MGR.iArValid |-> `MST_REQ_MGR.iArChannel.ar_prot[1:0] == '0)
  else $fatal (1, "Assertion Failed: Secure and Unpriviledge access is Supported");

  // 13. Assertion:
  assert_ar_qos: assert property (
  @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eArReady && `MST_REQ_MGR.iArValid |-> `MST_REQ_MGR.iArChannel.ar_qos == '0)
  else $fatal (1, "Assertion Failed: QoS is not Supported");

  // 14. Assertion:
  assert_ar_region: assert property (
    @(posedge clk) disable iff (~`MST_REQ_MGR.rst_n) `MST_REQ_MGR.eArReady && `MST_REQ_MGR.iArValid |-> `MST_REQ_MGR.iArChannel.ar_region == '0)
    else $fatal (1, "Assertion Failed: Multiple region interface is not Supported");

    //---------------------Block Level Coverproperties--------------------------------------------------

    // 01. Cover Property: Cover that the write handshake happens correctly after ready-valid in the previous cycle
    cover_mst_w_chnl_hs: cover property (
    @(posedge clk) ((`MST_REQ_MGR.eWrReady && `MST_REQ_MGR.iWrValid) |=> `MST_REQ_MGR.w_chnl_hs_q)
    );

    // 02. Cover Property: Cover that the read handshake happens correctly after ready-valid in the previous cycle
    cover_mst_ar_chnl_hs: cover property (
    @(posedge clk) ((`MST_REQ_MGR.eArReady && `MST_REQ_MGR.iArValid) |=> `MST_REQ_MGR.ar_chnl_hs_q)
    );

    // 03. Cover Property: when both AW and W handshakes happen together (first beat)
    cover_mst_aw_w_chnl_hs: cover property (
    @(posedge clk) ((`MST_REQ_MGR.w_chnl_hs_q && `MST_REQ_MGR.aw_chnl_hs_q) |-> `MST_REQ_MGR.wr_beat_valid)
    );

    // 04. Cover Property: when W handshake occurs and more data is pending (subsequent beats)
    cover_mst_w_chnl_sbsqnt_beats: cover property (
    @(posedge clk) ((`MST_REQ_MGR.w_chnl_hs_q && `MST_REQ_MGR.is_data_pndng_q) |-> `MST_REQ_MGR.wr_beat_valid)
    );

    // 05. Cover Property: 15 beats of data received
    cover_mst_w_chnl_max_beats: cover property (
    @(posedge clk) ((`MST_REQ_MGR.wr_beat_valid ) |-> `MST_REQ_MGR.wr_beat_cntr_q == 15)
    );

    // 06. Cover Property: Forward RR_Arb1 only if Stall Buffer is empty
    cover_mst_frwrd_cmng_trans: cover property (
    @(posedge clk) (((`MST_REQ_MGR.iopmp_state_q == `MST_REQ_MGR.NORMAL) && `MST_REQ_MGR.pr_arb2_vld[0]) |-> `MST_REQ_MGR.rr_arb1_gnt_i)
    );

    // 07. Cover Property: Forward from Stall Buffer if valid
    cover_mst_frwrd_stalled_trans: cover property (
    @(posedge clk) (((`MST_REQ_MGR.iopmp_state_q == `MST_REQ_MGR.NORMAL) && `MST_REQ_MGR.pr_arb2_vld[1]) |-> `MST_REQ_MGR.stall_buf_rd_en)
    );

    // 08. Cover Property: Stall Buffer full in Stall State
    cover_mst_stall_buf_full: cover property (
    @(posedge clk) ((`MST_REQ_MGR.iopmp_state_q == `MST_REQ_MGR.STALL) |-> `MST_REQ_MGR.stall_buf_full)
    );

    // 09. Cover Property: Cover that Read and Write Channels request received in same cycle
    cover_mst_two_reqs_same_time: cover property (
    @(posedge clk) (`MST_REQ_MGR.ar_chnl_hs_q |-> `MST_REQ_MGR.w_chnl_hs_q)
    );

    // 10. Cover Property: Cover that Read channel burst length is set to 15
    cover_mst_rd_chnl_max_brst_len: cover property (
    @(posedge clk) (`MST_REQ_MGR.ar_chnl_hs_q |-> `MST_REQ_MGR.rd_trans_buf_wr_data_q.len == 15)
    );


