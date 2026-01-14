  `define RFM_REGMAP tb_top.iopmp_dut.rfm.regmap
  `define L1_MUX_SEL tb_top.iopmp_dut.rfm.regmap.read_register.l1_mux_sel
  `define REQ_ACCESS tb_top.iopmp_dut.rfm.regmap.req_access_type

  // Macro to cover the read request on a Base Registers
  `define READ_MACRO(num, legal_value) \
    property READ_REG_``num``; \
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) \
      ( \
        ((16'h``num`` == {5'b00000,`RFM_REGMAP.req_offset_addr,2'b00}) && (!`REQ_ACCESS) && `RFM_REGMAP.is_addr_legal && `RFM_REGMAP.base_reg_legal) |-> (`L1_MUX_SEL == 3'h``legal_value``) \
      ); \
    endproperty \
    READ_REG_OFFSET_``num``: cover property (READ_REG_``num``);

  //****************************************************************************************************
  // Cover Properties
  //****************************************************************************************************

  // RFM.55. Cover Property: If the incoming request address is not legal, then l1_mux_sel must be 3'b111
  rfm_cover_l1_mux_sel_3b111: cover property (
    @(posedge clk) ((!`RFM_REGMAP.is_addr_legal) |-> (`L1_MUX_SEL == 3'b111))
  );

  if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN && config_iopmp_pkg::iopmp_cfg_default.MFR_EN) begin : cover_err_mfr_read_legal

    // RFM.56. Cover Property: If there is a read request on err_mfr register when MFR Extension is enabled, then err_mfr read legal should be generated
    rfm_cover_err_mfr_read_legal: cover property (
      @(posedge clk) ((`RFM_REGMAP.err_rpt_legal && `RFM_REGMAP.is_addr_legal && (!`REQ_ACCESS) && (`RFM_REGMAP.req_offset_addr[2:0] == 3'b101)) |-> (`RFM_REGMAP.err_mfr_read_legal))
    );
  end

  // #################################### BASE REGISTERS Read Cover ####################################

  // RFM.57 - RFM.78
  // `<name of macro>(register offset, level 2 mux number)
  `READ_MACRO(0000, 0)        // VERSION
  `READ_MACRO(0004, 0)        // IMPLEMENTATION
  `READ_MACRO(0008, 0)        // HWCFG0
  `READ_MACRO(000C, 0)        // HWCFG1
  `READ_MACRO(0010, 0)        // HWCFG2
  `READ_MACRO(0014, 0)        // ENTRY_OFFSET
  `READ_MACRO(0018, 0)        // BASE_ADDR
  `READ_MACRO(0030, 1)        // MDSTALL
  `READ_MACRO(0034, 1)        // MDSTALLH
  `READ_MACRO(0038, 1)        // RRIDSCP

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_0 || config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_2) begin : mdlck_mdlckh_read_cover
    `READ_MACRO(0040, 2)      // MDLCK
    `READ_MACRO(0044, 2)      // MDLCKH
  end

  if (config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_0) begin : mdcfglck_read_cover
    `READ_MACRO(0048, 2)      // MDCFGLCK
  end
  `READ_MACRO(004C, 2)        // ENTRYLCK

  if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : error_reporting_regs_read_cover
    `READ_MACRO(0060, 3)      // ERR_CFG
    `READ_MACRO(0064, 3)      // ERR_INFO
    `READ_MACRO(0068, 3)      // ERR_REQADDR

    if (config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : err_reqaddrh_read_cover
      `READ_MACRO(006C, 3)    // ERR_REQADDRH
    end

    `READ_MACRO(0070, 3)      // ERR_REQID

    if (config_iopmp_pkg::iopmp_cfg_default.MFR_EN) begin : err_mfr_read_cover
      `READ_MACRO(0074, 3)    // ERR_MFR
    end

    if (config_iopmp_pkg::iopmp_cfg_default.MSI_EN) begin : err_msiaddr_err_msiaddrh_read_cover
    `READ_MACRO(0078, 3)      // ERR_MSIADDR

    if (config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : err_msiaddrh_read_cover
      `READ_MACRO(007C, 3)    // ERR_MSIADDRH
    end
    end
  end

  // #################################### MDCFG REGISTERS Read Cover ###################################

  // RFM.79 - RFM.141
  // Cover read request on mdcfg registers
  if (config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_0) begin : gen_mdcfg_fmt_0_read_cover
    for (genvar i = 0; i < (config_iopmp_pkg::iopmp_cfg_default.MD_NUM * 4); i = i + 4) begin : mdcfg_reg_read_cover
      property READ_REG;
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n)
        (
          ((i[10:2] == `RFM_REGMAP.req_offset_addr) && (!`REQ_ACCESS) && `RFM_REGMAP.is_addr_legal && `RFM_REGMAP.mdcfg_legal) |-> (`L1_MUX_SEL == 3'b100)
        );
      endproperty

      MDCFG_REG_READ_COVER: cover property (READ_REG);
    end
  end

  // ################################ SRCMD FMT 0 REGISTERS Read Cover #################################

  // RFM.142 - RFM.525
  // Cover read request on srcmd registers for SRCMD Format 0
  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_0) begin : gen_srcmd_fmt_0_read_cover
    for (genvar i = 0; i < (config_iopmp_pkg::iopmp_cfg_default.RRID_NUM << 5); i = i + 4) begin : srcmd_fmt_0_reg_read_cover
      if (i[4:3] != 2'b11) begin : gen_cover_for_srcmd_regs
        property READ_REG;
          @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n)
          (
            ((i[10:2] == `RFM_REGMAP.req_offset_addr) && (!`REQ_ACCESS) && `RFM_REGMAP.is_addr_legal && `RFM_REGMAP.srcmd_legal) |-> (`L1_MUX_SEL == 3'b101)
          );
        endproperty

        SRCMD_REG_READ_COVER: cover property (READ_REG);
      end
    end
  end

  // ################################ SRCMD FMT 2 REGISTERS Read Cover #################################

  // RFM.526 - RFM.651
  // Cover read request on srcmd registers for SRCMD Format 2
  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_2) begin  : gen_srcmd_fmt_2_read_cover
    for (genvar i = 0; i < (config_iopmp_pkg::iopmp_cfg_default.MD_NUM << 5); i = i + 4) begin : srcmd_fmt_2_reg_read_cover
      if ((i[3:2] == 2'b01) || (i[3:2] == 2'b00)) begin
        property READ_REG;
          @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n)
          (
            ((i[10:2] == `RFM_REGMAP.req_offset_addr) && (!`REQ_ACCESS) && `RFM_REGMAP.is_addr_legal && `RFM_REGMAP.srcmd_legal) |-> (`L1_MUX_SEL == 3'b101)
          );
        endproperty

        SRCMD_REG_READ_COVER: cover property (READ_REG);
      end
    end
  end

  // ################################ ENTRY ARRAY REGISTERS Read Cover #################################

  // RFM.652 - RFM.1035
  // Cover read request on entry array registers
  for (genvar i = 0; i < (config_iopmp_pkg::iopmp_cfg_default.ENTRY_NUM << 4); i = i + 4) begin : entry_array_reg_read_cover
    if ((i[3:2] != 2'b11)) begin : gen_cover_for_entry_array_regs
      property READ_REG;
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n)
        (
          ((i[10:2] == `RFM_REGMAP.req_offset_addr) && (!`REQ_ACCESS) && `RFM_REGMAP.is_addr_legal && `RFM_REGMAP.entry_array_legal) |-> (`L1_MUX_SEL == 3'b110)
        );
      endproperty

      ENTRY_ARRAY_REG_READ_COVER: cover property (READ_REG);
    end
  end

  //****************************************************************************************************
  // Assertions
  //****************************************************************************************************

  // RFM.1036. Assertion: If the incoming request address is a legal, then l1_mux_sel should never be 3'b111
  rfm_assert_l1_mux_sel_for_lega_addr: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`RFM_REGMAP.is_addr_legal) |-> (`L1_MUX_SEL != 3'b111))
  ) else $error("[%0t] Assertion Failed: The address is legal but l1_mux_sel is 3'b111", $time);

  // RFM.1037. Assertion: If the incoming request address is not, then l1_mux_sel should never be 3'b000 - 3'b110
  rfm_assert_l1_mux_sel_for_illega_addr: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((!`RFM_REGMAP.is_addr_legal) |-> ((&`L1_MUX_SEL) != 1'b0))
  ) else $error("[%0t] Assertion Failed: The address is not legal but l1_mux_sel is either 3'b000 or 3'b001, ..., 3'b110", $time);

  if (!config_iopmp_pkg::iopmp_cfg_default.MFR_EN) begin : assert_err_mfr_read_illegal

    // RFM.1038. Assertion: If there is a read request on err_mfr register when MFR Extension is disabled, then read legal on err_mfr must not be generated
    rfm_assert_err_mfr_read_illegal: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`RFM_REGMAP.err_rpt_legal && `RFM_REGMAP.is_addr_legal && (!`REQ_ACCESS) && (`RFM_REGMAP.req_offset_addr[2:0] == 3'b101)) |-> (`RFM_REGMAP.err_mfr_read_legal != 1'b1))
    ) else $error("[%0t] Assertion Failed: Read on err_mfr register is illegal", $time);
  end
