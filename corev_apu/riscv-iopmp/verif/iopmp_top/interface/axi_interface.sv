/*************************************************************************
   > File Name:   axi_interface.sv
   > Description: AXI Interface definition for use in verification
   > Author:      Ahmed Raza
   > Modified:    Muhammad Hassan
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef AXI_INTERFACE
`define AXI_INTERFACE
`include "uvm_macros.svh"
import uvm_pkg::*;
interface axi_interface #(
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
  // Read Address Channel Signals
  /////////////////////////////////////////////////////////////////////////////
  logic [ID_WIDTH-1:0]     ARID;       // Read transaction ID
  logic [ADDR_WIDTH-1:0]   ARADDR;     // Read address
  logic [LEN_WIDTH-1:0]    ARLEN;      // Burst length
  logic [2:0]              ARSIZE;     // Burst size
  logic [1:0]              ARBURST;    // Burst type
  logic [1:0]              ARLOCK;     // Lock signal
  logic                    ARVALID;    // Address valid
  logic                    ARREADY;    // Address ready
  logic [3:0]              ARCACHE;    // For Cache
  logic [2:0]              ARPROT;     // For Protection
  logic [3:0]              ARREGION;     // For REGIION
  logic [3:0]              ARQOS;     // For QOS
  logic [R_USER_WIDTH-1:0] ARUSER;     // For User
  

  /////////////////////////////////////////////////////////////////////////////
  // Read Data Channel Signals
  /////////////////////////////////////////////////////////////////////////////
  logic [ID_WIDTH-1:0]     RID;        // Read transaction ID
  logic [DATA_WIDTH-1:0]   RDATA;      // Read data
  logic [1:0]              RRESP;      // Read response
  logic                    RLAST;      // Last transfer in burst
  logic                    RVALID;     // Read data valid
  logic                    RREADY;     // Read data ready
  logic [R_USER_WIDTH-1:0] RUSER;      // For User

  /////////////////////////////////////////////////////////////////////////////
  // Write Address Channel Signals
  /////////////////////////////////////////////////////////////////////////////
  logic [ID_WIDTH-1:0]     AWID;       // Write transaction ID
  logic [ADDR_WIDTH-1:0]   AWADDR;     // Write address
  logic [LEN_WIDTH-1:0]    AWLEN;      // Burst length
  logic [2:0]              AWSIZE;     // Burst size
  logic [1:0]              AWBURST;    // Burst type
  logic [1:0]              AWLOCK;     // Lock signal
  logic                    AWVALID;    // Address valid
  logic                    AWREADY;    // Address ready
  logic [3:0]              AWCACHE;    // For Cache
  logic [2:0]              AWPROT;     // For Protection
  logic [3:0]              AWREGION;     // For REGIION
  logic [3:0]              AWQOS;     // For QOS
  logic [W_USER_WIDTH-1:0] AWUSER;     // For User
  

  /////////////////////////////////////////////////////////////////////////////
  // Write Data Channel Signals
  /////////////////////////////////////////////////////////////////////////////
  logic [ID_WIDTH-1:0]     WID;        // Write Data transaction ID
  logic [DATA_WIDTH-1:0]   WDATA;      // Write data
  logic [STRB_WIDTH-1:0]   WSTRB;      // Write strobe
  logic                    WLAST;      // Last transfer in burst
  logic                    WVALID;     // Write data valid
  logic                    WREADY;     // Write data ready
  logic [W_USER_WIDTH-1:0] WUSER;      // For User

  /////////////////////////////////////////////////////////////////////////////
  // Write Response Channel Signals
  /////////////////////////////////////////////////////////////////////////////
  logic [ID_WIDTH-1:0]     BID;        // Write response ID
  logic [1:0]              BRESP;      // Write response
  logic                    BVALID;     // Write response valid
  logic                    BREADY;     // Write response ready
  logic [W_USER_WIDTH-1:0] BUSER;      // For User


  clocking driver_cb @(posedge ACLK);
    default input #0.1 output #0.1;
  
    // Write Address Channel
    output                     AWID;
    output                     AWADDR;
    output                     AWLEN;
    output                     AWSIZE;
    output                     AWBURST;
    output                     AWLOCK;
    output                     AWVALID;
    output                     AWUSER;
    output                     AWPROT;
    output                     AWREGION;
    output                     AWQOS;   
    input                      AWREADY;
    
    
   
    // Write Data Channel
    output                      WID;
    output                      WDATA;
    output                      WSTRB;
    output                      WLAST;
    output                      WVALID;
    output                      WUSER;
    input                       WREADY;
  
    // Write Response Channel
    input                      BID;
    input                      BRESP;
    input                      BUSER;
    input                      BVALID;
    output                     BREADY;
  
    // Read Address Channel
    output                      ARID;
    output                      ARADDR;
    output                      ARLEN;
    output                      ARSIZE;
    output                      ARBURST;
    output                      ARLOCK;
    output                      ARVALID;
    output                      ARPROT;
    output                      ARREGION;
    output                      ARQOS; 
    output                      ARUSER;
    input                       ARREADY;
  
    // Read Data Channel
    input                         RID;
    input                         RDATA;
    input                         RRESP;
    input                         RLAST;
    input                         RVALID;
    input                         RUSER;
    output                        RREADY;
    
  endclocking



  clocking monitor_cb @(posedge ACLK);
    default input #0.1 output #0.1;
  
    // Write Address Channel
    input                     AWID;
    input                     AWADDR;
    input                     AWLEN;
    input                     AWSIZE;
    input                     AWBURST;
    input                     AWLOCK;
    input                     AWPROT;
    input                     AWREGION;
    input                     AWQOS; 
    input                     AWVALID;
    input                     AWUSER;
    input                     AWREADY;
  
    // Write Data Channel
    input                      WID;
    input                      WDATA;
    input                      WSTRB;
    input                      WLAST;
    input                      WVALID;
    input                      WREADY;
    input                      WUSER;
  
    // Write Response Channel
    input                      BID;
    input                      BRESP;
    input                      BUSER;
    input                      BVALID;
    input                      BREADY;
  
    // Read Address Channel
    input                      ARID;
    input                      ARADDR;
    input                      ARLEN;
    input                      ARSIZE;
    input                      ARBURST;
    input                      ARPROT;
    input                      ARREGION;
    input                      ARQOS; 
    input                      ARLOCK;
    input                      ARUSER;
    input                      ARVALID;
    input                      ARREADY;
  
    // Read Data Channel
    input                        RID;
    input                        RDATA;
    input                        RRESP;
    input                        RLAST;
    input                        RUSER;
    input                        RVALID;
    input                        RREADY;
  endclocking

  modport monitor(clocking monitor_cb);
  modport driver(clocking driver_cb);

  //Task for reset
  task reset_axi();

    @(posedge ACLK);
    wait(!ARESETn);

    // Reset AXI interface signals to default
    ARADDR    <= 'b0;
    ARID      <= 'b0;
    ARLEN     <= 'b0;
    ARSIZE    <= 'b0;
    ARBURST   <= 'b0;
    ARUSER    <= 'b0;
    ARLOCK    <= `RD_ADDR_LOCK;
    ARVALID   <= 1'b0;
    ARCACHE   <= `RD_ADDR_CACHE;
    ARPROT    <= `RD_ADDR_PROT;
    // RDATA     <= 'b0;
    // RID       <= 'b0;
    // RLAST     <= 'b0;
    // RVALID    <= 1'b0;
    // RUSER     <= 1'b0;
    RREADY    <= 1'b1;
    // RRESP     <= 1'b0;
    AWADDR    <= 'b0;
    AWID      <= 'b0;
    AWLEN     <= 'b0;
    AWSIZE    <= 'b0;
    AWBURST   <= 'b0;
    AWLOCK    <= `WR_ADDR_LOCK;
    AWVALID   <= 1'b0;
    AWCACHE   <= `WR_ADDR_CACHE;
    AWPROT    <= `WR_ADDR_PROT;
    AWUSER    <= 1'b0;
    WSTRB     <= 'b0;
    WDATA     <= 'b0;
    WUSER     <= 'b0;
    WID       <= 'b0;
    WLAST     <= 'b0;
    WVALID    <= 1'b0;
    // BREADY    <= 1'b0;
  endtask : reset_axi

  //Task for post_reset
  task post_reset_axi();
    wait(ARESETn);
    @(posedge ACLK);
  endtask : post_reset_axi

  //------------------------------------------------------------------------------
  //  axi_protocol_assertions
  // Description: AXI protocol property definitions and assertions.
  //------------------------------------------------------------------------------

  /*
  * RESERVED_BURST: Ensures AWBURST does not have a reserved value (2'b11)
  * when AWVALID is asserted and the reset is active.
  */
  property RESERVED_BURST;
    @(posedge ACLK) (AWVALID && ARESETn |-> (AWBURST != 2'b11));
  endproperty : RESERVED_BURST
  axi_burst_reserved_bit: assert property (RESERVED_BURST)
    else `uvm_error("RESERVED_BURST", "AWBURST has a reserved value (2'b11)!")

  /*
  * AXI_ADDRESS_BOUNDARY: Ensures AWADDR remains within the valid address range (< 4095)
  * when AWVALID is asserted and the reset is active.
  */
  // property AXI_ADDRESS_BOUNDARY;
    // @(posedge ACLK) (AWVALID && ARESETn |-> (AWADDR < 4095));
  // endproperty : AXI_ADDRESS_BOUNDARY
  // axi_address_check: assert property (AXI_ADDRESS_BOUNDARY)
    // else `uvm_error("AXI_ADDRESS_BOUNDARY", "AWADDR exceeds the valid boundary (< 4095)!")
// 
  /*
  * arvalid_arready_handshake: Checks ARVALID and ARREADY handshake protocol.
  * Ensures ARVALID remains asserted for one clock cycle if ARREADY is not active.
  */
  property arvalid_arready_handshake;
    @(posedge ACLK) disable iff (!ARESETn)
      ARVALID && !ARREADY |-> ##1 ARVALID;
  endproperty : arvalid_arready_handshake
  assert property (arvalid_arready_handshake)
    else `uvm_error("ARVALID_HANDSHAKE", "ARVALID handshake protocol violated!")

  /*
  * rvalid_rready_handshake: Checks RVALID and RREADY handshake protocol.
  * Ensures RVALID remains asserted for one clock cycle if RREADY is not active.
  */
  property rvalid_rready_handshake;
    @(posedge ACLK) disable iff (!ARESETn)
      RVALID && !RREADY |-> ##1 RVALID;
  endproperty : rvalid_rready_handshake
  assert property (rvalid_rready_handshake)
    else `uvm_error("RVALID_HANDSHAKE", "RVALID handshake protocol violated!")

  /*
  * awvalid_awready_handshake: Checks AWVALID and AWREADY handshake protocol.
  * Ensures AWVALID remains asserted for one clock cycle if AWREADY is not active.
  */
  // property awvalid_awready_handshake;
    // @(posedge ACLK) disable iff (!ARESETn)
      // AWVALID && !AWREADY |-> ##1 AWVALID;
  // endproperty : awvalid_awready_handshake
  // assert property (awvalid_awready_handshake)
    // else `uvm_error("AWVALID_HANDSHAKE", "AWVALID handshake protocol violated!")

  /*
  * wvalid_wready_handshake: Checks WVALID and WREADY handshake protocol.
  * Ensures WVALID remains asserted for one clock cycle if WREADY is not active.
  */
  property wvalid_wready_handshake;
    @(posedge ACLK) disable iff (!ARESETn)
      WVALID && !WREADY |-> ##1 WVALID;
  endproperty : wvalid_wready_handshake
  assert property (wvalid_wready_handshake)
    else `uvm_error("WVALID_HANDSHAKE", "WVALID handshake protocol violated!")

  /*
  * bvalid_bready_handshake: Checks BVALID and BREADY handshake protocol.
  * Ensures BVALID remains asserted for one clock cycle if BREADY is not active.
  */
  property bvalid_bready_handshake;
    @(posedge ACLK) disable iff (!ARESETn)
      BVALID && !BREADY |-> ##1 BVALID;
  endproperty : bvalid_bready_handshake
  assert property (bvalid_bready_handshake)
    else `uvm_error("BVALID_HANDSHAKE", "BVALID handshake protocol violated!")

endinterface

`endif // AXI_INTERFACE
