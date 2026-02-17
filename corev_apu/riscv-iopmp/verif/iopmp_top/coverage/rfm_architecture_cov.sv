  `define ENTRY_ARRAY_PATH tb_top.iopmp_dut.rfm.regmap.entry_array_regs
  `define SRCMD_FMT_0_PATH tb_top.iopmp_dut.rfm.regmap.gen_srcmd_fmt_0_write_path.srcmd_fmt_0_regs
  `define SRCMD_FMT_2_PATH tb_top.iopmp_dut.rfm.regmap.gen_srcmd_fmt_2_write_path.srcmd_fmt_2_regs
  `define MDCFG_PATH tb_top.iopmp_dut.rfm.regmap.gen_mdcfg_fmt_0_write_path.mdcfg_regs
  `define INFO_PATH tb_top.iopmp_dut.rfm.regmap.base_regs.info_regs
  `define PROG_PROT_PATH tb_top.iopmp_dut.rfm.regmap.base_regs.prog_prot_regs
  `define ERR_RPT_PATH tb_top.iopmp_dut.rfm.regmap.base_regs.err_rpt_regs
  `define CONFIG_PROT_PATH tb_top.iopmp_dut.rfm.regmap.base_regs.config_prot_regs

  import rfm_pkg::*;

  //****************************************************************************************************
  // Cover Properties/Assertions
  //****************************************************************************************************

  // ######################################### SRCMD FORMAT 0 ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_0) begin : assert_srcmd_fmt_0_lock

    // RFM.2018. Assertion: If SRCMD_EN(s).l is asserted, then SRCMD_EN(s) SW write enable signal should not be asserted when SW tries to write on it
    rfm_assert_srcmd_en_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`SRCMD_FMT_0_PATH.srcmd_table_0[`SRCMD_FMT_0_PATH.srcmd_selected_demux].srcmd_en.l && `SRCMD_FMT_0_PATH.srcmd_reg_write_valid
      && `SRCMD_FMT_0_PATH.srcmd_legal && (`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_EN)) |-> (`SRCMD_FMT_0_PATH.srcmd_en_md_swen[`SRCMD_FMT_0_PATH.srcmd_selected_demux] != 1'b1))
    ) else $error("[%0t] Assertion Failed: SRCMD_EN(s) register is locked so write should not happen", $time);

    // RFM.2019. Assertion: If SRCMD_EN(s).l is asserted, then SRCMD_ENH(s) SW write enable signal should not be asserted when SW tries to write on it
    rfm_assert_srcmd_enh_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`SRCMD_FMT_0_PATH.srcmd_table_0[`SRCMD_FMT_0_PATH.srcmd_selected_demux].srcmd_en.l && `SRCMD_FMT_0_PATH.srcmd_reg_write_valid
      && `SRCMD_FMT_0_PATH.srcmd_legal && (`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_ENH)) |-> (`SRCMD_FMT_0_PATH.srcmd_enh_swen[`SRCMD_FMT_0_PATH.srcmd_selected_demux] != 1'b1))
    ) else $error("[%0t] Assertion Failed: SRCMD_ENH(s) register is locked so write should not happen", $time);

    // ######################################### SPS SUPPORT ###########################################

    if (config_iopmp_pkg::iopmp_cfg_default.SPS_EN) begin : assert_sps_enabled

      // RFM.2020. Assertion: If SRCMD_EN(s).l is asserted, then SRCMD_R(s) SW write enable signal should not be asserted when SW tries to write on it
      rfm_assert_srcmd_r_locked: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`SRCMD_FMT_0_PATH.srcmd_table_0[`SRCMD_FMT_0_PATH.srcmd_selected_demux].srcmd_en.l && `SRCMD_FMT_0_PATH.srcmd_reg_write_valid
        && `SRCMD_FMT_0_PATH.srcmd_legal && (`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_R)) |-> (`SRCMD_FMT_0_PATH.srcmd_r_swen[`SRCMD_FMT_0_PATH.srcmd_selected_demux] != 1'b1))
      ) else $error("[%0t] Assertion Failed: SRCMD_R(s) register is locked so write should not happen", $time);

      // RFM.2021. Assertion: If SRCMD_EN(s).l is asserted, then SRCMD_RH(s) SW write enable signal should not be asserted when SW tries to write on it
      rfm_assert_srcmd_rh_locked: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`SRCMD_FMT_0_PATH.srcmd_table_0[`SRCMD_FMT_0_PATH.srcmd_selected_demux].srcmd_en.l && `SRCMD_FMT_0_PATH.srcmd_reg_write_valid
        && `SRCMD_FMT_0_PATH.srcmd_legal && (`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_RH)) |-> (`SRCMD_FMT_0_PATH.srcmd_w_swen[`SRCMD_FMT_0_PATH.srcmd_selected_demux] != 1'b1))
      ) else $error("[%0t] Assertion Failed: SRCMD_RH(s) register is locked so write should not happen", $time);

      // RFM.2022. Assertion: If SRCMD_EN(s).l is asserted, then SRCMD_W(s) SW write enable signal should not be asserted when SW tries to write on it
      rfm_assert_srcmd_w_locked: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`SRCMD_FMT_0_PATH.srcmd_table_0[`SRCMD_FMT_0_PATH.srcmd_selected_demux].srcmd_en.l && `SRCMD_FMT_0_PATH.srcmd_reg_write_valid
        && `SRCMD_FMT_0_PATH.srcmd_legal && (`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_W)) |-> (`SRCMD_FMT_0_PATH.srcmd_r_swen[`SRCMD_FMT_0_PATH.srcmd_selected_demux] != 1'b1))
      ) else $error("[%0t] Assertion Failed: SRCMD_W(s) register is locked so write should not happen", $time);

      // RFM.2023. Assertion: If SRCMD_EN(s).l is asserted, then SRCMD_WH(s) SW write enable signal should not be asserted when SW tries to write on it
      rfm_assert_srcmd_wh_locked: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`SRCMD_FMT_0_PATH.srcmd_table_0[`SRCMD_FMT_0_PATH.srcmd_selected_demux].srcmd_en.l && `SRCMD_FMT_0_PATH.srcmd_reg_write_valid
        && `SRCMD_FMT_0_PATH.srcmd_legal && (`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_WH)) |-> (`SRCMD_FMT_0_PATH.srcmd_wh_swen[`SRCMD_FMT_0_PATH.srcmd_selected_demux] != 1'b1))
      ) else $error("[%0t] Assertion Failed: SRCMD_WH(s) register is locked so write should not happen", $time);
    end
    else begin : assert_sps_unsupported

      // RFM.2024. Assertion: If a write appears on SRCMD_R register when SPS extension is disabled, then the SW write enable signal for SRCMD_R should never be asserted
      rfm_assert_srcmd_r_write_invalid: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_R) |-> (`SRCMD_FMT_0_PATH.srcmd_r_swen[`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel] != 1'b1))
      ) else $error("[%0t] Assertion Failed: Wite should never happen on SRCMD_R register when SPS_EN is disabled", $time);

      // RFM.2025. Assertion: If a write appears on SRCMD_RH register when SPS extension is disabled, then the SW write enable signal for SRCMD_RH should never be asserted
      rfm_assert_srcmd_rh_write_invalid: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_RH) |-> (`SRCMD_FMT_0_PATH.srcmd_rh_swen[`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel] != 1'b1))
      ) else $error("[%0t] Assertion Failed: Wite should never happen on SRCMD_RH register when SPS_EN is disabled", $time);

      // RFM.2026. Assertion: If a write appears on SRCMD_W register when SPS extension is disabled, then the SW write enable signal for SRCMD_W should never be asserted
      rfm_assert_srcmd_w_write_invalid: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_W) |-> (`SRCMD_FMT_0_PATH.srcmd_w_swen[`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel] != 1'b1))
      ) else $error("[%0t] Assertion Failed: Wite should never happen on SRCMD_W register when SPS_EN is disabled", $time);

      // RFM.2027. Assertion: If a write appears on SRCMD_WH register when SPS extension is disabled, then the SW write enable signal for SRCMD_WH should never be asserted
      rfm_assert_srcmd_wh_write_invalid: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_WH) |-> (`SRCMD_FMT_0_PATH.srcmd_wh_swen[`SRCMD_FMT_0_PATH.srcmd_reg_demux_sel] != 1'b1))
      ) else $error("[%0t] Assertion Failed: Wite should never happen on SRCMD_WH register when SPS_EN is disabled", $time);
    end
  end

  // ######################################### SRCMD FORMAT 2 ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_2) begin : assert_srcmd_fmt_2_lock

    // RFM.2028. Assertion: If MDLCK.md[m] is asserted, then SRCMD_PERM(m)) SW write enable signal should not be asserted when SW tries to write on it
    rfm_assert_srcmd_perm_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((((`CONFIG_PROT_PATH.config_prot_reg.mdlck.md >> `SRCMD_FMT_2_PATH.srcmd_selected_demux) & 1'b1) && `SRCMD_FMT_2_PATH.srcmd_reg_write_valid
      && `SRCMD_FMT_2_PATH.srcmd_legal && (`SRCMD_FMT_2_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_PERM)) |-> (`SRCMD_FMT_2_PATH.srcmd_perm_swen[`SRCMD_FMT_2_PATH.srcmd_selected_demux] != 1'b1))
    ) else $error("[%0t] Assertion Failed: SRCMD_PERM(m) register is locked so write should not happen", $time);

    // RFM.2029. Assertion: If MDLCKH.mdh[m] is asserted, then SRCMD_PERMH(m) SW write enable signal should not be asserted when SW tries to write on it
    rfm_assert_srcmd_permh_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((((`CONFIG_PROT_PATH.config_prot_reg.mdlckh.mdh >> `SRCMD_FMT_2_PATH.srcmd_selected_demux) & 1'b1) && `SRCMD_FMT_2_PATH.srcmd_reg_write_valid
      && `SRCMD_FMT_2_PATH.srcmd_legal && (`SRCMD_FMT_2_PATH.srcmd_reg_demux_sel == IOPMP_SRCMD_PERMH)) |-> (`SRCMD_FMT_2_PATH.srcmd_permh_swen[`SRCMD_FMT_2_PATH.srcmd_selected_demux] != 1'b1))
    ) else $error("[%0t] Assertion Failed: SRCMD_PERMH(m) register is locked so write should not happen", $time);
  end

  // ######################################## MDLCK MDLCKH REGS ########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_0 || config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_2) begin : mdlck_mdlckh_locked

    // RFM.2030. Cover Property: If MDLCK.l is asserted, then MDLCK SW write enable signal should not be asserted when SW tries to write on it
    rfm_cover_mdlck_locked: cover property (
      @(posedge clk) ((`CONFIG_PROT_PATH.config_prot_reg.mdlck.l && `CONFIG_PROT_PATH.config_prot_reg_write_valid && `CONFIG_PROT_PATH.config_prot_legal &&
      (`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_MDLCK)) |-> (`CONFIG_PROT_PATH.mdlck_md_swen != 1'b1))
    );

    // RFM.2031. Cover Property: If MDLCK.l is asserted, then MDLCK SW write enable signal should not be asserted when SW tries to write on it
    rfm_cover_mdlckh_locked: cover property (
      @(posedge clk) ((`CONFIG_PROT_PATH.config_prot_reg.mdlck.l && `CONFIG_PROT_PATH.config_prot_reg_write_valid && `CONFIG_PROT_PATH.config_prot_legal &&
      (`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_MDLCKH)) |-> (`CONFIG_PROT_PATH.mdlckh_mdh_swen != 1'b1))
    );

    // RFM.2032. Assertion: If MDLCK.l is asserted, then MDLCK SW write enable signal should not be asserted
    rfm_assert_mdlck_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`CONFIG_PROT_PATH.config_prot_reg.mdlck.l && `CONFIG_PROT_PATH.config_prot_reg_write_valid &&
      `CONFIG_PROT_PATH.config_prot_legal && (`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_MDLCK)) |-> (`CONFIG_PROT_PATH.mdlck_md_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: MDLCK register is locked so write should not happen", $time);

    // RFM.2033. Assertion: If MDLCK.l is asserted, then MDLCKH SW write enable signal should not be asserted
    rfm_assert_mdlckh_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`CONFIG_PROT_PATH.config_prot_reg.mdlck.l && `CONFIG_PROT_PATH.config_prot_reg_write_valid &&
      `CONFIG_PROT_PATH.config_prot_legal && (`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_MDLCKH)) |-> (`CONFIG_PROT_PATH.mdlckh_mdh_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: MDLCKH register is locked so write should not happen", $time);
  end
  else begin : mdlck_mdlckh_unsupported

    // RFM.2034. Assertion: If SRCMD Format is 1, then MDLCK SW write enable signal should never be asserted
    rfm_assert_mdlck_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_MDLCK) |-> (`CONFIG_PROT_PATH.mdlck_md_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on MDLCK when SRCMD Format is 1", $time);

    // RFM.2035. Assertion: If SRCMD Format is 1, then MDLCKH SW write enable signal should never be asserted
    rfm_assert_mdlckh_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_MDLCKH) |-> (`CONFIG_PROT_PATH.mdlckh_mdh_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on MDLCKH when SRCMD Format is 1", $time);
  end

  // ######################################### MDCFG FORMAT 0 ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_0) begin : mdcfg_fmt_0

    // RFM.2036. Cover Property: If MDCFGLCK.l is asserted, then MDCFGLCK SW write enable signal should not be asserted when SW tries to write on it
    rfm_cover_mdcfglck_locked: cover property (
      @(posedge clk) ((`CONFIG_PROT_PATH.config_prot_reg.mdcfglck.l && `CONFIG_PROT_PATH.config_prot_reg_write_valid && `CONFIG_PROT_PATH.config_prot_legal &&
      (`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_MDCFGLCK)) |-> (`CONFIG_PROT_PATH.mdcfglck_f_swen != 1'b1))
    );

    // RFM.2037. Assertion: If MDCFGLCK.l is asserted, then MDCFGLCK SW write enable signal should not be asserted when SW tries to write on it
    rfm_assert_mdcfglck_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`CONFIG_PROT_PATH.config_prot_reg.mdcfglck.l && `CONFIG_PROT_PATH.config_prot_reg_write_valid &&
      `CONFIG_PROT_PATH.config_prot_legal && (`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_MDCFGLCK)) |-> (`CONFIG_PROT_PATH.mdcfglck_f_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: MDCFGLCK register is locked so write should not happen", $time);

    // RFM.2038. Assertion: If a write happens on MDCFGLK, then MDCFGLCK.f value should never be greater than HWCFG0.md_num
    rfm_assert_mdcfglck_f_write_legal: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`CONFIG_PROT_PATH.mdcfglck_f_swen)
      |=> (!(`CONFIG_PROT_PATH.config_prot_reg.mdcfglck.f > `INFO_PATH.info_reg.hwcfg0.md_num)))
    ) else $error("[%0t] Assertion Failed: MDCFGLCK.f legal value can be 0 - HWCFG0.md_num", $time);

    // RFM.2039. Assertion: If a write happens on any of the MDCFG register, then MDCFG.t value should never be greater than HWCFG1.entry_num
    rfm_assert_mdcfg_t_write_legal: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`MDCFG_PATH.mdcfg_t_swen[{`MDCFG_PATH.mdcfg_selected_demux, `MDCFG_PATH.mdcfg_reg_demux_sel}])
      |=> (!(`MDCFG_PATH.mdcfg_table[{`MDCFG_PATH.mdcfg_selected_demux_q, `MDCFG_PATH.mdcfg_reg_demux_sel_q}].t > `INFO_PATH.info_reg.hwcfg1.entry_num)))
    ) else $error("[%0t] Assertion Failed: MDCFG.t legal value can be 0 - HWCFG1.entry_num", $time);

    // RFM.2040. Assertion: If there is write request on any of the MDCFG register that is locked, then SW write enabled signal for that register should not be asserted
    rfm_assert_mdcfg_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`MDCFG_PATH.mdcfg_reg_write_valid && `MDCFG_PATH.mdcfg_legal &&
      ({`MDCFG_PATH.mdcfg_selected_demux, `MDCFG_PATH.mdcfg_reg_demux_sel} < `CONFIG_PROT_PATH.config_prot_reg.mdcfglck.f))
      |=> (`MDCFG_PATH.mdcfg_t_swen[{`MDCFG_PATH.mdcfg_selected_demux, `MDCFG_PATH.mdcfg_reg_demux_sel}] != 1'b1))
    ) else $error("[%0t] Assertion Failed: MDCFG(m) is locked so write should not happen", $time);
  end
  else begin : mdlcfglck_unsupported

    // RFM.2041. Assertion: If MDCFG Format is not 0, then MDCFGLCK SW write enable signal should never be asserted
    rfm_assert_mdcfglck_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_MDCFGLCK) |-> (`CONFIG_PROT_PATH.mdcfglck_f_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on MDCFGLCK when MDCFG Format is 1 or 2", $time);
  end

  // ######################################### TOR UNSUPPORTED #########################################

  if (!config_iopmp_pkg::iopmp_cfg_default.TOR_EN) begin : assert_tor_unsupported

    // RFM.2043. Assertion: If TOR address mode is not supported, then none of the the ENTRY_CFG.a should configured as TOR
    rfm_assert_tor_unsupport: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ENTRY_ARRAY_PATH.entry_cfg_a_swen[`ENTRY_ARRAY_PATH.entry_array_selected_demux])
      |=> (`ENTRY_ARRAY_PATH.entry_array[`ENTRY_ARRAY_PATH.entry_array_selected_demux_q[0]].entry_cfg.a != IOPMP_TOR))
    ) else $error("[%0t] Assertion Failed: ENTRY_CFG.a is configured as TOR when TOR_EN is disabled", $time);
  end

  // ################################# INTRPT SUPPRESSION UNSUPPORTED ##################################

  if (!config_iopmp_pkg::iopmp_cfg_default.PEIS) begin : assert_intrpt_suppress_bits_hardwired_zeros

    // RFM.2044. Assertion: If interrupt suppression bits are not implemented, then the SW write enable signal for ENTRY_CFG.sire should never be asserted
    rfm_assert_sire_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ENTRY_ARRAY_PATH.entry_array_legal && (`ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[1:0] == 2'b10))
      |-> (`ENTRY_ARRAY_PATH.entry_cfg_sire_swen[{`ENTRY_ARRAY_PATH.entry_array_selected_demux, `ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[2]}] != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on ENTRY_CFG.sire bit when PEIS is disabled", $time);

    // RFM.2045. Assertion: If interrupt suppression bits are not implemented, then the SW write enable signal for ENTRY_CFG.siwe should never be asserted
    rfm_assert_siwe_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ENTRY_ARRAY_PATH.entry_array_legal && (`ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[1:0] == 2'b10))
      |-> (`ENTRY_ARRAY_PATH.entry_cfg_siwe_swen[{`ENTRY_ARRAY_PATH.entry_array_selected_demux, `ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[2]}] != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on ENTRY_CFG.siwe bit when PEIS is disabled", $time);

    // RFM.2046. Assertion: If interrupt suppression bits are not implemented, then the SW write enable signal for ENTRY_CFG.sixe should never be asserted
    rfm_assert_sixe_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ENTRY_ARRAY_PATH.entry_array_legal && (`ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[1:0] == 2'b10))
      |-> (`ENTRY_ARRAY_PATH.entry_cfg_sixe_swen[{`ENTRY_ARRAY_PATH.entry_array_selected_demux, `ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[2]}] != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on ENTRY_CFG.sixe bit when PEIS is disabled", $time);
  end

  // ########################################## ENTRY ADDRH ############################################

  if (config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : assert_entry_addrh_locked

    // RFM.2047. Assertion: If there is write request on any of the ENTRY_ADDRH register that is locked, then SW write enabled signal for that register should not be asserted
    rfm_assert_entry_addrh_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ENTRY_ARRAY_PATH.entry_array_reg_write_valid && `ENTRY_ARRAY_PATH.entry_array_legal && (`ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[1:0] == 2'b01)
      && ({`ENTRY_ARRAY_PATH.entry_array_selected_demux, `ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[2]} < `CONFIG_PROT_PATH.config_prot_reg.entrylck.f))
      |=> (`ENTRY_ARRAY_PATH.entry_addrh_swen[{`ENTRY_ARRAY_PATH.entry_array_selected_demux, `ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[2]}] != 1'b1))
    ) else $error("[%0t] Assertion Failed: ENTRY_ADDRH(i) is locked so write should not happen", $time);
  end
  else begin : assert_entry_addrh_unsupported

    // RFM.2048. Assertion: If the system supports 32 bit address bus, then the SW write enable signal for ENTRY_ADDRH should never be asserted
    rfm_assert_entry_addrh_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[1:0] == 2'b01)) |-> ((|`ENTRY_ARRAY_PATH.entry_addrh_swen) != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on ENTRY_AADRH when ADDRH_EN is disabled", $time);
  end

  // ################################### PROGRAMABLE PRORITY FEATURE ###################################

  if (config_iopmp_pkg::iopmp_cfg_default.PRIENT_PROG) begin : assert_prog_prio_entry_supported

    // RFM.2049. Assertion: If programmable priority entry feature is supported, then hwcfg2.prio_entry value should never be greater than 48
    rfm_assert_prio_entry_write_legal: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`INFO_PATH.hwcfg2_prio_entry_swen)
      |=> (!(`INFO_PATH.info_reg.hwcfg2.prio_entry > 16'd48)))
    ) else $error("[%0t] Assertion Failed: HWCFG2.prio_entry legal value can be 0 - 48", $time);
  end
  else begin : assert_prog_prio_entry_unsupported

    // RFM.2050. Assertion: If programmable priority entry feature is not supported, then hwcfg2.prio_entry SW write enable signal should never be asserted
    rfm_assert_prio_entry_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`INFO_PATH.info_reg_demux_sel == IOPMP_HWCFG2) && `INFO_PATH.info_legal)
      |-> (`INFO_PATH.hwcfg2_prio_entry_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on HWCFG2.prio_entry when PRIENT_PROG is disabled", $time);
  end

  // #################################### PROGRAMABLE MD_ENTRY_NUM #####################################

  if (config_iopmp_pkg::iopmp_cfg_default.MDCFG_FMT_2) begin : cover_hwcfg0_md_entry_num_locked

    // RFM.2051. Assertion: If MDCFG Format is 2 and HWCFG0.enable is asserted, then hwcfg0.md_entry_num SW write enable signal should not be asserted
    rfm_assert_md_entry_num_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`INFO_PATH.info_reg_demux_sel == IOPMP_HWCFG0) && `INFO_PATH.info_legal && `INFO_PATH.info_reg.hwcfg0.enable)
      |-> (`INFO_PATH.hwcfg0_md_entry_num_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: HWCFG0.md_entry_num is locked as HWCFG0.enable is 1.", $time);
  end
  else begin : assert_md_entry_num_write_invalid

    // RFM.2052. Assertion: If MDCFG Format is not 2, then hwcfg0.md_entry_num SW write enable signal should never be asserted
    rfm_assert_md_entry_num_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`INFO_PATH.info_reg_demux_sel == IOPMP_HWCFG0) && `INFO_PATH.info_legal)
      |-> (`INFO_PATH.hwcfg0_md_entry_num_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on HWCFG0.md_entry_num when MDCFG Format is not 2", $time);
  end

  // ######################################### STALL FEATURE ###########################################

  if (config_iopmp_pkg::iopmp_cfg_default.STALL_EN) begin : cover_rridscp_stat_write

    // RFM.2053. Cover Property: If RRIDSCP.op querries the status of stall for the selected RRID, then RRIDSCP SW write enable signal should be asserted
    rfm_cover_rridscp_op_value_0: cover property (
      @(posedge clk) ((`PROG_PROT_PATH.rridscp_op_swen && (`PROG_PROT_PATH.rridscp_op_swdata == 2'b00)) |-> (`PROG_PROT_PATH.rridscp_stat_hwen == 1'b1))
    );
  end
  else begin : assert_stalling_unsupported

    // RFM.2054. Assertion: If stalling feature is not supported, then MDSTALL SW write enable signal should never be asserted
    rfm_assert_mdstall_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`PROG_PROT_PATH.prog_prot_demux_sel == IOPMP_MDSTALL) && `PROG_PROT_PATH.prog_prot_legal)
      |-> (`PROG_PROT_PATH.mdstall_exempt_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on MDSTALL register when STALL_EN is disabled", $time);

    // RFM.2055. Assertion: If stalling feature is not supported, then MDSTALLH SW write enable signal should never be asserted
    rfm_assert_mdstallh_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`PROG_PROT_PATH.prog_prot_demux_sel == IOPMP_MDSTALLH) && `PROG_PROT_PATH.prog_prot_legal)
      |-> (`PROG_PROT_PATH.mdstallh_mdh_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on MDSTALLH register when STALL_EN is disabled", $time);

    // RFM.2056. Assertion: If stalling feature is not supported, then RRIDSCP SW write enable signal should never be asserted
    rfm_assert_rridscp_write_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`PROG_PROT_PATH.prog_prot_demux_sel == IOPMP_RRIDSCP) && `PROG_PROT_PATH.prog_prot_legal)
      |-> (`PROG_PROT_PATH.rridscp_op_swen != 1'b1))
    ) else $error("[%0t] Assertion Failed: Write should never happen on RRIDSCP register when STALL_EN is disabled", $time);
  end

  // ####################################### ENTRY LOCK FEATURE ########################################

  // RFM.2057. Cover Property: If ENTRLCK.l is asserted, then ENTRYLCK SW write enable signal should not be asserted when SW tries to write on it
  rfm_cover_entrylck_locked: cover property (
    @(posedge clk) ((`CONFIG_PROT_PATH.config_prot_reg.entrylck.l && `CONFIG_PROT_PATH.config_prot_reg_write_valid && `CONFIG_PROT_PATH.config_prot_legal &&
    (`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_ENTRYLCK)) |-> (`CONFIG_PROT_PATH.entrylck_f_swen != 1'b1))
  );

  // RFM.2058. Assertion: If ENTRYLCK.l is asserted, then ENTRYLCK SW write enable signal should not be asserted when SW tries to write on it
  rfm_assert_entrylck_locked: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`CONFIG_PROT_PATH.config_prot_reg.entrylck.l && `CONFIG_PROT_PATH.config_prot_reg_write_valid &&
    `CONFIG_PROT_PATH.config_prot_legal && (`CONFIG_PROT_PATH.config_prot_reg_demux_sel == IOPMP_ENTRYLCK)) |-> (`CONFIG_PROT_PATH.entrylck_f_swen != 1'b1))
  ) else $error("[%0t] Assertion Failed: ENTRYLCK register is locked so write should not happen", $time);

  // RFM.2059. Assertion: If a write happens on ENTRYLCK, then ENTRYLCK.f value should never be greater than HWCFG0.entry_num
  rfm_assert_entrylck_f_write_legal: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`CONFIG_PROT_PATH.entrylck_f_swen)
    |=> (!(`CONFIG_PROT_PATH.config_prot_reg.entrylck.f > `INFO_PATH.info_reg.hwcfg1.entry_num)))
  ) else $error("[%0t] Assertion Failed: ENTRYLCK.f legal value can be 0 - HWCFG1.entry_num", $time);

  // RFM.2060. Assertion: If there is write request on any of the ENTRY_ADDR register that is locked, then SW write enabled signal for that register should not be asserted
  rfm_assert_entry_addr_locked: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ENTRY_ARRAY_PATH.entry_array_reg_write_valid && `ENTRY_ARRAY_PATH.entry_array_legal && (`ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[1:0] == 2'b00)
    && ({`ENTRY_ARRAY_PATH.entry_array_selected_demux, `ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[2]} < `CONFIG_PROT_PATH.config_prot_reg.entrylck.f))
    |=> (`ENTRY_ARRAY_PATH.entry_addr_swen[{`ENTRY_ARRAY_PATH.entry_array_selected_demux, `ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[2]}] != 1'b1))
  ) else $error("[%0t] Assertion Failed: ENTRY_ADDR(i) is locked so write should not happen", $time);

  // RFM.2061. Assertion: If there is write request on any of the ENTRY_CFG register that is locked, then SW write enabled signal for that register should not be asserted
  rfm_assert_entry_cfg_locked: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ENTRY_ARRAY_PATH.entry_array_reg_write_valid && `ENTRY_ARRAY_PATH.entry_array_legal && (`ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[1:0] == 2'b10)
    && ({`ENTRY_ARRAY_PATH.entry_array_selected_demux, `ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[2]} < `CONFIG_PROT_PATH.config_prot_reg.entrylck.f))
    |=> (`ENTRY_ARRAY_PATH.entry_cfg_a_swen[{`ENTRY_ARRAY_PATH.entry_array_selected_demux, `ENTRY_ARRAY_PATH.entry_array_reg_demux_sel[2]}] != 1'b1))
  ) else $error("[%0t] Assertion Failed: ENTRY_CFG(i) is locked so write should not happen", $time);

  // ###################################### ERROR CAPTURE FEATURE ######################################

  if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : assert_error_capture_enabled

    // RFM.2062 Cover Property: If ERR_CFG.l is asserted, then ERR_CFG SW write enable signal should not be asserted when SW tries to write on it
    rfm_cover_err_cfg_locked: cover property (
      @(posedge clk) ((`ERR_RPT_PATH.err_rpt_reg.err_cfg.l && `ERR_RPT_PATH.err_rpt_reg_write_valid && `ERR_RPT_PATH.err_rpt_legal &&
      (`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_CFG)) |-> (`ERR_RPT_PATH.err_cfg_ie_swen != 1'b1))
    );

    // RFM.2063. Assertion: If ERR_CFG.l is asserted, then ERR_CFG SW write enable signal should not be asserted when SW tries to write on it
    rfm_assert_err_cfg_locked: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`ERR_RPT_PATH.err_rpt_reg.err_cfg.l && `ERR_RPT_PATH.err_rpt_reg_write_valid &&
      `ERR_RPT_PATH.err_rpt_legal && (`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_CFG)) |-> (`ERR_RPT_PATH.err_cfg_ie_swen != 1'b1)))
    ) else $error("[%0t] Assertion Failed: ERR_CFG register is locked so write should not happen", $time);

    // ########################################## MSI FEATURE ##########################################

    if (config_iopmp_pkg::iopmp_cfg_default.MSI_EN) begin : msi_enabled

      // RFM.2064. Cover Property: If ERR_CFG.l is asserted, then ERR_MSIADDR SW write enable signal should not be asserted when SW tries to write on it
      rfm_cover_err_msiaddr_locked: cover property (
        @(posedge clk) ((`ERR_RPT_PATH.err_rpt_reg.err_cfg.l && `ERR_RPT_PATH.err_rpt_reg_write_valid && `ERR_RPT_PATH.err_rpt_legal &&
        (`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_MSIADDR)) |-> (`ERR_RPT_PATH.err_msiaddr_swen != 1'b1))
      );

      // RFM.2065. Assertion: If ERR_CFG.l is asserted, then ERR_MSIADDR SW write enable signal should not be asserted when SW tries to write on it
      rfm_assert_err_msiaddr_locked: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`ERR_RPT_PATH.err_rpt_reg.err_cfg.l && `ERR_RPT_PATH.err_rpt_reg_write_valid &&
        `ERR_RPT_PATH.err_rpt_legal && (`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_MSIADDR)) |-> (`ERR_RPT_PATH.err_msiaddr_swen != 1'b1)))
      ) else $error("[%0t] Assertion Failed: ERR_MSIADDR register is locked so write should not happen", $time);

      if (config_iopmp_pkg::iopmp_cfg_default.ADDRH_EN) begin : addrh_enabled

        // RFM.2066. Cover Property: If ERR_CFG.l is asserted, then ERR_MSIADDRH SW write enable signal should not be asserted when SW tries to write on it
        rfm_cover_err_msiaddrh_locked: cover property (
          @(posedge clk) ((`ERR_RPT_PATH.err_rpt_reg.err_cfg.l && `ERR_RPT_PATH.err_rpt_reg_write_valid && `ERR_RPT_PATH.err_rpt_legal &&
          (`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_MSIADDRH)) |-> (`ERR_RPT_PATH.err_msiaddrh_swen != 1'b1))
        );

        // RFM.2067. Assertion: If ERR_CFG.l is asserted, then ERR_MSIADDRH SW write enable signal should not be asserted when SW tries to write on it
        rfm_assert_err_msiaddrh_locked: assert property (
          @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`ERR_RPT_PATH.err_rpt_reg.err_cfg.l && `ERR_RPT_PATH.err_rpt_reg_write_valid &&
          `ERR_RPT_PATH.err_rpt_legal && (`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_MSIADDRH)) |-> (`ERR_RPT_PATH.err_msiaddrh_swen != 1'b1)))
        ) else $error("[%0t] Assertion Failed: ERR_MSIADDRH register is locked so write should not happen", $time);
      end
      else begin : addrh_disabled

        // RFM.2068. Assertion: If the system supports 32 bit address bus, then ERR_MSIADDRH SW write enable signal should never be asserted
        rfm_assert_msi_enabled_err_msiaddrh_write_invalid: assert property (
          @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_MSIADDRH)
          |-> (`ERR_RPT_PATH.err_msiaddrh_swen != 1'b1))
        ) else $error("[%0t] Assertion Failed: Write should never happen on ERR_MSIADDRH when AADRH_EN is disabled", $time);
      end
    end
    else begin : msi_unsupported

      // RFM.2069. Assertion: If IOPMP does not support MSI interrupts, then ERR_CFG.msidata SW write enable signal should never be asserted
      rfm_assert_err_cfg_msidata_write_invalid: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_CFG)
        |-> (`ERR_RPT_PATH.err_cfg_msidata_swen != 1'b1))
      ) else $error("[%0t] Assertion Failed: Write should never happen on ERR_CFG.msidata when MSI_EN is disabled", $time);

      // RFM.2070. Assertion: If IOPMP does not support MSI interrupts, then ERR_INFO.msi_werr SW write enable signal should never be asserted
      rfm_assert_err_info_msiwerr_write_invalid: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_INFO)
        |-> (`ERR_RPT_PATH.err_info_msi_werr_swen != 1'b1))
      ) else $error("[%0t] Assertion Failed: Write should never happen on ERR_INFO.msi_werr when MSI_EN is disabled", $time);

      // RFM.2071. Assertion: If IOPMP does not support MSI interrupts, then ERR_MSIADDR SW write enable signal should never be asserted
      rfm_assert_err_msiaddr_write_invalid: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_MSIADDR)
        |-> (`ERR_RPT_PATH.err_msiaddr_swen != 1'b1))
      ) else $error("[%0t] Assertion Failed: Write should never happen on ERR_MSIADDR when MSI_EN is disabled", $time);

      // RFM.2072. Assertion: If IOPMP does not support MSI interrupts, then ERR_MSIADDRH SW write enable signal should never be asserted
      rfm_assert_err_msiaddrh_write_invalid: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_MSIADDRH)
        |-> (`ERR_RPT_PATH.err_msiaddrh_swen != 1'b1))
      ) else $error("[%0t] Assertion Failed: Write should never happen on ERR_MSIADDRH when MSI_EN is disabled", $time);
    end

    // ########################################## MFR SUPPORT ##########################################

    if (config_iopmp_pkg::iopmp_cfg_default.MFR_EN) begin : assert_err_mfr_write_legal

      // RFM.2073. Assertion: If a write happens on ERR_MFR, then ERR_MFR.svi value should never be greater than or equal to HWCFG1.rrid_num/16
      rfm_assert_err_mfr_svi_write_legal: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ERR_RPT_PATH.err_mfr_svi_swen)
        |=> (!(`ERR_RPT_PATH.err_rpt_reg.err_mfr.svi > `ERR_RPT_PATH.MAX_SVI_VALUE)))
      ) else $error("[%0t] Assertion Failed: ERR_MFR.svi legal value can be 0 - ((HWCFG1.rrid_num/16)-1)", $time);
    end
    else begin : assert_mfr_unsupported

      // RFM.2074. Assertion: If MFR Extension is not supported, then ERR_MFR SW write enable signal should never be asserted
      rfm_assert_err_mfr_write_invalid: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`ERR_RPT_PATH.err_rpt_reg_demux_sel == IOPMP_ERR_MFR)
        |-> (`ERR_RPT_PATH.err_mfr_svi_swen != 1'b1))
      ) else $error("[%0t] Assertion Failed: Write should never happen on ERR_MFR when MFR_EN is disabled", $time);
    end
  end