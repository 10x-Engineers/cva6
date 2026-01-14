  `define RFM_ADDR_CHK tb_top.iopmp_dut.rfm.address_check

  //****************************************************************************************************
  // Sequences
  //****************************************************************************************************

  // Basic 4 bytes request address aligned check
  sequence SEQ_ALIGNED_ADDR;
    (`RFM_ADDR_CHK.valid_req && (`RFM_ADDR_CHK.req_addr[1:0] == 2'b00));
  endsequence

  // Check that an address is within a section legal range based on start and end offset
  sequence SEQ_ADDR_IN_RANGE (
    local input logic in_section,
    local input logic [15:0] start_offset,
    local input logic [15:0] end_offset
  );
    (SEQ_ALIGNED_ADDR and (in_section && (`RFM_ADDR_CHK.req_offset_addr >= start_offset) && (`RFM_ADDR_CHK.req_offset_addr <= end_offset)));
  endsequence

  // Check that an address belongs to a sub-category in Base Register Region based on adddress bits [6:4]
  sequence SEQ_BASE_REG (
    local input logic [2:0] offset_val
  );
    (SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, 0, `RFM_ADDR_CHK.MAX_BASE_REG_OFFSET) and (`RFM_ADDR_CHK.req_offset_addr[6:4] == offset_val));
  endsequence

  // Sequence to check if an address that belongs to a sub-category in Base Register Region is a legal address
  // The input signal legal_signal must be true for the respective sub-category if the address is legal
  // The remaining signals in the sequence must hold true when legal_signal is true
  sequence LEGAL_BASE_REG_ADDR (
    local input logic legal_signal
  );
    (legal_signal && `RFM_ADDR_CHK.is_addr_legal && `RFM_ADDR_CHK.base_reg_legal && `RFM_ADDR_CHK.is_addr_legal_section_1);
  endsequence

  // Sequence to check if an address that belongs to a sub-category in Base Register Region is an illegal address
  // The input signal legal_signal must be false for the respective sub-category and illegal_signal must be true if the address is illegal
  // The remaining signals in the sequence must be false when legal_signal is false
  sequence ILLEGAL_BASE_ADDR (
    local input logic legal_signal,
    local input logic illegal_signal
  );
    (illegal_signal && (!(`RFM_ADDR_CHK.is_addr_legal || `RFM_ADDR_CHK.base_reg_legal || `RFM_ADDR_CHK.is_addr_legal_section_1 || legal_signal)));
  endsequence

  // Sequence to check if an address that belongs to a TABLE register (MDCFG, SRCMD ENTRY_ARRAY) is a legal address
  // The input signal legal_signal must be true if the address is legal
  // The remaining signals in the sequence must hold true when legal_signal is true
  sequence TABLE_ADDR_LEGAL (
    local input logic legal_signal
  );
    (legal_signal && `RFM_ADDR_CHK.is_addr_legal);
  endsequence

  // Sequence to check if an address that belongs to a TABLE (MDCFG, SRCMD ENTRY_ARRAY) is an illegal address
  // The input signal legal_signal must be false and illegal_signal must be true if the address is illegal
  // The remaining signals in the sequence must be false when legal_signal is false
  sequence TABLE_ADDR_ILLEGAL(
    local input logic legal_signal,
    local input logic illegal_signal
  );
    (illegal_signal && (!(legal_signal || `RFM_ADDR_CHK.is_addr_legal)));
  endsequence

  //****************************************************************************************************
  // Cover Properties
  //****************************************************************************************************

  //****************************************************************************************************
  // Legal address and Misaligned address Cover Properties
  //****************************************************************************************************

  // RFM.01. Cover Property: If the incoming request address is 4 byte aligned and belongs to a legal register in either section 1 or section 2, then the address must be decoded as legal address
  rfm_cover_is_addr_legal: cover property (
    @(posedge clk) ((SEQ_ALIGNED_ADDR and (`RFM_ADDR_CHK.is_addr_legal_section_1 || `RFM_ADDR_CHK.entry_array_legal)) |-> (`RFM_ADDR_CHK.is_addr_legal))
  );

  // RFM.02. Cover Property: If the incoming request address is not 4 byte aligned, then the address should not be decoded as legal
  rfm_cover_misalign_addr: cover property (
    @(posedge clk) (((`RFM_ADDR_CHK.req_addr[1:0] != 2'b00) && `RFM_ADDR_CHK.valid_req) |-> ((!`RFM_ADDR_CHK.addr_aligned) && (!`RFM_ADDR_CHK.is_addr_legal)))
  );

  //****************************************************************************************************
  // MDCFG Format Cover Properties
  //****************************************************************************************************

  // ########################################## MDCFG FORMAT 0 #########################################

  if (config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_0) begin : cover_mdcfg_fmt_0

    // RFM.03. Cover Property: If the incoming request address belongs to MDCFG Region of SECTION 1 when MDCFG Format is 0, then TABLE_ADDR_LEGAL must be true
    rfm_cover_mdcfg_fmt_0: cover property (
      @(posedge clk) ((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.MDCFG_START_OFFSET, `RFM_ADDR_CHK.MAX_MDCFG_OFFSET)) |-> (TABLE_ADDR_LEGAL(`RFM_ADDR_CHK.mdcfg_legal && `RFM_ADDR_CHK.is_addr_legal_section_1)))
    );
  end

  // ######################################### MDCFG FORMAT 1 2 ########################################

  if (config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_1 || config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_2) begin : cover_mdcfg_fmt_1_2

    // RFM.04. Cover Property: If the incoming request address belongs to MDCFG Region of SECTION 1 when MDCFG Format is 1 or 2, then TABLE_ADDR_ILLEGAL must be true
    rfm_cover_mdcfg_fmt_1_2: cover property (
      @(posedge clk) ((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.MDCFG_START_OFFSET, `RFM_ADDR_CHK.MAX_MDCFG_OFFSET)) |-> (TABLE_ADDR_ILLEGAL(`RFM_ADDR_CHK.mdcfg_legal, 1)))
    );
  end

  //****************************************************************************************************
  // SRCMD Format Cover Properties
  //****************************************************************************************************

  // ########################################## SRCMD FORMAT 0 #########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_0) begin : cover_srcmd_fmt_0

    if (config_iopmp_pkg::iopmp_cfg_default.SPS_EN) begin : cover_sps_enable

      // RFM.05. Cover Property: If the incoming request address belongs to SRCMD Region of SECTION 1 when SRCMD Format is 0 and SPS is enabled, and incoming offset
      // address is not 0x18 or 0x1C (address[4:3] != 2'b11), then TABLE_ADDR_LEGAL must be true
      rfm_cover_sps_enable_legal_addr_srcmd_fmt_0: cover property (
        @(posedge clk) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.SRCMD_START_OFFSET, `RFM_ADDR_CHK.MAX_SRCMD_FMT_0_OFFSET)) and (!(&`RFM_ADDR_CHK.req_offset_addr[4:3])))
        |-> (TABLE_ADDR_LEGAL(`RFM_ADDR_CHK.srcmd_legal && `RFM_ADDR_CHK.is_addr_legal_section_1)))
      );
    end
    else begin : cover_sps_disable

      // RFM.06. Cover Property: If the incoming request address belongs to SRCMD Region of SECTION 1 when SRCMD Format is 0 and SPS is disabled, and incoming offset
      // address is not 0x08 or 0x0C or 0x10 or 0x14 or 0x18 or 0x1C (address[4] != 1'b1 or address[3] != 1'b1), then TABLE_ADDR_LEGAL must be true
      rfm_cover_sps_disable_legal_addr_srcmd_fmt_0: cover property (
        @(posedge clk) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.SRCMD_START_OFFSET, `RFM_ADDR_CHK.MAX_SRCMD_FMT_0_OFFSET)) and (!(|`RFM_ADDR_CHK.req_offset_addr[4:3])))
        |-> (TABLE_ADDR_LEGAL(`RFM_ADDR_CHK.srcmd_legal && `RFM_ADDR_CHK.is_addr_legal_section_1)))
      );

      // RFM.07. Cover Property: If the incoming request address belongs to SRCMD Region of SECTION 1 when SRCMD Format is 0 and SPS is disabled and incoming offset
      // address is either 0x08 or 0x0C or 0x10 or 0x14 or 0x18 or 0x1C (address[4] == 1'b1 or address[3] == 1'b1), then TABLE_ADDR_ILLEGAL must be true
      rfm_cover_sps_disable_illegal_addr_srcmd_fmt_0: cover property (
        @(posedge clk) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.SRCMD_START_OFFSET, `RFM_ADDR_CHK.MAX_SRCMD_FMT_0_OFFSET)) and (|`RFM_ADDR_CHK.req_offset_addr[4:3]))
        |-> (TABLE_ADDR_ILLEGAL(`RFM_ADDR_CHK.srcmd_legal, `RFM_ADDR_CHK.srcmd_illegal2)))
      );
    end

    // RFM.08. Cover Property: If the incoming request address belongs to SRCMD Region of SECTION 1 when SRCMD Format is 0 and incoming offset address is either 0x18
    // or 0x1C (address[4:3] == 2'b11), then TABLE_ADDR_ILLEGAL must be true
    rfm_cover_illegal_addr_srcmd_fmt_0: cover property (
      @(posedge clk) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.SRCMD_START_OFFSET, `RFM_ADDR_CHK.MAX_SRCMD_FMT_0_OFFSET)) and (&`RFM_ADDR_CHK.req_offset_addr[4:3]))
      |-> (TABLE_ADDR_ILLEGAL(`RFM_ADDR_CHK.srcmd_legal, `RFM_ADDR_CHK.srcmd_illegal1)))
    );
  end

  // ########################################## SRCMD FORMAT 2 #########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_2) begin : cover_srcmd_fmt_2

    // RFM.09. Cover Property: If the incoming request address belongs to SRCMD Region of SECTION 1 when SRCMD Format is 2 and incoming offset address is not
    // 0x08 or 0x0C or 0x10 or 0x14 or 0x18 or 0x1C (address[4] != 1'b1 or address[3] != 1'b1), then TABLE_ADDR_LEGAL must be true
    rfm_cover_legal_addr_srcmd_fmt_2: cover property (
      @(posedge clk) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.SRCMD_START_OFFSET, `RFM_ADDR_CHK.MAX_SRCMD_FMT_2_OFFSET)) and (!(|`RFM_ADDR_CHK.req_offset_addr[4:3])))
      |-> (TABLE_ADDR_LEGAL(`RFM_ADDR_CHK.srcmd_legal && `RFM_ADDR_CHK.is_addr_legal_section_1)))
    );

    // RFM.10. Cover Property: If the incoming request address belongs to SRCMD Region of SECTION 1 when SRCMD Format is 2 and incoming offset address is either
    // 0x08 or 0x0C or 0x10 or 0x14 or 0x18 or 0x1C (address[4] == 1'b1 or address[3] == 1'b1), then TABLE_ADDR_ILLEGAL must be true
    rfm_cover_illegal_addr_srcmd_fmt_2: cover property (
      @(posedge clk) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.SRCMD_START_OFFSET, `RFM_ADDR_CHK.MAX_SRCMD_FMT_2_OFFSET)) and (|`RFM_ADDR_CHK.req_offset_addr[4:3]))
      |-> (TABLE_ADDR_ILLEGAL(`RFM_ADDR_CHK.srcmd_legal, (`RFM_ADDR_CHK.srcmd_illegal1 || `RFM_ADDR_CHK.srcmd_illegal3))))
    );
  end

  // ########################################## SRCMD FORMAT 1 #########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_1) begin : cover_srcmd_fmt_1

    // RFM.11. Cover Property: If the incoming request address belongs to SRCMD Region of SECTION 1 when SRCMD Format is 1, then TABLE_ADDR_ILLEGAL must be true
    rfm_cover_illegal_addr_srcmd_fmt_1: cover property (
      @(posedge clk) ((SEQ_ALIGNED_ADDR and (`RFM_ADDR_CHK.is_section_1 && (`RFM_ADDR_CHK.req_offset_addr >= `RFM_ADDR_CHK.SRCMD_START_OFFSET) &&
      ((`RFM_ADDR_CHK.req_offset_addr <= `RFM_ADDR_CHK.MAX_SRCMD_FMT_0_OFFSET) || (`RFM_ADDR_CHK.req_offset_addr <= `RFM_ADDR_CHK.MAX_SRCMD_FMT_2_OFFSET)))) |-> (TABLE_ADDR_ILLEGAL(`RFM_ADDR_CHK.srcmd_legal, 1)))
    );
  end

  //****************************************************************************************************
  // ENTRY ARRAY Cover Properties
  //****************************************************************************************************

  if (config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : cover_addrh_en_true_for_entry_array

    // RFM.12. Cover Property: If the incoming request address belongs to ENTRY ARRAY Region of SECTION 2 when ADDRH_EN is enabled, and incoming offset address is not 0xC (address[3:2] != 2'b11) then TABLE_ADDR_LEGAL must be true
    rfm_cover_addrh_en_true_legal_addr_entry_array: cover property (
      @(posedge clk) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_2, 0, `RFM_ADDR_CHK.MAX_ENTRY_ARRAY_OFFSET)) and (!(&`RFM_ADDR_CHK.req_offset_addr[3:2]))) |-> (TABLE_ADDR_LEGAL(`RFM_ADDR_CHK.entry_array_legal)))
    );
  end
  else begin : cover_addrh_en_false_for_entry_array

    // RFM.13. Cover Property: If the incoming request address belongs to ENTRY ARRAY Region of SECTION 2 when ADDRH_EN is disabled, and incoming offset address is not 0x4 or 0xC (address[2] != 1'b1) then LEGAL_ENTRY_ARRAY_ADDR must be true
    rfm_cover_addrh_en_false_legal_addr_entry_array: cover property (
      @(posedge clk) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_2, 0, `RFM_ADDR_CHK.MAX_ENTRY_ARRAY_OFFSET)) and (!`RFM_ADDR_CHK.req_offset_addr[2])) |-> (TABLE_ADDR_LEGAL(`RFM_ADDR_CHK.entry_array_legal)))
    );

    // RFM.14. Cover Property: If the incoming request address belongs to ENTRY ARRAY Region of SECTION 2 when ADDRH_EN is disabled, and incoming offset address is 0x4 (address[3:2] == 2'b01) then TABLE_ADDR_ILLEGAL must be true
    rfm_cover_illegal_entry_addrh: cover property (
      @(posedge clk) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_2, 0, `RFM_ADDR_CHK.MAX_ENTRY_ARRAY_OFFSET)) and (`RFM_ADDR_CHK.req_offset_addr[3:2] != 2'b01))
      |-> (TABLE_ADDR_ILLEGAL(`RFM_ADDR_CHK.entry_array_legal, `RFM_ADDR_CHK.entry_array_illegal2)))
    );
  end

  // RFM.15. Cover Property: If the incoming request address belongs to ENTRY ARRAY Region of SECTION 2 and incoming offset address is 0xC (address[3:2] == 2'b11), then TABLE_ADDR_ILLEGAL must be true
  rfm_cover_illegal_addr_entry_array: cover property (
    @(posedge clk) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_2, 0, `RFM_ADDR_CHK.MAX_ENTRY_ARRAY_OFFSET)) and (&`RFM_ADDR_CHK.req_offset_addr[3:2]))
    |-> (TABLE_ADDR_ILLEGAL(`RFM_ADDR_CHK.entry_array_legal, `RFM_ADDR_CHK.entry_array_illegal1)))
  );

  //****************************************************************************************************
  // Base Registers Region SECTION 1 Cover Properties
  //****************************************************************************************************

  // RFM.16. Cover Property: If the incoming request address belongs to Base Registers Region of SECTION 1, then is_base_register must be true
  rfm_cover_base_registers_region: cover property (
    @(posedge clk) ((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, 0, `RFM_ADDR_CHK.MAX_BASE_REG_OFFSET)) |-> (`RFM_ADDR_CHK.is_base_register))
  );

  // ########################################## INFO REGISTERS #########################################

  // RFM.17. Cover Property: If the incoming address belongs to VERSION: 0x0000, IMPLEMENTATION: 0x0004, HWCFG0: 0x0008, HWCFG1: 0x000C,
  // then LEGAL_BASE_REG_ADDR must be true
  rfm_cover_addr_info_reg_1: cover property (
    @(posedge clk) ((SEQ_BASE_REG(3'b000)) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.info_legal && `RFM_ADDR_CHK.info_reg1_legal)))
  );

  // RFM.18. Cover Property: If the incoming request address belongs to HWCFG2: 0x0010, ENTRYOFSET: 0x0014, BASEADDR: 0x0018,
  // then LEGAL_BASE_REG_ADDR must be true
  rfm_cover_addr_info_reg_2: cover property (
    @(posedge clk) ((SEQ_BASE_REG(3'b001) and (!(&`RFM_ADDR_CHK.req_offset_addr[3:2]))) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.info_legal && `RFM_ADDR_CHK.info_reg2_legal)))
  );

  // ################################# PROGRAMMING PROTECTION REGISTERS ################################

  // RFM.19. Cover Property: If the incoming request address belongs to MDSTALL: 0x0030, MDSTALLH: 0x0034, RRIDSCP: 0x0038,
  // then LEGAL_BASE_REG_ADDR must be true
  rfm_cover_addr_prog_prot_reg: cover property (
    @(posedge clk) ((SEQ_BASE_REG(3'b011) and (!(&`RFM_ADDR_CHK.req_offset_addr[3:2]))) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.prog_prot_legal)))
  );

  // ############################### CONFIGURATION PROTECTION REGISTERS ################################

  // RFM.20. Cover Property: If the incoming request address belongs to ENTRYLCK: 0x004C, then LEGAL_BASE_REG_ADDR must be true
  rfm_cover_entrylck: cover property (
    @(posedge clk) ((SEQ_BASE_REG(3'b100) and (`RFM_ADDR_CHK.req_offset_addr[3:2] == 2'b11)) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.config_prot_legal)))
  );

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_0 || config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_2) begin : cover_legal_mdlck_mdlckh

    // RFM.21. Cover Property: If the incoming request address offset belongs to MDLCK: 0x0040 or MDLCKH: 0x0044 when SRCMD Format is 0 or 2,
    // then LEGAL_BASE_REG_ADDR must be true
    rfm_cover_legal_mdlck_mdlckh: cover property (
      @(posedge clk) ((SEQ_BASE_REG(3'b100) and (!`RFM_ADDR_CHK.req_offset_addr[3])) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.config_prot_legal)))
    );
  end
  else begin : cover_illegal_mdlck_mdlckh

    // RFM.22. Cover Property: If the incoming request address offset belongs to MDLCK: 0x0040 or MDLCKH: 0x0044 when SRCMD Format is 1,
    // then ILLEGAL_BASE_ADDR must be true
    rfm_cover_illegal_mdlck_mdlckh: cover property (
      @(posedge clk) ((SEQ_BASE_REG(3'b100) and (!`RFM_ADDR_CHK.req_offset_addr[3])) |-> (ILLEGAL_BASE_ADDR(`RFM_ADDR_CHK.config_prot_legal, `RFM_ADDR_CHK.config_prot_illegal1)))
    );
  end

  if (config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_0) begin : cover_legal_mdcfglck

    // RFM.23. Cover Property: If the incoming request address offset belongs to MDCFGLCK: 0x0048 when MDCFG Format is 0,
    // then LEGAL_BASE_REG_ADDR must be true
    rfm_cover_legal_mdcfglck: cover property (
      @(posedge clk) ((SEQ_BASE_REG(3'b100) and (`RFM_ADDR_CHK.req_offset_addr[3:2] == 2'b10)) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.config_prot_legal)))
    );
  end
  else begin : cover_illegal_mdcfglck

    // RFM.24. Cover Property: If the incoming request address offset belongs to MDCFGLCK: 0x0048 when MDCFG Format is 1 or 2,
    // then ILLEGAL_BASE_ADDR must be true
    rfm_cover_illegal_mdcfglck: cover property (
      @(posedge clk) ((SEQ_BASE_REG(3'b100) and (`RFM_ADDR_CHK.req_offset_addr[3:2] == 2'b10)) |-> (ILLEGAL_BASE_ADDR(`RFM_ADDR_CHK.config_prot_legal, `RFM_ADDR_CHK.config_prot_illegal2)))
    );
  end

  // #################################### ERROR REPORTING REGISTERS ####################################

  if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : cover_error_capture_enable

    // RFM.25. Cover Property: If the incoming request address belongs to ERR_CFG: 0x0060, ERR_INFO: 0x0064, ERR_REQADDR: 0x0068
    // when ERROR_CAPTURE_EN is enabled, then LEGAL_BASE_REG_ADDR must be true
    rfm_cover_errcfg_errinfo_errreqaddr: cover property (
      @(posedge clk) ((SEQ_BASE_REG(3'b110) and (!(&`RFM_ADDR_CHK.req_offset_addr[3:2]))) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.err_rpt1_legal)))
    );

    // RFM.26. Cover Property: If the incoming request address belongs to ERR_REQID: 0x0070 when ERROR_CAPTURE_EN is enabled,
    // then LEGAL_BASE_REG_ADDR must be true
    rfm_cover_err_reqid: cover property (
      @(posedge clk) ((SEQ_BASE_REG(3'b111) and (!(|`RFM_ADDR_CHK.req_offset_addr[3:2]))) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.err_rpt2_legal)))
    );

    if (config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : cover_addrh_en_true

      // RFM.27. Cover Property: If the incoming request address belongs to ERR_REQADDRH: 0x006C when ERROR_CAPTURE_EN and ADDRH_EN is enabled,
      // then LEGAL_BASE_REG_ADDR must be true
      rfm_cover_legal_err_reqaddrh: cover property (
        @(posedge clk) ((SEQ_BASE_REG(3'b110) and (&`RFM_ADDR_CHK.req_offset_addr[3:2])) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.err_rpt1_legal)))
      );

      if (config_iopmp_pkg::iopmp_cfg_default.MSI_EN) begin : cover_msi_en_true_addrh_en_true

        // RFM.28. Cover Property: If the incoming request address belongs to ERR_MSIADDR: 0x0078 or ERR_MSIADDRH: 0x007C when ERROR_CAPTURE_EN, MSI_EN
        // and ADDRH_EN (for ERR_MSIADDRH) is enabled, then LEGAL_BASE_REG_ADDR must be true
        rfm_cover_legal_err_msiaddr_err_msiaddrh: cover property (
          @(posedge clk) ((SEQ_BASE_REG(3'b111) and (`RFM_ADDR_CHK.req_offset_addr[3])) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.err_rpt2_legal)))
        );
      end
    end
    else begin : cover_addrh_en_false

      // RFM.29. Cover Property: If the incoming request address belongs to ERR_REQADDRH: 0x006C when ERROR_CAPTURE_EN is enabled and ADDRH_EN is
      // disabled, then ILLEGAL_BASE_ADDR must be true
      rfm_cover_illegal_err_reqaddrh: cover property (
        @(posedge clk) ((SEQ_BASE_REG(3'b110) and (&`RFM_ADDR_CHK.req_offset_addr[3:2])) |-> (ILLEGAL_BASE_ADDR(`RFM_ADDR_CHK.err_rpt1_legal, `RFM_ADDR_CHK.err_rpt1_illegal1)))
      );

      if (config_iopmp_pkg::iopmp_cfg_default.MSI_EN) begin : cover_msi_en_true_addrh_en_false

        // RFM.30. Cover Property: If the incoming request address belongs to ERR_MSIADDR: 0x0078 when ERROR_CAPTURE_EN and MSI_EN is enabled,
        // then LEGAL_BASE_REG_ADDR must be true
        rfm_cover_legal_err_msiaddr: cover property (
          @(posedge clk) ((SEQ_BASE_REG(3'b111) and (`RFM_ADDR_CHK.req_offset_addr[3:2] == 2'b10)) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.err_rpt2_legal)))
        );

        // RFM.31. Cover Property: If the incoming request address belongs to ERR_MSIADDRH: 0x007C when ERROR_CAPTURE_EN and MSI_EN is enabled
        // and ADDRH_EN is disabled, then ILLEGAL_BASE_ADDR must be true
        rfm_cover_illegal_err_msiaddrh: cover property (
          @(posedge clk) ((SEQ_BASE_REG(3'b111) and (&`RFM_ADDR_CHK.req_offset_addr[3:2])) |-> (ILLEGAL_BASE_ADDR(`RFM_ADDR_CHK.err_rpt2_legal, `RFM_ADDR_CHK.err_rpt2_illegal3)))
        );
      end
    end

    if (!config_iopmp_pkg::iopmp_cfg_default.MSI_EN) begin : cover_msi_en_false

      // RFM.32. Cover Property: If the incoming request address belongs to ERR_MSIADDR: 0x0078 or ERR_MSIADDRH: 0x007C when ERROR_CAPTURE_EN is enabled
      // and MSI_EN is disabled, then ILLEGAL_BASE_ADDR must be true
      rfm_cover_illegal_err_msiaddr_err_msiaddrh: cover property (
        @(posedge clk) ((SEQ_BASE_REG(3'b111) and (`RFM_ADDR_CHK.req_offset_addr[3])) |-> (ILLEGAL_BASE_ADDR(`RFM_ADDR_CHK.err_rpt2_legal, `RFM_ADDR_CHK.err_rpt2_illegal2)))
      );
    end

    if (config_iopmp_pkg::iopmp_cfg_default.MFR_EN) begin : cover_mfr_en_true

      // RFM.33. Cover Property: If the incoming request address belongs to ERR_MFR: 0x0070 when ERROR_CAPTURE_EN and MFR_EN is enabled,
      // then LEGAL_BASE_REG_ADDR must be true
      rfm_cover_legal_err_mfr: cover property (
        @(posedge clk) ((SEQ_BASE_REG(3'b111) and (`RFM_ADDR_CHK.req_offset_addr[3:2] == 2'b01)) |-> (LEGAL_BASE_REG_ADDR(`RFM_ADDR_CHK.err_rpt2_legal)))
      );
    end
    else begin : cover_mfr_en_false

      // RFM.34. Cover Property: If the incoming request address belongs to ERR_MFR: 0x0074 when ERROR_CAPTURE_EN is enabled
      // and MFR_EN is disabled, then ILLEGAL_BASE_ADDR must be true
      rfm_cover_illegal_err_mfr: cover property (
        @(posedge clk) (((SEQ_BASE_REG(3'b111)) and (`RFM_ADDR_CHK.req_offset_addr[3:2] == 2'b01)) |-> (ILLEGAL_BASE_ADDR(`RFM_ADDR_CHK.err_rpt2_legal, `RFM_ADDR_CHK.err_rpt2_illegal1)))
      );
    end
  end
  else begin : cover_error_capture_disabled

    // RFM.35. Cover Property: If the incoming request address belongs any of the ERROR REPORTING register when ERROR_CAPTURE_EN is
    // disbaled, then the address should not be decoded as legal
    rfm_cover_error_capture_disable: cover property (
      @(posedge clk) (((SEQ_BASE_REG(3'b111)) or (SEQ_BASE_REG(3'b110))) |-> (!`RFM_ADDR_CHK.is_addr_legal))
    );
  end

  // ################################## BASE REGISTER REGION ILLEGALS ##################################

  // RFM.36. Cover Property: If the incoming request address lies in SECTION 1 and offest matches 0x001C, then the address should not be decoded as legal
  rfm_cover_illegal_offset_addr_1C: cover property (
    @(posedge clk) (((SEQ_BASE_REG(3'b001)) and (&`RFM_ADDR_CHK.req_offset_addr[3:2])) |-> (!`RFM_ADDR_CHK.is_addr_legal))
  );

  // RFM.37. Cover Property: If the incoming request address lies in SECTION 1 and offset matches either 0x0020, 0x0024, 0x0028, 0x002C, then the address should not be decoded as legal
  rfm_cover_illegal1_addr_base_region: cover property (
    @(posedge clk) ((SEQ_BASE_REG(3'b010)) |-> (!`RFM_ADDR_CHK.is_addr_legal))
  );

  // RFM.38. Cover Property: If the incoming request address lies in SECTION 1 and offset matches 0x003C, then the address should not be decoded as legal
  rfm_cover_illegal_offset_addr_3C: cover property (
    @(posedge clk) ((SEQ_BASE_REG(3'b011) and (&`RFM_ADDR_CHK.req_offset_addr[3:2])) |-> (!`RFM_ADDR_CHK.is_addr_legal))
  );

  // RFM.39. Cover Property: If the incoming request address lies in SECTION 1 and offset matches either 0x0050, 0x0054, 0x0058, 0x005C, then the address should not be decoded as legal
  rfm_cover_illegal2_addr_base_region: cover property (
    @(posedge clk) ((SEQ_BASE_REG(3'b101)) |-> (!`RFM_ADDR_CHK.is_addr_legal))
  );

  // ####################################### SECTION 1 ILLEGALS ########################################

  // RFM.40. Cover Property: If the incoming request address lies b/w Base Register Region and MDCFG, then the address should not be decoded as legal
  rfm_cover_base_to_mdcfg_illegal: cover property (
    @(posedge clk) ((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.MAX_BASE_REG_OFFSET+4, `RFM_ADDR_CHK.MDCFG_START_OFFSET-4)) |-> (!`RFM_ADDR_CHK.is_addr_legal))
  );

  // RFM.41. Cover Property: If the incoming request address lies b/w MDCFG and SRCMD, then the address should not be decoded as legal
  rfm_cover_mdcfg_to_srcmd_illegal: cover property (
    @(posedge clk) ((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.MAX_MDCFG_OFFSET+4, `RFM_ADDR_CHK.SRCMD_START_OFFSET-4)) |-> (!`RFM_ADDR_CHK.is_addr_legal))
  );

  // RFM.42. Cover Property: If the incoming request address is out of SRCMD region within the SECTION 1, then is_addr_legal must be low in the cycle
  rfm_cover_offset_out_of_srcmd: cover property (
    @(posedge clk) ((SEQ_ALIGNED_ADDR and (`RFM_ADDR_CHK.is_section_1 && ((config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_0 && (`RFM_ADDR_CHK.req_offset_addr > `RFM_ADDR_CHK.MAX_SRCMD_FMT_0_OFFSET))
    || (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_2 && (`RFM_ADDR_CHK.req_offset_addr > `RFM_ADDR_CHK.MAX_SRCMD_FMT_2_OFFSET))))) |-> (!`RFM_ADDR_CHK.is_addr_legal))
  );

  // ####################################### SECTION 2 ILLEGALS ########################################

  // RFM.43. Cover Property: If the incoming request address is out of ENTRY ARRAY region within the SECTION 2, then the address should not be decoded as legal
  rfm_cover_offset_out_of_entry_array: cover property (
    @(posedge clk) ((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_2, `RFM_ADDR_CHK.MAX_ENTRY_ARRAY_OFFSET+4, 16'hFFFF)) |-> (!`RFM_ADDR_CHK.is_addr_legal))
  );

  // ################################### IOPMP ADDRESS SPACE ILLEGAL ###################################

  // RFM.44. Cover Property: If the incoming request address does not belong to any of the section, then the address should not be decoded as legal
  rfm_cover_illegal_section: cover property (
    @(posedge clk) ((`RFM_ADDR_CHK.valid_req && (!`RFM_ADDR_CHK.is_section_1) && (!`RFM_ADDR_CHK.is_section_2)) |-> (!`RFM_ADDR_CHK.is_addr_legal))
  );

  //****************************************************************************************************
  // Assertions for Format or Feature based illegal addresses
  //****************************************************************************************************

  // ######################################### SRCMD FORMAT 1 ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_1) begin : assert_mdlck_mdlckh_illegal

    // RFM.45. Assertion: If SRCMD Format is 1, then MDLCK and MDLCKH registers are not implemented and these register addresses should never be decoded as legal
    rfm_assert_mdlck_mdlckh_illegal: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_BASE_REG(3'b100) and (!`RFM_ADDR_CHK.req_offset_addr[3])) |-> (`RFM_ADDR_CHK.is_addr_legal != 1'b1))
    ) else $error("[%0t] Assertion Failed: MDLCK MDLCKH are not implemented in SRCMD Format 1", $time);

    // RFM.46. Assertion: If SRCMD Format is 1, then SRCMD Region becomes illegal and those addresses should never be decoded as legal
    rfm_assert_srcmd_region_illegal: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_ALIGNED_ADDR and (`RFM_ADDR_CHK.is_section_1 && (`RFM_ADDR_CHK.req_offset_addr >= `RFM_ADDR_CHK.SRCMD_START_OFFSET)
      && ((`RFM_ADDR_CHK.req_offset_addr <= `RFM_ADDR_CHK.MAX_SRCMD_FMT_0_OFFSET) || (`RFM_ADDR_CHK.req_offset_addr <= `RFM_ADDR_CHK.MAX_SRCMD_FMT_2_OFFSET)))) |-> (`RFM_ADDR_CHK.is_addr_legal != 1'b1))
    ) else $error("[%0t] Assertion Failed: SRCMD Region is illegal in SRCMD Format 1", $time);
  end

  // ######################################### MDCFG FORMAT 1 2 ########################################

  if (config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_1 || config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_2) begin : assert_mdcfglck_mdcfg_illegal

    // RFM.47. Assertion: If MDCFG Format is 1 or 2, then MDCFGLCK register is not implemented and this register address should never be decoded as legal
    rfm_assert_mdcfglck_illegal: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_BASE_REG(3'b100) and (`RFM_ADDR_CHK.req_offset_addr[3:2] == 2'b10)) |-> (`RFM_ADDR_CHK.is_addr_legal != 1'b1))
    ) else $error("[%0t] Assertion Failed: MDCFGLCK is not implemented in MDCFG Format 1 or 2", $time);

    // RFM.48. Assertion: If MDCFG Format is 1 or 2, then MDCFG registers are not implemented and these register addresses should never be decoded as legal
    rfm_assert_mdcfg_illegal: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_1, `RFM_ADDR_CHK.MDCFG_START_OFFSET, `RFM_ADDR_CHK.MAX_MDCFG_OFFSET)) |-> (`RFM_ADDR_CHK.is_addr_legal != 1'b1))
    ) else $error("[%0t] Assertion Failed: MDCFG registers are not implemented in MDCFG Format 1 or 2", $time);
  end

  // ######################################### ERROR REPORTING #########################################

  if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : assert_err_reqaddrh_mfr_msiaddr_msiaddrh_illegal

    if (!config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : assert_err_reqaddrh_illegal

      // RFM.49. Assertion: If the system is 32 bit, then ERR_REQADDRH register is not implemented and this register address should never be decoded as legal
      rfm_assert_err_reqaddrh_illegal: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_BASE_REG(3'b110) and (&`RFM_ADDR_CHK.req_offset_addr[3:2])) |-> (`RFM_ADDR_CHK.is_addr_legal != 1'b1))
      ) else $error("[%0t] Assertion Failed: ERR_REQADDRH register is not implemented as system is 32-bit", $time);
    end

    if (!config_iopmp_pkg::iopmp_cfg_default.MFR_EN) begin : assert_err_mfr_illegal

      // RFM.50. Assertion: If IOPMP does not support Multi-Fault Record (MFR) Extension, then ERR_MFR register is not implemented and this register address should never be decoded as legal
      rfm_assert_err_mfr_illegal: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_BASE_REG(3'b110) and (&`RFM_ADDR_CHK.req_offset_addr[3:2])) |-> (`RFM_ADDR_CHK.is_addr_legal != 1'b1))
      ) else $error("[%0t] Assertion Failed: ERR_MFR register is not implemented as IOPMP does not support MFR Extension", $time);
    end

    if (config_iopmp_pkg::iopmp_cfg_default.MSI_EN) begin : assert_msi_enable

      if (!config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : assert_err_msiaddrh_illegal

        // RFM.51. Assertion: If the system is 32 bit and IOPMP supports Message Signal Interrupts (MSI), then ERR_MSIADDRH register is not implemented and this register address should never be decoded as legal
        rfm_assert_msi_enabled_err_msiaddrh_illegal: assert property (
          @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_BASE_REG(3'b111) and (&`RFM_ADDR_CHK.req_offset_addr[3:2])) |-> (`RFM_ADDR_CHK.is_addr_legal != 1'b1))
        ) else $error("[%0t] Assertion Failed: ERR_MSIADDRH register is not implemented as system is 32-bit", $time);
      end
    end
    else begin : assert_msi_disabled

      // RFM.52. Assertion: If IOPMP does not support Message Signal Interrupts (MSI), then ERR_MSIADDR and ERR_MSIADDRH registers are not implemented and these register addresses should never be decoded as legal
      rfm_assert_err_msiaddr_msiaddrh_illegal: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_BASE_REG(3'b111) and (`RFM_ADDR_CHK.req_offset_addr[3])) |-> (`RFM_ADDR_CHK.is_addr_legal != 1'b1))
      ) else $error("[%0t] Assertion Failed: ERR_MSIADD and ERR_MSIADDRH registers are not implemented as MSI_EN is disabled", $time);
    end
  end
  else begin : assert_error_capture_regs_illegal

    // RFM.53. Assertion: If IOPMP does not support ERROR CAPTURE feature, then ERROR Reporting registers are not implemented and these register addresses should never be decoded as legal
    rfm_assert_err_cap_regs_illegal: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((SEQ_BASE_REG(3'b111)) or (SEQ_BASE_REG(3'b110))) |-> (`RFM_ADDR_CHK.is_addr_legal != 1'b1))
    ) else $error("[%0t] Assertion Failed: ERROR REPORTING registers are not implemented as IOPMP does not support ERROR CAPTURE Feature", $time);
  end

  // ########################################### ENTRY ADDRH ###########################################

  if (!config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : assert_entry_addrh_illegal

    // RFM.54. Assertion: If the system is 32 bit, then ENTRY_ADDRH register is not implemented and this register address should never be decoded as legal
    rfm_assert_entry_addrh_illegal: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((SEQ_ADDR_IN_RANGE(`RFM_ADDR_CHK.is_section_2, 0, `RFM_ADDR_CHK.MAX_ENTRY_ARRAY_OFFSET))
      and (`RFM_ADDR_CHK.req_offset_addr[3:2] != 2'b01)) |-> (`RFM_ADDR_CHK.is_addr_legal != 1'b1))
    ) else $error("[%0t] Assertion Failed: ENTRY_ADDRH register is not implemented as system is 32-bit", $time);
  end