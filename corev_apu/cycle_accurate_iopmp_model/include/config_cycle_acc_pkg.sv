///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Malik Faayez Muhammad <faayez.muhammad@10xengineers.ai>
/// Date Created: 21-July-2025
/// Description:
///////////////////////////////////////////////////////////////////////////

package config_cycle_acc_pkg;

  // AXI4 Parameters
  localparam MASTER_ID_WIDTH  = 5;                  // Max 32 transactions per channel
  localparam MASTER_USER_WDTH = 6;                  // RRID of the transaction (Max 64)
  localparam SLAVE_ID_WIDTH   = 6;                  // MSB Indicates MSI Write Transfer, Lower 5-bit contains transaction ID
  localparam SLAVE_USER_WDTH  = 11;                 // Upper 5-bits indicates the WD_TAG, Lower 6-bit contains RRID of the transaction
  localparam AXI_ADDR_WIDTH   = 52;                 // Supported Physical Address: (32-bit system) ? 34 : 52;
  localparam AXI_DATA_WIDTH   = 64;                 // Write Data Width
  localparam AXI_STRB_WIDTH   = AXI_DATA_WIDTH/8;   // Write Data Strobe Width
  localparam MAX_BURST_LEN    = 16;                 // Maximum Burst length supported on both channels

  // AHB LITE Parameters
  localparam AHB_LITE_ADDR_WIDTH = 32;
  localparam AHB_LITE_DATA_WIDTH = 32;

  //////////////////////////////////////////////////////////////////////////////
  // Implementation specific parameters                                       //
  //////////////////////////////////////////////////////////////////////////////
  localparam MAX_TRANS        = 32;
  localparam BASE_ADDR        = 32'h80000000;   // BASE_ADDR should be 64K byte aligned.
  localparam ENTRY_OFFSET     = 32'h10000;      // ENRTY_OFFSET should be 64K byte aligned.
  localparam MD_NUM           = 63;
  localparam PRIO_ENTRY       = 48;
  localparam ENTRY_NUM        = 128;
  localparam CHK_X            = 1;
  localparam NO_X             = 0;
  localparam NO_W             = 0;
  localparam TOR_EN           = 1;
  localparam PRIENT_PROG      = 1;
  localparam STALL_EN         = 1;
  localparam PEIS             = 1;
  localparam MFR_EN           = 1;
  localparam ADDRH_EN         = 1;
  localparam MSI_EN           = 1;
  localparam SE_EN            = 0;
  localparam ERROR_CAPTURE_EN = 1;
  localparam IMP_ENTRYLCK     = 1;
  localparam MDCFGLCK_F       = 0;
  localparam ENTRYLCK_F       = 0;

  `ifdef CFG_IOPMP_SRCMD_FMT_0
  localparam SRCMD_FMT        = 0;
  localparam RRID_NUM         = 64;
  localparam IMP_MDLCK        = 1;
  localparam SPS_EN           = 1;
  `endif

  `ifdef CFG_IOPMP_SRCMD_FMT_1
  localparam SRCMD_FMT        = 1;
  localparam RRID_NUM         = MD_NUM;
  localparam IMP_MDLCK        = 0;
  localparam SPS_EN           = 0;
  `endif

  `ifdef CFG_IOPMP_SRCMD_FMT_2
  localparam SRCMD_FMT        = 2;
  localparam RRID_NUM         = 32;
  localparam IMP_MDLCK        = 1;
  localparam SPS_EN           = 0;
  `endif

  `ifdef CFG_IOPMP_MDCFG_FMT_0
  localparam MDCFG_FMT        = 0;
  localparam IMP_MDCFGLCK     = 1;
  localparam MD_ENTRY_NUM     = 0;
  `endif

  `ifdef CFG_IOPMP_MDCFG_FMT_1
  localparam MDCFG_FMT        = 1;
  localparam IMP_MDCFGLCK     = 0;
  localparam MD_ENTRY_NUM     = 1;
  `endif

  `ifdef CFG_IOPMP_MDCFG_FMT_2
  localparam MDCFG_FMT        = 2;
  localparam IMP_MDCFGLCK     = 0;
  localparam MD_ENTRY_NUM     = 1;
  `endif

  localparam SRCMD_FMT_0 = (SRCMD_FMT==0);
  localparam SRCMD_FMT_1 = (SRCMD_FMT==1);
  localparam SRCMD_FMT_2 = (SRCMD_FMT==2);
  localparam MDCFG_FMT_0 = (MDCFG_FMT==0);
  localparam MDCFG_FMT_1 = (MDCFG_FMT==1);
  localparam MDCFG_FMT_2 = (MDCFG_FMT==2);

endpackage