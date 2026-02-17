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

package config_iopmp_pkg;

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
  localparam MD_NUM           = 31;
  localparam PRIO_ENTRY       = 48;
  localparam ENTRY_NUM        = 128;
  localparam CHK_X            = 1;
  localparam NO_X             = 0;
  localparam NO_W             = 0;
  localparam TOR_EN           = 0;
  localparam PRIENT_PROG      = 0;
  localparam STALL_EN         = 1;
  localparam PEIS             = 1;
  localparam MFR_EN           = 0;
  localparam ADDRH_EN         = 1;
  localparam MSI_EN           = 1;
  localparam SE_EN            = 0;
  localparam ERROR_CAPTURE_EN = 1;
  localparam IMP_ENTRYLCK     = 1;
  localparam MDCFGLCK_F       = 0;
  localparam ENTRYLCK_F       = 0;

  `ifdef CFG_IOPMP_SRCMD_FMT_0
  localparam SRCMD_FMT        = 0;
  localparam RRID_NUM         = 24;
  localparam IMP_MDLCK        = 0;
  localparam SPS_EN           = 0;
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
  localparam IMP_MDCFGLCK     = 0;
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

  typedef struct packed {
    bit					 SRCMD_FMT_0;
    bit					 SRCMD_FMT_1;
    bit					 SRCMD_FMT_2;
    bit					 MDCFG_FMT_0;
    bit					 MDCFG_FMT_1;
    bit					 MDCFG_FMT_2;
		bit					 TOR_EN;
		bit					 SPS_EN;
		bit					 PRIENT_PROG;
		bit					 CHK_X;
    bit					 NO_X;
    bit					 NO_W;
    bit					 STALL_EN;
		bit					 PEIS;
    bit					 MFR_EN;
		logic [6:0]  MD_ENTRY_NUM;
    logic [5:0]  MD_NUM;
		bit 				 ADDRH_EN;
		logic [15:0] RRID_NUM;
    logic [15:0] ENTRY_NUM;
		logic [15:0] PRIO_ENTRY;
    int signed   ENTRY_OFFSET;
		int unsigned BASE_ADDR;
    bit 				 IMP_MDLCK;
    bit          IMP_MDCFGLCK;
		logic [5:0]  MDCFGLCK_F;
		bit 				 IMP_ENTRYLCK;
    logic [15:0] ENTRYLCK_F;
		bit 				 ERROR_CAPTURE_EN;
    bit 				 MSI_EN;
    bit 				 SE_EN;
  } iopmp_cfg_t;

  localparam iopmp_cfg_t iopmp_cfg_default = '{
  	SRCMD_FMT_0:      bit'(SRCMD_FMT==0),
  	SRCMD_FMT_1:      bit'(SRCMD_FMT==1),
  	SRCMD_FMT_2:      bit'(SRCMD_FMT==2),
  	MDCFG_FMT_0:      bit'(MDCFG_FMT==0),
  	MDCFG_FMT_1:      bit'(MDCFG_FMT==1),
  	MDCFG_FMT_2:      bit'(MDCFG_FMT==2),
  	TOR_EN:           bit'(TOR_EN),
  	SPS_EN:           bit'(SPS_EN),
  	PRIENT_PROG:      bit'(PRIENT_PROG),
  	CHK_X:            bit'(CHK_X),
  	NO_X:             bit'(NO_X),
  	NO_W:             bit'(NO_W),
  	STALL_EN:         bit'(STALL_EN),
  	PEIS:             bit'(PEIS),
  	MFR_EN:           bit'(MFR_EN),
  	MD_ENTRY_NUM:     unsigned'(MD_ENTRY_NUM),
  	MD_NUM:           unsigned'(MD_NUM),
  	ADDRH_EN:         bit'(ADDRH_EN),
  	RRID_NUM:         unsigned'(RRID_NUM),
  	ENTRY_NUM:        unsigned'(ENTRY_NUM),
  	PRIO_ENTRY:       unsigned'(PRIO_ENTRY),
  	ENTRY_OFFSET:     signed'(ENTRY_OFFSET),
  	BASE_ADDR:        unsigned'(BASE_ADDR),
  	IMP_MDLCK:        bit'(IMP_MDLCK),
    IMP_MDCFGLCK:     bit'(IMP_MDCFGLCK),
  	MDCFGLCK_F:       unsigned'(MDCFGLCK_F),
  	IMP_ENTRYLCK:     bit'(IMP_ENTRYLCK),
  	ENTRYLCK_F:       unsigned'(ENTRYLCK_F),
  	ERROR_CAPTURE_EN: bit'(ERROR_CAPTURE_EN),
  	MSI_EN:           bit'(MSI_EN),
  	SE_EN:            bit'(SE_EN)
  };

endpackage
