///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 11-June-2025
/// Description: This module performs the SRCMD Table Traversal to find the
/// associated MDs with the transaction and corresponding RW permissions.
/// This module is parametrized to generate the SRCMD Table traversal
/// logic based on SRCMD Format.
///////////////////////////////////////////////////////////////////////////

module srcmd_table_traversal
  import execution_pipeline_pkg::*;
  import rfm_pkg::srcmd_table_0_t;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  // Axi Master Request Manager ==> SRCMD Table Traversal
  input  logic [5:0]                        transaction_rrid,   // AXI transaction RRID required for SRCMD Table indexing

  // Register File Manager ==> SRCMD Table Traversal
  input  srcmd_table_0_t [CFG.RRID_NUM-1:0] srcmd_table_0,      // SRCMD Table contains SRCMD_EN/SRCMD_ENH when SRCMD Format is 0 and
                                                                // if Secondary Permission Setting is enabled it also contains SRCMD_R/SRCMD_RH and SRCMD_W/SRCMD_WH registers

  // SRCMD Table Traversal ==> MDCFG Table Traversal
  output logic [CFG.MD_NUM-1:0]             mdpresent,          // Indicates the associated MDs with the transaction
  output logic [CFG.MD_NUM-1:0]             mdrperm,            // SRCMD_R(H) registers value when SRCMD Format 0 and SPS Extension is enabled
  output logic [CFG.MD_NUM-1:0]             mdwperm    			    // SRCMD_W(H) registers value when SRCMD Format 0 and SPS Extension is enabled
);

  logic [CFG.RRID_NUM-1:0] read_vec;

  // Perform SRCMD Table Traversal when SRCMD Format is 0 and find the associated MDs and corresponding RW permissions
  if (CFG.SRCMD_FMT_0) begin : gen_srcmd_fmt_0

    // If supported MDs less than 31, then only srcmd_en register is used to determine mdpresent
    // and srcmd_r/srcmd_w for corresponding RW permissions if Secondary Permission Setting is enabled
    if (CFG.MD_NUM < 31) begin : gen_md_num_less_than_31

      if (CFG.SE_EN) begin : source_enforcement_enabled

        assign mdpresent = srcmd_table_0[0].srcmd_en.md;
        assign mdrperm   = CFG.SPS_EN ? srcmd_table_0[0].srcmd_r.md : '0;
        assign mdwperm   = CFG.SPS_EN ? srcmd_table_0[0].srcmd_w.md : '0;
      end
      else begin  : source_enforcement_disbled

        always_comb begin

          mdpresent = '0;
          mdrperm   = '0;
          mdwperm   = '0;
          read_vec  = 'b1 << transaction_rrid;

          for (int i = 0; i < int'(CFG.RRID_NUM); i++) begin
            mdpresent |= read_vec[i] ? srcmd_table_0[i].srcmd_en.md : '0;

            if (CFG.SPS_EN) begin
              mdrperm |= read_vec[i] ? srcmd_table_0[i].srcmd_r.md : '0;
              mdwperm |= read_vec[i] ? srcmd_table_0[i].srcmd_w.md : '0;
            end
          end
        end
      end
    end

    // If supported MDs are greater than 30, then both srcmd_en and srcmd_enh registers are used to determine mdpresent
    // and srcmd_r(h)/srcmd_w(h) for corresponding RW permissions if Secondary Permission Setting is enabled
    else begin : gen_md_num_greater_than_30

      if (CFG.SE_EN) begin : source_enforcement_enabled

        assign mdpresent = {srcmd_table_0[0].srcmd_enh.mdh, srcmd_table_0[0].srcmd_en.md};
        assign mdrperm   = CFG.SPS_EN ? {srcmd_table_0[0].srcmd_rh.mdh, srcmd_table_0[0].srcmd_r.md} : '0;
        assign mdwperm   = CFG.SPS_EN ? {srcmd_table_0[0].srcmd_wh.mdh, srcmd_table_0[0].srcmd_w.md} : '0;
      end
      else begin  : source_enforcement_disbled

        always_comb begin

          mdpresent = '0;
          mdrperm   = '0;
          mdwperm   = '0;
          read_vec  = 'b1 << transaction_rrid;

          for (int i = 0; i < int'(CFG.RRID_NUM); i++) begin
            mdpresent |= read_vec[i] ? {srcmd_table_0[i].srcmd_enh.mdh, srcmd_table_0[i].srcmd_en.md} : '0;

            if (CFG.SPS_EN) begin
              mdrperm |= read_vec[i] ? {srcmd_table_0[i].srcmd_rh.mdh, srcmd_table_0[i].srcmd_r.md} : '0;
              mdwperm |= read_vec[i] ? {srcmd_table_0[i].srcmd_wh.mdh, srcmd_table_0[i].srcmd_w.md} : '0;
            end
          end
        end
      end
    end
  end

  // For SRCMD Format 1, there is one-to-one mapping of RRIDs and MDs. mdpresent[m] gets set for m = RRID in the incoimg transaction
  else if (CFG.SRCMD_FMT_1) begin : gen_srcmd_fmt_1
    assign mdpresent = 'b1 << transaction_rrid;
    assign mdrperm   = '0;
    assign mdwperm   = '0;
  end

  // In SRCMD Format 2, all MDs are associated with the incoming RRID. Traverse all MDs and find associated entries and permission
  else begin : gen_srcmd_fmt_2
    assign mdpresent = '1;
    assign mdrperm   = '0;
    assign mdwperm   = '0;
  end

endmodule
