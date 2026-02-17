  `define RAP_RESP_GEN tb_top.iopmp_dut.rap.response_generator_inst

  import execution_pipeline_pkg::*;

  //****************************************************************************************************
  // Cover Properties
  //****************************************************************************************************

  // ########################################## ERROR RESPONSE #########################################

  // RAP_RG.01. Cover Property: If final stage output from execution pipeline indicates ERROR or SEARCH operation, then an error response should be generated
  rap_cover_error_response: cover property (
    @(posedge clk) ((`RAP_RESP_GEN.operation[1]) |-> (`RAP_RESP_GEN.is_resp_error))
  );

  // RAP_RG.02. Cover Property: If final stage output from execution pipeline indicates ERROR or SEARCH operation for a read/execute transaction, then an error response should be generated over the read channel
  rap_cover_rd_ex_error_resp: cover property (
    @(posedge clk) (((`RAP_RESP_GEN.transaction.r || `RAP_RESP_GEN.transaction.x) && `RAP_RESP_GEN.operation[1]) |-> (`RAP_RESP_GEN.rap_rd_err_valid))
  );

  // RAP_RG.03. Cover Property: If final stage output from execution pipeline indicates ERROR or SEARCH operation for a write transaction, then an error response should be generated over the write channel
  rap_cover_wr_error_resp: cover property (
    @(posedge clk) ((`RAP_RESP_GEN.transaction.w && `RAP_RESP_GEN.operation[1]) |-> (`RAP_RESP_GEN.rap_wr_err_valid))
  );

  // ######################################### SUCCESS RESPONSE ########################################

  // RAP_RG.04. Cover Property: If final stage output from execution pipeline indicates MATCHED operation, then a success response should be generated
  rap_cover_success_response: cover property (
    @(posedge clk) ((`RAP_RESP_GEN.operation == MATCHED) |-> (`RAP_RESP_GEN.is_resp_success))
  );

  // RAP_RG.05. Cover Property: If final stage output from execution pipeline indicates MATCHED operation for a read/execute transaction, then a success response should be generated over the read channel
  rap_cover_rd_ex_success_resp: cover property (
    @(posedge clk) (((`RAP_RESP_GEN.transaction.r || `RAP_RESP_GEN.transaction.x) && (`RAP_RESP_GEN.operation == MATCHED)) |-> (`RAP_RESP_GEN.rap_rd_valid))
  );

  // RAP_RG.06. Cover Property: If final stage output from execution pipeline indicates MATCHED operation for a write transaction, then a success response should be generated over the write channel
  rap_cover_wr_success_resp: cover property (
    @(posedge clk) ((`RAP_RESP_GEN.transaction.w && (`RAP_RESP_GEN.operation == MATCHED)) |-> (`RAP_RESP_GEN.rap_wr_valid))
  );

  // ####################################### ERRROR REPORT ENABLED #####################################

  if (config_iopmp_pkg::iopmp_cfg_default.ERROR_CAPTURE_EN) begin : error_report_enabled

    // RAP_RG.07. Cover Property: If final stage output from execution pipeline indicates ERROR or SEARCH operation, then the error should be reported to EIC Block
    rap_cover_report_error_to_eic: cover property (
      @(posedge clk) ((`RAP_RESP_GEN.operation[1]) |-> (`RAP_RESP_GEN.rap_eic_valid))
    );

    // RAP_RG.08. Cover Property: If final stage output from execution pipeline indicates SEARCH operation with no error information, then the reported error information to EIC Block should be NOT_HIT_ANY_RULE
    rap_cover_reported_error_type: cover property (
      @(posedge clk) (((`RAP_RESP_GEN.operation == SEARCH) && (!(|`RAP_RESP_GEN.err_info))) |-> (`RAP_RESP_GEN.rap_eic_error_info.err_info == {NOT_HIT_ANY_RULE, 1'b0}))
    );

  //****************************************************************************************************
  // Assertions
  //****************************************************************************************************

  // ####################################### ERRROR REPORT ENABLED #####################################

    // RAP_RG.09. Assertion: If the final stage output from execution pipeline indicates ERROR operation, then the error information should match one of the error type listed in IOPMP Spec
    rap_assert_error_type: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`RAP_RESP_GEN.operation == ERROR) |-> (|`RAP_RESP_GEN.err_info))
    ) else $error("[%0t] Assertion Failed: Partial Adress matched hit for a Non-Priority Entry", $time);
  end
  else begin : error_report_disabled

  // ###################################### ERRROR REPORT DISABLED #####################################

    // RAP_RG.10. Assertion: If the final stage output from execution pipeline indicates ERROR operation when ERROR CAPTURE is not enabled, then error must not be reported to EIC Block
    rap_assert_error_report_disable: assert property (
      @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`RAP_RESP_GEN.operation[1]) |-> (`RAP_RESP_GEN.rap_eic_valid != 1'b1))
    ) else $error("[%0t] Assertion Failed: Partial Adress matched hit for a Non-Priority Entry", $time);
  end
