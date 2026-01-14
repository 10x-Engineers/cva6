  `define MST_RSP_MGR iopmp_dut.mst_resp_mgr

  import iopmp_axi_pkg::*;

  //---------------------Interface Level Assertions--------------------------------------------------


  //---------------------Block Level Coverproperties--------------------------------------------------

  // 01. Cover Property: Cover that Tag is cleared from Error RSP Buffer
  cover_mrsp_tag_clr_err_rsp: cover property (
  @(posedge clk) (`MST_RSP_MGR.iBReady && `MST_RSP_MGR.eBValid  |-> `MST_RSP_MGR.pr_arb4_rdy[0])
  );

  // 02. Cover Property: Cover that Tag is cleared from Slave response
  cover_mrsp_tag_clr_b_rsp: cover property (
  @(posedge clk) (`MST_RSP_MGR.iBReady && `MST_RSP_MGR.eBValid |-> !`MST_RSP_MGR.pr_arb4_rdy[0])
  );

  // 03. Cover Property: Cover that B Channel has highest priority
  cover_mrsp_b_rsp_hi_pri: cover property (
  @(posedge clk) ((`MST_RSP_MGR.pr_arb4_vld == 2'b11) |-> `MST_RSP_MGR.pr_arb4_rdy[1])
  );

  // 04. Cover Property: Cover that Slave R Channel has highest priority
  cover_mrsp_r_rsp_hi_pri: cover property (
  @(posedge clk) ((`MST_RSP_MGR.pr_arb5_vld == 2'b11) |-> `MST_RSP_MGR.pr_arb5_rdy[1])
  );

  // 05. Cover Property: Lowered slave read channel priority while read error burst is active
  cover_mrsp_rerr_rsp_hi_pri: cover property (
  @(posedge clk) (`MST_RSP_MGR.pr_arb5_vld == 2'b11 |-> `MST_RSP_MGR.pr_arb5_rdy[0])
  );

  // 06. Cover Property: Cover that 16 beats of read response is generated from IOPMP to Master
  cover_mrsp_max_rlen: cover property (
  @(posedge clk) (`MST_RSP_MGR.burst_trnsfr |-> `MST_RSP_MGR.rd_trnsfr_len == 15)
  );

  // 07. Cover Property: Cover that MSI Okay response is received
  cover_mrsp_msi_oky_rsp_rcvd: cover property (
  @(posedge clk) (`MST_RSP_MGR.mrspm_eic_valid |-> `MST_RSP_MGR.mrspm_eic_trans)
  );

  // 08. Cover Property: Cover that MSI error response is received
  cover_mrsp_msi_err_rsp_rcvd: cover property (
  @(posedge clk) (`MST_RSP_MGR.mrspm_eic_valid |-> !`MST_RSP_MGR.mrspm_eic_trans)
  );
