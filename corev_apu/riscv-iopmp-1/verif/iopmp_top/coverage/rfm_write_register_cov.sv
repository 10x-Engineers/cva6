  `define RFM_REGMAP tb_top.iopmp_dut.rfm.regmap
  `define WRITE_ACCESS tb_top.iopmp_dut.rfm.regmap.req_access_type

  // Macro to cover write request on Base Registers
  `define WRITE_MACRO(num, condition) \
    property WRITE_REG_``num``; \
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) \
      ( \
        (``condition`` && `WRITE_ACCESS) |-> (16'h``num`` == {5'b00000,`RFM_REGMAP.req_offset_addr,2'b00}) \
      ); \
    endproperty \
    WRITE_REG_OFFSET_``num``: cover property (WRITE_REG_``num``);

  //****************************************************************************************************
  // Cover Properties
  //****************************************************************************************************

  // RFM.1039 - RFM.1060
  // `<name of macro>(register_offset, control_signal)
  `WRITE_MACRO(0000, `RFM_REGMAP.info_legal)           // VERSION
  `WRITE_MACRO(0004, `RFM_REGMAP.info_legal)           // IMPLEMENTATION
  `WRITE_MACRO(0008, `RFM_REGMAP.info_legal)           // HWCFG0
  `WRITE_MACRO(000C, `RFM_REGMAP.info_legal)           // HWCFG1
  `WRITE_MACRO(0010, `RFM_REGMAP.info_legal)           // HWCFG2
  `WRITE_MACRO(0014, `RFM_REGMAP.info_legal)           // ENTRY_OFFSET
  `WRITE_MACRO(0018, `RFM_REGMAP.info_legal)           // BASE_ADDR
  `WRITE_MACRO(0030, `RFM_REGMAP.prog_prot_legal)      // MDSTALL
  `WRITE_MACRO(0034, `RFM_REGMAP.prog_prot_legal)      // MDSTALLH
  `WRITE_MACRO(0038, `RFM_REGMAP.prog_prot_legal)      // RRIDSCP

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_0 || config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_2) begin : mdlck_mdlckh_write_cover
    `WRITE_MACRO(0040, `RFM_REGMAP.config_prot_legal)  // MDLCK
    `WRITE_MACRO(0044, `RFM_REGMAP.config_prot_legal)  // MDLCKH
  end

  if (config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_0) begin : mdcfglck_write_cover
    `WRITE_MACRO(0048, `RFM_REGMAP.config_prot_legal)  // MDCFGLCK
  end

  `WRITE_MACRO(004C, `RFM_REGMAP.config_prot_legal)    // ENTRYLCK

  if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : error_reporting_regs_write_cover
    `WRITE_MACRO(0060, `RFM_REGMAP.err_rpt_legal)      // ERR_CFG
    `WRITE_MACRO(0064, `RFM_REGMAP.err_rpt_legal)      // ERR_INFO
    `WRITE_MACRO(0068, `RFM_REGMAP.err_rpt_legal)      // ERR_REQADDR

    if (config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : err_reqaddrh_write_cover
      `WRITE_MACRO(006C, `RFM_REGMAP.err_rpt_legal)    // ERR_REQADDRH
    end

    `WRITE_MACRO(0070, `RFM_REGMAP.err_rpt_legal)      // ERR_REQID

    if (config_iopmp_pkg::iopmp_cfg_default.MFR_EN) begin : err_mfr_write_cover
      `WRITE_MACRO(0074, `RFM_REGMAP.err_rpt_legal)    // ERR_MFR
    end

    if (config_iopmp_pkg::iopmp_cfg_default.MSI_EN) begin : err_msiaddr_err_msiaddrh_write_cover
      `WRITE_MACRO(0078, `RFM_REGMAP.err_rpt_legal)    // ERR_MSIADDR

      if (config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : err_msiaddrh_write_cover
        `WRITE_MACRO(007C, `RFM_REGMAP.err_rpt_legal)  // ERR_MSIADDRH
      end
    end
  end

  // RFM.1061 - RFM.1123
  // Cover write request on mdcfg registers
  if (config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_0) begin : gen_mdcfg_fmt_0_write_cover
    for (genvar i = 0; i < (config_iopmp_pkg::iopmp_cfg_default.MD_NUM * 4); i = i + 4) begin : mdcfg_reg_write_cover
      property WRITE_REG;
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n)
        (
          (`WRITE_ACCESS && `RFM_REGMAP.mdcfg_legal) |-> (i[10:2] == `RFM_REGMAP.req_offset_addr)
        );
      endproperty

      MDCFG_REG_WRITE_COVER: cover property (WRITE_REG);
    end
  end

  // RFM.1124 - RFM.1507
  // Cover write request on SRCMD registers
  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_0) begin : gen_srcmd_fmt_0_write_cover
    for (genvar i = 0; i < (config_iopmp_pkg::iopmp_cfg_default.RRID_NUM << 5); i = i + 4) begin : srcmd_fmt_0_reg_write_cover
      if (i[4:3] != 2'b11) begin
        property WRITE_REG;
          @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n)
          (
            (`WRITE_ACCESS && `RFM_REGMAP.srcmd_legal) |-> (i[10:2] == `RFM_REGMAP.req_offset_addr)
          );
        endproperty

        SRCMD_REG_WRITE_COVER: cover property (WRITE_REG);
      end
    end
  end

  // RFM.1508 - RFM.1633
  // Cover write request on SRCMD registers
  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_2) begin : gen_srcmd_fmt_2_write_cover
    for (genvar i = 0; i < (config_iopmp_pkg::iopmp_cfg_default.MD_NUM << 5); i = i + 4) begin : srcmd_fmt_2_reg_write_cover
      if ((i[3:2] == 2'b01) || (i[3:2] == 2'b00)) begin
        property WRITE_REG;
          @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n)
          (
            (`WRITE_ACCESS && `RFM_REGMAP.srcmd_legal) |-> (i[10:2] == `RFM_REGMAP.req_offset_addr)
          );
        endproperty

        SRCMD_REG_WRITE_COVER: cover property (WRITE_REG);
      end
    end
  end

  // RFM.1634 - RFM.2017
  // Cover write request on entry array registers
  for (genvar i = 0; i < (config_iopmp_pkg::iopmp_cfg_default.ENTRY_NUM << 4); i = i + 4) begin : entry_array_reg_write_cover
    if ((i[3:2] != 2'b11)) begin
      property WRITE_REG;
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n)
        (
          (`WRITE_ACCESS && `RFM_REGMAP.entry_array_legal) |-> (i[10:2] == `RFM_REGMAP.req_offset_addr)
        );
      endproperty

      ENTRY_ARRAY_REG_WRITE_COVER: cover property (WRITE_REG);
    end
  end