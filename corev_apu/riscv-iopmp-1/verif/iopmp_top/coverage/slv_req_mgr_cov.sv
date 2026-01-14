  `define SLV_REQ_MGR iopmp_dut.slave_req_mgr
  `define AXI_W_CNTRL iopmp_dut.slave_req_mgr.axi_write_chnl_controller

  import iopmp_axi_pkg::*;

  //---------------------Interface Level Assertions--------------------------------------------------


  //---------------------Block Level Coverproperties--------------------------------------------------

  // 01. Cover Property: Cover that Arbiter has given priority to MSI Buffer
  cover_slv_msi_buf_has_pri: cover property (
  @(posedge clk) ((`SLV_REQ_MGR.iAwReady && (`SLV_REQ_MGR.pr_arb3_vld == 2'b11))  |-> `SLV_REQ_MGR.msi_req_buf_rd_en)
  );

  // 03. Cover Property: Cover that AW HS is successful, MSI buffer contains valid data and no WDATA is pending
  cover_slv_aw_hs_stop_until_data_cmp_msi_buf: cover property (
  @(posedge clk) ((`AXI_W_CNTRL.aw_chnl_hs_done_q && `SLV_REQ_MGR.pr_arb3_vld[0]) |-> `SLV_REQ_MGR.msi_req_buf_rd_en)
  );

  // 04. Cover Property: Cover that AW HS is pending, MSI buffer contains valid data, W HS is successful, so AW Valid should be high until HS
  cover_slv_w_hs_no_aw_hs_msi: cover property (
  @(posedge clk) ((!`AXI_W_CNTRL.aw_chnl_hs_done_q && `SLV_REQ_MGR.pr_arb3_vld[0]) |-> `SLV_REQ_MGR.msi_req_buf_rd_en)
  );

  // 05. Cover Property: Cover that AW HS is successful, WR_ERR buffer contains valid data and no WDATA is pending
  cover_slv_aw_hs_stop_until_data_cmp_mst_buf: cover property (
  @(posedge clk) ((`AXI_W_CNTRL.aw_chnl_hs_done_q && `SLV_REQ_MGR.pr_arb3_vld[1]) |-> `SLV_REQ_MGR.mst_wrreq_buf_rd_en)
  );

  // 06. Cover Property: Cover that AW HS is pending, WR_ERR buffer contains valid data, W HS is successful, so AW Valid should be high until HS
  cover_slv_w_hs_no_aw_hs_mst: cover property (
  @(posedge clk) ((!`AXI_W_CNTRL.aw_chnl_hs_done_q && `SLV_REQ_MGR.pr_arb3_vld[1]) |-> `SLV_REQ_MGR.mst_wrreq_buf_rd_en)
  );

  // 07. Cover Property: Cover that MSI Write Request is sent from Slave request Manager
  cover_slv_msi_req_idle: cover property (
  @(posedge clk) (`SLV_REQ_MGR.eAwValid && `AXI_W_CNTRL.msi_vld && (`AXI_W_CNTRL.axi_wr_state == `AXI_W_CNTRL.IDLE) |-> `SLV_REQ_MGR.eWrValid)
  );

  // 08. Cover Property: Cover that Non-MSI Write Request is sent from Slave request Manager
  cover_slv_mst_req_idle: cover property (
  @(posedge clk) (`SLV_REQ_MGR.eAwValid && `SLV_REQ_MGR.mst_wd_buf_vld && (`AXI_W_CNTRL.axi_wr_state == `AXI_W_CNTRL.IDLE) |-> `SLV_REQ_MGR.eWrValid)
  );

  // 09. Cover Property: Cover that due to no W HS in IDLE state, MSI request is sent from WAIT_W_HS state
  cover_slv_msi_req_W_HS: cover property (
  @(posedge clk) (`AXI_W_CNTRL.msi_req_q && (`AXI_W_CNTRL.axi_wr_state == `AXI_W_CNTRL.WAIT_W_HS) |-> `SLV_REQ_MGR.eWrValid)
  );

  // 10. Cover Property: Cover that due to no W HS in IDLE state, Non-MSI request is sent from WAIT_W_HS state
  cover_slv_no_W_HS: cover property (
  @(posedge clk) (`SLV_REQ_MGR.mst_wd_buf_vld && (`AXI_W_CNTRL.axi_wr_state == `AXI_W_CNTRL.WAIT_W_HS) |-> `SLV_REQ_MGR.eWrValid)
  );

  // 11. Cover Property: Cover that AW_HS is successful after Data Transfer is completed
  cover_slv_AW_HS_after_data_trnsfr: cover property (
  @(posedge clk) (!`AXI_W_CNTRL.last_transfer && `AXI_W_CNTRL.is_wd_buf_data_pndg_q && (`AXI_W_CNTRL.axi_wr_state == `AXI_W_CNTRL.WAIT_AW_HS) |-> `AXI_W_CNTRL.aw_chnl_hs)
  );

  // 12. Cover Property: Cover that AW_HS is successful before Data Transfer is completed
  cover_slv_AW_HS_before_data_trnsfr: cover property (
  @(posedge clk) (!`AXI_W_CNTRL.is_wd_buf_data_pndg_q && (`AXI_W_CNTRL.axi_wr_state == `AXI_W_CNTRL.WAIT_AW_HS) |-> `AXI_W_CNTRL.aw_chnl_hs)
  );

  // 13. Cover Property: Cover that MSI data is sent in Upper strobe
  cover_slv_msi_req_upr_strb: cover property (
  @(posedge clk) (`SLV_REQ_MGR.eAwValid && `AXI_W_CNTRL.msi_vld && `AXI_W_CNTRL.awaddr2 |-> `SLV_REQ_MGR.eWrValid)
  );

  // 13. Cover Property: Cover that MSI data is sent in Lower strobe
  cover_slv_msi_req_lwr_strb: cover property (
  @(posedge clk) (`SLV_REQ_MGR.eAwValid && `AXI_W_CNTRL.msi_vld && !`AXI_W_CNTRL.awaddr2 |-> `SLV_REQ_MGR.eWrValid)
  );


