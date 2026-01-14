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
/// Description: This package defines the structured register map for an
/// IOPMP (I/O Physical Memory Protection) unit. It also defines all the
/// structs required within or outside of Register File Manager module.
///////////////////////////////////////////////////////////////////////////


package rfm_pkg;

  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;

  //****************************************************************************************************
  // INFO REGISTERS
  //****************************************************************************************************

  // VERSION register is a read-only register reporting IOPMP comfiguration information of the instance:
  // 1. vendor ID
  // 2. Specification version
  typedef struct packed {
    logic [7:0] specver;                    // The specification version
    logic [23:0] vendor;                    // The vendor ID
  } version_t;

  // IMPLEMENTATION register is a read-only register reporting implementation ID specific to the instance
  typedef struct packed {
    logic [31:0] impid;                     // The user-defined implementation ID.
  } implementation_t;

  // HWCFG0 register is one of hardware configuration registers reporting features supported by IOPMP
  typedef struct packed {
    logic        enable;                    // Indicate if the IOPMP checks transactions by default.
                                            // If it is implemented, it should be initial to 0 and sticky to 1.
                                            // If it is not implemented, it should be wired to 1.

    logic        addrh_en;                  // Indicate if the IOPMP implements ENTRY_ADDRH(i)

    logic [5:0]  md_num;                    // Indicate the supported number of MD in the instance

    logic [6:0]  md_entry_num;              // When HWCFG0.mdcfg_fmt =
                                            //  -> 0x0: must be zero
                                            //  -> 0x1 or 0x2: md_entry_num indicates each memory domain exactly
                                            // has (md_entry_num + 1) entries in a memory domain
                                            // md_entry_num is locked if HWCFG0.enable is 1.

    logic        mfr_en;                    // Indicate if the IOPMP implements Multi Faults Record Extension

    logic        pees;                      // Indicate if the IOPMP implements the error suppression per entry

    logic        peis;                      // Indicate if the IOPMP implements interrupt suppression per entry

    logic        stall_en;                  // Indicate if the IOPMP implements stall-related features, which are MDSTALL,
                                            // MDSTALLH, and RRIDSCP registers.

    logic        no_w;                      // Indicate if the IOPMP always fails write accesses

    logic        no_x;                      // For chk_x=1, the IOPMP with no_x=1 always fails on an instruction fetch; otherwise,
                                            // it should depend on x-bit in ENTRY_CFG(i). For chk_x=0, no_x has no effect

    logic        chk_x;                     // Indicate if the IOPMP implements the check of an instruction fetch. On chk_x=0, all fields of illegal
                                            // instruction fetches are ignored, including HWCFG0.no_x, ENTRY_CFG(i).sixe, ENTRY_CFG(
                                            // i).esxe, and ENTRY_CFG(i).x. It should be wired to zero if there is no indication for an instruction fetch
                                            // otherwise, it should depend on x-bit in ENTRY_CFG(i).

    logic        rrid_transl_prog;          // A write-1-set bit is sticky to 0 and indicate if the field sid_transl
                                            // is programmable. Support only for rrid_transl_en=1, otherwise, wired to 0.

    logic        rrid_transl_en;            // Indicate the if tagging a new RRID on the requestor port is supported

    logic        prient_prog;               // A write-1-clear bit is sticky to 0 and indicates if HWCFG2.prio_entry
                                            // is programmable. Reset to 1 if the implementation supports programmable
                                            // prio_entry, otherwise, wired to 0.

    logic        user_cfg_en;               // Indicate if user customized attributes is supported; which are
                                            // ENTRY_USER_CFG(i) registers.

    logic        sps_en;                    // Indicate secondary permission settings is supported; which are SRCMD_R/RH(i)
                                            // and SRCMD_W/WH registers

    logic        tor_en;                    // Indicate if TOR is supported

    logic [1:0]  srcmd_fmt;                 // Indicate the MDCFG format
                                            //  -> 0x0: Format 0. SRCMD_EN(s) and SRCMD_ENH(s) are available.
                                            //  -> 0x1: Format 1. No SRCMD table.
                                            //  -> 0x2: Format 2. SRCMD_PERM(m) and SRCMD_PERMH(m) are available.
                                            //  -> 0x3: reserved.

    logic [1:0]  mdcfg_fmt;                 // Indicate the MDCFG format
                                            //  -> 0x0: Format 0. MDCFG table is implemented.
                                            //  -> 0x1: Format 1. No MDCFG table. HWCFG.md_entry_num is fixed.
                                            //  -> 0x2: Format 2. No MDCFG table. HWCFG.md_entry_num is programmable.
                                            //  -> 0x3: reserved.
  } hwcfg0_t;

  // HWCFG1 register is one of hrdware configuration registers reporting features supported by IOPMP.
  typedef struct packed {
    logic [15:0] entry_num;                 // Indicate the supported number of entries in the instance
    logic [15:0] rrid_num;                  // Indicate the supported number of RRID in the instance
  } hwcfg1_t;

  // HWCFG2 register is one of hrdware configuration registers reporting features supported by IOPMP.
  typedef struct packed {
    logic [15:0] rrid_transl;               // Indicate the supported number of entries in the instance
    logic [15:0] prio_entry;                // Indicate the supported number of RRID in the instance
  } hwcfg2_t;

  // ENTRYOFFSET register indicates the offset address of ENTRY ARRAY from the base of IOPMP.
  typedef struct packed {
    logic signed [31:0] offset;             // Indicate the offset address of the IOPMP array from the base
                                            // of an IOPMP instance, a.k.a. the address of VERSION.
                                            // Note: the offset is a signed number. That is, the IOPMP array can be placed in front of VERSION.
  } entry_offset_t;

	// BASEADDR indicates the base address of IOPMP i.e. Address of VERSION register
  typedef struct packed {
    logic [31:0] base;                      // Indicates the base address of IOPMP.
  } base_addr_t;

  // INFO Registers Packed Struct
	typedef struct packed {
    version_t        version;
    implementation_t imp;
    hwcfg0_t         hwcfg0;
    hwcfg1_t         hwcfg1;
    hwcfg2_t         hwcfg2;
    entry_offset_t   entry_offset;
    base_addr_t      base_addr;
  } info_reg_t;

  //****************************************************************************************************
  // PROGRAMMING PROTECTION REGISTERS
  //****************************************************************************************************

  // MDSTALL is an optional register and used to support atomicity issue while programming the IOPMP, as the IOPMP rule may not be updated in a single transaction.
  typedef struct packed {
    logic        is_busy;                   // Indicates the status of previous writing MDSTALL and RRIDSCP
                                            //  -> 0: the write has taken effect or no previous write
                                            //  -> 1: the write has not taken effect

    logic [30:0] md;                        // Writing md[i]=1 selects MD i; reading md[i] = 1 means MD i selected

    logic        exempt;                    // Stall transactions from selected RRIDs
                                            //  -> 0: the RRIDs are associated with a selected MD
                                            //  -> 1: the RRIDs are not associated with any selected MD
  } mdstall_t;

  // MDSTALLH is an optional register implemented along with MDSTALL to support upto 63 memory domains (MDs) while programming the IOPMP
  typedef struct packed {
    logic [31:0] mdh;                       // Writting mdh[i]=1 selects MD i+31; reading mdh[i] = 1 means MD i+31 selected.
  } mdstallh_t;

  // RRIDSCP is an optional register and used to support atomicity issue while programming the IOPMP, as the IOPMP rule may not be updated in a single transaction.
  typedef struct packed {
    logic [1:0]  stat;                      // Stat is ready-only and located at [31:30]
                                            // 0: RRIDSCP not implemented
                                            // 1: transactions associated with selected RRID are stalled
                                            // 2: transactions associated with selected RRID are not stalled
                                            // 3: unimplemented or unselectable RRID

    logic [1:0]  op;                        // 0x0: query
                                            // 0x1: stall transactions associated with selected RRID
                                            // 0x2: do not stall transactions associated with selected RRID
                                            // 0x3: reserved

    logic [15:0] rrid;                      // RRID to select
  } rridscp_t;

  // PROGRAMMING PROTECTION Registers Packed Struct
	typedef struct packed {
    mdstall_t  mdstall;
    mdstallh_t mdstallh;
    rridscp_t  rridscp;
	} prog_prot_reg_t;

  //****************************************************************************************************
  // CONFIGURATION PROTECTION REGISTERS
  //****************************************************************************************************

  // MDLCK is an optional register with a bitmap field to indicate which MDs are locked in SRCMD table.
  typedef struct packed {
    logic [30:0] md;                        // md[j] = 1, indicates MD j is locked for all source memory domain table entries.
    logic        l;                         // Lock bit to MDLCK and MDLCKH register.
  } mdlck_t;

  // MDLCKH is an optional register implemented along with MDLCK to support upto 63 memory domains (MDs)
  typedef struct packed {
    logic [31:0] mdh;                       // md[j] = 1, indicates MD j+31 is locked for all source memory domain table entries.
  } mdlckh_t;

  // MDCFGLCK is the lock register to MDCFG table available only in MDCFG Format 0.
  typedef struct packed {
    logic [5:0]  f;                         // Indicate the number of locked MDCFG entries MDCFG(i) is locked for i < f.
    logic        l;                         // Lock bit to MDCFGLCK register.
  } mdcfglck_t;

  // ENTRYLCK is the lock register to Entry table.
  typedef struct packed {
    logic [15:0] f;                         // Indicate the number of locked IOPMP entries ENTRY_ADDR(i), ENTRY_ADDRH(i), ENTRY_CFG(i), and
                                            // ENTRY_USER_CFG(i) are locked for i < f.
    logic        l;                         // Lock bit to ENTRYLCK register.
  } entrylck_t;

  // CONFIGURATION PROTECTION Registers Packed Struct
	typedef struct packed {
    mdlck_t    mdlck;
    mdlckh_t   mdlckh;
    mdcfglck_t mdcfglck;
    entrylck_t entrylck;
	} config_prot_reg_t;

  //****************************************************************************************************
  // ERROR REPORTING REGISTERS
  //****************************************************************************************************

  // ERR_CFG is a read/write WARL register used to configure the global error reporting behavior on an IOPMP violation.
  typedef struct packed {
    logic [10:0] msidata;                   // The data to trigger MSI

    logic [2:0]  rsv1;                      // These bits are reserved and should be assigned default zero

    logic        stall_violation_en;        // Indicates whether the IOPMP faults stalled transactions. When the bit is set, the IOPMP
                                            // faults the transactions if the corresponding RRID is not exempt from stall

    logic        msi_en;                    // It indicates whether the IOPMP triggers MSI

    logic        rs;                        // To suppress an error response on an IOPMP rule violation
                                            //  -> 0x0: respond an implementation-dependent error, such as a bus error
                                            //  -> 0x1: respond a success with a pre-defined value to the requestor instead of an error

    logic        ie;                        // Enable the interrupt of the IOPMP

    logic        l;                         // Lock fields to ERR_CFG register
  } err_cfg_t;

  // ERR_REQINFO captures more detailed error infomation.
  typedef struct packed {
    logic        svc;                       // Indicate there is a subsequent violation caught in ERR_MFR. Implemented only for HWCFG0.mfr_en=1

    logic [3:0]  etype;                     // Indicates the type of violation
                                            //  -> 0x00 = no error
                                            //  -> 0x01 = illegal read access
                                            //  -> 0x02 = illegal write access
                                            //  -> 0x03 = illegal instruction fetch
                                            //  -> 0x04 = partial hit on a priority rule
                                            //  -> 0x05 = not hit any rule
                                            //  -> 0x06 = unknown RRID
                                            //  -> 0x07 = 0x07 = error due to a stalled transaction. It should not
                                            //   happen when ERR_CFG.stall_violation_en is 0.
                                            //  -> 0x08 ~ 0x0D = N/A, reserved for future
                                            //  -> 0x0E ~ 0x0F = user-defined error

    logic        msi_werr;                  // It is asserted when the write access to trigger an IOPMP-
                                            // originated MSI has failed. When it is not available, it should
                                            // be ZERO.
                                            // Write 1 clears the bit. Write 0 causes no effect on the bit

    logic [1:0]  ttype;                     // Indicates the transaction type
                                            //  -> 0x00 = reserved
                                            //  -> 0x01 = read access
                                            //  -> 0x02 = write access
                                            //  -> 0x03 = instruction fetch

    logic        v;                         // Indicate if the illegal capture recorder register has a
                                            // valid content and will keep the content until the bit is cleared
  } rfm_hw_err_info_t;

  // ERR_REQADDR indicate the errored request address.
  typedef struct packed {
    logic [31:0] addr;                      // Indicate the errored address[33:2]
  } rfm_hw_err_reqaddr_t;

  // ERR_REQADDRH indicate the errored request address.
  typedef struct packed {
    logic [17:0] addrh;                     // Indicate the errored address[51:34]
  } rfm_hw_err_reqaddrh_t;

  // ERR_REQID indicates the errored RRID and entry index.
  typedef struct packed {
    logic [15:0] eid;                       // Indicates the index pointing to the entry that catches the violation. If no entry
                                            // is hit, i.e., etype=0x05, the value of this field is invalid

    logic [15:0] rrid;                      // Indicate the errored RRID
  } rfm_hw_err_reqid_t;

  // ERR_MFR is an optional register. If Multi-Faults Record Extension is enabled (HWCFG0.mfr_en=1), ERR_MFR can be used to retrieve which RRIDs make subsequent violations.
  typedef struct packed {
    logic        svs;                       // the status of this windows content:
                                            //  -> 0x0 = no subsequent violation found
                                            //  -> 0x1 = subsequent violation found

    logic [11:0] svi;                       // Windows index to search subsequent violations

                                            // When read, svi moves forward until one subsequent violation
                                            // is found or svi has been rounded back to the same value
    logic [15:0] svw;                       // Subsequent violations in the window indexed by svi
  } err_mfr_t;

  // MSI Data Address register
  typedef struct packed {
    logic [31:0] msiaddr;                   // The address to trigger MSI. For HWCFG0.addrh_en=0, it contains bits 33 to 2 of the
                                            // address; otherwise, it contains bits 31 to 0. Available only if ERR_CFG.msi_en=1
  } err_msiaddr_t;

  // MSI Data Address register
  typedef struct packed {
    logic [19:0] msiaddrh;                  // The higher 20 bits of the address to trigger MSI. Available only if HWCFG0.addrh_en=1 and ERR_CFG.msi_en=1
  } err_msiaddrh_t;

  // ERROR REPORTING Registers Packed Struct
	typedef struct packed {
    err_cfg_t             err_cfg;
    rfm_hw_err_info_t     err_info;
    rfm_hw_err_reqaddr_t  err_reqaddr;
    rfm_hw_err_reqaddrh_t err_reqaddrh;
    rfm_hw_err_reqid_t    err_reqid;
    err_mfr_t             err_mfr;
    err_msiaddr_t         err_msiaddr;
    err_msiaddrh_t        err_msiaddrh;
	} err_rpt_reg_t;

  // ERR_REQINFO captures more detailed error infomation.
  typedef struct packed {
    struct packed {
      logic       hwen;                     // Hardware write enable
      logic       hwdata;                   // Hardware write data
    } v;
    struct packed {
      logic       hwen;                     // Hardware write enable
      logic [1:0] hwdata;                   // Hardware write data
    } ttype;
    struct packed {
      logic       hwen;                     // Hardware write enable
      logic       hwdata;                   // Hardware write data
    } msi_werr;
    struct packed {
      logic       hwen;                     // Hardware write enable
      logic [3:0] hwdata;                   // Hardware write data
    } etype;
  } hw_rfm_err_info_t;

  // ERR_REQADDR indicate the errored request address.
  typedef struct packed {
    logic        hwen;                      // Hardware write enable
    logic [31:0] hwdata;                    // Hardware write data
  } hw_rfm_err_reqaddr_t;

  // ERR_REQADDRH indicate the errored request address.
  typedef struct packed {
    logic        hwen;                      // Hardware write enable
    logic [17:0] hwdata;                    // Hardware write data
  } hw_rfm_err_reqaddrh_t;

  // ERR_REQID indicates the errored RRID and entry index.
  typedef struct packed {
    struct packed {
      logic        hwen;                    // Hardware write enable
      logic [15:0] hwdata;                  // Hardware write data
    } rrid;
    struct packed {
      logic        hwen;                    // Hardware write enable
      logic [15:0] hwdata;                  // Hardware write data
    } eid;
  } hw_rfm_err_reqid_t;

  //****************************************************************************************************
  // MDCFG REGISTERS
  //****************************************************************************************************

  // MDCFG table is a lookup to specify the number of IOPMP entries that is associated with each MD. Number of MDCFG registers is equal to HWCFG0.md_num
  typedef struct packed {
    logic [15:0] t;                       // Indicate the top range of memory domain m. An IOPMP entry with index j belongs to MD
  } mdcfg_t;

  //****************************************************************************************************
  // SRCMD TABLE REGISTERS
  //****************************************************************************************************

  // Srcmd_en, srcmd_enh, srcmd_r, srcmd_rh, srcmd_w and srcmd_wh registers avaiable for SRCMD_FMT = 0
  // SRCMD_EN register (0, .... , HWCFG1.rrid_num-1) is a specific register for each source (RRID) and indicates which MDs this source maps to
  typedef struct packed {
    logic [30:0] md;                        // md[j] = 1 indicates MD j is associated with RRID s.
    logic        l;                         // A sticky lock bit. When set, locks SRCMD_EN(s), SRCMD_ENH(s), SRCMD_R(s), SRCMD_RH(s), SRCMD_W(s), SRCMD_WH(s).
  } srcmd_en_t;

  // SRCMD_ENH register (0, .... , HWCFG1.rrid_num-1) is a specific register for each source (RRID) and indicates which MDs this source maps to
  typedef struct packed {
    logic [31:0] mdh;                       // mdh[i]=1 indicates MD i+31 is associated with RRID;
  } srcmd_enh_t;

  // SRCMD_R register (0, .... , HWCFG1.rrid_num-1) is a optional specific register for each source (RRID) and indicates which MDs has read permissions.
  typedef struct packed {
    logic [30:0] md;                        // md[j] = 1 indicates RRID s has read permission to the corresponding MD
  } srcmd_r_t;

  // SRCMD_RH register (0, .... , HWCFG1.rrid_num-1) is a optional specific register for each source (RRID) and indicates which MDs has read permissions.
  typedef struct packed {
    logic [31:0] mdh;                       // md[j] = 1 indicates RRID s has read permission to the corresponding MD j+31
  } srcmd_rh_t;

  // SRCMD_W register (0, .... , HWCFG1.rrid_num-1) is a optional specific register for each source (RRID) and indicates which MDs has write permissions.
  typedef struct packed {
    logic [30:0] md;                        // md[j] = 1 indicates RRID s has write permission to the corresponding MD
  } srcmd_w_t;

  // SRCMD_WH register (0, .... , HWCFG1.rrid_num-1) is a optional specific register for each source (RRID) and indicates which MDs has write permissions.
  typedef struct packed {
    logic [31:0] mdh;                       // md[j] = 1 indicates RRID s has write permission to the corresponding MD j+31
  } srcmd_wh_t;

  // SRCMD FORMAT 0 Registers Packed Struct
  typedef struct packed {
    srcmd_en_t  srcmd_en;
    srcmd_enh_t srcmd_enh;
    srcmd_r_t   srcmd_r;
    srcmd_rh_t  srcmd_rh;
    srcmd_w_t   srcmd_w;
    srcmd_wh_t  srcmd_wh;
  } srcmd_table_0_t;

  // In Format 2, an IOPMP checks both the permission of SRCMD_PERM(H)(m) and the ENTRY_CFG.r/w/x permission. A transaction is legal if any of them allows the transaction.
  typedef struct packed {
    logic [31:0] perm;                      // Holds two bits per RRID that give the RRIDs read and write permissions for the entry.
  } srcmd_perm_t;

  typedef struct packed {
    logic [31:0] permh;                     // Holds two bits per RRID that give the RRID read and write permissions for the entry.
                                            // The register is implemented when HWCFG0.rrid_num > 16.
  } srcmd_permh_t;

  // SRCMD FORMAT 2 Registers Packed Struct
  typedef struct packed {
    srcmd_perm_t  srcmd_perm;
    srcmd_permh_t srcmd_permh;
  } srcmd_table_2_t;

  // SRCMD Table Registers Packed Struct
  typedef struct packed {
    srcmd_table_0_t [63:0] srcmd_table_0;
    srcmd_table_2_t [62:0] srcmd_table_2;
  } srcmd_table_t;

  //****************************************************************************************************
  // ENTRY ARRAY REGISTERS
  //****************************************************************************************************

  // ENTRY_ADDR registers (0, ..... HWCFG1.entry_num-1) holds physical address of protected memory region
  typedef struct packed {
    logic [31:0] addr;                      // The physical address[33:2] of protected memory region.
  } entry_addr_t;

  // ENTRY_ADDRH register (0, ..... HWCFG1.entry_num-1) holds physical address of protected memory region.
  // It is implemented to support wider physical addresses However, an IOPMP can only manage a segment of space, so an implementation would have a certain
  // number of the most significant bits that are the same among all entries. These bits are allowed to be hardwired.
  typedef struct packed {
    logic [17:0] addrh;                     // The physical address[51:34] of protected memory region.
  } entry_addrh_t;

  // ENTRY_CFG register (0, ..... HWCFG1.entry_num-1) holds permissions related to protected meomory region (IOPMP entry). These entries are used to validate the requested permissions.
  typedef struct packed {
    logic        sexe;                      // Supress the (bus) error on an illegal instruction fetch
                                            // caught by the entry
                                            //  -> 0x0: the response by ERR_CFG.rxe
                                            //  -> 0x1: do not respond an error. User to define the behavior,
                                            //      e.g., respond a success with an implementation-dependent value to the requestor.

    logic        sewe;                      // Supress the (bus) error on an illegal write access caught by the entry
                                            // -> 0x0: the response by ERR_CFG.rwe
                                            // -> 0x1: do not respond an error. User to define the behavior,
                                            //       e.g., respond a success if response is needed

    logic        sere;                      // Supress the (bus) error on an illegal read access caught by the entry
                                            // 0x0: the response by ERR_CFG.rre
                                            // 0x1: do not respond an error. User to define the behavior,
                                            //      e.g., respond a success with an implementation-dependent value to the requestor.

    logic        sixe;                      // Suppress interrupt on an illegal instruction fetch caught by the entry

    logic        siwe;                      // Suppress interrupt for write violations caught by the entry

    logic        sire;                      // To suppress interrupt for an illegal read access caught by the entry

    logic [1:0]  a;                         // The address mode of the IOPMP entry
                                            //  -> 0x0: OFF
                                            //  -> 0x1: TOR
                                            //  -> 0x2: NA4
                                            //  -> 0x3: NAPOT

    logic        x;                         // The instruction fetch permission to the protected memory region.
                                            // Optional field, if unimplemented, write any read the same value
                                            // as r field.

    logic        w;                         // The write permission to the protected memory region

    logic        r;                         // The read permission to protected memory region
  } entry_cfg_t;

  // ENTRY ARRAY Registers Packed Struct
  typedef struct packed {
    entry_addr_t  entry_addr;
    entry_addrh_t entry_addrh;
    entry_cfg_t   entry_cfg;
  } entry_array_t;

  //****************************************************************************************************
  // IOPMP REGISTERS PACKED STRUCTURE
  //****************************************************************************************************
  typedef struct packed {
    info_reg_t info_reg;
    prog_prot_reg_t prog_prot_reg;
    config_prot_reg_t config_prot_reg;
    err_rpt_reg_t err_rpt_reg;
    mdcfg_t [62:0] mdcfg_table;
    srcmd_table_t srcmd_table;
    entry_array_t [127:0] entry_array;
  } iopmp_reg_t;

  //****************************************************************************************************
  // STRUCTS AND REGISTERS ENUM
  //****************************************************************************************************

  // eic_rfm_t struct holds registers that hardware can write
  typedef struct packed {
    hw_rfm_err_info_t     err_info;
    hw_rfm_err_reqaddr_t  err_reqaddr;
    hw_rfm_err_reqaddrh_t err_reqaddrh;
    hw_rfm_err_reqid_t    err_reqid;
  } eic_rfm_t;

  // rfm_ttu_t struct holds the registers data required in Table Traversal Unit
  typedef struct packed {
    logic       hwcfg0_chk_x;
    logic       hwcfg0_no_x;
    logic       hwcfg0_no_w;
    logic       hwcfg0_enable;
    logic [6:0] hwcfg1_rrid_num;
    logic [2:0] hwcfg0_md_entry_num;
    mdcfg_t [CFG.MD_NUM-1:0] mdcfg;
    srcmd_table_0_t [CFG.RRID_NUM-1:0] srcmd_table_0;
    srcmd_table_2_t [CFG.MD_NUM-1:0] srcmd_table_2;
  } rfm_ttu_t;

  // rfm_rap_t struct holds the registers data required in Rule Analyzer Pipeline
  typedef struct packed {
    entry_array_t [CFG.ENTRY_NUM-1:0] entry_table;
    logic [CFG.ENTRY_NUM-1:0][5:0]    napot_size;
    logic [CFG.ENTRY_NUM-1:0]         prio_entry_vec;
    logic [CFG.ENTRY_NUM-1:0]         valid_range_vec;
  } rfm_rap_t;

	// rfm_eic_t struct holds the registers data required in Error and Interrupt Control
  typedef struct packed {
    logic          err_cfg_ie;
    logic          err_cfg_msi_en;
    logic          err_info_v;
    logic          err_info_msi_werr;
    err_msiaddr_t  err_msiaddr;
    err_msiaddrh_t err_msiaddrh;
  } rfm_eic_t;

  // INFO Registers-MUX Map
  typedef enum bit [2:0] {
    IOPMP_VERSION      = 3'h0,    // 0
    IOPMP_IMP          = 3'h1,    // 1
    IOPMP_HWCFG0       = 3'h2,    // 2
    IOPMP_HWCFG1       = 3'h3,    // 3
    IOPMP_HWCFG2       = 3'h4,    // 4
    IOPMP_ENTRY_OFFSET = 3'h5,    // 5
		IOPMP_BASE_ADDR    = 3'h6 		// 6
	} info_reg_e;

  // PROGRAMMING PROTECTION Registers-MUX Map
  typedef enum bit [2:0]  {
		IOPMP_MDSTALL  = 3'h4,    // 4
    IOPMP_MDSTALLH = 3'h5,    // 5
    IOPMP_RRIDSCP  = 3'h6     // 6
	} prog_prot_reg_e;

	// CONFIGURATION PROTECTION Registers-MUX Map
  typedef enum bit [2:0]  {
		IOPMP_MDLCK  	 = 3'h0,    // 0
    IOPMP_MDLCKH   = 3'h1,    // 1
    IOPMP_MDCFGLCK = 3'h2,    // 2
		IOPMP_ENTRYLCK = 3'h3     // 3
	} config_prot_reg_e;

  // ERROR REPORTING Registers-MUX Map
  typedef enum bit [2:0] {
    IOPMP_ERR_CFG 		 = 3'h0,    // 0
    IOPMP_ERR_INFO     = 3'h1,    // 1
    IOPMP_ERR_REQADDR  = 3'h2,    // 2
    IOPMP_ERR_REQADDRH = 3'h3,    // 3
    IOPMP_ERR_REQID    = 3'h4,    // 4
    IOPMP_ERR_MFR  		 = 3'h5,    // 5
    IOPMP_ERR_MSIADDR  = 3'h6,    // 6
		IOPMP_ERR_MSIADDRH = 3'h7     // 7
	} err_rpt_reg_e;

  // SRCMD Format 0 Registers-MUX Map
  typedef enum bit [2:0] {
    IOPMP_SRCMD_EN  = 3'h0,    // 0
    IOPMP_SRCMD_ENH = 3'h1,    // 1
    IOPMP_SRCMD_R   = 3'h2,    // 2
    IOPMP_SRCMD_RH  = 3'h3,    // 3
    IOPMP_SRCMD_W   = 3'h4,    // 4
    IOPMP_SRCMD_WH  = 3'h5     // 5
  } srcmd_fmt_0_reg_e;

  // SRCMD Format 2 Registers-MUX Map
  typedef enum bit [2:0] {
    IOPMP_SRCMD_PERM  = 3'h0,    // 0
    IOPMP_SRCMD_PERMH = 3'h1     // 1
  } srcmd_fmt_2_reg_e;

  // ENTRY ARRAY Registers-MUX Map
  typedef enum bit [2:0] {
    IOPMP_ENTRY_ADDR_0  = 3'h0,    // 0
    IOPMP_ENTRY_ADDRH_0 = 3'h1,    // 1
    IOPMP_ENTRY_CFG_0   = 3'h2,    // 2
    IOPMP_ENTRY_ADDR_1  = 3'h4,    // 4
    IOPMP_ENTRY_ADDRH_1 = 3'h5,    // 5
    IOPMP_ENTRY_CFG_1   = 3'h6     // 6
  } entry_array_reg_e;

	// IOPMP Address Modes
	typedef enum bit [1:0] {
	  IOPMP_OFF   = 2'b00,    // IOPMP is disabled (0)
	  IOPMP_TOR   = 2'b01,    // Top-of-Range mode (1)
	  IOPMP_NA4   = 2'b10,    // Naturally aligned 4-byte regions (2)
	  IOPMP_NAPOT = 2'b11     // Naturally aligned power of two regions (3)
	} iopmp_mode_e;

	typedef enum logic [1:0] {
    NONE     = 2'b00,
    FORWARD  = 2'b01,
    BACKWARD = 2'b10
  } change_state_e;

endpackage