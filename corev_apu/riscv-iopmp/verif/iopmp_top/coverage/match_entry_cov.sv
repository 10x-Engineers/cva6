  `define RAP_MATCH_ENTRY tb_top.iopmp_dut.rap.gen_match_8_entry[0].match_8_entry_inst.gen_match_entry[0].match_entry_inst

  import execution_pipeline_pkg::*;
  import rfm_pkg::*;

  //****************************************************************************************************
  // Cover Properties
  //****************************************************************************************************

  // ########################################## ADDR MODE NA4 ##########################################

  // RAP_ME.01. Cover Property: If the entry address mode is set to NA4 and transaction address matches the base address then start_addr_match should be asserted
  rap_cover_addr_mode_na4_start_addr_match: cover property (
    @(posedge clk) (((`RAP_MATCH_ENTRY.entry_cfg.a == IOPMP_NA4) && (`RAP_MATCH_ENTRY.transaction.addr[AXI_ADDR_WIDTH-1:2] == `RAP_MATCH_ENTRY.base_addr)) |-> (`RAP_MATCH_ENTRY.start_addr_match))
  );

  // RAP_ME.02. Cover Property: If the entry address mode is set to NA4 and transaction end address matches the base address then end_addr_match should be asserted
  rap_cover_addr_mode_na4_end_addr_match: cover property (
    @(posedge clk) (((`RAP_MATCH_ENTRY.entry_cfg.a == IOPMP_NA4) && (`RAP_MATCH_ENTRY.trans_end_addr[AXI_ADDR_WIDTH-1:2] == `RAP_MATCH_ENTRY.base_addr)) |-> (`RAP_MATCH_ENTRY.end_addr_match))
  );

  // ######################################### ADDR MODE NAPOT #########################################

  // RAP_ME.03. Cover Property: If the entry address mode is set to NA4 and transaction address matches the base address then start_addr_match should be asserted
  rap_cover_addr_mode_napot_start_addr_match: cover property (
    @(posedge clk) (((`RAP_MATCH_ENTRY.entry_cfg.a == IOPMP_NAPOT) && ((`RAP_MATCH_ENTRY.transaction.addr[AXI_ADDR_WIDTH-1:2] & `RAP_MATCH_ENTRY.addr_region_mask) == `RAP_MATCH_ENTRY.base_addr)) |-> (`RAP_MATCH_ENTRY.start_addr_match))
  );

  // RAP_ME.04. Cover Property: If the entry address mode is set to NA4 and transaction end address matches the base address then end_addr_match should be asserted
  rap_cover_addr_mode_napot_end_addr_match: cover property (
    @(posedge clk) (((`RAP_MATCH_ENTRY.entry_cfg.a == IOPMP_NAPOT) && ((`RAP_MATCH_ENTRY.trans_end_addr[AXI_ADDR_WIDTH-1:2] & `RAP_MATCH_ENTRY.addr_region_mask) == `RAP_MATCH_ENTRY.base_addr)) |-> (`RAP_MATCH_ENTRY.end_addr_match))
  );

  // ########################################## ADDR MODE TOR ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.TOR_EN) begin : tor_enabled_cover

    // RAP_ME.05. Cover Property: If the entry address mode is set to TOR when TOR mode is supported and transaction address matches the base address within
    // the valid TOR range, then start_addr_match should be asserted
    rap_cover_addr_mode_tor_start_addr_match: cover property (
      @(posedge clk) (((`RAP_MATCH_ENTRY.entry_cfg.a == IOPMP_TOR) && (`RAP_MATCH_ENTRY.transaction.addr[AXI_ADDR_WIDTH-1:2] >= `RAP_MATCH_ENTRY.base_addr) && `RAP_MATCH_ENTRY.is_valid_range) |-> (`RAP_MATCH_ENTRY.start_addr_match))
    );

    // RAP_ME.06. Cover Property: If the entry address mode is set to TOR when TOR mode is supported and transaction end address matches the end address within
    // the valid TOR range, then end_addr_match should be asserted
    rap_cover_addr_mode_tor_end_addr_match: cover property (
      @(posedge clk) (((`RAP_MATCH_ENTRY.entry_cfg.a == IOPMP_TOR) && (`RAP_MATCH_ENTRY.trans_end_addr[AXI_ADDR_WIDTH-1:2] < `RAP_MATCH_ENTRY.end_addr) && `RAP_MATCH_ENTRY.is_valid_range) |-> (`RAP_MATCH_ENTRY.end_addr_match))
    );
  end

  // ########################################## ADDRESS MATCH ##########################################

  // RAP_ME.07. Cover Property: If the transaction address lies within the set boundary region (indicated by start_addr_match and end_addr_match), then
  // full_addr_match should be asserted
  rap_cover_full_addr_match: cover property (
    @(posedge clk) ((`RAP_MATCH_ENTRY.start_addr_match && `RAP_MATCH_ENTRY.end_addr_match) |-> (`RAP_MATCH_ENTRY.full_addr_match))
  );

  // RAP_ME.08. Cover Property: If the transaction address patially matches the set boundary region (indicated by start_addr_match xor end_addr_match) for a priority
  // entry, then partial_addr_match should be asserted
  rap_cover_partial_addr_match: cover property (
    @(posedge clk) (((`RAP_MATCH_ENTRY.start_addr_match ^ `RAP_MATCH_ENTRY.end_addr_match) && `RAP_MATCH_ENTRY.is_prio_entry) |-> (`RAP_MATCH_ENTRY.partial_addr_match))
  );

  // RAP_ME.09. Cover Property: If the transaction address does not fully or partially match the configured address region, then operation should be ERROR when
  // entry is checked
  rap_cover_addr_mismatch: cover property (
    @(posedge clk) (((!`RAP_MATCH_ENTRY.partial_addr_match) && (!`RAP_MATCH_ENTRY.full_addr_match) && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.operation == SEARCH))
  );

  // RAP_ME.10. Cover Property: If the transaction address partially matches the configured address region, then operation should be ERROR when entry is checked
  rap_cover_partial_addr_match_error: cover property (
    @(posedge clk) ((`RAP_MATCH_ENTRY.partial_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.operation == ERROR))
  );

  // ######################################## PERMISSION MATCH #########################################

  // RAP_ME.11. Cover Property: If the transaction address fully matches the configured address region and read permission is allowed for a read transaction, then
  // operation should be MATCHED when entry is checked
  rap_cover_read_perm_match: cover property (
    @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.r && `RAP_MATCH_ENTRY.rd_allowed && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.operation == MATCHED))
  );

  // RAP_ME.12. Cover Property: If the transaction address fully matches the configured address region and read permission is not allowed for a read transaction,
  // then operation should be ERROR when entry is checked
  rap_cover_read_perm_no_match: cover property (
    @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.r && (!`RAP_MATCH_ENTRY.rd_allowed) && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.operation == ERROR))
  );

  // RAP_ME.13. Cover Property: If the transaction address fully matches the configured address region and write permission is allowed for a write transaction, then
  // operation should be MATCHED when entry is checked
  rap_cover_write_perm_match: cover property (
    @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.w && `RAP_MATCH_ENTRY.wr_allowed && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.operation == MATCHED))
  );

  // RAP_ME.14. Cover Property: If the transaction address fully matches the configured address region and write permission is not allowed for a write transaction,
  // then operation should be ERROR when entry is checked
  rap_cover_write_perm_no_match: cover property (
    @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.w && (!`RAP_MATCH_ENTRY.wr_allowed) && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.operation == ERROR))
  );

  // RAP_ME.15. Cover Property: If the transaction address does not fully or partially match the configured address region, then error info should always
  // be NO_ERROR when entry is checked
  rap_cover_no_error: cover property (
    @(posedge clk) (((!`RAP_MATCH_ENTRY.partial_addr_match) && (!`RAP_MATCH_ENTRY.full_addr_match) && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.err_info == 5'd0))
  );

  // ########################################### ERROR INFO ############################################

  if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : error_capture_enabled_cover

    // RAP_ME.16. Cover Property: If the transaction address partially matches the configured address region, then error information should be indicate
    // PARTIAL_HIT_ON_PRIORITY error when entry is checked
    rap_cover_partial_hit_on_priority_error: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.partial_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.err_info == {PARTIAL_HIT_ON_PRIORITY, 1'b0}))
    );

    // RAP_ME.17. Cover Property: If the transaction address fully matches the configured address region and read permission is not allowed for a read transaction,
    // then error information should indicate ILLEGAL_READ_ACCESS with the interrupt suppression bit when entry is checked
    rap_cover_illegal_read_access_error: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.r && (!`RAP_MATCH_ENTRY.rd_allowed) && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.err_info == {ILLEGAL_READ_ACCESS, `RAP_MATCH_ENTRY.entry_cfg.sire}))
    );

    // RAP_ME.18. Cover Property: If the transaction address fully matches the configured address region and write permission is not allowed for a write transaction,
    // then error information should indicate ILLEGAL_WRITE_ACCESS with the interrupt suppression bit when entry is checked
    rap_cover_illegal_write_access_error: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.w && (!`RAP_MATCH_ENTRY.wr_allowed) && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.err_info == {ILLEGAL_WRITE_ACCESS, `RAP_MATCH_ENTRY.entry_cfg.siwe}))
    );
  end

  // ########################################## CHK_X ENABLED ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.CHK_X) begin : chk_x_enabled_cover

    // RAP_ME.19. Cover Property: If the transaction address fully matches the configured address region and execute permission is allowed for an instruction fetch
    // transaction when CHK_X is enabled, then operation should be MATCHED when entry is checked
    rap_cover_chkx_enabled_execute_perm_match: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.x && `RAP_MATCH_ENTRY.ex_allowed && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.operation == MATCHED))
    );

    // RAP_ME.20. Cover Property: If the transaction address fully matches the configured address region and execute permission is not allowed for an instruction fetch
    // transaction when CHK_X is enabled, then operation should be ERROR when entry is checked
    rap_cover_chkx_enabled_execute_perm_no_match: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.x && (!`RAP_MATCH_ENTRY.ex_allowed) && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.operation == ERROR))
    );

    if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : illegal_instr_fetch_error

      // RAP_ME.21. Cover Property: If the transaction address fully matches the configured address region and execute permission is not allowed for an instruction fetch
      // transaction, then error information should indicate ILLEGAL_INSTR_FETCH with the interrupt suppression bit when entry is checked
      rap_cover_illegal_instr_fetch_error: cover property (
        @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.x && (!`RAP_MATCH_ENTRY.ex_allowed) && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.err_info == {ILLEGAL_INSTR_FETCH, `RAP_MATCH_ENTRY.entry_cfg.sixe}))
      );
    end
  end

  // ########################################## CHK_X DISABLED #########################################
  else begin : ckh_x_disbaled_cover

    // RAP_ME.22. Cover Property: If the transaction address fully matches the configured address region and read permission is allowed for an instruction fetch
    // transaction when CHK_X is disabled, then operation should be MATCHED when entry is checked
    rap_cover_chkx_disabled_execute_perm_match: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.x && `RAP_MATCH_ENTRY.rd_allowed && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.operation == MATCHED))
    );

    // RAP_ME.23. Cover Property: If the transaction address fully matches the configured address region and read permission is not allowed for an instruction fetch
    // transaction when CHK_X is disabled, then operation should be ERROR when entry is checked
    rap_cover_chkx_disabled_execute_perm_no_match: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.x && (!`RAP_MATCH_ENTRY.rd_allowed) && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.operation == ERROR))
    );

    if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : illegal_read_access_error_on_instr_fetch

      // RAP_ME.24. Cover Property: If the transaction address fully matches the configured address region and read permission is not allowed for an instruction fetch
      // transaction, then error information should indicate ILLEGAL_INSTR_FETCH with the interrupt suppression bit when entry is checked
      rap_cover_illegal_read_access_error_on_instr_fetch: cover property (
        @(posedge clk) ((`RAP_MATCH_ENTRY.transaction.x && (!`RAP_MATCH_ENTRY.rd_allowed) && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.err_info == {ILLEGAL_READ_ACCESS, `RAP_MATCH_ENTRY.entry_cfg.sire}))
      );
    end
  end

  // ########################################## SRCMD Format 0 #########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_0) begin : permissions_for_srcmd_fmt_0

    if (config_iopmp_pkg::iopmp_cfg_default.SPS_EN) begin : sps_enabled

      // RAP_ME.25. Cover Property: If SRCMD Format is 0 when SPS extension is enabled, the IOPMP checks both the R/W/X and the ENTRY_CFG.r/w/x permission and follows a fail-first rule
      rap_cover_srcmd_fmt_0_sps_enabled_rd_allowed: cover property (
        @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.r && `RAP_MATCH_ENTRY.entry_perms[0]) |-> (`RAP_MATCH_ENTRY.rd_allowed))
      );

      // RAP_ME.26. Cover Property: If SRCMD Format is 0 when SPS extension is enabled, the IOPMP checks both the R/W/X and the ENTRY_CFG.r/w/x permission and follows a fail-first rule
      rap_cover_srcmd_fmt_0_sps_enabled_wr_allowed: cover property (
        @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.w && `RAP_MATCH_ENTRY.entry_perms[1]) |-> (`RAP_MATCH_ENTRY.wr_allowed))
      );

      // RAP_ME.27. Cover Property: If SRCMD Format is 0 when SPS extension is enabled, the IOPMP checks both the R/W/X and the ENTRY_CFG.r/w/x permission and follows a fail-first rule
      rap_cover_srcmd_fmt_0_sps_enabled_ex_allowed: cover property (
        @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.x && `RAP_MATCH_ENTRY.entry_perms[0]) |-> (`RAP_MATCH_ENTRY.ex_allowed))
      );
    end
    else begin : sps_disabled

      // RAP_ME.28. Cover Property: If SRCMD Format is 0 when SPS extension is disabled, the IOPMP checks ENTRY_CFG.r/w/x permission
      rap_cover_srcmd_fmt_0_sps_disabled_rd_allowed: cover property (
        @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.r) |-> (`RAP_MATCH_ENTRY.rd_allowed))
      );

      // RAP_ME.29. Cover Property: If SRCMD Format is 0 when SPS extension is disabled, the IOPMP checks ENTRY_CFG.r/w/x permission
      rap_cover_srcmd_fmt_0_sps_disabled_wr_allowed: cover property (
        @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.w) |-> (`RAP_MATCH_ENTRY.wr_allowed))
      );

      // RAP_ME.30. Cover Property: If SRCMD Format is 0 when SPS extension is disabled, the IOPMP checks ENTRY_CFG.r/w/x permission
      rap_cover_srcmd_fmt_0_sps_disabled_ex_allowed: cover property (
        @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.x) |-> (`RAP_MATCH_ENTRY.ex_allowed))
      );
    end
  end

  // ########################################## SRCMD Format 1 #########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_1) begin : permissions_for_srcmd_fmt_1

    // RAP_ME.31. Cover Property: If SRCMD Format is 1, the IOPMP checks ENTRY_CFG.r/w/x permission
    rap_cover_srcmd_fmt_1_rd_allowed: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.r) |-> (`RAP_MATCH_ENTRY.rd_allowed))
    );

    // RAP_ME.32. Cover Property: If SRCMD Format is 1, the IOPMP checks ENTRY_CFG.r/w/x permission
    rap_cover_srcmd_fmt_1_wr_allowed: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.w) |-> (`RAP_MATCH_ENTRY.wr_allowed))
    );

    // RAP_ME.33. Cover Property: If SRCMD Format is 1, the IOPMP checks ENTRY_CFG.r/w/x permission
    rap_cover_srcmd_fmt_1_ex_allowed: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.x) |-> (`RAP_MATCH_ENTRY.ex_allowed))
    );
  end

  // ########################################## SRCMD Format 2 #########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SRCMD_FMT_2) begin : permissions_for_srcmd_fmt_2

    // RAP_ME.34. Cover Property: If SRCMD Format is 2, the IOPMP checks both the permission of SRCMD_PERM(H)(m) and the ENTRY_CFG.r/w/x permission
    // A transaction is legal if any of them allows the transaction
    rap_cover_srcmd_fmt_2_rd_allowed: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.r || `RAP_MATCH_ENTRY.entry_perms[0]) |-> (`RAP_MATCH_ENTRY.rd_allowed))
    );

    // RAP_ME.35. Cover Property: If SRCMD Format is 2, the IOPMP checks both the permission of SRCMD_PERM(H)(m) and the ENTRY_CFG.r/w/x permission
    // A transaction is legal if any of them allows the transaction
    rap_cover_srcmd_fmt_2_wr_allowed: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.w || `RAP_MATCH_ENTRY.entry_perms[1]) |-> (`RAP_MATCH_ENTRY.wr_allowed))
    );

    // RAP_ME.36. Cover Property: If SRCMD Format is 2, the IOPMP checks both the permission of SRCMD_PERM(H)(m) and the ENTRY_CFG.r/w/x permission
    // A transaction is legal if any of them allows the transaction
    rap_cover_srcmd_fmt_2_ex_allowed: cover property (
      @(posedge clk) ((`RAP_MATCH_ENTRY.entry_cfg.x || `RAP_MATCH_ENTRY.entry_perms[0]) |-> (`RAP_MATCH_ENTRY.ex_allowed))
    );
  end

  //****************************************************************************************************
  // Assertions
  //****************************************************************************************************

  // ######################################## NON PRIORITY ENTRY #######################################

  // RAP_ME.37. Assertion: If the entry is non-priority, then partial_addr_match should never be asserted
  rap_assert_non_prio_entry: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((!`RAP_MATCH_ENTRY.is_prio_entry) |-> (!`RAP_MATCH_ENTRY.partial_addr_match))
  ) else $error("[%0t] Assertion Failed: Partial Adress matched hit for a Non-Priority Entry", $time);

  if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : error_capture_enabled_assertion

    // RAP_ME.38. Assertion: If the entry is non-priority, then error information should never indicate PARTIAL_HIT_ON_PRIORITY error
    rap_assert_no_partial_hit_on_priority_error: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((!`RAP_MATCH_ENTRY.is_prio_entry) |-> (`RAP_MATCH_ENTRY.err_info != {PARTIAL_HIT_ON_PRIORITY, 1'b0}))
    ) else $error("[%0t] Assertion Failed: PARTIAL_HIT_ON_PRIORITY error detected for a Non-Priority Entry", $time);

    // ######################################### CHK_X DISABLED ########################################

    if (!(config_iopmp_pkg::iopmp_cfg_default.CHK_X)) begin : chk_x_disabled_assertion

      // RAP_ME.39. Assertion: If CHK_X is disabled, then error information should never indicate ILLEGAL_INSTR_FETCH error
      rap_assert_illegal_instr_fetch_error: assert property (
        @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`RAP_MATCH_ENTRY.transaction.x && ((!`RAP_MATCH_ENTRY.rd_allowed) || (!`RAP_MATCH_ENTRY.ex_allowed)) && `RAP_MATCH_ENTRY.full_addr_match && `RAP_MATCH_ENTRY.check_entry) |-> (`RAP_MATCH_ENTRY.err_info != {ILLEGAL_INSTR_FETCH, `RAP_MATCH_ENTRY.entry_cfg.sixe}))
      ) else $error("[%0t] Assertion Failed: Partial Adress matched hit for a Non-Priority Entry", $time);
    end
  end