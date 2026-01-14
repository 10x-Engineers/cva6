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

package axi_c_pkg;

  import config_cycle_acc_pkg::*;

  typedef struct packed {
    logic [MASTER_ID_WIDTH-1:0]  aw_id;       // 5
    logic [AXI_ADDR_WIDTH-1:0]   aw_addr;     // 52/34
    logic [7:0]                  aw_len;      // 8
    logic [2:0]                  aw_size;     // 3
    logic [1:0]                  aw_burst;
    logic                        aw_lock;
    logic [3:0]                  aw_cache;
    logic [2:0]                  aw_prot;
    logic [3:0]                  aw_qos;
    logic [3:0]                  aw_region;
    logic [MASTER_USER_WDTH-1:0] aw_user;     // 6
  } aw_channel_t;

  typedef struct packed {
    logic [AXI_DATA_WIDTH-1:0]   w_data;
    logic [AXI_STRB_WIDTH-1:0]   w_strb;
    logic                        w_last;
    logic [MASTER_USER_WDTH-1:0] w_user;
  } w_channel_t;

  typedef struct packed {
    logic [MASTER_ID_WIDTH-1:0]  b_id;          // 5
    logic [1:0]                  b_resp;        // 2
    logic [MASTER_USER_WDTH-1:0] b_user;      // 6
  } b_channel_t;

  typedef struct packed {
    logic [MASTER_ID_WIDTH-1:0]  ar_id;       // 5
    logic [AXI_ADDR_WIDTH-1:0]   ar_addr;     // 64
    logic [7:0]                  ar_len;      // 8
    logic [2:0]                  ar_size;     // 3
    logic [1:0]                  ar_burst;
    logic                        ar_lock;
    logic [3:0]                  ar_cache;
    logic [2:0]                  ar_prot;
    logic [3:0]                  ar_qos;
    logic [3:0]                  ar_region;
    logic [MASTER_USER_WDTH-1:0] ar_user;    // 6
  } ar_channel_t;

  typedef struct packed {
    logic [MASTER_ID_WIDTH-1:0]  r_id;       // 5
    logic [AXI_DATA_WIDTH-1:0]   r_data;
    logic [1:0]                  r_resp;
    logic                        r_last;
    logic [MASTER_USER_WDTH-1:0] r_user;
  } r_channel_t;

endpackage
