///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 13-June-2025
/// Description: This module implements the MDs Traversal. When MDCFG Format
/// is 1, this module generates upto 3 pipeline stages where each stage
/// can prcoess upto 21 memory domains. The supported number of MDs dictates
/// the pipeline stages and the number of cycles required to traverse the
/// MDs before the final output is sent to Rule Analyzer Pipeline for
/// further address checks and permissions matches.
///////////////////////////////////////////////////////////////////////////

module mdcfg_fmt_1
  import execution_pipeline_pkg::*;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;
  import iopmp_axi_pkg::transaction_t;
  import rfm_pkg::srcmd_table_2_t;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default,

  // Parameter defining the number of TTU stages
  parameter NUM_TTU_STAGES = 1
) (
  input  logic                            clk,                 // Clock Rising Edge
  input  logic                            rst_n,               // Reset Active Low

  // Axi Master Request Manager ==> MDCFG Format 1
  input  transaction_t                    transaction_i,       // AXI transaction

  // TTU Checks ==> MDCFG Format 1
  input  operation_e                      ttu_operation,       // Operation evaluated in Table Traversal Unit
  input  errorType_t                      ttu_err_info,			   // Error information encountered inside TTU

  // Register File Manager ==> MDCFG Format 1
  input  srcmd_table_2_t [CFG.MD_NUM-1:0] srcmd_table_2,       // SRCMD Table contains SRCMD_PERM(H) in SRCMD Format 2

  // SRCMD Table Traversal ==> MDCFG Format 1
  input  logic [CFG.MD_NUM-1:0]           mdpresent,           // Indicates the associated MDs with the transaction
  input  logic [CFG.MD_NUM-1:0]           mdrperm,             // SRCMD_R(H) registers value when SRCMD Format is 0 and SPS Extension is enabled
  input  logic [CFG.MD_NUM-1:0]           mdwperm,    				 // SRCMD_W(H) registers value when SRCMD Format is 0 and SPS Extension is enabled

  // MDCFG Format 1 ==> Rule Analyzer Pipeline
  output logic [CFG.ENTRY_NUM-1:0]        entrypresent_or,     // Indicates the entries to be checked in Rule Analyzer Pipeline
  output logic [CFG.ENTRY_NUM-1:0][1:0]   mdrwperm_repl,       // Indicates the RW permission for entries that will be matched in Rule Analyzer Pipeline
  output transaction_t                    transaction_o,       // TTU to RAP AXI transaction
  output logic [AXI_ADDR_WIDTH-1:0]       trans_end_addr,      // Transaction end Address
  output operation_e                      ttu_rapo,            // TTU to RAP operation
  output errorType_t                      rap_err_info         // Error information encountered in TTU
);

  logic [CFG.MD_NUM-1:0][$clog2(CFG.ENTRY_NUM):0] LWR_ENTRY_INDEX;
  logic [CFG.MD_NUM-1:0][$clog2(CFG.ENTRY_NUM):0] UPR_ENTRY_INDEX;

  // Generate UPPER ENTRY INDEX and LOWER ENTRY INDEX for each MD
  for (genvar cur_md = 0; cur_md < int'(CFG.MD_NUM); cur_md++) begin
    assign LWR_ENTRY_INDEX[cur_md] = cur_md * (CFG.MD_ENTRY_NUM + 1);
    assign UPR_ENTRY_INDEX[cur_md] = (cur_md + 1) * (CFG.MD_ENTRY_NUM + 1);
  end

  //###############################
  // Internal Signals Declarations
  //###############################

  // Intermediate stages flops when MDCFG Format is 1
  operation_e   [NUM_TTU_STAGES:0]                           updated_rap_operation;     // Indicates operation for Rule Analyzer Pipeline at every TTU stage
  errorType_t   [NUM_TTU_STAGES:0]                           ttu_rap_err_info;			    // Indicates error information encountered in Table Traversal Unit at every stage
  transaction_t [NUM_TTU_STAGES:0]                           transaction_l;             // Incoimg transaction from AXI at every pipeline stage
  logic         [NUM_TTU_STAGES-1:0][CFG.MD_NUM-1:0]         mdpresent_l_i;             // mdpresent_l_i indicates the associated MDs at the input of every pipeline stage
  logic         [NUM_TTU_STAGES-1:0][CFG.MD_NUM-1:0]         mdrperm_l_i;               // Indicates the read permissions for MDs at the input of every pipeline stage
  logic         [NUM_TTU_STAGES-1:0][CFG.MD_NUM-1:0]         mdwperm_l_i;               // Indicates the write permissions for MDs at the input of every pipeline stage
  logic         [NUM_TTU_STAGES:0][CFG.ENTRY_NUM-1:0]        ep_or_l_i;                 // Indicates the entries associated with a transaction at the input of each pipeline stage
  logic         [NUM_TTU_STAGES:0][CFG.ENTRY_NUM-1:0][1:0]   mdrwperm_repl_l_i;         // Indicates the RW permissions for associated entries with a transaction at the input of each pipeline stage
  logic         [NUM_TTU_STAGES-1:0][CFG.MD_NUM-1:0]         mdpresent_l_o;             // mdpresent_l_o indicates the associated MDs at the output of slice
  logic         [NUM_TTU_STAGES-1:0][CFG.MD_NUM-1:0]         mdrperm_l_o;               // Indicates the read permissions for MDs at the output of every pipeline stage
  logic         [NUM_TTU_STAGES-1:0][CFG.MD_NUM-1:0]         mdwperm_l_o;               // Indicates the write permissions for MDs at the output of every pipeline stage
  logic         [NUM_TTU_STAGES-1:0][CFG.ENTRY_NUM-1:0]      ep_or_l_o;                 // Indicates the entries associated with a transaction at the output of each pipeline stage
  logic         [NUM_TTU_STAGES-1:0][CFG.ENTRY_NUM-1:0][1:0] mdrwperm_repl_l_o;         // Indicates the RW permissions for associated entries with a transaction at the output of each pipeline stage
  operation_e                                                final_ttu_rap_operation;   // Final operation from TTU after the 4KB Boundary check
  errorType_t                                                final_ttu_rap_err_info;    // Final error information from TTU after the 4KB Boundary check
  logic         [12:0]                                       end_addr;                  // Transaction end address

  //****************************************************************************************************
  // Input signals to Stage 1
  //****************************************************************************************************
  assign updated_rap_operation[0] = ttu_operation;    // rapo at stage 1
  assign ttu_rap_err_info[0]      = ttu_err_info;     // Error information at stage 1
  assign transaction_l[0]         = transaction_i;    // AXI transaction at stage 1
  assign mdpresent_l_i[0]         = mdpresent;        // MDPRESENT_L0 at the input of slice 1
  assign mdrperm_l_i[0]           = mdrperm;          // mdrperm at the input of slice 1
  assign mdwperm_l_i[0]           = mdwperm;          // mdwperm at the input of slice 1
  assign ep_or_l_i[0]             = '0;               // ep_or_l0 at the input of slice 1
  assign mdrwperm_repl_l_i[0]     = '0;               // mdrwperm_repl_l0 at the input of slice 1

  // The loop generates a number of stages pipeline where each stage processes a distinct chunk of MDs
  // using the mds_traversal_fmt_1 module. Signals are forwarded from one stage to the next at every clock cycle
  // The START_MD is set to 0 for the first stage, 21 for the second, and 42 for the third, based on the stage index
  // The END_MD is computed such that each module has exactly 21 MDs to process if hwcfg0.md_num is 63, otherwise END_MD
  // for any slice can't be greater than hwcfg0.md_num
  for (genvar curr_stage = 0; curr_stage < NUM_TTU_STAGES; curr_stage++) begin : gen_mds_traversal_units

    localparam int START_MD = (curr_stage == 0) ? 0 : ((curr_stage == 1) ? 21 : 42);
    localparam int END_MD   = ((curr_stage + 1) * 21 > CFG.MD_NUM) ? int'(CFG.MD_NUM) : ((curr_stage + 1) * 21);

    mds_traversal_fmt_1 #(
      .CFG(CFG),
      .START_MD(START_MD),
      .END_MD(END_MD)
    ) mds_traversal_fmt_1
    (
      // MDCFG Format 1 ==> MDs Traversal Format 1
      .transaction_rrid_l  (transaction_l[curr_stage].rrid[4:0]),    // transaction_l[0] input to slice 1, transaction_l[1] input to slice 2, transaction_l[2] input to slice 3
      .mdpresent_l_i       (mdpresent_l_i[curr_stage]),              // mdpresent_l_i[0] input to slice 1, mdpresent_l_i[1] input to slice 2, mdpresent_l_i[2] input to slice 3
      .lwr_entry_index     (LWR_ENTRY_INDEX[END_MD-1:START_MD]),     // Each stage takes LWR_ENTRY_INDEX from START_MD to END_ENTRY-1
      .upr_entry_index     (UPR_ENTRY_INDEX[END_MD-1:START_MD]),     // Each stage takes UPR_ENTRY_INDEX from START_MD to END_ENTRY-1
      .ep_or_l_i           (ep_or_l_i[curr_stage]),                  // ep_or_l_i[0] input to slice 1, ep_or_l_i[1] input to slice 2, ep_or_l_i[2] input to slice 3
      .mdrwperm_repl_l_i   (mdrwperm_repl_l_i[curr_stage]),          // mdrwperm_repl_l_i[0] input to slice 1, mdrwperm_repl_l_i[1] input to slice 2, mdrwperm_repl_l_i[2] input to slice 3
      .mdrperm_l_i         (mdrperm_l_i[curr_stage]),                // mdrperm_l_i[0] input to slice 1, mdrperm_l_i[1] input to slice 2, mdrperm_l_i[2] input to slice 3
      .mdwperm_l_i         (mdwperm_l_i[curr_stage]),                // mdwperm_l_i[0] input to slice 1, mdwperm_l_i[1] input to slice 2, mdwperm_l_i[2] input to slice 3
      .srcmd_table         (srcmd_table_2[END_MD-1:START_MD]),       // SRCMD Table for extratcting RW permissions when SRCMD Format 2. Each stage inputs the required SRCMD Table Register

      // MDs Traversal Format 1 ==> MDCFG Format 1
      .mdpresent_l_o       (mdpresent_l_o[curr_stage]),              // mdpresent_l_o[0] output of slice 1, mdpresent_l_o[1] output of slice 2, mdpresent_l_o[2] output of slice 3
      .ep_or_l_o           (ep_or_l_o[curr_stage]),                  // ep_or_l_o[0] output of slice 1, ep_or_l_o[1] output of slice 2, ep_or_l_o[2] output of slice 3
      .mdrwperm_repl_l_o   (mdrwperm_repl_l_o[curr_stage]),          // mdrwperm_repl_l_o[0] output of slice 1, mdrwperm_repl_l_o[1] output of slice 2, mdrwperm_repl_l_o[2] output of slice 3
      .mdrperm_l_o         (mdrperm_l_o[curr_stage]),                // mdrperm_l_o[0] output of slice 1, mdrperm_l_o[1] output of slice 2, mdrperm_l_o[2] output of slice 3
      .mdwperm_l_o         (mdwperm_l_o[curr_stage])                 // mdwperm_l_o[0] output of slice 1, mdwperm_l_o[1] output of slice 2, mdwperm_l_o[2] output of slice 3
    );

    //****************************************************************************************************
    // Stages Flops
    //****************************************************************************************************

    // The output of current stage is the input to the current stage flop. curr_stage + 1, indicates the output of flop for that stage
    always_ff @(posedge clk or negedge rst_n) begin : gen_stage_flops
      if (!rst_n) begin
        transaction_l[curr_stage+1]     <= '0;
        ep_or_l_i[curr_stage+1]         <= '0;
        mdrwperm_repl_l_i[curr_stage+1] <= '0;
      end
      else begin
        transaction_l[curr_stage+1]     <= transaction_l[curr_stage];
        ep_or_l_i[curr_stage+1]         <= ep_or_l_o[curr_stage];
        mdrwperm_repl_l_i[curr_stage+1] <= mdrwperm_repl_l_o[curr_stage];
      end
    end
  end

  // This for loop generates NUM_TTU_STAGE-1 number of flops
  for (genvar curr_stage = 1; curr_stage < NUM_TTU_STAGES; curr_stage++) begin : gen_intermediate_flops
    always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        updated_rap_operation[curr_stage] <= NOP;
        ttu_rap_err_info[curr_stage]      <= NO_ERROR;
        mdpresent_l_i[curr_stage]         <= '0;
        mdrperm_l_i[curr_stage]           <= '0;
        mdwperm_l_i[curr_stage]           <= '0;
      end
      else begin
        updated_rap_operation[curr_stage] <= updated_rap_operation[curr_stage-1];
        ttu_rap_err_info[curr_stage]      <= ttu_rap_err_info[curr_stage-1];
        mdpresent_l_i[curr_stage]         <= mdpresent_l_o[curr_stage-1];
        mdrperm_l_i[curr_stage]           <= mdrperm_l_o[curr_stage-1];
        mdwperm_l_i[curr_stage]           <= mdwperm_l_o[curr_stage-1];
      end
    end
  end

  // The maximum number of bytes in a transaction is 4KB and transactions are not permitted to cross a 4KB boundary
  // To check the 4KB Boundary Alignment for a transaction: For INCR (incremental) Burst type (AxBURST), multiply the total number of transfers (AxLEN + 1) in a
  // transaction with the number of bytes in each data transfer (AxSIZE) within a transaction and add the result to the transaction address. Subtract one from final result
  // For FIXED Burst type, add transaction address to the number of bytes in a data transfer and subtract one.
  // If the 12 bit of end_addr is 1, it indicates the transaction has crossed the 4KB boundary
  assign end_addr = (({1'b0, transaction_l[NUM_TTU_STAGES-1].addr[11:0]} + ((({9'd0, transaction_l[NUM_TTU_STAGES-1].len} & {13{(|transaction_l[NUM_TTU_STAGES-1].burst)}}) + {{12{1'b0}},1'b1}) << transaction_l[NUM_TTU_STAGES-1].size)) - {{12{1'b0}},1'b1});

  // If the transaction end address crosses the 4KB boundary (indicated by end_addr[12] bit high) when the previous stage operation is
  // SEARCH (2'b10), then report an error of type NOT HIT ANY RULE. Otherwise, pass the previous stage operation and error information
  assign final_ttu_rap_operation = ((updated_rap_operation[NUM_TTU_STAGES-1] == SEARCH) && end_addr[12]) ?
                                   ERROR : updated_rap_operation[NUM_TTU_STAGES-1];

  assign final_ttu_rap_err_info  = ((updated_rap_operation[NUM_TTU_STAGES-1] == SEARCH) && end_addr[12] && CFG.ERROR_CAPTURE_EN) ?
                                   NOT_HIT_ANY_RULE : ttu_rap_err_info[NUM_TTU_STAGES-1];

  // Generate the transaction end address flop and updated operation and eror information
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      trans_end_addr                        <= '0;
      updated_rap_operation[NUM_TTU_STAGES] <= NOP;
      ttu_rap_err_info[NUM_TTU_STAGES]      <= NO_ERROR;
    end
    else begin
      trans_end_addr                        <= {transaction_l[NUM_TTU_STAGES-1].addr[AXI_ADDR_WIDTH-1:12], end_addr[11:0]};
      updated_rap_operation[NUM_TTU_STAGES] <= final_ttu_rap_operation;
      ttu_rap_err_info[NUM_TTU_STAGES]      <= final_ttu_rap_err_info;
    end
  end

  // Final output from TTU to RAP
  assign ttu_rapo        = updated_rap_operation[NUM_TTU_STAGES];    // The last stage operation is the final output to RAP
  assign rap_err_info    = ttu_rap_err_info[NUM_TTU_STAGES];         // The last stage error information is the final output to RAP
  assign transaction_o   = transaction_l[NUM_TTU_STAGES];            // The last stage transaction is the final output to RAP
  assign entrypresent_or = ep_or_l_i[NUM_TTU_STAGES];                // The last stage ep_or is the final output to RAP
  assign mdrwperm_repl   = mdrwperm_repl_l_i[NUM_TTU_STAGES];        // The last stage mdrwperm_repl is the final output to RAP

endmodule
