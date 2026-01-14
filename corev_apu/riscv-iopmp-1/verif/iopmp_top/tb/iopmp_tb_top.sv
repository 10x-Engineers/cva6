
/*************************************************************************
   > File Name:   tb_top.sv
   > Description: This is the top module from where we run the test
                  in this module we're generating clock, and instantiating
                  DUT
   > Author:      Muhammad Hassan
   > Modified:    Muhammad Hassan
   > Mail:        muhammad.hassan@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

import uvm_pkg::*;
`include "uvm_macros.svh"
`timescale 1ns/1ps

module tb_top;
  // import reg32_uvm_pkg::*;
  import tb_pkg::*;
  import config_iopmp_pkg::*;
  import iopmp_axi_pkg::*;
  import ahb_lite_pkg::*;

  ////////////////////////////////////////////////////////////////////////////////
  // Reset and Clock Generation
  ////////////////////////////////////////////////////////////////////////////////

  bit clk;
  bit reset;
  bit RESETn;
  iopmp_reg regmodel;


  initial begin
    reset = 1'b0;
    #10;
    reset = 1'b1;
  end
  initial begin
     RESETn = 1'b1;
     axi_s_if.RVALID = 0;
     axi_s_if.BVALID = 0;
    repeat (5) @(posedge clk);
     RESETn = 1'b0;
    repeat (10) @(posedge clk);
     RESETn = 1'b1;
  end

  initial begin
    clk = 1'b0;
    forever #0.5ns clk = ~clk;
  end

  ////////////////////////////////////////////////////////////////////////////////
  // Interface Instance
  ////////////////////////////////////////////////////////////////////////////////


  axi_interface #(.ID_WIDTH(`AXI_ID_WIDTH),
                  .ADDR_WIDTH(`AXI_ADDR_WIDTH),
                  .R_USER_WIDTH(`R_USER_WIDTH),
                  .W_USER_WIDTH(`W_USER_WIDTH),
                  .DATA_WIDTH(`AXI_DATA_WIDTH))
          axi_if (.ACLK(clk), .ARESETn(reset));

  axi_s_interface #(.ID_WIDTH(`AXI_ID_WIDTH),
                    .ADDR_WIDTH(`AXI_ADDR_WIDTH),
                    .R_USER_WIDTH(`R_USER_WIDTH),
                    .W_USER_WIDTH(`W_USER_WIDTH),
                    .DATA_WIDTH(`AXI_DATA_WIDTH))
          axi_s_if (.ACLK(clk), .ARESETn(RESETn));

  ahb_interface  #(.ADDR_WIDTH(`AHB_ADDR_WIDTH),
                  .DATA_WIDTH(`AHB_DATA_WIDTH))
          ahb_if (.HCLK(clk), .HRESETn(reset));

  ////////////////////////////////////////////////////////////////////////////////
  // DUT Instantiation
  ////////////////////////////////////////////////////////////////////////////////


  // initial begin
  iopmp_axi_pkg::aw_channel_t      aw_channel;
  iopmp_axi_pkg::w_channel_t       w_channel;
  iopmp_axi_pkg::b_channel_t       b_channel;
  iopmp_axi_pkg::ar_channel_t      ar_channel;
  iopmp_axi_pkg::r_channel_t       r_channel;

  iopmp_axi_pkg::slv_aw_channel_t      aw_s_channel;
  iopmp_axi_pkg::w_channel_t       w_s_channel;
  iopmp_axi_pkg::slv_b_channel_t       b_s_channel;
  iopmp_axi_pkg::ar_channel_t      ar_s_channel;
  iopmp_axi_pkg::r_channel_t       r_s_channel;

  ahb_lite_pkg::ahb_req_t         ahb_req;
  ahb_lite_pkg::ahb_resp_t        ahb_resp;
  logic            wsi;
    //AW CHANNEL
    assign  aw_channel.aw_id      = axi_if.AWID;
    assign  aw_channel.aw_len     = axi_if.AWLEN;
    assign  aw_channel.aw_size    = axi_if.AWSIZE;
    assign  aw_channel.aw_burst   = axi_if.AWBURST;
    assign  aw_channel.aw_cache   = axi_if.AWCACHE;
    assign  aw_channel.aw_addr    = axi_if.AWADDR;
    assign  aw_channel.aw_prot    = axi_if.AWPROT;
    assign  aw_channel.aw_region  = axi_if.AWREGION;
    assign  aw_channel.aw_qos     = axi_if.AWQOS;
    assign  aw_channel.aw_lock    = axi_if.AWLOCK;
    assign  aw_channel.aw_user    = axi_if.AWUSER;
    // assign  aw_channel.aw_qos     =         ;
    // assign  aw_channel.aw_atop    =        ;
    // assign  aw_channel.aw_region  =         ;
    //AW SLAVE
    assign axi_s_if.AWID    = aw_s_channel.aw_id;
    assign axi_s_if.AWLEN   = aw_s_channel.aw_len;
    assign axi_s_if.AWSIZE  = aw_s_channel.aw_size;
    assign axi_s_if.AWBURST = aw_s_channel.aw_burst;
    assign axi_s_if.AWCACHE = aw_s_channel.aw_cache;
    assign axi_s_if.AWADDR  = aw_s_channel.aw_addr;
    assign axi_s_if.AWPROT  = aw_s_channel.aw_prot;
    assign axi_s_if.AWLOCK  = aw_s_channel.aw_lock;
    assign axi_s_if.AWUSER  = aw_s_channel.aw_user;

    //AR CHANNEL
    assign  ar_channel.ar_id      = axi_if.ARID;
    assign  ar_channel.ar_len     = axi_if.ARLEN;
    assign  ar_channel.ar_size    = axi_if.ARSIZE;
    assign  ar_channel.ar_burst   = axi_if.ARBURST;
    assign  ar_channel.ar_cache   = axi_if.ARCACHE;
    assign  ar_channel.ar_addr    = axi_if.ARADDR;
    assign  ar_channel.ar_prot    = axi_if.ARPROT;
    assign  ar_channel.ar_region    = axi_if.ARREGION;
    assign  ar_channel.ar_qos    = axi_if.ARQOS;
    assign  ar_channel.ar_lock    = axi_if.ARLOCK;
    assign  ar_channel.ar_user    = axi_if.ARUSER;
    // assign  ar_channel.ar_qos     =
    // assign  ar_channel.ar_atop    =
    // assign  ar_channel.ar_region  =
    //AR SLAVE
    assign axi_s_if.ARID    = ar_s_channel.ar_id;
    assign axi_s_if.ARLEN   = ar_s_channel.ar_len;
    assign axi_s_if.ARSIZE  = ar_s_channel.ar_size;
    assign axi_s_if.ARBURST = ar_s_channel.ar_burst;
    assign axi_s_if.ARCACHE = ar_s_channel.ar_cache;
    assign axi_s_if.ARADDR  = ar_s_channel.ar_addr;
    assign axi_s_if.ARPROT  = ar_s_channel.ar_prot;
    assign axi_s_if.ARLOCK  = ar_s_channel.ar_lock;
    assign axi_s_if.ARUSER  = ar_s_channel.ar_user;


    //B CHANNEL
    assign  axi_if.BID            = b_channel.b_id;
    assign  axi_if.BRESP          = b_channel.b_resp;
    assign  axi_if.BUSER          = b_channel.b_user;

    //B SLAVE
    assign b_s_channel.b_id    = axi_s_if.BID;
    assign b_s_channel.b_resp  = axi_s_if.BRESP;
    assign b_s_channel.b_user  = axi_s_if.BUSER;

    //W Channel
    assign w_channel.w_data     = axi_if.WDATA;
    assign w_channel.w_strb     = axi_if.WSTRB;
    assign w_channel.w_last     = axi_if.WLAST;
    assign w_channel.w_user     = axi_if.WUSER;

    //W SLAVE
    assign axi_s_if.WDATA = w_s_channel.w_data;
    assign axi_s_if.WSTRB = w_s_channel.w_strb;
    assign axi_s_if.WLAST = w_s_channel.w_last;
    assign axi_s_if.WUSER = w_s_channel.w_user;

    //R CHANNEL
    assign  axi_if.RID            = r_channel.r_id;
    assign  axi_if.RDATA          = r_channel.r_data;
    assign  axi_if.RRESP          = r_channel.r_resp;
    assign  axi_if.RLAST          = r_channel.r_last;
    assign  axi_if.RUSER          = r_channel.r_user;

    //R Slave
    assign r_s_channel.r_id   = axi_s_if.RID;
    assign r_s_channel.r_data = axi_s_if.RDATA;
    assign r_s_channel.r_resp = axi_s_if.RRESP;
    assign r_s_channel.r_last = axi_s_if.RLAST;
    assign r_s_channel.r_user = axi_s_if.RUSER;

    //AHB REQ
    assign  ahb_req.haddr         = ahb_if.HADDR;
    assign  ahb_req.hwrite        = ahb_if.HWRITE;
    assign  ahb_req.hsize         = ahb_if.HSIZE;
    assign  ahb_req.hburst        = ahb_if.HBURST;
    assign  ahb_req.htrans        = ahb_if.HTRANS;
    assign  ahb_req.hwdata        = ahb_if.HWDATA;
    assign  ahb_req.hprot         = ahb_if.HPROT;
    assign  ahb_req.hmastlock     = ahb_if.HMASTLOCK;
    assign  ahb_req.hsel          = ahb_if.HSEL;
    assign  ahb_req.hready        = ahb_resp.hreadyout;


    //AHB RESP
    assign  ahb_if.HRDATA         = ahb_resp.hrdata;
    assign  ahb_if.HRESP          = ahb_resp.hresp;
    assign  ahb_if.HREADY         = ahb_resp.hreadyout;

  // end

    iopmp #(.CFG(config_iopmp_pkg::iopmp_cfg_default)) iopmp_dut (
      .clk                (clk),
      .rst_n              (reset),
      // Address Write Channel
      .iAwValid           (axi_if.AWVALID),
      .iAwChannel         (aw_channel),
      .eAwReady           (axi_if.AWREADY),
      // Data Write channel
      .iWrValid            (axi_if.WVALID),
      .iWrChannel          (w_channel),
      .eWrReady            (axi_if.WREADY),
      // Address Read Channel
      .iArValid           (axi_if.ARVALID),
      .iArChannel         (ar_channel),
      .eArReady           (axi_if.ARREADY),
      // Write Response Channel
      .eBValid            (axi_if.BVALID),
      .iBReady            ('1),
      .eBChannel          (b_channel),
      // Read Response Channel
      .eRValid            (axi_if.RVALID),
      .iRReady            (axi_if.RREADY),
      .eRChannel          (r_channel),
      // Slave Address Write Channel
      .iAwReady           (axi_s_if.AWREADY),
      .eAwValid           (axi_s_if.AWVALID),
      .eAwChannel         (aw_s_channel),
      // Slave Address Read Channel
      .iArReady           (axi_s_if.ARREADY),
      .eArValid           (axi_s_if.ARVALID),
      .eArChannel         (ar_s_channel),
      // Slave Write Channel
      .iWrReady           (axi_s_if.WREADY),
      .eWrValid           (axi_s_if.WVALID),
      .eWrChannel         (w_s_channel),
      // Slave Read Response Channel
      .eRReady            (axi_s_if.RREADY),
      .iRValid            (axi_s_if.RVALID),
      .iRChannel          (r_s_channel),
      // Slave Write Response Channel
      .eBReady            (axi_s_if.BREADY),
      .iBValid            (axi_s_if.BVALID),
      .iBChannel          (b_s_channel),
      //AHB REQ Channel
      .ahb_req            (ahb_req),
      //AHB RESP Channel
      .ahb_resp           (ahb_resp),
      .wsi                (wsi)
    );

    bind iopmp_dut interface_func_cov intf_func_cov(.*);

  if (0) begin : iopmp_cp_sva
    if (1) begin : master_req_mgr
    `include "mst_req_mgr_cov.sv"
    end
    if (1) begin : slave_req_mgr
    `include "slv_req_mgr_cov.sv"
    end
    if (1) begin : master_resp_mgr
    `include "mrsp_req_mgr_cov.sv"
    end
    if (1) begin : ahb_req_signal
    `include "ahb_req_cov.sv"
    end
    if (1) begin : rap
    `include "match_entry_cov.sv"
    `include "rap_resp_gen_cov.sv"
    `include "rap_encoder_cov.sv"
    end
    if (1) begin : ttu
    `include "ttu_cov.sv"
    end
    if (1) begin : eic_block
    `include "eic_block_cov.sv"
    end
    if (1) begin : rfm
    `include "rfm_address_check_cov.sv"
    `include "rfm_read_register_cov.sv"
    `include "rfm_write_register_cov.sv"
    if (1) begin : rfm_arch
    `include "rfm_architecture_cov.sv"
    end
    end
  end

  //////////////////////////////////////////////////////////////////////////////
  // // UVM Phases Execution
  //////////////////////////////////////////////////////////////////////////////

  // initial begin
  //   run_test("read_write_test");
  // end

  ////////////////////////////////////////////////////////////////////////////////
  // Configuration Database Setup
  ////////////////////////////////////////////////////////////////////////////////
  initial begin
    regmodel = iopmp_reg::type_id::create("regmodel");
    regmodel.build();
    regmodel.reset();
    regmodel.default_map.set_base_addr(0);
    regmodel.default_map.set_auto_predict(1);
    // regmodel.default_map.set_check_on_read(1);

    regmodel.lock_model();

    uvm_config_db#(iopmp_reg)::set(null, "*", "regmodel", regmodel);
    uvm_config_db#(virtual axi_interface#(.ID_WIDTH(`AXI_ID_WIDTH),.ADDR_WIDTH(`AXI_ADDR_WIDTH),.R_USER_WIDTH(`R_USER_WIDTH),.W_USER_WIDTH(`W_USER_WIDTH),.DATA_WIDTH(`AXI_DATA_WIDTH)))::set(null, "*", "axi_vif", axi_if);
    uvm_config_db#(virtual axi_s_interface#(.ID_WIDTH(`AXI_ID_WIDTH),.ADDR_WIDTH(`AXI_ADDR_WIDTH),.R_USER_WIDTH(`R_USER_WIDTH),.W_USER_WIDTH(`W_USER_WIDTH),.DATA_WIDTH(`AXI_DATA_WIDTH)))::set(null, "*", "axi_s_vif", axi_s_if);
    uvm_config_db#(virtual ahb_interface#(.ADDR_WIDTH(`AHB_ADDR_WIDTH),.DATA_WIDTH(`AHB_DATA_WIDTH)))::set(null, "*", "ahb_vif", ahb_if);
    run_test("read_write_test");
  end

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0);
  end

  `ifdef CFG_IOPMP_SRCMD_FMT_0
    if (RRID_NUM > 64) begin
      $error("Supported RRIDs can be upto 64");
    end
  `endif

  `ifdef CFG_IOPMP_SRCMD_FMT_1
    if (RRID_NUM > MD_NUM) begin
      $error("Maximum supported RRIDs can be equal to supported MDs");
    end
  `endif

  `ifdef CFG_IOPMP_SRCMD_FMT_2
    if (RRID_NUM > 32) begin
      $error("Supported RRIDs can be upto 32");
    end
  `endif

  `ifndef CFG_IOPMP_MDCFG_FMT_0
    if (MD_ENTRY_NUM > 7) begin
      $error("Supported Entries per MD in MDCFG Format 1 or 2 can be upto 7");
    end

    if (MDCFGLCK_F > MD_NUM) begin
      $error("Number of Prelocked MDs can not be greater than supported MDs");
    end
  `endif

  if (SRCMD_FMT > 2) begin
    $error("SRCMD Format has the legal value: 0, 1, 2");
  end

  if (MDCFG_FMT > 2) begin
    $error("MDCFG Format has the legal value: 0, 1, 2");
  end

  if (MD_NUM > 63) begin
    $error("Supported MDs can be upto 63");
  end

  if (PRIO_ENTRY > 48) begin
    $error("Maximum priority entries can be upto 48");
  end

  if (ENTRY_NUM > 128) begin
    $error("Supported Entries can be upto 128");
  end

  if (ENTRYLCK_F > ENTRY_NUM) begin
    $error("Number of Prelocked entries can not be greater than supported entries");
  end

  if ((AXI_ADDR_WIDTH == 52) && (!ADDRH_EN)) begin
    $error("ADDRH_EN must be 1 when system is 64 bit");
  end

  if ((AXI_ADDR_WIDTH == 34) && ADDRH_EN) begin
    $error("ADDRH_EN must be 0 when system is 32 bit");
  end

  if (|BASE_ADDR[15:0]) begin
    $error("Base Address must be 4KB Aligned");
  end

  if (|ENTRY_OFFSET[15:0]) begin
    $error("Entry Offset must be 4KB Aligned");
  end

  if (ENTRY_OFFSET[31:16] == 0) begin
    $error("Upper 16 bits of Entry Offset can not be all zeros");
  end

endmodule