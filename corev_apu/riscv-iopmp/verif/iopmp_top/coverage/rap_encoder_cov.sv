  `define RAP_ENCODER tb_top.iopmp_dut.rap.gen_match_8_entry[0].match_8_entry_inst.encoder

  import execution_pipeline_pkg::*;

  //****************************************************************************************************
  // Cover Properties
  //****************************************************************************************************

  // RAP_ENC.01. Cover Property: If the 1st entry of the current stage outputs the operation MATCHED or ERROR and is a priority entry when the operation from earlier stages is SEARCH,
  // then current stage operation should match the 1st entry opreation
  rap_cover_prio_entry_0_op: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && `RAP_ENCODER.entry_operation[0][0] && `RAP_ENCODER.prio_entries[0]) |-> (`RAP_ENCODER.operation_o == `RAP_ENCODER.entry_operation[0]))
  );

  // RAP_ENC.02. Cover Property: If the 2nd entry of the current stage outputs the operation MATCHED or ERROR and is a priority entry when the operation from earlier stages is SEARCH and
  // operation of 1st entry of the current stage is not a MATCHED or ERROR, then current stage operation should match the 2nd entry operation
  rap_cover_prio_entry_1_op: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && (!`RAP_ENCODER.entry_operation[0][0]) && `RAP_ENCODER.entry_operation[1][0] && `RAP_ENCODER.prio_entries[1]) |-> (`RAP_ENCODER.operation_o == `RAP_ENCODER.entry_operation[1]))
  );

  // RAP_ENC.03. Cover Property: If the 3rd entry of the current stage outputs the operation MATCHED or ERROR and is a priority entry when the operation from earlier stages is SEARCH and
  // operation of 1st and 2nd entries of the current stage is not a MATCHED or ERROR, then current stage operation should match the 3rd entry operation
  rap_cover_prio_entry_2_op: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[0][0]) && `RAP_ENCODER.entry_operation[2][0] &&
    `RAP_ENCODER.prio_entries[2]) |-> (`RAP_ENCODER.operation_o == `RAP_ENCODER.entry_operation[2]))
  );

  // RAP_ENC.04. Cover Property: If the 4th entry of the current stage outputs the operation MATCHED or ERROR and is a priority entry when the operation from earlier stages is SEARCH and
  // operation of 1st, 2nd and 3rd entries of the current stage is not a MATCHED or ERROR, then current stage operation should match the 4th entry operation
  rap_cover_prio_entry_3_op: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && (!`RAP_ENCODER.entry_operation[2][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[0][0]) &&
    `RAP_ENCODER.entry_operation[3][0] && `RAP_ENCODER.prio_entries[3]) |-> (`RAP_ENCODER.operation_o == `RAP_ENCODER.entry_operation[3]))
  );

  // RAP_ENC.05. Cover Property: If the 5th entry of the current stage outputs the operation MATCHED or ERROR and is a priority entry when the operation from earlier stages is SEARCH and
  // operation of 1st, 2nd, 3rd and 4th entries of the current stage is not a MATCHED or ERROR, then current stage operation should match the 5th entry operation
  rap_cover_prio_entry_4_op: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && (!`RAP_ENCODER.entry_operation[3][0]) && (!`RAP_ENCODER.entry_operation[2][0]) && (!`RAP_ENCODER.entry_operation[1][0]) &&
    (!`RAP_ENCODER.entry_operation[0][0]) && `RAP_ENCODER.entry_operation[4][0] && `RAP_ENCODER.prio_entries[4]) |-> (`RAP_ENCODER.operation_o == `RAP_ENCODER.entry_operation[4]))
  );

  // RAP_ENC.06. Cover Property: If the 6th entry of the current stage outputs the operation MATCHED or ERROR and is a priority entry when the operation from earlier stages is SEARCH and
  // operation of 1st, 2nd, 3rd, 4th and 5th entries of the current stage is not a MATCHED or ERROR, then current stage operation should match the 6th entry operation
  rap_cover_prio_entry_5_op: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && (!`RAP_ENCODER.entry_operation[4][0]) && (!`RAP_ENCODER.entry_operation[3][0]) && (!`RAP_ENCODER.entry_operation[2][0]) &&
    (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[0][0]) && `RAP_ENCODER.entry_operation[5][0] && `RAP_ENCODER.prio_entries[5]) |-> (`RAP_ENCODER.operation_o == `RAP_ENCODER.entry_operation[5]))
  );

  // RAP_ENC.07. Cover Property: If the 7th entry of the current stage outputs the operation MATCHED or ERROR and is a priority entry when the operation from earlier stages is SEARCH and
  // operation of 1st, 2nd, 3rd, 4th, 5th and 6th entries of the current stage is not a MATCHED or ERROR, then current stage operation should match the 7th entry operation
  rap_cover_prio_entry_6_op: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && (!`RAP_ENCODER.entry_operation[5][0]) && (!`RAP_ENCODER.entry_operation[4][0]) && (!`RAP_ENCODER.entry_operation[3][0]) && (!`RAP_ENCODER.entry_operation[2][0]) &&
    (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[0][0]) && `RAP_ENCODER.entry_operation[6][0] && `RAP_ENCODER.prio_entries[6]) |-> (`RAP_ENCODER.operation_o == `RAP_ENCODER.entry_operation[6]))
  );

  // RAP_ENC.08. Cover Property: If the 8th entry of the current stage outputs the operation MATCHED or ERROR and is a priority entry when the operation from earlier stages is SEARCH and
  // operation of all other entries of the current stage is not a MATCHED or ERROR, then current stage operation should match the 8th entry operation
  rap_cover_prio_entry_7_op: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && (!`RAP_ENCODER.entry_operation[6][0]) && (!`RAP_ENCODER.entry_operation[5][0]) && (!`RAP_ENCODER.entry_operation[4][0]) && (!`RAP_ENCODER.entry_operation[3][0]) &&
    (!`RAP_ENCODER.entry_operation[2][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[0][0]) && `RAP_ENCODER.entry_operation[7][0] && `RAP_ENCODER.prio_entries[7]) |-> (`RAP_ENCODER.operation_o == `RAP_ENCODER.entry_operation[7]))
  );

  // RAP_ENC.09. Cover Property: If the operation of all the entries in the current stage is not MATCHED and all are non-priority entries when the operation from earlier stages is SEARCH,
  // then current stage operation should be SEARCH
  rap_cover_non_prio_op_search: cover property (
    @(posedge clk) (((!(|`RAP_ENCODER.prio_entries)) && (`RAP_ENCODER.operation_i == SEARCH) && (`RAP_ENCODER.entry_operation[0] != MATCHED) && (`RAP_ENCODER.entry_operation[1] != MATCHED) &&
    (`RAP_ENCODER.entry_operation[2] != MATCHED) && (`RAP_ENCODER.entry_operation[3] != MATCHED) && (`RAP_ENCODER.entry_operation[4] != MATCHED) && (`RAP_ENCODER.entry_operation[5] != MATCHED) &&
    (`RAP_ENCODER.entry_operation[6] != MATCHED) && (`RAP_ENCODER.entry_operation[7] != MATCHED)) |-> (`RAP_ENCODER.operation_o == SEARCH))
  );

  // RAP_ENC.10. Cover Property: If the operation of any of the entry in the current stage is MATCHED and all are non-priority entries when the operation from earlier stages is SEARCH,
  // then current stage operation should be MATCHED
  rap_cover_non_prio_op_match: cover property (
    @(posedge clk) (((!(|`RAP_ENCODER.prio_entries)) && (`RAP_ENCODER.operation_i == SEARCH) && ((`RAP_ENCODER.entry_operation[0] == MATCHED) || (`RAP_ENCODER.entry_operation[1] == MATCHED) ||
    (`RAP_ENCODER.entry_operation[2] == MATCHED) || (`RAP_ENCODER.entry_operation[3] == MATCHED) || (`RAP_ENCODER.entry_operation[4] == MATCHED) || (`RAP_ENCODER.entry_operation[5] == MATCHED) ||
    (`RAP_ENCODER.entry_operation[6] == MATCHED) || (`RAP_ENCODER.entry_operation[7] == MATCHED))) |-> (`RAP_ENCODER.operation_o == MATCHED))
  );

  // RAP_ENC.11. Cover Property:
  rap_cover_non_prio_entry_1_op_match: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && `RAP_ENCODER.prio_entries[0]) && ((!`RAP_ENCODER.prio_entries[1]) && ((`RAP_ENCODER.entry_operation[1] == MATCHED) ||
    (`RAP_ENCODER.entry_operation[2] == MATCHED) || (`RAP_ENCODER.entry_operation[3] == MATCHED) || (`RAP_ENCODER.entry_operation[4] == MATCHED) || (`RAP_ENCODER.entry_operation[5] == MATCHED) ||
    (`RAP_ENCODER.entry_operation[6] == MATCHED) || (`RAP_ENCODER.entry_operation[7] == MATCHED)))) |-> (`RAP_ENCODER.operation_o == MATCHED))
  );

  // RAP_ENC.12. Cover Property:
  rap_cover_non_prio_entry_1_op_search: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && `RAP_ENCODER.prio_entries[0]) && ((!`RAP_ENCODER.prio_entries[1]) && ((`RAP_ENCODER.entry_operation[1] != MATCHED) &&
    (`RAP_ENCODER.entry_operation[2] != MATCHED) && (`RAP_ENCODER.entry_operation[3] != MATCHED) && (`RAP_ENCODER.entry_operation[4] != MATCHED) && (`RAP_ENCODER.entry_operation[5] != MATCHED) &&
    (`RAP_ENCODER.entry_operation[6] != MATCHED) && (`RAP_ENCODER.entry_operation[7] != MATCHED)))) |-> (`RAP_ENCODER.operation_o == SEARCH))
  );

  // RAP_ENC.13. Cover Property:
  rap_cover_non_prio_entry_2_op_match: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (&`RAP_ENCODER.prio_entries[1:0])) && ((!`RAP_ENCODER.prio_entries[2]) &&
    ((`RAP_ENCODER.entry_operation[2] == MATCHED) || (`RAP_ENCODER.entry_operation[3] == MATCHED) || (`RAP_ENCODER.entry_operation[4] == MATCHED) || (`RAP_ENCODER.entry_operation[5] == MATCHED) ||
    (`RAP_ENCODER.entry_operation[6] == MATCHED) || (`RAP_ENCODER.entry_operation[7] == MATCHED)))) |-> (`RAP_ENCODER.operation_o == MATCHED))
  );

  // RAP_ENC.14. Cover Property:
  rap_cover_non_prio_entry_2_op_search: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (&`RAP_ENCODER.prio_entries[1:0])) && ((!`RAP_ENCODER.prio_entries[2]) &&
    ((`RAP_ENCODER.entry_operation[2] != MATCHED) && (`RAP_ENCODER.entry_operation[3] != MATCHED) && (`RAP_ENCODER.entry_operation[4] != MATCHED) && (`RAP_ENCODER.entry_operation[5] != MATCHED) &&
    (`RAP_ENCODER.entry_operation[6] != MATCHED) && (`RAP_ENCODER.entry_operation[7] != MATCHED)))) |-> (`RAP_ENCODER.operation_o == SEARCH))
  );

  // RAP_ENC.15. Cover Property:
  rap_cover_non_prio_entry_3_op_match: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[2][0]) && (&`RAP_ENCODER.prio_entries[2:0]))
    && ((!`RAP_ENCODER.prio_entries[3]) && ((`RAP_ENCODER.entry_operation[3] == MATCHED) || (`RAP_ENCODER.entry_operation[4] == MATCHED) || (`RAP_ENCODER.entry_operation[5] == MATCHED) ||
    (`RAP_ENCODER.entry_operation[6] == MATCHED) || (`RAP_ENCODER.entry_operation[7] == MATCHED)))) |-> (`RAP_ENCODER.operation_o == MATCHED))
  );

  // RAP_ENC.16. Cover Property:
  rap_cover_non_prio_entry_3_op_search: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[2][0]) && (&`RAP_ENCODER.prio_entries[2:0]))
    && ((!`RAP_ENCODER.prio_entries[3]) && ((`RAP_ENCODER.entry_operation[3] != MATCHED) && (`RAP_ENCODER.entry_operation[4] != MATCHED) && (`RAP_ENCODER.entry_operation[5] != MATCHED) &&
    (`RAP_ENCODER.entry_operation[6] != MATCHED) && (`RAP_ENCODER.entry_operation[7] != MATCHED)))) |-> (`RAP_ENCODER.operation_o == SEARCH))
  );

  // RAP_ENC.17. Cover Property:
  rap_cover_non_prio_entry_4_op_match: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[2][0]) &&
    (!`RAP_ENCODER.entry_operation[3][0]) && (&`RAP_ENCODER.prio_entries[3:0])) && ((!`RAP_ENCODER.prio_entries[4]) && ((`RAP_ENCODER.entry_operation[4] == MATCHED) ||
    (`RAP_ENCODER.entry_operation[5] == MATCHED) || (`RAP_ENCODER.entry_operation[6] == MATCHED) || (`RAP_ENCODER.entry_operation[7] == MATCHED)))) |-> (`RAP_ENCODER.operation_o == MATCHED))
  );

  // RAP_ENC.18. Cover Property:
  rap_cover_non_prio_entry_4_op_search: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[2][0]) &&
    (!`RAP_ENCODER.entry_operation[3][0]) && (&`RAP_ENCODER.prio_entries[3:0])) && ((!`RAP_ENCODER.prio_entries[4]) && ((`RAP_ENCODER.entry_operation[4] != MATCHED) &&
    (`RAP_ENCODER.entry_operation[5] != MATCHED) && (`RAP_ENCODER.entry_operation[6] != MATCHED) && (`RAP_ENCODER.entry_operation[7] != MATCHED)))) |-> (`RAP_ENCODER.operation_o == SEARCH))
  );

  // RAP_ENC.19. Cover Property:
  rap_cover_non_prio_entry_5_op_match: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[2][0]) &&
    (!`RAP_ENCODER.entry_operation[3][0]) && (!`RAP_ENCODER.entry_operation[4][0]) && (&`RAP_ENCODER.prio_entries[4:0])) && ((!`RAP_ENCODER.prio_entries[5]) && ((`RAP_ENCODER.entry_operation[5] == MATCHED)
    || (`RAP_ENCODER.entry_operation[6] == MATCHED) || (`RAP_ENCODER.entry_operation[7] == MATCHED)))) |-> (`RAP_ENCODER.operation_o == MATCHED))
  );

  // RAP_ENC.20. Cover Property:
  rap_cover_non_prio_entry_5_op_search: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[2][0]) &&
    (!`RAP_ENCODER.entry_operation[3][0]) && (!`RAP_ENCODER.entry_operation[4][0]) && (&`RAP_ENCODER.prio_entries[4:0])) && ((!`RAP_ENCODER.prio_entries[5]) && ((`RAP_ENCODER.entry_operation[5] != MATCHED)
    && (`RAP_ENCODER.entry_operation[6] != MATCHED) && (`RAP_ENCODER.entry_operation[7] != MATCHED)))) |-> (`RAP_ENCODER.operation_o == SEARCH))
  );

  // RAP_ENC.21. Cover Property:
  rap_cover_non_prio_entry_6_op_match: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[2][0]) &&
    (!`RAP_ENCODER.entry_operation[3][0]) && (!`RAP_ENCODER.entry_operation[4][0]) && (!`RAP_ENCODER.entry_operation[5][0]) && (&`RAP_ENCODER.prio_entries[5:0])) && ((!`RAP_ENCODER.prio_entries[6])
    && ((`RAP_ENCODER.entry_operation[6] == MATCHED) || (`RAP_ENCODER.entry_operation[7] == MATCHED)))) |-> (`RAP_ENCODER.operation_o == MATCHED))
  );

  // RAP_ENC.22. Cover Property:
  rap_cover_non_prio_entry_6_op_search: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[2][0]) &&
    (!`RAP_ENCODER.entry_operation[3][0]) && (!`RAP_ENCODER.entry_operation[4][0]) && (!`RAP_ENCODER.entry_operation[5][0]) && (&`RAP_ENCODER.prio_entries[5:0])) && ((!`RAP_ENCODER.prio_entries[6])
    && ((`RAP_ENCODER.entry_operation[6] != MATCHED) && (`RAP_ENCODER.entry_operation[7] != MATCHED)))) |-> (`RAP_ENCODER.operation_o == SEARCH))
  );

  // RAP_ENC.23. Cover Property:
  rap_cover_non_prio_entry_7_op_match: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[2][0]) &&
    (!`RAP_ENCODER.entry_operation[3][0]) && (!`RAP_ENCODER.entry_operation[4][0]) && (!`RAP_ENCODER.entry_operation[5][0]) && (!`RAP_ENCODER.entry_operation[6][0]) && (&`RAP_ENCODER.prio_entries[6:0]))
    && ((!`RAP_ENCODER.prio_entries[7]) && (`RAP_ENCODER.entry_operation[7] == MATCHED))) |-> (`RAP_ENCODER.operation_o == MATCHED))
  );

  // RAP_ENC.24. Cover Property:
  rap_cover_non_prio_entry_7_op_search: cover property (
    @(posedge clk) (((`RAP_ENCODER.operation_i == SEARCH) && ((!`RAP_ENCODER.entry_operation[0][0]) && (!`RAP_ENCODER.entry_operation[1][0]) && (!`RAP_ENCODER.entry_operation[2][0]) &&
    (!`RAP_ENCODER.entry_operation[3][0]) && (!`RAP_ENCODER.entry_operation[4][0]) && (!`RAP_ENCODER.entry_operation[5][0]) && (!`RAP_ENCODER.entry_operation[6][0]) && (&`RAP_ENCODER.prio_entries[6:0]))
    && ((!`RAP_ENCODER.prio_entries[7]) && (`RAP_ENCODER.entry_operation[7] != MATCHED))) |-> (`RAP_ENCODER.operation_o == SEARCH))
  );

  //****************************************************************************************************
  // Assertions
  //****************************************************************************************************

  // RAP_ENC.25. Assertion: If the operation from earlier stages is not SEARCH, then current stage operation should never be SEARCH
  rap_assert_op_i_not_search: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`RAP_ENCODER.operation_i != SEARCH) |-> (`RAP_ENCODER.operation_o != SEARCH))
  ) else $error("[%0t] Assertion Failed: Operation from earlier stages is not SEARCH", $time);