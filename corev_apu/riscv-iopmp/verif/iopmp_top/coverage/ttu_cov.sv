  `define TTU tb_top.iopmp_dut.ttu

  `ifdef CFG_IOPMP_MDCFG_FMT_0
    `define LAST_STAGE tb_top.iopmp_dut.ttu.gen_mdcfg_fmt_0.mdcfg_fmt_0
  `elsif CFG_IOPMP_MDCFG_FMT_1
    `define LAST_STAGE tb_top.iopmp_dut.ttu.gen_mdcfg_fmt_1.mdcfg_fmt_1
  `else
    `define LAST_STAGE tb_top.iopmp_dut.ttu.gen_mdcfg_fmt_2.mdcfg_fmt_2
  `endif

  import execution_pipeline_pkg::*;

  //****************************************************************************************************
  // TTU Check Module Cover Properties
  //****************************************************************************************************

  // ########################################## IOPMP DISABLED #########################################

  // TTU.01. Cover Property: IOPMP checks the transaction when hwcfg0.enable is set to 1; otherwise, the transaction bypasses the IOPMP
  ttu_cover_iopmp_disable: cover property (
    @(posedge clk) (((`TTU.rap_operation == SEARCH) && (!`TTU.rfm_ttu.hwcfg0_enable)) |-> (`TTU.ttu_operation == MATCHED))
  );

  // ########################################### IOPMP ENABLED #########################################

  // TTU.02. Cover Property: If the read transaction RRID falls in legal range, then TTU operation should be SEARCH
  ttu_cover_read_transaction_pass: cover property (
    @(posedge clk) (((`TTU.rap_operation == SEARCH) && `TTU.rfm_ttu.hwcfg0_enable && (`TTU.transaction_i.rrid[5:0] < `TTU.rfm_ttu.hwcfg1_rrid_num) && (`TTU.transaction_i.r)) |-> (`TTU.ttu_operation == SEARCH))
  );

  if (!config_iopmp_pkg::iopmp_cfg_default.NO_W) begin : cover_no_w_disabled

    // TTU.03. Cover Property: If the write transaction RRID falls in legal range when hwcfg0.no_w=0, then TTU operation should be SEARCH
    ttu_cover_write_transaction_pass: cover property (
      @(posedge clk) (((`TTU.rap_operation == SEARCH) && `TTU.rfm_ttu.hwcfg0_enable && (`TTU.transaction_i.rrid[5:0] < `TTU.rfm_ttu.hwcfg1_rrid_num) && `TTU.transaction_i.w) |-> (`TTU.ttu_operation == SEARCH))
    );
  end

  if ((!config_iopmp_pkg::iopmp_cfg_default.NO_X) && config_iopmp_pkg::iopmp_cfg_default.CHK_X) begin : cover_no_x_disabled

    // TTU.04. Cover Property: If the instruction fetch transaction RRID falls in legal range when hwcfg0.no_x=0, then TTU operation should be SEARCH
    ttu_cover_instr_fetch_transaction_pass: cover property (
      @(posedge clk) (((`TTU.rap_operation == SEARCH) && `TTU.rfm_ttu.hwcfg0_enable && (`TTU.transaction_i.rrid[5:0] < `TTU.rfm_ttu.hwcfg1_rrid_num) && `TTU.transaction_i.x) |-> (`TTU.ttu_operation == SEARCH))
    );
  end

  // ########################################### NO_W ENABLED ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.NO_W) begin : cover_no_w_enabled

    // TTU.05. Cover Property: IOPMP always fails write accesses with hwcfg0.no_w=1 considered as as no rule matched
    ttu_cover_no_write_access: cover property (
      @(posedge clk) (((`TTU.rap_operation == SEARCH) && `TTU.rfm_ttu.hwcfg0_enable && `TTU.transaction_i.w) |-> (`TTU.ttu_operation == ERROR))
    );

    // TTU.06. Cover Property: If IOPMP fails on write access due to hwcfg0.no_w=1, then it will be considered as no rule match with error type NOT_HIT_ANY_RULE
    ttu_cover_no_w_enabled_error: cover property (
      @(posedge clk) (((`TTU.rap_operation == SEARCH) && `TTU.rfm_ttu.hwcfg0_enable && `TTU.transaction_i.w) |-> (`TTU.ttu_err_info == NOT_HIT_ANY_RULE))
    );
  end

  // ########################################### NO_X ENABLED ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.NO_X && config_iopmp_pkg::iopmp_cfg_default.CHK_X) begin : cover_no_x_enabled

    // TTU.07. Cover Property: For hwcfg0.chk_x=1, the IOPMP with hwcfg0.no_x=1 always fails on an instruction fetch
    ttu_cover_no_instr_fetch_access: cover property (
      @(posedge clk) (((`TTU.rap_operation == SEARCH) && `TTU.rfm_ttu.hwcfg0_enable && `TTU.transaction_i.x) |-> (`TTU.ttu_operation == ERROR))
    );

    // TTU.08. Cover Property: If IOPMP fails on instruction fetch due to hwcfg0.no_x=1, then it will be considered as no rule match with error type NOT_HIT_ANY_RULE
    ttu_cover_no_x_enabled_error: cover property (
      @(posedge clk) (((`TTU.rap_operation == SEARCH) && `TTU.rfm_ttu.hwcfg0_enable && `TTU.transaction_i.x) |-> (`TTU.ttu_err_info == NOT_HIT_ANY_RULE))
    );
  end

  // ####################################### NO_W OR NO_X ENABLED ######################################

  if ((config_iopmp_pkg::iopmp_cfg_default.NO_X && config_iopmp_pkg::iopmp_cfg_default.CHK_X) || config_iopmp_pkg::iopmp_cfg_default.NO_W) begin : cover_no_x_or_no_w_enabled

    // TTU.09. Cover Property: If IOPMP fails on instruction fetch or write access due to hwcfg0.no_x=1 or hwcfg0.no_w=1, then it will be considered as no rule match
    // with error type NOT_HIT_ANY_RULE even if transaction rrid is not legal
    ttu_cover_not_hit_any_rule_corner_case: cover property (
      @(posedge clk) (((`TTU.rap_operation == SEARCH) && `TTU.rfm_ttu.hwcfg0_enable && ((`TTU.transaction_i.x && `TTU.rfm_ttu.hwcfg0_no_x) || (`TTU.transaction_i.w && `TTU.rfm_ttu.hwcfg0_no_w))
      && (`TTU.transaction_i.rrid[5:0] >= `TTU.rfm_ttu.hwcfg1_rrid_num)) |-> (`TTU.ttu_err_info == NOT_HIT_ANY_RULE))
    );
  end

  // ########################################### SE_EN ENABLED #########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SE_EN) begin : source_enforcement_enabled_cover

    // TTU.10. If Source Enforcement Feature is supported, then the transaction RRID is ignored even if it is not a legal RRID and TTU operation is set to SEARCH if no check fails
    ttu_cover_no_error_on_illegal_rrid: cover property (
      @(posedge clk) (((`TTU.rap_operation == SEARCH) && (`TTU.rfm_ttu.hwcfg0_enable) && (`TTU.transaction_i.rrid[5:0] >= `TTU.rfm_ttu.hwcfg1_rrid_num)) |-> (`TTU.ttu_operation == SEARCH))
    );
  end
  else begin : source_enforcement_disabled_cover

  // ########################################## SE_EN DISABLED #########################################

    // TTU.11. Cover Property: If the transaction RRID is illegal, then TTU operation should be ERROR
    ttu_cover_rrid_check_fail: cover property (
      @(posedge clk) (((`TTU.rap_operation == SEARCH) && (`TTU.rfm_ttu.hwcfg0_enable) && (`TTU.transaction_i.rrid[5:0] >= `TTU.rfm_ttu.hwcfg1_rrid_num)) |-> (`TTU.ttu_operation == ERROR))
    );

    // TTU.12. Cover Property: If the transaction RRID is illegal, then TTU should indicates UNKNOWN_RRID error type
    ttu_cover_unknown_rrid_error: cover property (
      @(posedge clk) (((`TTU.rap_operation == SEARCH) && (`TTU.transaction_i.rrid[5:0] >= `TTU.rfm_ttu.hwcfg1_rrid_num) && (`TTU.rfm_ttu.hwcfg0_enable)) |-> (`TTU.ttu_err_info == UNKNOWN_RRID))
    );
  end

  // TTU.13. Cover Property: If IOPMP is not enabled, then TTU operation should be MATCHED even if hwcfg.no_x=1 or hwcfg0.no_w=1 or transaction rrid is illegal
  ttu_cover_match_operation_corner_case: cover property (
    @(posedge clk) (((`TTU.rap_operation == SEARCH) && (!`TTU.rfm_ttu.hwcfg0_enable) && ((`TTU.transaction_i.x && `TTU.rfm_ttu.hwcfg0_no_x) || (`TTU.transaction_i.w && `TTU.rfm_ttu.hwcfg0_no_w)
    || (`TTU.transaction_i.rrid[5:0] >= `TTU.rfm_ttu.hwcfg1_rrid_num))) |-> (`TTU.ttu_operation == MATCHED))
  );

  //****************************************************************************************************
  // TTU Check Module Assertions
  //****************************************************************************************************

  // ########################################### NO_W ENABLED ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.NO_W) begin : assert_no_w_enabled

  // TTU.14. Assertion: If hwcfg0.no_w feature is enabled, then TTU operation should not be MATCHED or SEARCH for a write transaction
  ttu_assert_no_write_access: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`TTU.rap_operation == SEARCH) && `TTU.transaction_i.w && `TTU.rfm_ttu.hwcfg0_enable) |-> ((&`TTU.ttu_operation) != 1'b0))
  ) else $error("[%0t] Assertion Failed: Write Access grant is not supported", $time);
  end

  // ########################################### NO_X ENABLED ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.NO_X && config_iopmp_pkg::iopmp_cfg_default.CHK_X) begin : assert_no_x_enabled

  // TTU.15. Assertion: If hwcfg0.no_x feature is enabled when hwcfg0.chk_x=1, then TTU operation should not be MATCHED or SEARCH for an instruction fetch transaction
  ttu_assert_no_instr_fetch_access: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`TTU.rap_operation == SEARCH) && `TTU.transaction_i.x && `TTU.rfm_ttu.hwcfg0_enable) |-> ((&`TTU.ttu_operation) != 1'b0))
  ) else $error("[%0t] Assertion Failed: Instruction Fetch grant is not supported", $time);
  end

  // ######################################## NO_W NO_X DISABLED #######################################

  if (((!config_iopmp_pkg::iopmp_cfg_default.NO_X) && config_iopmp_pkg::iopmp_cfg_default.CHK_X) && (!config_iopmp_pkg::iopmp_cfg_default.NO_W)) begin : assert_no_x_no_w_disabled

    // TTU.16. Assertion: If IOPMP supports write and instruction fetch transaction checks, then TTU should never indicates NOT_HIT_ANY_RULE error
    ttu_assert_no_x_no_w_disabled: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`TTU.rap_operation == SEARCH) |-> (`TTU.ttu_err_info != NOT_HIT_ANY_RULE))
    ) else $error("[%0t] Assertion Failed: NOT_HIT_ANY_RULE error is not valid as hwcfg0.no_x=0 and hwcfg0.no_w=0", $time);
  end

  // ####################################### NO_W OR NO_X ENABLED ######################################

  if ((config_iopmp_pkg::iopmp_cfg_default.NO_X && config_iopmp_pkg::iopmp_cfg_default.CHK_X) || config_iopmp_pkg::iopmp_cfg_default.NO_W) begin : assert_no_x_or_no_w_enabled

    // TTU.17. Cover Property: If IOPMP fails on instruction fetch or write access when transaction RRID is illegal, then the TTU should never indicates UNKNOWN_RRID error for instruction fetch/write transactions
    ttu_assert_not_hit_any_rule_corner_case: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`TTU.rap_operation == SEARCH) && `TTU.rfm_ttu.hwcfg0_enable && ((`TTU.transaction_i.x && `TTU.rfm_ttu.hwcfg0_no_x) ||
      (`TTU.transaction_i.w && `TTU.rfm_ttu.hwcfg0_no_w)) && (`TTU.transaction_i.rrid[5:0] >= `TTU.rfm_ttu.hwcfg1_rrid_num)) |-> (`TTU.ttu_err_info != UNKNOWN_RRID))
    ) else $error("[%0t] Assertion Failed: Write/Instruction fetch transaction should fail with error type NOT_HIT_ANY_RULE", $time);
  end

  // ########################################## SE_EN ENABLED ##########################################

  if (config_iopmp_pkg::iopmp_cfg_default.SE_EN) begin : unknown_rrid_error_invalid

    // TTU.18. Assertion: If Source Enforcement is enabled, then IOPMP ignores the rrid and TTU should never indicates UNKNOWN_RRID error
    ttu_assert_unknown_rrid_error_invalid: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`TTU.rap_operation == SEARCH) && (`TTU.transaction_i.rrid[5:0] >= `TTU.rfm_ttu.hwcfg1_rrid_num)) |-> (`TTU.ttu_err_info != UNKNOWN_RRID))
    ) else $error("[%0t] Assertion Failed: UNKNOWN_RRID error is not valid as Source Enforcement is enabled", $time);
  end

  // ########################################## IOPMP DISABLED #########################################

  // TTU.19. Assertion: If IOPMP is disabled (hwcfg0.enable=0), then TTU operation should not be ERROR or SEARCH for any transaction
  ttu_assert_iopmp_disable: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) (((`TTU.rap_operation == SEARCH) && (!`TTU.rfm_ttu.hwcfg0_enable)) |-> (`TTU.ttu_operation[1] != 1'b1))
  ) else $error("[%0t] Assertion Failed: IOPMP is disabled", $time);

  // ######################################## NO AXI TRANSACTION #######################################

  // TTU.20. Assertion: If the operation from AXI Master Request Manager is not SEARCH, then TTU operation should never be SEARCH or ERROR or MATCH
  ttu_assert_axi_req_no_search: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`TTU.rap_operation != SEARCH) |-> ((|`TTU.ttu_operation) != 1'b1))
  ) else $error("[%0t] Assertion Failed: Operation from AXI Master Request Manager is not SEARCH", $time);

  //****************************************************************************************************
  // 4KB Transaction Address Check Cover Properties
  //****************************************************************************************************

  // TTU.21. Cover Property: If any transaction crosses 4KB boundary, then TTU operation should be error if the operation from last stage is SEARCH
  ttu_cover_4kb_check_fail: cover property (
    @(posedge clk) (((`LAST_STAGE.updated_rap_operation[`TTU.NUM_TTU_STAGES-1] == SEARCH) && `LAST_STAGE.end_addr[12]) |=> (`LAST_STAGE.ttu_rapo == ERROR))
  );

  // TTU.22. Cover Property: If any transaction crosses 4KB boundary, then TTU should indicates NOT_HIT_ANY_RULE error
  ttu_cover_4kb_check_fail_error: cover property (
    @(posedge clk) (((`LAST_STAGE.updated_rap_operation[`TTU.NUM_TTU_STAGES-1] == SEARCH) && `LAST_STAGE.end_addr[12]) |=> (`LAST_STAGE.rap_err_info == NOT_HIT_ANY_RULE))
  );