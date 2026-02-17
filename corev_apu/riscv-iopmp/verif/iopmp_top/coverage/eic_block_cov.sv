  `define EIC tb_top.iopmp_dut.gen_eic_block.eic_block

  if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : gen_error_capture_enable_cover

    //****************************************************************************************************
    // Sequences
    //****************************************************************************************************

    // Sequence to check if condition for an interrupt generation is met i.e, global interrupt should be enabled, interrupt suppression bit, ERR_INFO.v and ERR_INFO.msi_werr must be low
    sequence SEQ_GEN_INTRPT;
      ((!(`EIC.rfm_eic.err_info_v || `EIC.rfm_eic.err_info_msi_werr || `EIC.rap_eic_error_info.err_info[0])) && `EIC.rfm_eic.err_cfg_ie && `EIC.rap_eic_valid);
    endsequence

    // Sequence to check if condition for error record enable is generated i.e, error will be logged in error register when ERR_INFO.v and ERR_INFO.msi_werr are low
    sequence SEQ_ERR_REC_ENABLE;
      (`EIC.rap_eic_valid && (!(`EIC.rfm_eic.err_info_v || `EIC.rfm_eic.err_info_msi_werr)));
    endsequence

    //****************************************************************************************************
    // Cover Properties
    //****************************************************************************************************

    //****************************************************************************************************
    // Interrupt Cover Properties
    //****************************************************************************************************

    // EIC.01. Cover Property: If SEQ_GEN_INTRPT is true, then interrupt must be generated either via MSI or WSI
    eic_cover_intrpt_generation: cover property (
      @(posedge clk) ((SEQ_GEN_INTRPT) |-> (`EIC.generate_intrpt))
    );

    // ########################################## WSI Interrupt ##########################################

    // EIC.02. Cover Property: If SEQ_GEN_INTRPT is true and ERR_CFG.msi_en is low, then interrupt must generate via WSI
    eic_cover_wsi_intrpt: cover property (
      @(posedge clk) ((SEQ_GEN_INTRPT and (!`EIC.rfm_eic.err_cfg_msi_en)) |-> (`EIC.wsi))
    );

    // ########################################## MSI Interrupt ##########################################

    if (config_iopmp_pkg::iopmp_cfg_default.MSI_EN) begin : msi_intrpt_enable

      // EIC.03. Cover Property: If SEQ_GEN_INTRPT is true and ERR_CFG.msi_en is high, then interrupt must generate via MSI
      eic_cover_msi_intrpt: cover property (
        @(posedge clk) ((SEQ_GEN_INTRPT and (`EIC.rfm_eic.err_cfg_msi_en)) |-> (`EIC.eic_msi_valid))
      );

      // EIC.04. Cover Property: If SEQ_GEN_INTRPT is true and ERR_CFG.msi_en is high, then aw_id[5] must be logic 1 indicating MSI transaction
      eic_cover_msi_trans_aw_id: cover property (
        @(posedge clk) ((SEQ_GEN_INTRPT and (`EIC.rfm_eic.err_cfg_msi_en)) |-> (`EIC.eic_msi_trans.aw_id[5]))
      );
    end

    //****************************************************************************************************
    // ERROR Record Cover Properties
    //****************************************************************************************************

    // EIC.05. Cover Property: If SEQ_ERR_REC_ENABLE is true, then err_rec_en and error registers hardware write enable signals must be asserted
    eic_cover_error_record_enable: cover property (
      @(posedge clk) ((SEQ_ERR_REC_ENABLE) |-> (`EIC.err_rec_en))
    );

    // ################################ Multi Fault Record (MFR) Extension ###############################

    if (config_iopmp_pkg::iopmp_cfg_default.MFR_EN) begin : subsequent_violation_enable

      // EIC.06. Cover Property: If an error is reported to EIC Block and ERR_INFO.v or ERR_INFO.msi_werr is high when MFR_EN is enabled, then subsequent violation is logged in error window
      eic_cover_subsequent_violation_enable: cover property (
        @(posedge clk) ((`EIC.rap_eic_valid && (`EIC.rfm_eic.err_info_v || `EIC.rfm_eic.err_info_msi_werr)) |-> (`EIC.eic_rfm_valid))
      );
    end

    //****************************************************************************************************
    // ERROR Type Cover Properties
    //****************************************************************************************************

    // EIC.07. Cover Property: If SEQ_GEN_INTRPT is true, check the error type is NOT_HIT_ANY_RULE
    eic_cover_error_not_hit_any_rule: cover property (
      @(posedge clk) ((SEQ_ERR_REC_ENABLE) and (`EIC.rap_eic_error_info.err_info[4:1] == 4'b0101))
    );

    // EIC.08. Cover Property: If SEQ_GEN_INTRPT is true, check the error type is PARTIAL_HIT_ON_PRIORITY
    eic_cover_error_partial_hit_on_priority: cover property (
      @(posedge clk) ((SEQ_ERR_REC_ENABLE) and (`EIC.rap_eic_error_info.err_info[4:1] == 4'b0100))
    );

    // EIC.09. Cover Property: If SEQ_GEN_INTRPT is true, check the error type is ILLEGAL_READ_ACCESS
    eic_cover_error_illegal_read_access: cover property (
      @(posedge clk) ((SEQ_ERR_REC_ENABLE) and (`EIC.rap_eic_error_info.err_info[4:1] == 4'b0001))
    );

    // EIC.10. Cover Property: If SEQ_GEN_INTRPT is true, check the error type is ILLEGAL_WRITE_ACCESS
    eic_cover_error_illegal_write_access: cover property (
      @(posedge clk) ((SEQ_ERR_REC_ENABLE) and (`EIC.rap_eic_error_info.err_info[4:1] == 4'b0010))
    );

    // EIC.11. Cover Property: If SEQ_GEN_INTRPT is true, check the error type is ILLEGAL_INSTR_FETCH
    eic_cover_error_illegal_instr_fetch: cover property (
      @(posedge clk) ((SEQ_ERR_REC_ENABLE) and (`EIC.rap_eic_error_info.err_info[4:1] == 4'b0011))
    );

    // EIC.12. Cover Property: If SEQ_GEN_INTRPT is true, check the error type is UNKNOWN_RRID
    eic_cover_error_unknown_rrid: cover property (
      @(posedge clk) ((SEQ_ERR_REC_ENABLE) and (`EIC.rap_eic_error_info.err_info[4:1] == 4'b0110))
    );

    //****************************************************************************************************
    // Assertions
    //****************************************************************************************************

    // ########################################## WSI Interrupt ##########################################

    // EIC.13. Assertion: If global interrupt enable is low when ERR_INFO.v is cleared, then wsi must not be asserted
    eic_assert_wsi_intrpt_disable: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((!`EIC.rfm_eic.err_cfg_ie) && (!`EIC.rfm_eic.err_info_v) && `EIC.rap_eic_valid) |-> (!`EIC.wsi))
    ) else $error("[%0t] Assertion Failed: WSI Interrupt should not be generated", $time);

    // ########################################## MSI Interrupt ##########################################

    if (config_iopmp_pkg::iopmp_cfg_default.MSI_EN) begin : msi_intrpt_disable

      // EIC.14. Assertion: If global interrupt enable is low when err_cfg.msi_en is 1, then eic_msi_valid must not be asserted
      eic_assert_msi_intrpt_disable: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((!`EIC.rfm_eic.err_cfg_ie) && `EIC.rfm_eic.err_cfg_msi_en && `EIC.rap_eic_valid) |-> (`EIC.eic_msi_valid != 1'b1))
      ) else $error("[%0t] Assertion Failed: MSI Interrupt should not be generated", $time);
    end
    else begin : msi_intrpt_unsupported

      // EIC.15. Assertion: If SEQ_GEN_INTRPT is true when MSI_EN is dsiabled, then eic_msi_valid must not be asserted
      eic_assert_msi_intrpt_unsupported: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_GEN_INTRPT) |-> (`EIC.eic_msi_valid != 1'b1))
      ) else $error("[%0t] Assertion Failed: Interrupt through MSI is not supported", $time);
    end

    // ####################################### ERROR Record Enable #######################################

    // EIC.16. Assertion: If the ERR_INFO.v or ERR_INFO.msi_werr is high, then err_rec_en and register hardware enable signals must not be asserted
    eic_assert_error_record_disable: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`EIC.rfm_eic.err_info_v || `EIC.rfm_eic.err_info_msi_werr) && `EIC.rap_eic_valid) |-> (!`EIC.err_rec_en))
    ) else $error("[%0t] Assertion Failed: Error should not be recorded", $time);

    // ################################ Multi Fault Record (MFR) Extension ###############################

    if (config_iopmp_pkg::iopmp_cfg_default.MFR_EN) begin : subsequent_violation_disable

      // EIC.17. Assertion: If SEQ_ERR_REC_ENABLE is true, then subsequent violation log must not be generated
      eic_assert_subsequent_violation_disable: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_ERR_REC_ENABLE) |-> (!`EIC.eic_rfm_valid))
      ) else $error("[%0t] Assertion Failed: Not a subsequent violation", $time);
    end
    else begin : subsequent_violation_unsupported

      // EIC.18. Assertion: If a subsequent violation has occured when MFR_EN is disabled, then eic_rfm_valid must not be asserted
      eic_assert_subsequent_violation_unsupported: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`EIC.rap_eic_valid && (`EIC.rfm_eic.err_info_v || `EIC.rfm_eic.err_info_msi_werr)) |-> (`EIC.eic_rfm_valid != 1'b1))
      ) else $error("[%0t] Assertion Failed: MFR is not supported", $time);
    end

    // EIC.19. Assertion: If there is no error reported to EIC, then there should be no sign of error record enable or interrupt generation
    eic_assert_no_error: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`EIC.rap_eic_valid != 1'b1)) |-> ((`EIC.generate_intrpt != 1'b1) && (`EIC.err_rec_en != 1'b1) && (`EIC.eic_rfm_valid != 1'b1)))
    ) else $error("[%0t] Assertion Failed: Transaction was a success but EIC generated interrupt/error", $time);

    // EIC.20. Assertion: If SEQ_ERR_REC_ENABLE is true, then error information must match one of the IOPMP error types (must not indicates NO_ERROR)
    eic_assert_error_type: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((SEQ_ERR_REC_ENABLE) |-> (|`EIC.rap_eic_error_info.err_info[4:1]))
    ) else $error("[%0t] Assertion Failed: The reported error info does not match the error type", $time);
  end