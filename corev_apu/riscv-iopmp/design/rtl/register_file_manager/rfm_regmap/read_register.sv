
///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 25-June-2025
/// Description:
///////////////////////////////////////////////////////////////////////////

module read_register
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import rfm_pkg::iopmp_reg_t;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  // AHB-LITE Interface ==> Read Register
  input  logic [8:0]                     req_offset_addr,     // Incoming request offset address bit[10:2]

  // Address Check ==> Read Register
  input  logic                           is_addr_legal,       // Indicates address is legal or illegal
  input  logic                           base_reg_legal,      // Indicates whether incoming address belongs to a legal register in BASE region section 1
  input  logic                           mdcfg_legal,         // Indicates whether incoming address belongs to a legal register in MDCFG region section 1
  input  logic                           srcmd_legal,         // Indicates whether incoming address belongs to a legal register in SRCMD region section 1
  input  logic                           entry_array_legal,   // Indicates whether incoming address is legal or not in entry array

  // Base Registers ==> Read Register
  input  logic [AHB_LITE_DATA_WIDTH-1:0] err_mfr_rdata,       // ERR_MFR read data

  // Regmap ==> Read Register
  input  iopmp_reg_t                     iopmp_reg,           // IOPMP Registers Packed Struct

  // Read Register ==> Regmap
  output logic [AHB_LITE_DATA_WIDTH-1:0] ahb_hrdata           // Registers data on a read request
);

  //###############################
  // Internal Signals Declarations
  //###############################

  logic [2:0]  mux_b2_sel, mux_m2_sel, mux_m3_sel, mux_s2_sel, mux_s3_sel, mux_s4_sel, mux_ea2_sel, mux_ea3_sel, mux_ea4_sel;
  logic [31:0] mux_b20_out, mux_b21_out, mux_b22_out, mux_b23_out, mux_m2_out, mux_s2_out, mux_ea2_out;
  logic [31:0] mux_m30_out, mux_m31_out, mux_m32_out, mux_m33_out, mux_m34_out, mux_m35_out, mux_m36_out, mux_m37_out;
  logic [63:0][31:0] mux_s4_out, mux_ea4_out;
  logic [7:0][31:0]  mux_s3_out, mux_ea3_out;
  int s_l3_index, s_l4_index, ea_l3_index, ea_l4_index;
  logic [2:0] l1_mux_sel;

  //****************************************************************************************************
  // An 8 to 1 mux function.
  // Each input (i0 through i7) and the output (muxout) is 32 bits wide.
  // The select signal (sel) is 3 bits wide.
  //****************************************************************************************************
  function [31:0] muxout (input [2:0]  sel,
                          input [31:0] i0, i1, i2, i3, i4, i5, i6, i7);
    begin
      case (sel)
        3'b000 : muxout = i0;
        3'b001 : muxout = i1;
        3'b010 : muxout = i2;
        3'b011 : muxout = i3;
        3'b100 : muxout = i4;
        3'b101 : muxout = i5;
        3'b110 : muxout = i6;
        3'b111 : muxout = i7;
      endcase
    end
  endfunction

  localparam logic [31:0] ILLEGAL = 32'h00000000;

  always_comb begin : register_read_path

    mux_b2_sel  = req_offset_addr[2:0];    // base register mux select
    mux_m2_sel  = req_offset_addr[5:3];    // MDCFG Level 2 mux select
    mux_m3_sel  = req_offset_addr[2:0];    // MDCFG Level 3 mux select
    mux_s2_sel  = req_offset_addr[8:6];    // SRCMD Level 2 mux select
    mux_s3_sel  = req_offset_addr[5:3];    // SRCMD Level 3 mux select
    mux_s4_sel  = req_offset_addr[2:0];    // SRCMD Level 4 mux select
    mux_ea2_sel = req_offset_addr[8:6];    // ENTRY ARRAY Level 2 mux select
    mux_ea3_sel = req_offset_addr[5:3];    // ENTRY ARRAY Level 3 mux select
    mux_ea4_sel = req_offset_addr[2:0];    // ENTRY ARRAY Level 4 mux select

    //****************************************************************************************************
    // Base Registers Muxes
    // The muxes output for BASE REGISTERS are numbered as follows:
    // b20, b21, b22, b23 (b for BASE REGISTERS, 2 for second level muxes, and the 0-3 for the four muxes)
    // 0- INFO REGISTERS
    // 1- PROGRAMMING PROTECTION REGISTERS
    // 2- CONFIGURATION PROTECTION REGISTERS
    // 3- ERROR REPOROTING REGISTERS
    //****************************************************************************************************

    // INFO registers MUX output
    mux_b20_out = muxout (mux_b2_sel, iopmp_reg.info_reg.version, iopmp_reg.info_reg.imp, iopmp_reg.info_reg.hwcfg0, iopmp_reg.info_reg.hwcfg1,
                          iopmp_reg.info_reg.hwcfg2, iopmp_reg.info_reg.entry_offset, iopmp_reg.info_reg.base_addr, ILLEGAL);

    // PROGRAMMING PROTECTION registers MUX output
    mux_b21_out = muxout (mux_b2_sel, ILLEGAL, ILLEGAL, ILLEGAL, ILLEGAL, {iopmp_reg.prog_prot_reg.mdstall.md, iopmp_reg.prog_prot_reg.mdstall.is_busy},
                          iopmp_reg.prog_prot_reg.mdstallh, {iopmp_reg.prog_prot_reg.rridscp.stat, 14'd0, iopmp_reg.prog_prot_reg.rridscp.rrid}, ILLEGAL);

    // CONFIGURATION PROTECTION registers MUX output
    mux_b22_out = muxout (mux_b2_sel, iopmp_reg.config_prot_reg.mdlck, iopmp_reg.config_prot_reg.mdlckh, {25'd0, iopmp_reg.config_prot_reg.mdcfglck},
                          {15'd0, iopmp_reg.config_prot_reg.entrylck}, ILLEGAL, ILLEGAL, ILLEGAL, ILLEGAL);

    // ERROR REPORTING registers MUX output
    mux_b23_out = muxout (mux_b2_sel, {13'd0, iopmp_reg.err_rpt_reg.err_cfg}, {23'd0, iopmp_reg.err_rpt_reg.err_info}, iopmp_reg.err_rpt_reg.err_reqaddr, {14'd0, iopmp_reg.err_rpt_reg.err_reqaddrh},
                          iopmp_reg.err_rpt_reg.err_reqid, err_mfr_rdata, iopmp_reg.err_rpt_reg.err_msiaddr, {12'd0, iopmp_reg.err_rpt_reg.err_msiaddrh});

    //****************************************************************************************************
    // MDCFG Registers Muxes
    // The level 3 muxes output for MDCFG REGISTERS are numbered as follows:
    // m30, m31, ..., m37 (m for MDCFG REGISTERS, 3 for third level muxes, and the 0-7 for the eight muxes)
    //  - [0] maps 0-7 mdcfg registers
    //  - [1] maps 8-15 mdcfg registers
    //  - [2] maps 16-23 mdcfg registers
    //  - [3] maps 24-31 mdcfg registers
    //  - [4] maps 32-39 mdcfg registers
    //  - [5] maps 40-47 mdcfg registers
    //  - [6] maps 48-55 mdcfg registers
    //  - [7] maps 56-62 mdcfg registers and 1 ILLEGAL
    //
    // 16'd0 represent the reserved bits of mdcfg register and is concatenated with mdcfg.t field of each
    // register to get the 32 bit value of register on read
    //****************************************************************************************************
    if (CFG.MDCFG_FMT_0) begin : gen_mdcfg_fmt_0_read_path

      mux_m30_out = muxout (mux_m3_sel, {16'd0, iopmp_reg.mdcfg_table[0].t},  {16'd0, iopmp_reg.mdcfg_table[1].t}, {16'd0, iopmp_reg.mdcfg_table[2].t}, {16'd0, iopmp_reg.mdcfg_table[3].t},
                            {16'd0, iopmp_reg.mdcfg_table[4].t}, {16'd0, iopmp_reg.mdcfg_table[5].t}, {16'd0, iopmp_reg.mdcfg_table[6].t}, {16'd0, iopmp_reg.mdcfg_table[7].t});

      mux_m31_out = muxout (mux_m3_sel, {16'd0, iopmp_reg.mdcfg_table[8].t},  {16'd0, iopmp_reg.mdcfg_table[9].t}, {16'd0, iopmp_reg.mdcfg_table[10].t}, {16'd0, iopmp_reg.mdcfg_table[11].t},
                            {16'd0, iopmp_reg.mdcfg_table[12].t}, {16'd0, iopmp_reg.mdcfg_table[13].t}, {16'd0, iopmp_reg.mdcfg_table[14].t}, {16'd0, iopmp_reg.mdcfg_table[15].t});

      mux_m32_out = muxout (mux_m3_sel, {16'd0, iopmp_reg.mdcfg_table[16].t},  {16'd0, iopmp_reg.mdcfg_table[17].t}, {16'd0, iopmp_reg.mdcfg_table[18].t}, {16'd0, iopmp_reg.mdcfg_table[19].t},
                            {16'd0, iopmp_reg.mdcfg_table[20].t}, {16'd0, iopmp_reg.mdcfg_table[21].t}, {16'd0, iopmp_reg.mdcfg_table[22].t}, {16'd0, iopmp_reg.mdcfg_table[23].t});

      mux_m33_out = muxout (mux_m3_sel, {16'd0, iopmp_reg.mdcfg_table[24].t},  {16'd0, iopmp_reg.mdcfg_table[25].t}, {16'd0, iopmp_reg.mdcfg_table[26].t}, {16'd0, iopmp_reg.mdcfg_table[27].t},
                            {16'd0, iopmp_reg.mdcfg_table[28].t}, {16'd0, iopmp_reg.mdcfg_table[29].t}, {16'd0, iopmp_reg.mdcfg_table[30].t}, {16'd0, iopmp_reg.mdcfg_table[31].t});

      mux_m34_out = muxout (mux_m3_sel, {16'd0, iopmp_reg.mdcfg_table[32].t},  {16'd0, iopmp_reg.mdcfg_table[33].t}, {16'd0, iopmp_reg.mdcfg_table[34].t}, {16'd0, iopmp_reg.mdcfg_table[35].t},
                            {16'd0, iopmp_reg.mdcfg_table[36].t}, {16'd0, iopmp_reg.mdcfg_table[37].t}, {16'd0, iopmp_reg.mdcfg_table[38].t}, {16'd0, iopmp_reg.mdcfg_table[39].t});

      mux_m35_out = muxout (mux_m3_sel, {16'd0, iopmp_reg.mdcfg_table[40].t},  {16'd0, iopmp_reg.mdcfg_table[41].t}, {16'd0, iopmp_reg.mdcfg_table[42].t}, {16'd0, iopmp_reg.mdcfg_table[43].t},
                            {16'd0, iopmp_reg.mdcfg_table[44].t}, {16'd0, iopmp_reg.mdcfg_table[45].t}, {16'd0, iopmp_reg.mdcfg_table[46].t}, {16'd0, iopmp_reg.mdcfg_table[47].t});

      mux_m36_out = muxout (mux_m3_sel, {16'd0, iopmp_reg.mdcfg_table[48].t},  {16'd0, iopmp_reg.mdcfg_table[49].t}, {16'd0, iopmp_reg.mdcfg_table[50].t}, {16'd0, iopmp_reg.mdcfg_table[51].t},
                            {16'd0, iopmp_reg.mdcfg_table[52].t}, {16'd0, iopmp_reg.mdcfg_table[53].t}, {16'd0, iopmp_reg.mdcfg_table[54].t}, {16'd0, iopmp_reg.mdcfg_table[55].t});

      mux_m37_out = muxout (mux_m3_sel, {16'd0, iopmp_reg.mdcfg_table[56].t},  {16'd0, iopmp_reg.mdcfg_table[57].t}, {16'd0, iopmp_reg.mdcfg_table[58].t}, {16'd0, iopmp_reg.mdcfg_table[59].t},
                            {16'd0, iopmp_reg.mdcfg_table[60].t}, {16'd0, iopmp_reg.mdcfg_table[61].t}, {16'd0, iopmp_reg.mdcfg_table[62].t}, ILLEGAL);

      // Level 2 mux output of MDCFG REGISTERS. It selects one out of the 8 muxes at level 3
      mux_m2_out = muxout (mux_m2_sel, mux_m30_out, mux_m31_out, mux_m32_out, mux_m33_out,
                           mux_m34_out, mux_m35_out, mux_m36_out, mux_m37_out);
    end
    else begin : gen_mdcfg_fmt_1_2_read_path
      mux_m2_out = '0;
    end

    if (!CFG.SRCMD_FMT_1) begin : gen_srcmd_fmt_0_2_read_path
      //****************************************************************************************************
      // SRCMD Registers Muxes
      // The level 4 muxes output for SRCMD REGISTERS are numbered as follows:
      // s4[0], s4[1], ..., s4[63] (s for SRCMD REGISTERS, 4 for fourth level muxes,
      // and the 0-63 for the sixty-four muxes)
      //
      // The level 3 muxes output for SRCMD REGISTERS are numbered as follows:
      // s3[0], s3[1], ..., s3[7] (s for SRCMD REGISTERS, 3 for third level muxes,
      // and the 0-7 for the eight muxes)
      //****************************************************************************************************
      if (CFG.SRCMD_FMT_0) begin : gen_srcmd_fmt_0_l4_muxes
        //****************************************************************************************************
        // Level 4 muxes output of SRCMD REGISTERS
        // The level 4 mux selects one of the SRCMD register or ILLEGAL:
        //  - [0] SRCMD_EN
        //  - [1] SRCMD_ENH
        //  - [2] SRCMD_R
        //  - [3] SRCMD_RH
        //  - [4] SRCMD_W
        //  - [5] SRCMD_WH
        //  - [6] ILLEGAL
        //  - [7] ILLEGAL
        //
        // The number of these muxes is given by hwcfg1.rrid_num. The outer loop (with variable j) traverse
        // the eight level 3 mux (each having eight level 4 muxes). The inner loop (with variable i) iterates
        // over the eight level 4 muxes within a level 3 mux
        //****************************************************************************************************
        for (int j = 0; j < 8; j++) begin : srcmd_l4_mux_outer_loop
          for (int i = 0; i < 8; i++) begin : srcmd_l4_mux_inner_loop
            s_l4_index = (j << 3) + i;
            mux_s4_out[s_l4_index] = muxout (mux_s4_sel, iopmp_reg.srcmd_table.srcmd_table_0[s_l4_index].srcmd_en, iopmp_reg.srcmd_table.srcmd_table_0[s_l4_index].srcmd_enh, {iopmp_reg.srcmd_table.srcmd_table_0[s_l4_index].srcmd_r, 1'b0},
                                             iopmp_reg.srcmd_table.srcmd_table_0[s_l4_index].srcmd_rh, {iopmp_reg.srcmd_table.srcmd_table_0[s_l4_index].srcmd_w, 1'b0}, iopmp_reg.srcmd_table.srcmd_table_0[s_l4_index].srcmd_wh, ILLEGAL, ILLEGAL);
          end
        end
      end
      else if (CFG.SRCMD_FMT_2) begin : gen_srcmd_fmt_2_l4_muxes
        //****************************************************************************************************
        // Level 4 muxes output of SRCMD REGISTERS
        // The level 4 mux selects one of the SRCMD register or ILLEGAL:
        //  - [0] SRCMD_PERM
        //  - [1] SRCMD_PERMH
        //  - [2] ILLEGAL
        //  - [3] ILLEGAL
        //  - [4] ILLEGAL
        //  - [5] ILLEGAL
        //  - [6] ILLEGAL
        //  - [7] ILLEGAL
        //
        // The number of these muxes is given by hwcfg1.rrid_num. The outer loop (with variable j) traverse
        // the eight level 3 mux (each having eight level 4 muxes). The inner loop (with variable i) iterates
        // over the eight level 4 muxes within a level 3 mux
        //****************************************************************************************************
        for (int j = 0; j < 8; j++) begin : srcmd_l4_mux_outer_loop
          for (int i = 0; i < 8; i++) begin : srcmd_l4_mux_inner_loop
            s_l4_index = (j << 3) + i;

            // In SRCMD Format 2, the number of srcmd_perm or srcmd_permh registers can't be greater than 63 as maximum supported MDs can be 63
            if (s_l4_index < 63) begin : valid_srcmd_mux
              mux_s4_out[s_l4_index] = muxout (mux_s4_sel, iopmp_reg.srcmd_table.srcmd_table_2[s_l4_index].srcmd_perm, iopmp_reg.srcmd_table.srcmd_table_2[s_l4_index].srcmd_permh,
                                               ILLEGAL, ILLEGAL, ILLEGAL, ILLEGAL, ILLEGAL, ILLEGAL);
            end

            // 63 index of mux_s4_out is assigned 0 to maintain the mux structure in SRCMD Format 2
            else begin : illegal
              mux_s4_out[63] = ILLEGAL;
            end
          end
        end
      end

      //****************************************************************************************************
      // Level 3 muxes output of SRCMD REGISTERS
      // Each level 3 mux maps 8 out of 64 muxes at level 4:
      //  - [0] maps 0-7 level 4 mux
      //  - [1] maps 8-15 level 4 mux
      //  - [2] maps 16-23 level 4 mux
      //  - [3] maps 24-31 level 4 mux
      //  - [4] maps 32-39 level 4 mux
      //  - [5] maps 40-47 level 4 mux
      //  - [6] maps 48-55 level 4 mux
      //  - [7] maps 56-63 level 4 mux
      //
      // The loop iterates over the eight muxes at level 3
      //****************************************************************************************************
      for (int k = 0; k < 8; k++) begin : srcmd_l3_muxes
        s_l3_index = k << 3;
        mux_s3_out[k] = muxout (mux_s3_sel, mux_s4_out[s_l3_index], mux_s4_out[(s_l3_index + 1)], mux_s4_out[(s_l3_index + 2)], mux_s4_out[(s_l3_index + 3)],
                                mux_s4_out[(s_l3_index + 4)], mux_s4_out[(s_l3_index + 5)], mux_s4_out[(s_l3_index + 6)], mux_s4_out[(s_l3_index + 7)]);
      end

      // Level 2 mux output of SRCMD REGISTERS. It selects one out of the 8 muxes at level 3
      mux_s2_out = muxout(mux_s2_sel, mux_s3_out[0], mux_s3_out[1], mux_s3_out[2], mux_s3_out[3],
                          mux_s3_out[4], mux_s3_out[5], mux_s3_out[6], mux_s3_out[7]);
    end
    else begin : gen_srcmd_fmt_1_read_path
      mux_s2_out = '0;
    end

    //****************************************************************************************************
    // ENTRY ARRAY Registers Muxes
    // The level 4 muxes output for ENTRY ARRAY REGISTERS are numbered as follows:
    // ea4[0], ea4[1], ..., ea4[63] (ea for ENTRY ARRAY REGISTERS, 4 for fourth level muxes,
    // and the 0-63 for the sixty-four muxes)
    //
    // The level 3 muxes output for ENTRY ARRAY REGISTERS are numbered as follows:
    // ea3[0], ea3[1], ..., ea3[7] (ea for ENTRY ARRAY REGISTERS, 3 for third level muxes,
    // and the 0-7 for the eight muxes)
    //****************************************************************************************************

    //****************************************************************************************************
    // Level 4 muxes output of ENTRY ARRAY REGISTERS
    // The level 4 mux selects one of the ENTRY ARRAY register or ILLEGAL:
    //  - [0] ENTRY_ADDR
    //  - [1] ENTRY_ADDRH
    //  - [2] ENTRY_CFG
    //  - [3] ILLEGAL
    //  - [4] ENTRY_ADDR
    //  - [5] ENTRY_ADDRH
    //  - [6] ENTRY_CFG
    //  - [7] ILLEGAL
    //
    // The number of these muxes is given by hwcfg1.entry_num/2. The outer loop (with variable j) traverse
    // the eight level 3 mux (each having eight level 4 muxes). The inner loop (with variable i) iterates
    // over the eight level 4 muxes within a level 3 mux
    //****************************************************************************************************
    for (int j = 0; j < 8; j++) begin : entry_array_l4_mux_outer_loop
      for (int i = 0; i < 8; i++) begin : entry_array_l4_mux_inner_loop
        ea_l4_index = (i << 1) + (j << 4);
        mux_ea4_out[((j << 3) + i)] = muxout (mux_ea4_sel, iopmp_reg.entry_array[ea_l4_index].entry_addr, {14'd0, iopmp_reg.entry_array[ea_l4_index].entry_addrh}, {21'd0, iopmp_reg.entry_array[ea_l4_index].entry_cfg}, ILLEGAL,
                                              iopmp_reg.entry_array[ea_l4_index+1].entry_addr, {14'd0, iopmp_reg.entry_array[ea_l4_index+1].entry_addrh}, {21'd0, iopmp_reg.entry_array[ea_l4_index+1].entry_cfg}, ILLEGAL);
      end
    end

    //****************************************************************************************************
    // Level 3 muxes output of ENTRY ARRAY REGISTERS
    // Each level 3 mux maps 8 out of 64 muxes at level 4:
    //  - [0] maps 0-7 level 4 mux
    //  - [1] maps 8-15 level 4 mux
    //  - [2] maps 16-23 level 4 mux
    //  - [3] maps 24-31 level 4 mux
    //  - [4] maps 32-39 level 4 mux
    //  - [5] maps 40-47 level 4 mux
    //  - [6] maps 48-55 level 4 mux
    //  - [7] maps 56-63 level 4 mux
    //
    // The loop iterates over the eight muxes at level 3
    //****************************************************************************************************
    for (int k = 0; k < 8; k++) begin : entry_array_l3_muxes
      ea_l3_index = k << 3;
      mux_ea3_out[k] = muxout (mux_ea3_sel, mux_ea4_out[ea_l3_index], mux_ea4_out[(ea_l3_index + 1)], mux_ea4_out[(ea_l3_index + 2)], mux_ea4_out[(ea_l3_index + 3)],
                               mux_ea4_out[(ea_l3_index + 4)], mux_ea4_out[(ea_l3_index + 5)], mux_ea4_out[(ea_l3_index + 6)], mux_ea4_out[(ea_l3_index + 7)]);
    end

    // Level 2 mux output of ENTRY ARRAY REGISTERS. It selects one out of the 8 muxes at level 3
    mux_ea2_out = muxout(mux_ea2_sel, mux_ea3_out[0], mux_ea3_out[1], mux_ea3_out[2], mux_ea3_out[3],
                        mux_ea3_out[4], mux_ea3_out[5], mux_ea3_out[6], mux_ea3_out[7]);

    //****************************************************************************************************
    // Level 1 Mux Select Generation
    // Drive the appropriate value of l1_mux_sel signal based on result of Adress Check
    //****************************************************************************************************

    // Check if incoming request address is legal or not. If legal, drive legal value of mux select signals for level 1
    if (is_addr_legal) begin

      l1_mux_sel = 3'b000;

      // Check if address points to a base register. If it does, drive the appropriate mux select signal
      if (base_reg_legal) begin

        // Based on the address bits [6:5] the value of l1_mux_sel can be:
        // - 3'b000: Select INFO Register
        // - 3'b001: Select PROGRAMMING PROTECTION Register
        // - 3'b010: Select CONFIGURATION PROTECTION Register
        // - 3'b011: Select ERROR REPOTING Register
        l1_mux_sel = {1'b0,req_offset_addr[4:3]};
      end

      // Check if address points to an MDCFG register. If the check passes, drive the corresponding mux select signal
      if (mdcfg_legal) begin
        l1_mux_sel = 3'b100;    // Select MDCFG Register
      end

      // Check if address legal in SRCMD region. If it does, drive the related mux select signals
      if (srcmd_legal) begin
        l1_mux_sel = 3'b101;    // Select SRCMD Register
      end

      // Check if address legal in ENTRY ARRAY. If the check passes, drive the corresponding mux select signals
      if (entry_array_legal) begin
        l1_mux_sel = 3'b110;    // Select ENTRY ARRAY Register
      end
    end

    // The address is not legal
    else begin
      l1_mux_sel = 3'b111;      // Select ILLEGAL value
    end

    //****************************************************************************************************
    // Level 1 Mux Output
    // Top-level mux selects one of the 7 register blocks or an ILLEGAL:
    //  - [0]-[3] BASE REGISTERS (0- INFO REGISTERS
    //                            1- PROGRAMMING PROTECTION REGISTERS
    //                            2- CONFIGURATION PROTECTION REGISTERS
    //                            3- ERROR REPOROTING REGISTERS)
    //  - [4] MDCFG REGISTERS
    //  - [5] SRCMD REGISTERS
    //  - [6] ENTRY_ARRAY REGISTERS
    //  - [7] ILLEGAL
    //****************************************************************************************************
    ahb_hrdata = muxout(l1_mux_sel, mux_b20_out, mux_b21_out, mux_b22_out, mux_b23_out,
                        mux_m2_out, mux_s2_out, mux_ea2_out, ILLEGAL);

  end

endmodule
