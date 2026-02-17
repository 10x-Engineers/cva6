///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 15-Jan-2025
/// Description: This package defines the AHB-Lite bus interface signals,
/// in separate request and response channel structures.
///////////////////////////////////////////////////////////////////////////

package ahb_lite_pkg;

  import config_iopmp_pkg::AHB_LITE_ADDR_WIDTH;
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;

  // AHB REQUEST CHANNEL from interface
  typedef struct packed {
    logic [AHB_LITE_ADDR_WIDTH-1:0] haddr;      // 4 bytes address
    logic                           hwrite;     // Supported value: 1'b0, 1'b1 (R/W request supported)
    logic [2:0]                     hsize;      // Supported value: 3'b010 (4 bytes Transfer Size)
    logic [2:0]                     hburst;     // Supported value: 3'b000 (SINGLE)
    logic [3:0]                     hprot;      // Supported value: 4'b0011 (non-cacheable, non-bufferable, privileged, data access)
    logic [1:0]                     htrans;     // Supported value: 2'b00 (IDLE), 2'b10 (NONSEQ)
    logic                           hmastlock;  // Supported value: 1'b0 (No Lock Transfer)
    logic [AHB_LITE_DATA_WIDTH-1:0]	hwdata;     // 4 bytes write data
    logic                           hsel;       // Indicates if the slave is selected (1'b0: Slave not selected, 1'b1: Slave selected)
  } ahb_req_i_t;

  // AHB REQUEST CHANNEL with hready drive internally
  typedef struct packed {
    logic [AHB_LITE_ADDR_WIDTH-1:0] haddr;      // 4 bytes address
    logic                           hwrite;     // Supported value: 1'b0, 1'b1 (R/W request supported)
    logic [2:0]                     hsize;      // Supported value: 3'b010 (4 bytes Transfer Size)
    logic [2:0]                     hburst;     // Supported value: 3'b000 (SINGLE)
    logic [3:0]                     hprot;      // Supported value: 4'b0011 (non-cacheable, non-bufferable, privileged, data access)
    logic [1:0]                     htrans;     // Supported value: 2'b00 (IDLE), 2'b10 (NONSEQ)
    logic                           hmastlock;  // Supported value: 1'b0 (No Lock Transfer)
    logic [AHB_LITE_DATA_WIDTH-1:0]	hwdata;     // 4 bytes write data
    logic                           hready;     // Indicates the status of current transfer (1'b0: WAIT STATE, 1'b1: TRANSFER COMPLETED)
    logic                           hsel;       // Indicates if the slave is selected (1'b0: Slave not selected, 1'b1: Slave selected)
  } ahb_req_t;

  // AHB RESPONSE CHANNEL
  typedef struct packed {
    logic [AHB_LITE_DATA_WIDTH-1:0] hrdata;     // 4 bytes
    logic                           hresp;      // Supported value: 1'b0 (SUCCESS Response), 1'b1 (ERROR Response)
    logic                           hreadyout;  // Indicates the status of current transfer (1'b0: WAIT STATE, 1'b1: TRANSFER COMPLETED)
  } ahb_resp_t;

endpackage
