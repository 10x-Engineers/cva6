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
/// Description:
///////////////////////////////////////////////////////////////////////////

module iopmp
  import config_iopmp_pkg::MAX_BURST_LEN;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;
  import config_iopmp_pkg::MAX_TRANS;
#(
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                    clk,
  input  logic                    rst_n,

  // Address Write Channel
  input  logic                    iAwValid,
  input  iopmp_axi_pkg::aw_channel_t    iAwChannel,
  output logic                    eAwReady,

  // Address Read Channel
  input  logic                    iArValid,
  input  iopmp_axi_pkg::ar_channel_t    iArChannel,
  output logic                    eArReady,

  // Write Channel
  input  logic                    iWrValid,
  input  iopmp_axi_pkg::w_channel_t     iWrChannel,
  output logic                    eWrReady,

  // Write Response Channel
  input  logic                    iBReady,
  output logic                    eBValid,
  output iopmp_axi_pkg::b_channel_t     eBChannel,

  // Read Response Channel
  input  logic                    iRReady,
  output logic                    eRValid,
  output iopmp_axi_pkg::r_channel_t     eRChannel,

  // Slave Address Write Channel
  input  logic                    iAwReady,
  output logic                    eAwValid,
  output iopmp_axi_pkg::slv_aw_channel_t eAwChannel,

  // Slave Address Read Channel
  input  logic                    iArReady,
  output logic                    eArValid,
  output iopmp_axi_pkg::ar_channel_t    eArChannel,

  // Slave Write Channel
  input  logic                    iWrReady,
  output logic                    eWrValid,
  output iopmp_axi_pkg::w_channel_t     eWrChannel,

  // Slave Read Response Channel
  input  logic                    iRValid,
  input  iopmp_axi_pkg::r_channel_t     iRChannel,
  output logic                    eRReady,

  // Slave Write Response Channel
  input  logic                    iBValid,
  input  iopmp_axi_pkg::slv_b_channel_t iBChannel,
  output logic                    eBReady,

  // Ahb Request/Response Channel
  input  ahb_lite_pkg::ahb_req_t  ahb_req,
  output ahb_lite_pkg::ahb_resp_t ahb_resp,

  // WSI - Wire-signaled-interrupt
  output logic                    wsi
);

  logic [CFG.RRID_NUM-1:0]             rrid_stall;
  iopmp_axi_pkg::transaction_t               axi_ttu_trans, transaction_o, rap_eic_trans;
  logic                                rap_rd_err_valid;
  iopmp_axi_pkg::r_channel_t                 rap_rd_err_req;
  logic                                rap_wr_err_valid;
  iopmp_axi_pkg::slv_b_channel_t             rap_wr_err_req;
  logic                                rap_rd_valid;
  iopmp_axi_pkg::ar_channel_t                rap_rd_req;
  logic                                rap_wr_valid;
  iopmp_axi_pkg::slv_aw_channel_t            rap_wr_trans;
  logic [$clog2(MAX_BURST_LEN)-1:0]    ar_len;
  logic [10:0]                         msi_data;
  rfm_pkg::change_state_e              change_state;
  execution_pipeline_pkg::errorType_t  ttu_rap_err_info;
  logic [CFG.ENTRY_NUM-1:0]            entrypresent_or;
  logic [CFG.ENTRY_NUM-1:0][1:0]       mdrwperm_repl;
  rfm_pkg::rfm_ttu_t                   rfm_ttu;
  rfm_pkg::rfm_rap_t                   rfm_rap;
  execution_pipeline_pkg::operation_e  ttu_rapo, rap_operation;
  logic [AXI_ADDR_WIDTH-1:0]           trans_end_addr;      // Transaction end Address
  rfm_pkg::eic_rfm_t                   eic_rfm;
  rfm_pkg::rfm_eic_t                   rfm_eic;
  logic                                rap_eic_valid;
  execution_pipeline_pkg::error_info_t rap_eic_error_info;
  logic                                eic_rfm_valid;
  logic [5:0]                          eic_rfm_err_rrid;
  logic                                mrspm_eic_valid, mrspm_eic_trans;
  logic                                eic_msi_valid;
  iopmp_axi_pkg::slv_aw_channel_t            eic_msi_trans;

  // Slave Request Manager <==> Master Request Manager
  logic [MAX_BURST_LEN-1:0]         rden;
  logic [$clog2(MAX_TRANS)-1:0]     raddr;
  logic [$clog2(MAX_BURST_LEN)-1:0] mst_wd_index;
  iopmp_axi_pkg::w_channel_t              mst_wd_data;
  logic                             mst_wd_data_vld;

  // Master Response Manager <==> Master Request Manager
  logic                         clr_tag;
  logic [$clog2(MAX_TRANS)-1:0] tag_in;

  master_req_mgr master_req_mgr
  (
    .clk            (clk),
    .rst_n          (rst_n),

    // Address Write Channel
    .iAwValid       (iAwValid),
    .iAwChannel     (iAwChannel),
    .eAwReady       (eAwReady),

    // Address Read Channel
    .iArValid       (iArValid),
    .iArChannel     (iArChannel),
    .eArReady       (eArReady),

    // Write Channel
    .iWrValid       (iWrValid),
    .iWrChannel     (iWrChannel),
    .eWrReady       (eWrReady),

    .rrid_stall     (rrid_stall),
    .change_state   (change_state),

    // Slave Request Manager <==> Master Request Manager
    .mst_wd_buf_rden     (rden),
    .mst_wd_buf_raddr    (raddr),
    .mst_wd_buf_rd_index (mst_wd_index),
    .mst_wd_buf_data     (mst_wd_data),
    .mst_wd_buf_vld      (mst_wd_data_vld),

    // Master Response Manager <==> Master Request Manager
    .clr_tag        (clr_tag),
    .tag_in         (tag_in),

    // Arbiters Output
    .rap_operation  (rap_operation),
    .axi_ttu_trans  (axi_ttu_trans)
  );

  slave_req_mgr slave_req_mgr
  (
    .clk           (clk),
    .rst_n         (rst_n),

    // Address Write Channel
    .iAwReady      (iAwReady),
    .eAwValid      (eAwValid),
    .eAwChannel    (eAwChannel),

    // Address Read Channel
    .iArReady      (iArReady),
    .eArValid      (eArValid),
    .eArChannel    (eArChannel),

    // Write Channel
    .iWrReady      (iWrReady),
    .eWrValid      (eWrValid),
    .eWrChannel    (eWrChannel),

    // Slave Request Manager <==> Master Request Manager
    .mst_wd_buf_rden  (rden),
    .mst_wd_buf_raddr (raddr),
    .mst_wd_buf_rd_index (mst_wd_index),
    .mst_wd_buf_data  (mst_wd_data),
    .mst_wd_buf_vld   (mst_wd_data_vld),

    // Master RREQ Buffer
    .rap_rd_valid  (rap_rd_valid),
    .rap_rd_req    (rap_rd_req),

    // Master WREQ Buffer
    .rap_wr_valid  (rap_wr_valid),
    .rap_wr_trans  (rap_wr_trans),

    // MSI Request Buffer
    .eic_msi_valid (eic_msi_valid),
    .eic_msi_trans (eic_msi_trans),
    .msi_data      (msi_data)
  );

  mst_resp_mgr mst_resp_mgr
  (
    .clk             (clk),
    .rst_n           (rst_n),

    // RAP <==> Master Response Manager
    .rap_rd_err_valid (rap_rd_err_valid),
    .rap_rd_err_req   (rap_rd_err_req),
    .ar_len           (ar_len),

    // Master WREQ Buffer
    .rap_wr_err_valid (rap_wr_err_valid),
    .rap_wr_err_req   (rap_wr_err_req),

    // Write Response Channel
    .iBReady          (iBReady),
    .eBValid          (eBValid),
    .eBChannel        (eBChannel),

    // Read Response Channel
    .iRReady          (iRReady),
    .eRValid          (eRValid),
    .eRChannel        (eRChannel),

    // Slave Read Response Channel
    .eRReady          (eRReady),
    .iRValid          (iRValid),
    .iRChannel        (iRChannel),

    // Slave Write Response Channel
    .eBReady          (eBReady),
    .iBValid          (iBValid),
    .iBChannel        (iBChannel),

    // Master Response Manager <==> Master Request Manager
    .clr_tag          (clr_tag),
    .tag_in           (tag_in),

    .mrspm_eic_valid  (mrspm_eic_valid),
    .mrspm_eic_trans  (mrspm_eic_trans)
  );

  register_file_manager #(
    .CFG(CFG)
  ) rfm
  (
    .clk              (clk),
    .rst_n            (rst_n),

    // Register File Manager ==> Table Traversal Unit
    .rfm_ttu          (rfm_ttu),

    // Register File Manager ==> Rule Analyzer Pipeline
    .rfm_rap          (rfm_rap),

    // Register File Manager <==> Error and Interrupt Control
    .rfm_eic          (rfm_eic),
    .eic_rfm          (eic_rfm),
    .eic_rfm_valid    (eic_rfm_valid),
    .eic_rfm_err_rrid (eic_rfm_err_rrid),

    // Register File Manager ==> AXI Master Request Manager
    .change_state     (change_state),
    .rrid_stall       (rrid_stall),

    // Register File Manager ==> AXI Slave Request Manager
    .msi_data         (msi_data),

    // Register File Manager <==>  AHB-Lite
    .ahb_req          (ahb_req),
    .ahb_resp         (ahb_resp)
  );

  table_traversal_unit #(
    .CFG(CFG)
  ) ttu
  (
    .clk              (clk),
    .rst_n            (rst_n),

    // Axi Transaction Manager  <==>  Table Traversal Unit
    .rap_operation    (rap_operation),
    .transaction_i    (axi_ttu_trans),

    // Register File Manager  ==>  Table Traversal Unit
    .rfm_ttu          (rfm_ttu),

    // Table Traversal Unit  ==>  Rule Analyzer Pipeline
    .entrypresent_or  (entrypresent_or),
    .mdrwperm_repl    (mdrwperm_repl),
    .transaction_o    (transaction_o),
    .trans_end_addr   (trans_end_addr),      // Transaction end Address
    .ttu_rapo         (ttu_rapo),
    .ttu_rap_err_info (ttu_rap_err_info)
  );

  rule_analyzer_pipeline #(
    .CFG(CFG)
  ) rap
  (
    .clk                (clk),
    .rst_n              (rst_n),

    // Table Traversal Unit  ==>  Rule Analyzer Pipeline
    .entrypresent_or    (entrypresent_or),
    .mdrwperm_repl      (mdrwperm_repl),
    .transaction_i      (transaction_o),
    .trans_end_addr     (trans_end_addr),      // Transaction end Address
    .ttu_rapo           (ttu_rapo),
    .ttu_rap_err_info   (ttu_rap_err_info),

    // Register File Manager  ==>  Rule Analyzer Pipeline
    .rfm_rap            (rfm_rap),

    // Rule Analyzer Pipeline ==> Master Response Manager
    .rap_rd_err_valid   (rap_rd_err_valid),
    .rap_rd_err_req     (rap_rd_err_req),
    .ar_len             (ar_len),
    .rap_wr_err_valid   (rap_wr_err_valid),
    .rap_wr_err_req     (rap_wr_err_req),

    // Rule Analyzer Pipeline ==> Slave Request Manager
    .rap_rd_valid       (rap_rd_valid),
    .rap_rd_req         (rap_rd_req),
    .rap_wr_valid       (rap_wr_valid),
    .rap_wr_trans       (rap_wr_trans),

    // Rule Analyer Pipeline   ==> EIC Block
    .rap_eic_trans      (rap_eic_trans),
    .rap_eic_valid      (rap_eic_valid),
    .rap_eic_error_info (rap_eic_error_info)
  );

  if (CFG.ERROR_CAPTURE_EN) begin : gen_eic_block
    eic_block #(
      .CFG(CFG)
    ) eic_block
    (
      .clk                (clk),
      .rst_n              (rst_n),

      // Rule Analzyer Pipeline ==> Error and Interrupt Control
      .rap_eic_trans      (rap_eic_trans),
      .rap_eic_valid      (rap_eic_valid),
      .rap_eic_error_info (rap_eic_error_info),

      // Register File Manager <==> Error and Interrupt Control
      .rfm_eic            (rfm_eic),
      .eic_rfm_valid      (eic_rfm_valid),
      .eic_rfm_err_rrid   (eic_rfm_err_rrid),
      .eic_rfm            (eic_rfm),

      // Error and Interrupt Control ==> Slave Request Manager
      .eic_msi_valid      (eic_msi_valid),
      .eic_msi_trans      (eic_msi_trans),

      // Master Response Manager ==> Error and Interrupt Control
      .mrspm_eic_valid    (mrspm_eic_valid),
      .mrspm_eic_trans    (mrspm_eic_trans),

      // Error and Interrupt Control ==>
      .wsi                (wsi)
    );
  end
  else begin

    assign eic_rfm          = '0;
    assign eic_rfm_valid    = 1'b0;
    assign eic_rfm_err_rrid = '0;
    assign eic_msi_valid    = 1'b0;
    assign eic_msi_trans    = '0;
    assign wsi              = 1'b0;
  end

endmodule