/*************************************************************************
   > File Name:   axi_s_interface.sv
   > Description: AXI Interface definition for use in verification
   > Author:      Malik Faayez Muhammad
   > Mail:        faayez.muhammd@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
`ifndef AXI_S_INTERFACE
`define AXI_S_INTERFACE
`include "uvm_macros.svh"
import uvm_pkg::*;
interface axi_s_interface #(
  parameter ID_WIDTH     = 5,              // ID width for AXI transactions
  parameter ADDR_WIDTH   = 64,             // Address width for AXI transactions
  parameter R_USER_WIDTH   = 6,            // r user width
  parameter W_USER_WIDTH   = 6,            // w user width
  parameter DATA_WIDTH   = 64,             // Data width for AXI transactions
  parameter STRB_WIDTH   = DATA_WIDTH / 8, // Write strobe width
  parameter LEN_WIDTH    = 8               // Burst length width
)(
  input logic ACLK,       // Clock signal
  input logic ARESETn     // Active-low reset signal
);

  /////////////////////////////////////////////////////////////////////////////
  // Write Address Channel Signals
  /////////////////////////////////////////////////////////////////////////////
  logic [ID_WIDTH:0]     AWID;       // Write transaction ID
  logic [ADDR_WIDTH-1:0]   AWADDR;     // Write address
  logic [LEN_WIDTH-1:0]    AWLEN;      // Burst length
  logic [2:0]              AWSIZE;     // Burst size
  logic [1:0]              AWBURST;    // Burst type
  logic [1:0]              AWLOCK;     // Lock signal//
  logic                    AWVALID;    // Address valid
  logic                    AWREADY;    // Address ready
  logic [3:0]              AWCACHE;    // For Cache//
  logic [2:0]              AWPROT;     // For Protection
  logic [bus_params_pkg::BUS_U_SLAVE-1:0] AWUSER;     // For User//

  /////////////////////////////////////////////////////////////////////////////
  // Write Data Channel Signals
  /////////////////////////////////////////////////////////////////////////////
  logic [ID_WIDTH:0]     WID;        // Write Data transaction ID
  logic [DATA_WIDTH-1:0]   WDATA;      // Write data
  logic [STRB_WIDTH-1:0]   WSTRB;      // Write strobe
  logic                    WLAST;      // Last transfer in burst
  logic                    WVALID;     // Write data valid
  logic                    WREADY;     // Write data ready
  logic [bus_params_pkg::BUS_U_SLAVE-1:0] WUSER;      // For User//

  /////////////////////////////////////////////////////////////////////////////
  // Write Response Channel Signals
  /////////////////////////////////////////////////////////////////////////////
  logic [ID_WIDTH:0]     BID;        // Write response ID
  logic [1:0]              BRESP;      // Write response
  logic                    BVALID;     // Write response valid
  logic                    BREADY;     // Write response ready
  logic [bus_params_pkg::BUS_U_SLAVE-1:0] BUSER;      // For User//

  /////////////////////////////////////////////////////////////////////////////
  // Read Address Channel Signals
  /////////////////////////////////////////////////////////////////////////////
  logic [ID_WIDTH:0]     ARID;       // Read transaction ID
  logic [ADDR_WIDTH-1:0]   ARADDR;     // Read address
  logic [LEN_WIDTH-1:0]    ARLEN;      // Burst length
  logic [2:0]              ARSIZE;     // Burst size
  logic [1:0]              ARBURST;    // Burst type
  logic [1:0]              ARLOCK;     // Lock signal//
  logic                    ARVALID;    // Address valid
  logic                    ARREADY;    // Address ready
  logic [3:0]              ARCACHE;    // For Cache//
  logic [2:0]              ARPROT;     // For Protection
  logic [bus_params_pkg::BUS_U_SLAVE-1:0] ARUSER;     // For User//

  /////////////////////////////////////////////////////////////////////////////
  // Read Data Channel Signals
  /////////////////////////////////////////////////////////////////////////////
  logic [ID_WIDTH:0]     RID;        // Read transaction ID
  logic [DATA_WIDTH-1:0]   RDATA;      // Read data
  logic [1:0]              RRESP;      // Read response
  logic                    RLAST;      // Last transfer in burst
  logic                    RVALID;     // Read data valid
  logic                    RREADY;     // Read data ready
  logic [bus_params_pkg::BUS_U_SLAVE-1:0] RUSER;      // For User//

// Driver Clocking block - Outputs and inputs are inverted with respect to DUT
   clocking driver_cb @(posedge ACLK);
   default input #0.1 output #0.1;
        input AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK, AWVALID, AWUSER, WID, WDATA, WSTRB, WLAST, WVALID, WUSER, BREADY, ARID, ARADDR, ARLEN, ARSIZE,
        ARBURST, ARLOCK, ARVALID, ARUSER, RREADY;
        output  AWREADY, WREADY, BID,  BRESP, BUSER, BVALID, ARREADY, RID, RDATA, RRESP, RLAST, RVALID, RUSER;
   endclocking: driver_cb

   // Monitor Clocking block - For sampling by monitor components
   clocking monitor_cb @(posedge ACLK);
   default input #0.1 output #0.1;
        input AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK, AWVALID, AWUSER, WID, WDATA, WSTRB, WLAST, WVALID, WUSER, BREADY, ARID, ARADDR, ARLEN, ARSIZE,
        ARBURST, ARLOCK, ARVALID, ARUSER, RREADY, AWREADY, WREADY, BID,  BRESP, BUSER, BVALID, ARREADY, RID, RDATA, RRESP, RLAST, RVALID, RUSER;
   endclocking: monitor_cb

   task reset_axi_s();

    @(posedge ACLK);
    wait(!ARESETn);

    // Reset AXI interface signals to default
    AWREADY   <= 'b0;
    WREADY    <= 'b0;
    BID       <= 'b0;
    BRESP     <= 'b0;
    BUSER     <= 'b0;
    BVALID    <= 'b0;
    ARREADY   <= 'b0;
    RID       <= 'b0;
    RDATA     <= 'b0;
    RRESP     <= 'b0;
    RLAST     <= 'b0;
    RVALID    <= 'b0;
    RUSER     <= 'b0;


   endtask : reset_axi_s

   // Define modports for monitor and driver
   modport monitor(clocking monitor_cb);
   modport driver(clocking driver_cb);

    // clocking cb @(posedge ACLK);
    // default input #2 output #2;
    // output AWADDR, AWPROT, AWVALID, AWID, AWLEN, AWSIZE, AWBURST;
    // output WDATA, WSTRB, WVALID, WID, WLAST;
    // input  BREADY;
    // input ARADDR, ARPROT, ARVALID, ARID, ARLEN, ARSIZE, ARBURST;
    // input  RREADY;
    // endclocking

    // modport monitor (
    // input ACLK,
    // input ARESETn,
    // clocking cb
    // );
    // modport smonitor(clocking monitor_cb);
    // modport sdriver(clocking driver_cb);

endinterface

`endif