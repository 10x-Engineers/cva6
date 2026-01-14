///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 16-June-2025
/// Description: This module determines the target IOPMP region/section
/// RFM_ACcess based on the AHB Request address and configuration. It detects
/// misaligned, legal and illegal addresses, and generates appropriate
/// control signals for address decode and Response Generator block. This
/// module supports flexible configurations via parameters for different
/// IOPMP models and feature enables.
///
///      IOPMP ADDRESS SPACE
///
///    +---------------------+  0xFFFF_FFFF
///    |      ILLEGAL        |
///    +---------------------+
///    |     SECTION 2       |
///    +---------------------+
///    |      ILLEGAL        |
///    +---------------------+
///    |     SECTION 1       |
///    +---------------------+
///    |      ILLEGAL        |
///    +---------------------+  0x0000_0000
///
/// The placement of SECTION 1 and SECTION 2 depends on configuration
/// paramerters CFG.BASE_ADDR and CFG.ENTRY_OFFSET.
///
///////////////////////////////////////////////////////////////////////////

module address_check
  import config_iopmp_pkg::AHB_LITE_ADDR_WIDTH;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  // AHB-LITE Interface ==> Address Check
  input  logic [AHB_LITE_ADDR_WIDTH-1:0] req_addr,                  // Incoming Request Address

  // Top Wrapper ==> Address Check
  input  logic                           valid_req,                 // Indicates AHB Request validity. A Request is valid when htrans == 2, hsel == 1 and hready == 1

  // Address Check ==> Regmap/AHB Response Generator
  output logic                           is_addr_legal,             // Indicates address is legal or illegal

  // Address Check ==> Regmap
  output logic                           base_reg_legal,            // Indicates whether incoming address belongs to a legal register in BASE region section 1
  output logic                           info_legal,                // Indicates whether incoming address belongs to a legal INFO register
  output logic                           prog_prot_legal,           // Indicates whether incoming address belongs to a legal PROGRAMMING PROTECTION register
  output logic                           config_prot_legal,         // Indicates whether incoming address belongs to a legal CONFIGURATION PROTECTION register
  output logic                           err_rpt_legal,             // Indicates whether incoming address belongs to a legal ERROR REPORTING register
  output logic                           mdcfg_legal,               // Indicates whether incoming address belongs to MDCFG region section 1
  output logic                           srcmd_legal,               // Indicates whether incoming address belongs to a legal register in SRCMD region section 1
  output logic                           entry_array_legal          // Indicates whether incoming address is legal or not in entry array
);

  // Local parameters for base address of section 1 and 2
  // Base Address of each section must be 64K byte aligned
  localparam logic [15:0] BASE_ADDR_OF_SECT_1    = CFG.BASE_ADDR[31:16];
  localparam logic [15:0] BASE_ADDR_OF_SECT_2    = CFG.BASE_ADDR[31:16] + CFG.ENTRY_OFFSET[31:16];

  localparam              REG_SIZE               = 4;             // Register size in IOPMP is 4 byte
  localparam logic [15:0] MAX_BASE_REG_OFFSET    = 16'h007C;      // This parameter indicates the maximum value of offset address that lies in BASE region
  localparam logic [15:0] MDCFG_START_OFFSET     = 16'h0800;      // This parameter indicates the start offset address of MDCFG region
  localparam logic [15:0] SRCMD_START_OFFSET     = 16'h1000;      // This parameter indicates the start offset address of SRCMD region
  localparam logic [15:0] MAX_MDCFG_OFFSET       = (MDCFG_START_OFFSET + (CFG.MD_NUM << 2)) - REG_SIZE;     // Indicates the maximum offset address that can belong to region 3 (MDCFG)
  localparam logic [15:0] MAX_SRCMD_FMT_0_OFFSET = (SRCMD_START_OFFSET + (CFG.RRID_NUM << 5)) - REG_SIZE;   // Indicates the maximum offset address that can belong to region 5 (SRCMD) when SRCMD Format is 0
  localparam logic [15:0] MAX_SRCMD_FMT_2_OFFSET = (SRCMD_START_OFFSET + (CFG.MD_NUM << 5)) - REG_SIZE;     // Indicates the maximum offset address that can belong to region 5 (SRCMD) when SRCMD Format is 2
  localparam logic [15:0] MAX_ENTRY_ARRAY_OFFSET = (CFG.ENTRY_NUM << 4) - REG_SIZE;   // Indicates the maximum offset address that can belong to section 2 (ENTRY ARRAY)

  //###############################
  // Internal Signals Declarations
  //###############################
  logic [15:0] req_base_addr, req_offset_addr;    // Indicates the base and offset of incoming request address
  logic        is_section_1, is_section_2;        // Indicates the section to which incoming request address belongs
  logic        is_addr_legal_section_1;           // Indicates if the incoming address belongs to a legal register in section 1
  logic        info_reg1_legal, info_reg2_legal;  // Indicates if incoming address belongs to INFO registers
  logic        is_base_register;          // Indicates if incoming address lies in BASE region
  logic        is_srcmd_register;         // Indicates if incoming address lies in SRCMD region
  logic        is_entry_array;            // Indicates if incoming address lies in ENTRY ARRAY region
  logic        config_prot_maybe_legal;   // Indicates if incoimg address belongs to CONFIGURATION PROTECTION registers
  logic        config_prot_illegal1, config_prot_illegal2;      // Indicates if incoming address refers to illegal CONFIGURATION PROTECTION registers due to certain configuration parameter value
  logic        srcmd_illegal1, srcmd_illegal2, srcmd_illegal3;  //  Indicates if incoming address refers to illegal SRCMD registers due to some holes or certain configuration parameter value
  logic        entry_array_illegal1, entry_array_illegal2;      //  Indicates if incoming address refers to illegal ENTRY ARRAY registers due to certain configuration parameter value
  logic        err_rpt1_maybe_legal, err_rpt1_legal, err_rpt2_maybe_legal, err_rpt2_legal;    // Indicates if incoimg address belongs to ERROR REPORTING registers
  logic        err_rpt1_illegal1, err_rpt2_illegal1, err_rpt2_illegal2, err_rpt2_illegal3;    // Indicates if incoming address refers to illegal ERROR REPORTING registers due to certain configuration parameter value

  // Input request base and offset addresses
  assign req_base_addr   = req_addr[31:16];    // Base address which is upper 16 bits of incoming request address
  assign req_offset_addr = req_addr[15:0];     // Offset address which is lower 16 bits of incoming request address

  // Incoming request address must be 4 byte aligned for a valid request.
  assign addr_aligned = (req_addr[1:0] == 2'b00);

  // Determine whether the address lies in Section 1 or Section 2 based on the base address
  assign is_section_1 = (req_base_addr == BASE_ADDR_OF_SECT_1);
  assign is_section_2 = (req_base_addr == BASE_ADDR_OF_SECT_2);

  //****************************************************************************************************
  // Check if offset maps to Section 1 legal register regions
  //
  //           SECTION 1 ADDRESS SPACE
  //
  //      +------------------------------+  0x0000
  //      |  REGION 1 : BASE Registers   |
  //      +------------------------------+  0x0080
  //      |      REGION 2 : ILLEGAL      |
  //      +------------------------------+  0x0800
  //      |       REGION 3 : MDCFG       |
  //      +------------------------------+  0x08FC
  //      |      REGION 4 : ILLEGAL      |
  //      +------------------------------+  0x1000
  //      |       REGION 5 : SRCMD       |
  //      +------------------------------+  0x17FC
  //
  //****************************************************************************************************

  //****************************************************************************************************
  // Check if offset is in the legal BASE register region
  // and check if the offset addresses legal registers only
  //****************************************************************************************************

  assign is_base_register = (req_offset_addr <= MAX_BASE_REG_OFFSET);

  // info_reg1 <REGISTER NAME>: <Offset>
  //      VERSION: 0x0000, IMPLEMENTATION: 0x0004, HWCFG0: 0x0008, HWCFG1: 0x000C
  assign info_reg1_legal = (is_base_register) && (req_offset_addr[6:4] == 3'b000);

  // info_reg2 <REGISTER NAME>: <Offset>
  //      HWCFG2: 0x0010, ENTRYOFSET: 0x0014, BASEADDR: 0x0018, ILLEGAL: 0x001C
  assign info_reg2_legal = (is_base_register) && (req_offset_addr[6:4] == 3'b001) && (!(&req_offset_addr[3:2]));

  // Determine info register legal
  assign info_legal = (is_section_1) && (info_reg1_legal || info_reg2_legal);

  // prog_prot <REGISTER NAME>: <Offset>
  //      MDSTALL: 0x0030, MDSTALLH: 0x0034, RRIDSCP: 0x0038, ILLEGAL: 0x003C
  assign prog_prot_legal = (is_section_1) && (is_base_register) && (req_offset_addr[6:4] == 3'b011) && (!(&req_offset_addr[3:2]));

  // config_prot <REGISTER NAME>: <Offset>
  //      MDLCK: 0x0040, MDLCKH: 0x0044, MDCFGLCK: 0x0048, ENTRYLCK: 0x004C
  // Some of these registers selectively become illegal based on configuration parameters
  assign config_prot_maybe_legal = (is_base_register) && (req_offset_addr[6:4] == 3'b100);

  // err_rpt1 <REGISTER NAME>: <Offset>
  //      ERR_CFG: 0x0060, ERR_INFO: 0x0064, ERR_REQADDR: 0x0068, ERR_REQADDRH: 0x006C
  // Only legal if Error Capture enabled
  // Some of these registers selectively become illegal based on configuration parameters
  assign err_rpt1_maybe_legal = (is_base_register) && (req_offset_addr[6:4] == 3'b110) && (CFG.ERROR_CAPTURE_EN);

  // err_rpt2 <REGISTER NAME>: <Offset>
  //      ERR_REQID: 0x0070, ERR_MFR: 0x0074, ERR_MSIADDR: 0x0078, ERR_MSIADDRH: 0x007C
  // Only legal if Error Capture enabled
  // Some of these registers selectively become illegal based on configuration parameters
  assign err_rpt2_maybe_legal = (is_base_register) && (req_offset_addr[6:4] == 3'b111) && (CFG.ERROR_CAPTURE_EN);

  // ***************************************************************************************************
  // Check for specific illegal addresses because of certain configuration parameter values
  // ***************************************************************************************************

  // Check the following config_prot registers which become illegal becasue of configuration parameters
  //
  //      REGISTERS   OFFSET      IDENTIFYING BITS       CONFIGURATION PARAMETER
  //      ---------   ------      ----------------       -----------------------
  //      MDLCK       0x0040      [3] == 1'b0            CFG.SRCMD_FMT_1
  //      MDLCKH      0x0044      [3] == 1'b0            CFG.SRCMD_FMT_1
  //      MDCFGLCK    0x0048      [3:2] == 2'b10         CFG.MDCFG_FMT_1 or CFG.MDCFG_FMT_2

  // If SRCMD Format is 1, there is no physcial SRCMD Table and MDLCK and MDLCKH registers are illegal
  assign config_prot_illegal1 = (CFG.SRCMD_FMT_1) && (!req_offset_addr[3]);

  // If MDCFG Format is 1 or 2, there is no physcial MDCFG Table and MDCFGLCK register is illegal
  assign config_prot_illegal2 = (CFG.MDCFG_FMT_1 || CFG.MDCFG_FMT_2) && (req_offset_addr[3] && (!req_offset_addr[2]));

  // Since config_prot has legal and illegal addresses, determine only the legal addresses
  assign config_prot_legal = (is_section_1) && (config_prot_maybe_legal) && (!(config_prot_illegal1 || config_prot_illegal2));

  // Check the following err_rpt1 register which become illegal because of configuration parameters
  //
  //      REGISTERS         OFFSET      IDENTIFYING BITS       CONFIGURATION PARAMETER
  //      ---------         ------      ----------------       -----------------------
  //      ERR_REQADDRH      0x006C      [3:2] == 2'b11         !CFG.ADDRH_EN

  // If ADDRH_EN = 0, ERR_REQADDRH becomes illegal.
  assign err_rpt1_illegal1 = (!CFG.ADDRH_EN) && (&req_offset_addr[3:2]);

  // Since err_rpt1 has legal and illegal addresses, determine only the legal addresses
  assign err_rpt1_legal = (err_rpt1_maybe_legal) && (!err_rpt1_illegal1);

  // Check the following err_rpt2 register which become illegal because of configuration parameters
  //
  //      REGISTERS         OFFSET      IDENTIFYING BITS       CONFIGURATION PARAMETER
  //      ---------         ------      ----------------       -----------------------
  //      ERR_MFR           0x0074      [3:2] == 2'b01         !CFG.MFR_EN
  //      ERR_MSIADDRH      0x007C      [3:2] == 2'b11         (CFG.MSI_EN and !CFG.ADDRH_EN)
  //      ERR_MSIADDR       0x0078      [3] == 1'b1            !CFG.MSI_EN
  //      ERR_MSIADDRH      0x007C      [3] == 1'b1            !CFG.MSI_EN

  // If MFR_EN = 0, ERR_MFR becomes illegal.
  assign err_rpt2_illegal1 = (!CFG.MFR_EN) && ((!req_offset_addr[3]) && req_offset_addr[2]);

  // If MSI_EN = 0, ERR_MSIADDR and ERR_MSIADDRH become illegal
  assign err_rpt2_illegal2 = (!CFG.MSI_EN) && (req_offset_addr[3]);

  // If ADDRH_EN = 0 when MSI_EN = 1, ERR_MSIADDRH becomes illegal
  assign err_rpt2_illegal3 = (CFG.MSI_EN) && (!CFG.ADDRH_EN) && (&req_offset_addr[3:2]);

  // Since err_rpt2 has legal and illegal addresses, determine only the legal addresses
  assign err_rpt2_legal = (err_rpt2_maybe_legal) && (!(err_rpt2_illegal1 || err_rpt2_illegal2 || err_rpt2_illegal3));

  // Determine error reporting register legal
  assign err_rpt_legal = (is_section_1) && (err_rpt1_legal || err_rpt2_legal);

  // Since BASE region has legal and illegal addresses, determine only the legal addresses
  assign base_reg_legal = ((info_legal) || (prog_prot_legal) || (config_prot_legal) || (err_rpt_legal));

  //****************************************************************************************************
  // Check if offset is in legal MDCFG register region
  // MDCFG table exists only in MDCFG format 0
  //****************************************************************************************************

  // For MDCFG Format 0, MDCFG region is valid and any offset that lies in this region is legal based on supported number of Memory Domains (MDs)
  // For MDCFG Format 1 or 2, MDCFG region is not valid
  assign mdcfg_legal = (CFG.MDCFG_FMT_0) && (is_section_1) && ((req_offset_addr >= MDCFG_START_OFFSET) && (req_offset_addr <= MAX_MDCFG_OFFSET));

  //****************************************************************************************************
  // Check if offset is in legal SRCMD register region
  // SRCMD table exits only in SRCMD format 1 or 2
  // Some of these registers selectively become illegal based on configuration parameters
  //****************************************************************************************************

  // For SRCMD Format 0, SRCMD region is valid and the range of this region is determined by supported number of RRIDs
  // For SRCMD Format 2, SRCMD region is valid and the range of this region is determined by supported number of MDs
  // For SRCMD Format 1, there is no SRCMD Table so SRCMD region is not valid
  assign is_srcmd_register =  (CFG.SRCMD_FMT_0 && ((req_offset_addr >= SRCMD_START_OFFSET) && (req_offset_addr <= MAX_SRCMD_FMT_0_OFFSET))) ||
                              (CFG.SRCMD_FMT_2  && ((req_offset_addr >= SRCMD_START_OFFSET) && (req_offset_addr <= MAX_SRCMD_FMT_2_OFFSET)));

  // ***************************************************************************************************
  // Check for illegal addresses (holes) that exist in SRCMD region
  // Check for specific illegal addresses because of certain configuration parameter values
  // ***************************************************************************************************

  // SRCMD register region has some illegal registers (holes) and some registers which become illegal because of configuration parameters
  //
  //      REGISTERS   OFFSET                  IDENTIFYING BITS        CONFIGURATION PARAMETER               ILLEGAL
  //      ---------   ------                  ----------------        -----------------------               -------
  //      -           0x1018, 0x1038, ...     [4:3] = 2'b11           N/A                                   illegal1
  //      -           0x101C, 0x103C, ...     [4:3] = 2'b11           N/A                                   illegal1
  //      SRCMD_R     0x1008, 0x1028, ...     [4:3] = 2'b(01,10,11)   CFG.SRCMD_FMT_0 and !CFG.SPS_EN       illegal2
  //      SRCMD_RH    0x100C, 0x102C, ...     [4:3] = 2'b(01,10,11)   CFG.SRCMD_FMT_0 and !CFG.SPS_EN       illegal2
  //      SRCMD_W     0x1010, 0x1030, ...     [4:3] = 2'b(01,10,11)   CFG.SRCMD_FMT_0 and !CFG.SPS_EN       illegal2
  //      SRCMD_WH    0x1014, 0x1034, ...     [4:3] = 2'b(01,10,11)   CFG.SRCMD_FMT_0 and !CFG.SPS_EN       illegal2
  //      SRCMD_R     0x1008, 0x1028, ...     [4:3] = 2'b(01,10,11)   CFG.SRCMD_FMT_2                       illegal3
  //      SRCMD_RH    0x100C, 0x102C, ...     [4:3] = 2'b(01,10,11)   CFG.SRCMD_FMT_2                       illegal3
  //      SRCMD_W     0x1010, 0x1030, ...     [4:3] = 2'b(01,10,11)   CFG.SRCMD_FMT_2                       illegal3
  //      SRCMD_WH    0x1014, 0x1034, ...     [4:3] = 2'b(01,10,11)   CFG.SRCMD_FMT_2                       illegal3

  assign srcmd_illegal1 = (&req_offset_addr[4:3]);
  assign srcmd_illegal2 = (CFG.SRCMD_FMT_0 && (!CFG.SPS_EN) && (|req_offset_addr[4:3]));
  assign srcmd_illegal3 = (CFG.SRCMD_FMT_2 && (|req_offset_addr[4:3]));

  // Since SRCMD region has legal and illegal addresses, determine only the legal addresses
  assign srcmd_legal = (is_section_1) && (is_srcmd_register) && (!(srcmd_illegal1 || srcmd_illegal2 || srcmd_illegal3));

  //****************************************************************************************************
  // Check if offset maps to Section 2 legal register regions
  //
  //           SECTION 2 ADDRESS SPACE
  //
  //      +------------------------------+  0x0000
  //      |         ENTRY ARRAY          |
  //      +------------------------------+  0x0800
  //
  //****************************************************************************************************

  assign is_entry_array = (req_offset_addr <= MAX_ENTRY_ARRAY_OFFSET);

  // ***************************************************************************************************
  // Check for illegal addresses (holes) that exist in ENTRY ARRAY region
  // Check for specific illegal addresses because of certain configuration parameter values
  // ***************************************************************************************************

  // ENTRY_USER_CFG is always illegal
  assign entry_array_illegal1 = (&req_offset_addr[3:2]);

  // Check the following entry_array register which become illegal because of configuration parameters
  //
  //      REGISTERS     OFFSET                  IDENTIFYING BITS       CONFIGURATION PARAMETER
  //      ---------     ------                  ----------------       -----------------------
  //      ENTRY_ADDRH   0x0004, 0x0014, ...     [3:2] == 2'b01         !CFG.ADDRH_EN

  assign entry_array_illegal2 = (!CFG.ADDRH_EN) && ((!req_offset_addr[3]) && req_offset_addr[2]);

  // Since ENTRY ARRAY region has legal and illegal addresses, determine only the legal addresses
  assign entry_array_legal = (is_section_2) && (is_entry_array) && (!(entry_array_illegal1 || entry_array_illegal2));

  //****************************************************************************************************
  // Calculate if address is legal or not w.r.t to section
  //****************************************************************************************************

  // Calculate if address maps to a legal section 1 address
  assign is_addr_legal_section_1 = ((base_reg_legal) || (mdcfg_legal) || (srcmd_legal));

  // Address is legal only if:
  // - Request is valid
  // - Address is 4-byte aligned
  // - Address lies in a legal region of Section 1 or ENTRY ARRAY
  assign is_addr_legal = (is_addr_legal_section_1 || entry_array_legal) && addr_aligned && valid_req;

endmodule
