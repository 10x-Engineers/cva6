///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 15-June-2025
/// Description: This module performs the MDs Traversal when MDCFG Format
/// is 1. It process upto 21 memory domains in a single cycle. It
/// first generates the bitmap representation of mdcfg.t field and then
/// proccess it with the bitmap representation of all the previous MDs to
/// find the asscociated entries with that particular MD. Once the
/// associated entries are found for an MD, the corresponding permissions
/// from SRCMD Table are assigned to them.
///////////////////////////////////////////////////////////////////////////

module mds_traversal_fmt_1
  import rfm_pkg::srcmd_table_2_t;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default,

  // Start MD of slice
  parameter START_MD = 0,

  // End MD of slice
  parameter END_MD   = 0
) (
  // MDCFG Format 1 ==> MDCFG Table Traversal
  input  logic [4:0]                                            transaction_rrid_l,   // Transaction rrid to extract RW permission from srcmd table in SRCMD Format 2
  input  logic [CFG.MD_NUM-1:0]                                 mdpresent_l_i,        // Indicates the associated MDs with the transaction
  input  logic [(END_MD-START_MD)-1:0][$clog2(CFG.ENTRY_NUM):0] upr_entry_index,
  input  logic [(END_MD-START_MD)-1:0][$clog2(CFG.ENTRY_NUM):0] lwr_entry_index,
  input  logic [CFG.ENTRY_NUM-1:0]                              ep_or_l_i,            // Indicates the associated entries with the transaction from previous stage
  input  logic [CFG.ENTRY_NUM-1:0][1:0]                         mdrwperm_repl_l_i,    // Indicates the RW permission for associated entries with the transaction from previous stage
  input  logic [CFG.MD_NUM-1:0]                                 mdrperm_l_i,          // Indicates the read permission for MDs in SRCMD Format 0 at the input of current stage
  input  logic [CFG.MD_NUM-1:0]                                 mdwperm_l_i,          // Indicates the write permission for MDs in SRCMD Format 0 at the input of current stage
  input  srcmd_table_2_t [(END_MD-START_MD)-1:0]                srcmd_table,          // SRCMD Table to extract RW permissions, contains srcmd_perm and srcmd_permh when SRCMD Format 2

  // MDCFG Table Traversal ==> MDCFG Format 1
  output logic [CFG.MD_NUM-1:0]                                 mdpresent_l_o,        // Indicates the associated MDs with the transaction
  output logic [CFG.ENTRY_NUM-1:0]                              ep_or_l_o,            // Indicates the associated entries with the transaction till current stage
  output logic [CFG.ENTRY_NUM-1:0][1:0]                         mdrwperm_repl_l_o,    // Indicates the RW permission for associated entries with the transaction till current stage
  output logic [CFG.MD_NUM-1:0]                                 mdrperm_l_o,          // Indicates the read permission for MDs in SRCMD Format 0 at the output of current stage
  output logic [CFG.MD_NUM-1:0]                                 mdwperm_l_o           // Indicates the write permission for MDs in SRCMD Format 0 at the output of current stage
);

  //###############################
  // Internal Signals Declarations
  //###############################

  // Intermediate signals when MDCFG Format is 1
  logic [(END_MD-START_MD)-1:0][CFG.ENTRY_NUM-1:0]      ep;                   // Indicates the associated entries for each MD
  logic [(END_MD-START_MD)-1:0][CFG.ENTRY_NUM-1:0]      ep_or_l;              // Indicates the OR of ep till current stage
  logic [(END_MD-START_MD)-1:0][CFG.ENTRY_NUM-1:0][1:0] mdrwperm_l;           // Indicates the RW permissions for associated entries with an MD
  logic [(END_MD-START_MD)-1:0][CFG.ENTRY_NUM-1:0][1:0] mdrwperm_repl_or_l;   // Indicates the OR of mdrwperm_l for associated MDs till current stage
  logic [(CFG.RRID_NUM*2)-1:0]                          mdrwperm;             // Contains the RW permission when srcmd format 2
  logic [(CFG.RRID_NUM*2)-2:0]                          read_vec;             // Indicates incoming RRID read permission bit index when srcmd format 2

  always_comb begin

    //#########################
    // Generate EP
    //#########################

    // Determine the associated entries for the first MD in the current stage if that MD is associated with the current transaction
    ep[0] = mdpresent_l_i[START_MD] ? ({CFG.ENTRY_NUM{1'b1}} << lwr_entry_index[0]) & (~({CFG.ENTRY_NUM{1'b1}} << upr_entry_index[0])) : '0;

    //#########################
    // Generate EP_OR
    //#########################
    ep_or_l[0] = ep_or_l_i | ep[0];   // OR of ep of all previous MDs and current MD

    //#########################
    // Generate MDPERM_REPL
    //#########################
    if (CFG.SRCMD_FMT_2) begin : gen_srmcd_fmt_2_0

      // In SRCMD Format 2, if supported value of RRIDs is less than 16, then only srcmd_perm will be used to extract RW permission for an RRID
      if (CFG.RRID_NUM < 16) begin : gen_rrid_num_16_0
        mdrwperm = srcmd_table[0].srcmd_perm.perm;
      end

      // In SRCMD Format 2, if supported value of RRIDs is greater than 15, srcmd_permh and srcmd_perm both will be used to get RW permissions for an RRID
      else begin : gen_rrid_num_32_0
        mdrwperm = {srcmd_table[0].srcmd_permh.permh, srcmd_table[0].srcmd_perm.perm}; // Concatenation of SRCMD_PERM and SRCMD_PERMH
      end

      read_vec  = 'b1 << (transaction_rrid_l << 1);
    end

    // MDRWPERM_REPL vector is avaialbel only when SRCMD Format 0 with SPS Extension enabled or SRCMD Format is 2
    if (CFG.SRCMD_FMT_2 || CFG.SPS_EN) begin : gen_mdrwperm_l_0

      // Traverse the ep for current stage MDs and extract the RW permission for associated entries
      for (int entry_index = 0; entry_index < int'(CFG.ENTRY_NUM); entry_index++) begin

        if (ep[0][entry_index]) begin

          // If SRCMD Format is 0 and Secondary Permission Setting is enabled, then mdrwperm_l will be set based on input mdrperm_l_i and mdwperm_l_i
          if (CFG.SPS_EN) begin : gen_mdrwperm_l_1
            mdrwperm_l[0][entry_index] = {mdwperm_l_i[START_MD], mdrperm_l_i[START_MD]};
          end

          // If SRCMD Format is 2, then mdrwperm_l will be set based on mdrwperm
          else if (CFG.SRCMD_FMT_2) begin : gen_mdrwperm_l_2
            for (int index = 0; index < ((int'(CFG.RRID_NUM)*2)-1); index++)
              mdrwperm_l[0][entry_index] = read_vec[index] ? {mdrwperm[index + 1], mdrwperm[index]} : 2'b00;
          end
        end

        // If the entry is not associated with the current MD, drive zero to indicate that entry has no RW permissions
        else begin
          mdrwperm_l[0][entry_index] = 2'b00;
        end
      end

      // Generate mdrwperm_repl_or_l
      mdrwperm_repl_or_l[0] = mdrwperm_repl_l_i | mdrwperm_l[0];   // OR of mdrwperm_repl of all previous MDs and current MD
    end

    // Traverse the MDs in current stage to generate bitmap representation, finding associated entries for associated MDs and assigning permission for those entries
    for (int cur_md = 1; cur_md  < (END_MD - START_MD); cur_md++) begin

      //#########################
      // Generate EP
      //#########################

      // Determine the associated entries for the current MD if that MD is associated with the current transaction
      ep[cur_md] = mdpresent_l_i[START_MD + cur_md] ? ({CFG.ENTRY_NUM{1'b1}} << lwr_entry_index[cur_md]) & (~({CFG.ENTRY_NUM{1'b1}} << upr_entry_index[cur_md])) : '0;

      //#########################
      // Generate EP_OR
      //#########################
      ep_or_l[cur_md] = ep_or_l[cur_md-1] | ep[cur_md];     // OR of ep of all previous MDs and current MD

      //#########################
      // Generate MDRWPERM_REPL
      //#########################

      if (CFG.SRCMD_FMT_2) begin : gen_srmcd_fmt_2_1

        // In SRCMD Format 2, if supported value of RRIDs is less than 16, then only srcmd_perm will be used to extract RW permission for an RRID
        if (CFG.RRID_NUM < 16) begin : gen_rrid_num_16_1
          mdrwperm = srcmd_table[cur_md].srcmd_perm.perm;
        end

        // In SRCMD Format 2, if supported value of RRIDs is greater than 15, srcmd_permh and srcmd_perm both will be used to get RW permissions for an RRID
        else begin : gen_rrid_num_32_1
          mdrwperm = {srcmd_table[cur_md].srcmd_permh.permh, srcmd_table[cur_md].srcmd_perm.perm}; // Concatenation of SRCMD_PERM and SRCMD_PERMH
        end
      end

      // MDRWPERM_REPL vector is avaialbel only when SRCMD Format 0 with SPS Extension enabled or SRCMD Format is 2
      if (CFG.SRCMD_FMT_2 || CFG.SPS_EN) begin : gen_mdrwperm_l_4

        // Traverse the ep for current stage MDs and extract the RW permission for associated entries
        for (int entry_index = 0; entry_index < int'(CFG.ENTRY_NUM); entry_index++) begin

          // Check if the entry is associated with the current MD. If it does, extract the corresponding RW permissions for the entry based on SRCMD Format
          if (ep[cur_md][entry_index]) begin

            // If SRCMD Format is 0 and Secondary Permission Setting is enabled, then mdrwperm_l will be set based on input mdrperm_l_i and mdwperm_l_i
            if (CFG.SPS_EN) begin : gen_mdrwperm_l_5
              mdrwperm_l[cur_md][entry_index] = {mdwperm_l_i[cur_md + START_MD], mdrperm_l_i[cur_md + START_MD]};
            end

            // If SRCMD Format is 2, then mdrwperm_l will be set based on mdrwperm
            else if (CFG.SRCMD_FMT_2) begin : gen_mdrwperm_l_6
              for (int index = 0; index < ((int'(CFG.RRID_NUM)*2)-1); index++)
                mdrwperm_l[cur_md][entry_index] = read_vec[index] ? {mdrwperm[index + 1], mdrwperm[index]} : 2'b00;
            end
          end

          // If the entry is not associated with the current MD, drive zero to indicate that entry has no RW permissions
          else begin
            mdrwperm_l[cur_md][entry_index] = 2'b00;
          end
        end

        // Generate mdrwperm_repl_or_l
        mdrwperm_repl_or_l[cur_md] = mdrwperm_repl_or_l[cur_md-1] | mdrwperm_l[cur_md];    // OR of mdrwperm_repl of all previous MDs and current MD
      end
    end

    ep_or_l_o = ep_or_l[(END_MD-START_MD)-1];   // ep_or_l[END_MD] send to next slice

    if (CFG.SRCMD_FMT_2 || CFG.SPS_EN) begin : gen_mdrwperm_l_7
      mdrwperm_repl_l_o = mdrwperm_repl_or_l[(END_MD-START_MD)-1];   // mdrwperm_repl_l[END_MD] send to next slice
    end
    else begin
      mdrwperm_repl_l_o = mdrwperm_repl_l_i;
    end
  end

  assign mdpresent_l_o = mdpresent_l_i;  // mdpresent_l send to next slice
  assign mdrperm_l_o   = mdrperm_l_i;    // mdrperm_l send to next slice
  assign mdwperm_l_o   = mdwperm_l_i;    // mdwperm_l send to next slice

endmodule
