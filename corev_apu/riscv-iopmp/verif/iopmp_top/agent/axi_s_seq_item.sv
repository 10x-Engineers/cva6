/*************************************************************************
   > File Name:   axi_s_seq_item.sv
   > Description: The AXI Sequence Item is a UVM class defining randomized AXI4 Slave transactions with constraints
                  to ensure protocol compliance and diverse test coverage.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef AXI_S_SEQ_ITEM
`define AXI_S_SEQ_ITEM

// AXI Sequence Item Class
class axi_s_seq_item extends uvm_sequence_item;

    // Write Address Channel
    bit [bus_params_pkg::BUS_AW-1:0] AWADDR;
    bit [2:0]  AWPROT;
    bit        AWVALID;
    rand bit   AWREADY;
    bit [bus_params_pkg::BUS_IDW:0]  AWID;
    bit [3:0]  AWLEN;
    bit [bus_params_pkg::BUS_DS-1:0]  AWSIZE;
    burst_type  AWBURST;
    bit [bus_params_pkg::BUS_U_W-1:0] AWUSER;     // For User//
    bit [1:0]              AWLOCK;     // Lock signal//
    bit [3:0]              AWCACHE;    // For Cache//

    // Write Data Channel
    bit [bus_params_pkg::BUS_DW-1:0] WDATA;
    bit [bus_params_pkg::BUS_DBW-1:0]  WSTRB;
    bit        WVALID;
    rand bit   WREADY;
    bit [bus_params_pkg::BUS_IDW:0]  WID;
    bit        WLAST;
    bit [bus_params_pkg::BUS_U_SLAVE-1:0] WUSER;      // For User//

    // Write Response Channel
    rand response_type  BRESP;
    rand bit        BVALID;
    bit             BREADY;
    rand bit [bus_params_pkg::BUS_IDW:0]  BID;
    rand bit [bus_params_pkg::BUS_U_SLAVE-1:0] BUSER;      // For User//

    // Read Address Channel
    bit [bus_params_pkg::BUS_AW-1:0] ARADDR;
    bit [2:0]  ARPROT;
    bit        ARVALID;
    rand bit   ARREADY;
    bit [bus_params_pkg::BUS_IDW:0]  ARID;
    bit [3:0]  ARLEN;
    bit [bus_params_pkg::BUS_DS-1:0]  ARSIZE;
    burst_type  ARBURST;
    bit [bus_params_pkg::BUS_U_SLAVE-1:0] ARUSER;     // For User//
    bit [1:0]              ARLOCK;     // Lock signal//
    bit [3:0]              ARCACHE;    // For Cache//

    // Read Data Channel
    rand bit [bus_params_pkg::BUS_DW-1:0] RDATA;
    rand response_type  RRESP;
    rand bit        RVALID;
    bit             RREADY;
    rand bit [bus_params_pkg::BUS_IDW:0]  RID;
    rand bit        RLAST;
    bit [bus_params_pkg::BUS_U_SLAVE-1:0] RUSER;      // For User//



  // Constraints
  constraint ready_signals {
        ARREADY == 1;
        AWREADY == 1;
        WREADY  == 1;
        BRESP   == 0;
        BVALID  == 1;
        RRESP   == 0;
    }


  // UVM Macros for field registration
  `uvm_object_utils_begin(axi_s_seq_item)
      `uvm_field_int(AWADDR, UVM_ALL_ON)
      `uvm_field_int(AWPROT, UVM_ALL_ON)
      `uvm_field_int(AWVALID, UVM_ALL_ON)
      `uvm_field_int(AWREADY, UVM_ALL_ON)
      `uvm_field_int(AWID, UVM_ALL_ON)
      `uvm_field_int(AWLEN, UVM_ALL_ON)
      `uvm_field_int(AWSIZE, UVM_ALL_ON)
      `uvm_field_int(AWBURST, UVM_ALL_ON)
      `uvm_field_int(AWUSER, UVM_ALL_ON)
      `uvm_field_int(AWLOCK, UVM_ALL_ON)
      `uvm_field_int(AWCACHE, UVM_ALL_ON)
      `uvm_field_int(WDATA, UVM_ALL_ON)
      `uvm_field_int(WSTRB, UVM_ALL_ON)
      `uvm_field_int(WVALID, UVM_ALL_ON)
      `uvm_field_int(WREADY, UVM_ALL_ON)
      `uvm_field_int(WID, UVM_ALL_ON)
      `uvm_field_int(WLAST, UVM_ALL_ON)
      `uvm_field_int(WUSER, UVM_ALL_ON)
      `uvm_field_int(BRESP, UVM_ALL_ON)
      `uvm_field_int(BVALID, UVM_ALL_ON)
      `uvm_field_int(BREADY, UVM_ALL_ON)
      `uvm_field_int(BID, UVM_ALL_ON)
      `uvm_field_int(BUSER, UVM_ALL_ON)
      `uvm_field_int(ARADDR, UVM_ALL_ON)
      `uvm_field_int(ARPROT, UVM_ALL_ON)
      `uvm_field_int(ARVALID, UVM_ALL_ON)
      `uvm_field_int(ARREADY, UVM_ALL_ON)
      `uvm_field_int(ARID, UVM_ALL_ON)
      `uvm_field_int(ARLEN, UVM_ALL_ON)
      `uvm_field_int(ARSIZE, UVM_ALL_ON)
      `uvm_field_int(ARBURST, UVM_ALL_ON)
      `uvm_field_int(ARLOCK, UVM_ALL_ON)
      `uvm_field_int(ARCACHE, UVM_ALL_ON)
      `uvm_field_int(ARUSER, UVM_ALL_ON)
      `uvm_field_int(RDATA, UVM_ALL_ON)
      `uvm_field_int(RRESP, UVM_ALL_ON)
      `uvm_field_int(RVALID, UVM_ALL_ON)
      `uvm_field_int(RREADY, UVM_ALL_ON)
      `uvm_field_int(RID, UVM_ALL_ON)
      `uvm_field_int(RLAST, UVM_ALL_ON)
      `uvm_field_int(RUSER, UVM_ALL_ON)
    `uvm_object_utils_end

  // Constructor
  function new(string name="axi_s_seq_item");
    super.new(name);
  endfunction


endclass

`endif


