/*************************************************************************
   > File Name:   interface_functional_cov.sv
   > Description: Interface functional coverage model. This will include AXI Master and SLave, and AHB interface
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef INTERFACE_FUNC_COV
`define INTERFACE_FUNC_COV

import uvm_pkg::*;
`include "uvm_macros.svh"
import config_iopmp_pkg::*;

module interface_func_cov(
  input logic clk,
  input logic rst_n,

  // Address Write Channel
  input logic iAwValid,
  input iopmp_axi_pkg::aw_channel_t iAwChannel,
  input logic eAwReady,

  // Data Write channel
  input logic iWrValid,
  input iopmp_axi_pkg::w_channel_t iWrChannel,
  input logic eWrReady,

  // Address Read Channel
  input logic iArValid,
  input iopmp_axi_pkg::ar_channel_t iArChannel,
  input logic eArReady,

  // Write Response Channel
  input logic eBValid,
  input logic iBReady,
  input iopmp_axi_pkg::b_channel_t eBChannel,

  // Read Response Channel
  input logic eRValid,
  input logic iRReady,
  input iopmp_axi_pkg::r_channel_t eRChannel,

  // Slave Address Write Channel
  input logic iAwReady,
  input logic eAwValid,
  input iopmp_axi_pkg::slv_aw_channel_t eAwChannel,

  // Slave Address Read Channel
  input logic iArReady,
  input logic eArValid,
  input iopmp_axi_pkg::ar_channel_t eArChannel,

  // Slave Write Channel
  input logic iWrReady,
  input logic eWrValid,
  input iopmp_axi_pkg::w_channel_t eWrChannel,

  // Slave Read Response Channel
  input logic eRReady,
  input logic iRValid,
  input iopmp_axi_pkg::r_channel_t iRChannel,

  // Slave Write Response Channel
  input logic eBReady,
  input logic iBValid,
  input iopmp_axi_pkg::slv_b_channel_t iBChannel,

  //AHB REQ Channel
  input ahb_lite_pkg::ahb_req_i_t ahb_req,

  //AHB RESP Channel
  input ahb_lite_pkg::ahb_resp_t ahb_resp,

  input logic wsi
);

  covergroup ahb @(posedge clk);

  cp_ahb_write: coverpoint ahb_req.hwrite {
    bins write = {1};
    bins read  = {0};
  }

  cp_ahb_size: coverpoint ahb_req.hsize {
    bins size_byte      = {3'b000}; // 8-bit
    bins size_halfword  = {3'b001}; // 16-bit
    bins size_word      = {3'b010}; // 32-bit
    bins size_others    = {[3'b011:3'b111]};
  }

  cp_ahb_burst: coverpoint ahb_req.hburst {
    bins single    = {3'b000};
    bins incr      = {3'b001};
    bins wrap4     = {3'b010};
    bins incr4     = {3'b011};
    bins wrap8     = {3'b100};
    bins incr8     = {3'b101};
    bins wrap16    = {3'b110};
    bins incr16    = {3'b111};
  }

  cp_ahb_trans: coverpoint ahb_req.htrans {
    bins idle      = {2'b00};
    bins busy      = {2'b01};
    bins nonseq    = {2'b10};
    bins seq       = {2'b11};
  }

  cp_ahb_prot: coverpoint ahb_req.hprot {
    bins priv_data     = {4'b0000};
    bins user_instr    = {4'b0101};
    bins others        = default;
  }

  cp_ahb_mastlock: coverpoint ahb_req.hmastlock {
    bins unlocked  = {0};
    bins locked    = {1};
  }

  cp_ahb_sel: coverpoint ahb_req.hsel {
    bins deselected = {0};
    bins selected   = {1};
  }

  cp_ahb_addr: coverpoint ahb_req.haddr{
    bins version        = {32'h0000};
    bins implementation = {32'h4};
    bins hwcfg0         = {32'h8};
    bins hwcfg1         = {32'hC};
    bins hwcfg2         = {32'h10};
    bins entryoffset    = {32'h14};
    bins mdstall        = {32'h30};
    bins mdstallh       = {32'h34};
    bins rridscp        = {32'h38};
    bins mdlck          = {32'h40};
    bins mdlckh         = {32'h44};
    bins mdcfglck       = {32'h48};
    bins entrylck       = {32'h4C};
    bins err_cfg        = {32'h60};
    bins err_info       = {32'h64};
    bins err_reqaddr    = {32'h68};
    bins err_reqaddrh   = {32'h6C};
    bins err_reqid      = {32'h70};
    bins err_mfr        = {32'h74};
    bins err_msiaddr    = {32'h78};
    bins err_msiaddrh   = {32'h7C};
    bins mdcfg_0    		= {[32'h800:32'h8F8]};
    bins srcmd_en_0 		= {[32'h1000:32'h17E0]};
    bins srcmd_enh_0		= {[32'h1004:32'h17E4]};
    bins srcmd_r_0  		= {[32'h1008:32'h17E8]};
    bins srcmd_rh_0 		= {[32'h100C:32'h17EC]};
    bins srcmd_w_0  		= {[32'h1010:32'h17F0]};
    bins srcmd_wh_0 		= {[32'h1014:32'h17F4]};
    bins entry_addr_0   = {[ENTRY_OFFSET + 32'h0000 : ENTRY_OFFSET + 32'h07F0] };
    bins entry_addrh_0  = {[ENTRY_OFFSET + 32'h0004 : ENTRY_OFFSET + 32'h07F4] };
    bins entry_cfg_0    = {[ENTRY_OFFSET + 32'h0008 : ENTRY_OFFSET + 32'h07F8] };
  }

  cp_ahb_rdata: coverpoint ahb_resp.hrdata {
    bins zero_data     = {32'h0000_0000};
    bins all_ones      = {32'hFFFF_FFFF};
    bins lower_half = {[32'h0000_0001:32'h0000_FFFF]};
  }

  cp_ahb_resp: coverpoint ahb_resp.hresp {
    bins zero_resp     = {0};
    bins valid_resp      = {1};
  }

  cp_ahb_readyout: coverpoint ahb_resp.hreadyout {
    bins readyout     = {1};
    bins not_readyout = {0};
  }
  endgroup

  ahb ahb_cov;

  initial begin
    ahb_cov = new();
  end

endmodule

`endif