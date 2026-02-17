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

module entry_array_regs
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;
  import rfm_pkg::entry_array_t;
  import rfm_pkg::IOPMP_ENTRY_ADDR_0;
  import rfm_pkg::IOPMP_ENTRY_ADDRH_0;
  import rfm_pkg::IOPMP_ENTRY_CFG_0;
  import rfm_pkg::IOPMP_ENTRY_ADDR_1;
  import rfm_pkg::IOPMP_ENTRY_ADDRH_1;
  import rfm_pkg::IOPMP_ENTRY_CFG_1;
#(
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                           clk,                           // Clock Rising Edge
  input  logic                           rst_n,                         // Reset Active Low

  // AHB-LITE Interface ==> ENTRY ARRAY Registers
  input  logic [5:0]                     entry_array_selected_demux,    // ENTRY ARRAY demux to select
  input  logic [2:0]                     entry_array_reg_demux_sel,     // ENTRY ARRAY register level 4 mux select signal
  input  logic [AHB_LITE_DATA_WIDTH-1:0] entry_array_reg_swdata,        // Write data for ENTRY ARRAY registers

  // Address Check ==> Regmap
  input  logic                           entry_array_legal,             // Indicates whether incoming address is legal or not in entry array

  // Regmap ==> ENTRY ARRAY Registers
  input  logic                           entry_array_reg_write_valid,   // Write valid signal for ENTRY ARRAY register

  // Base Registers ==> ENTRY ARRAY Registers
  input  logic [7:0]                     entrylck_f,                    // Indicates the number of locked entry array registers

  // ENTRY ARRAY Registers ==> Regmap
  output entry_array_t [127:0]           entry_array,                   // ENTRY ARRAY Registers
  output logic [CFG.ENTRY_NUM-1:0][5:0]  napot_size,                    // Calculated value of NAPOT size per entry based on 64 bit entry address
  output logic [CFG.ENTRY_NUM-1:0]       valid_range_vec                // Each bit indicates that the entry address is greater than the previous entry address (applicable for TOR address mode)
);

  localparam ENTRY_NUM_BY_16  = (int'(CFG.ENTRY_NUM) + 15)/16;

  //###############################
  // Internal Signals Declarations
  //###############################

  logic                               is_entry_array_reg_locked, is_write_allowed;
  logic [ENTRY_NUM_BY_16-1:0]         entry_array_reg_write_valid_q, entry_array_legal_q;
  logic [ENTRY_NUM_BY_16-1:0][2:0]    entry_array_reg_demux_sel_q;
  logic [ENTRY_NUM_BY_16-1:0][5:0]    entry_array_selected_demux_q;
  logic [((CFG.ENTRY_NUM + 1)/2)-1:0] entry_array_demux_enable;
  logic [AHB_LITE_DATA_WIDTH-1:0]     entry_addr_0_swdata_q, entry_addr_1_swdata_q;
  logic [17:0]                        entry_addrh_0_swdata_q, entry_addrh_1_swdata_q;
  logic [7:0]                         entry_cfg_0_swdata_q, entry_cfg_1_swdata_q;
  logic [AXI_ADDR_WIDTH-3:0]          curr_entry_address;   // Complete 52 bit address of the current entry
  logic [AXI_ADDR_WIDTH-3:0]          prev_entry_address;   // Complete 52 bit address of the previous entry
  logic                               is_valid_addr_range;  // Indicates if previous entry address is less than current entry address
  logic [5:0]                         trail_zeros;          // Count Trailing zeros in entry address
  int                                 entry_array_reg_index;

  // Registers/Fields SW write enable and write data signals
  logic [CFG.ENTRY_NUM-1:0][31:0] entry_addr_swdata;
  logic [CFG.ENTRY_NUM-1:0]       entry_addr_swen;
  logic [CFG.ENTRY_NUM-1:0][17:0] entry_addrh_swdata;
  logic [CFG.ENTRY_NUM-1:0]       entry_addrh_swen;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_r_swdata;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_r_swen;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_w_swdata;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_w_swen;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_x_swdata;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_x_swen;
  logic [CFG.ENTRY_NUM-1:0][1:0]  entry_cfg_a_swdata;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_a_swen;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_sire_swdata;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_sire_swen;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_siwe_swdata;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_siwe_swen;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_sixe_swdata;
  logic [CFG.ENTRY_NUM-1:0]       entry_cfg_sixe_swen;
  logic [CFG.ENTRY_NUM-1:0]       napot_size_swen_n, napot_size_swen_q;
  logic [CFG.ENTRY_NUM-1:0][5:0]  napot_size_swdata;

  //****************************************************************************************************
  // Generate DEMUX enable signals
  //****************************************************************************************************
  generate

    // The outer loop divides the number of ENTRY ARRAY demuxes into a block of 8 demuxes as 1 flop of entry_array_selected_demux_q and
    // entry_array_legal_q should not drive more than 8 demuxes enable signal
    for (genvar j = 0; j < ENTRY_NUM_BY_16; j++) begin : gen_demux_enable_outer_loop

      // The inner loop generates 8 demux enable signal based on entry_array_selected_demux_q and entry_array_legal_q
      for (genvar i = 0; i < 8; i++) begin : gen_demux_enable_inner_loop

        // Each demux maps 2 ENTRY ARRAY register block (containing ENTRY_ADDR, ENTRY_ADDRH, ENTRY_CFG), so the j (outer loop variable)
        // is multiplied by 16 and i (inner loop variable) is multiplied by 2 and the result is added together to get the entry array block index
        // ENTRY_NUM indicates the supported number of ENTRY ARRAY registers so ((i << 1) + (j << 4)) should always be less than ENTRY NUM
        if (((i << 1) + (j << 4)) < int'(CFG.ENTRY_NUM)) begin : valid_entry

          // Determine the entry array demux to select based on entry_array_selected_demux_q (address bit [10:5]) signal and qualify it with
          // entry_array_legal_q signal to generate demux enable signals
          assign entry_array_demux_enable[((j << 3) + i)] = entry_array_legal_q[j] && (entry_array_selected_demux_q[j][2:0] == i) && (entry_array_selected_demux_q[j][5:3] == j);
        end
      end
    end
  endgenerate

  //****************************************************************************************************
  // DEMUX for Registers/Fields SW Write Enable Signals
  //****************************************************************************************************
  always_comb begin : entry_array_write_path

    // The outer loop divides the number of ENTRY ARRAY demuxes into a block of 8 demuxes as 1 write valid signal should drive not more than 64 registers
    for (int j = 0; j < ENTRY_NUM_BY_16; j++) begin : gen_write_outer_loop

      // The inner loop generates 16 instances of ENTRY ARRAY register block (containing ENTRY_ADDR, ENTRY_ADDRH, ENTRY_CFG)
      // (2 blocks per demux) sw write enable signals per demux
      for (int i = 0; i < 8; i++) begin : gen_write_inner_loop

        // Each demux maps 2 ENTRY ARRAY register block (containing ENTRY_ADDR, ENTRY_ADDRH, ENTRY_CFG), so the j (outer loop variable) is
        // multiplied by 16 and i (inner loop variable) is multiplied by 2 and the result is added together to get the entry array block index
        entry_array_reg_index = ((i << 1) + (j << 4));

        // Check if ENTRY ARRAY register block exist for entry_array_reg_index and then generate its SW write valid signal.
        // ENTRY_NUM indicates the supported number of ENTRY ARRAY registers so entry_array_reg_index should always be less than ENTRY NUM
        if (entry_array_reg_index < int'(CFG.ENTRY_NUM)) begin : gen_valid_entry_regs_write

          // Determine whether the register is locked or not based on entrylck.f.
          // ENTRY_ADDR(i), ENTRY_ADDRH(i) or ENTRY_CFG(i) are locked for i < entrylck.f.
          is_entry_array_reg_locked = (({5'd0, entry_array_reg_demux_sel_q[j]} >> 2) + ({5'd0, entry_array_selected_demux_q[j][2:0]} << 1) + ({5'd0, entry_array_selected_demux_q[j][5:3]} << 4)) < entrylck_f;

          // Allow register to write only if it is not locked
          is_write_allowed = (!is_entry_array_reg_locked) && entry_array_reg_write_valid_q[j];

          // The signal entry_array_demux_enable act as an enable signal to ENTRY ARRAY demux
          // When high it indicates demux is enabled and determine the ENTRY ARRAY register/fields to write based on entry_array_reg_demux_sel_q signal
          if (entry_array_demux_enable[((j << 3) + i)]) begin : write_demux_enable

            // Drive the SW write enable signals of ENTRY ARRAY registers/fields indexed by entry_array_reg_index low before matching any case
            // The case statement only handles the SW write enable signal for the particular register/fields it matches
            entry_addr_swen[entry_array_reg_index]       = 1'b0;
            entry_addrh_swen[entry_array_reg_index]      = 1'b0;
            entry_cfg_r_swen[entry_array_reg_index]      = 1'b0;
            entry_cfg_w_swen[entry_array_reg_index]      = 1'b0;
            entry_cfg_x_swen[entry_array_reg_index]      = 1'b0;
            entry_cfg_a_swen[entry_array_reg_index]      = 1'b0;
            entry_cfg_sire_swen[entry_array_reg_index]   = 1'b0;
            entry_cfg_siwe_swen[entry_array_reg_index]   = 1'b0;
            entry_cfg_sixe_swen[entry_array_reg_index]   = 1'b0;

            if ((entry_array_reg_index + 1) < int'(CFG.ENTRY_NUM)) begin : assign_zero_if_exist
              entry_addr_swen[entry_array_reg_index+1]     = 1'b0;
              entry_addrh_swen[entry_array_reg_index+1]    = 1'b0;
              entry_cfg_r_swen[entry_array_reg_index+1]    = 1'b0;
              entry_cfg_w_swen[entry_array_reg_index+1]    = 1'b0;
              entry_cfg_x_swen[entry_array_reg_index+1]    = 1'b0;
              entry_cfg_a_swen[entry_array_reg_index+1]    = 1'b0;
              entry_cfg_sire_swen[entry_array_reg_index+1] = 1'b0;
              entry_cfg_siwe_swen[entry_array_reg_index+1] = 1'b0;
              entry_cfg_sixe_swen[entry_array_reg_index+1] = 1'b0;
            end

            // Determine the register/fields to write based on corrpsonding entry_array_reg_demux_sel_q (address bit [4:2])
            unique case (entry_array_reg_demux_sel_q[j])

              IOPMP_ENTRY_ADDR_0: begin

                // ENTRY_ADDR(i) is locked for i < entrylck.f.
                entry_addr_swen[entry_array_reg_index] = is_write_allowed;
              end

              IOPMP_ENTRY_ADDRH_0: if (CFG.ADDRH_EN) begin : gen_entry_addrh_0_write

                // ENTRY_ADDRH(i) is locked for i < entrylck.f.
                entry_addrh_swen[entry_array_reg_index] = is_write_allowed;
              end

              IOPMP_ENTRY_CFG_0: begin

                // ENTRY_CFG(i) is locked for i < entrylck.f.
                entry_cfg_r_swen[entry_array_reg_index]    = is_write_allowed;
                entry_cfg_w_swen[entry_array_reg_index]    = is_write_allowed;
                entry_cfg_x_swen[entry_array_reg_index]    = is_write_allowed;
                entry_cfg_a_swen[entry_array_reg_index]    = is_write_allowed;
                entry_cfg_sire_swen[entry_array_reg_index] = CFG.PEIS && is_write_allowed;
                entry_cfg_siwe_swen[entry_array_reg_index] = CFG.PEIS && is_write_allowed;
                entry_cfg_sixe_swen[entry_array_reg_index] = CFG.PEIS && is_write_allowed;
              end

              IOPMP_ENTRY_ADDR_1: if ((entry_array_reg_index + 1) < int'(CFG.ENTRY_NUM)) begin : gen_valid_entry_addr_write

                // ENTRY_ADDR(i) is locked for i < entrylck.f.
                entry_addr_swen[(entry_array_reg_index + 1)] = is_write_allowed;
              end

              IOPMP_ENTRY_ADDRH_1: if (((entry_array_reg_index + 1) < int'(CFG.ENTRY_NUM)) && CFG.ADDRH_EN) begin : gen_entry_addrh_1_write

                // ENTRY_ADDRH(i) is locked for i < entrylck.f.
                entry_addrh_swen[(entry_array_reg_index + 1)] = is_write_allowed;
              end

              IOPMP_ENTRY_CFG_1: if ((entry_array_reg_index + 1) < int'(CFG.ENTRY_NUM)) begin : gen_valid_entry_cfg_write

                // ENTRY_CFG(i) is locked for i < entrylck.f.
                entry_cfg_r_swen[(entry_array_reg_index + 1)]    = is_write_allowed;
                entry_cfg_w_swen[(entry_array_reg_index + 1)]    = is_write_allowed;
                entry_cfg_x_swen[(entry_array_reg_index + 1)]    = is_write_allowed;
                entry_cfg_a_swen[(entry_array_reg_index + 1)]    = is_write_allowed;
                entry_cfg_sire_swen[(entry_array_reg_index + 1)] = CFG.PEIS && is_write_allowed;
                entry_cfg_siwe_swen[(entry_array_reg_index + 1)] = CFG.PEIS && is_write_allowed;
                entry_cfg_sixe_swen[(entry_array_reg_index + 1)] = CFG.PEIS && is_write_allowed;
              end
              default: ;
            endcase
          end

          // Drive SW write enable signals zero when demux is not enabled
          else begin : write_demux_disable
            entry_addr_swen[entry_array_reg_index]       = 1'b0;
            entry_addrh_swen[entry_array_reg_index]      = 1'b0;
            entry_cfg_r_swen[entry_array_reg_index]      = 1'b0;
            entry_cfg_w_swen[entry_array_reg_index]      = 1'b0;
            entry_cfg_x_swen[entry_array_reg_index]      = 1'b0;
            entry_cfg_a_swen[entry_array_reg_index]      = 1'b0;
            entry_cfg_sire_swen[entry_array_reg_index]   = 1'b0;
            entry_cfg_siwe_swen[entry_array_reg_index]   = 1'b0;
            entry_cfg_sixe_swen[entry_array_reg_index]   = 1'b0;

            if ((entry_array_reg_index + 1) < int'(CFG.ENTRY_NUM)) begin : drive_zero_if_exist
              entry_addr_swen[entry_array_reg_index+1]     = 1'b0;
              entry_addrh_swen[entry_array_reg_index+1]    = 1'b0;
              entry_cfg_r_swen[entry_array_reg_index+1]    = 1'b0;
              entry_cfg_w_swen[entry_array_reg_index+1]    = 1'b0;
              entry_cfg_x_swen[entry_array_reg_index+1]    = 1'b0;
              entry_cfg_a_swen[entry_array_reg_index+1]    = 1'b0;
              entry_cfg_sire_swen[entry_array_reg_index+1] = 1'b0;
              entry_cfg_siwe_swen[entry_array_reg_index+1] = 1'b0;
              entry_cfg_sixe_swen[entry_array_reg_index+1] = 1'b0;
            end
          end
        end
      end
    end
  end

  //****************************************************************************************************
  // Calculate NAPOT size and valid address range vector
  //****************************************************************************************************
  always_comb begin : gen_napot_size_valid_range_vect

    curr_entry_address = '0;      // Default current entry address (that is being written)

    // Previous entry address will be determined if the address mode TOR is supported
    if (CFG.TOR_EN) begin : gen_prev_entry_addr_0
      prev_entry_address = '0;    // Default previous entry address
    end

    // Keep record of which entry address is written
    napot_size_swen_n = entry_addr_swen | entry_addrh_swen;

    // Iterate over all entries to find which entry_addr or entry_addrh register is written and extract the complete current entry address (that is written) and the previous entry address
    for (int reg_index = 0; reg_index < int'(CFG.ENTRY_NUM); reg_index++) begin : gen_entry_address
      curr_entry_address |= {(AXI_ADDR_WIDTH-2){napot_size_swen_q[reg_index]}} &
                            {entry_array[reg_index].entry_addrh.addrh, entry_array[reg_index].entry_addr.addr};

      // Previous entry address will be determined if the address mode TOR is supported
      if (CFG.TOR_EN) begin : gen_prev_entry_addr
        prev_entry_address |= (reg_index == 0) ? '0 : {(AXI_ADDR_WIDTH-2){napot_size_swen_q[reg_index]}} &
                                                      {entry_array[reg_index-1].entry_addrh.addrh, entry_array[reg_index-1].entry_addr.addr};
      end
    end

    if (CFG.TOR_EN) begin : gen_is_valid_addr_range
      // If TOR is selected, the associated entry address registers forms the top of the address range, and the
      // preceding entry address register forms the bottom of the address range. If entry_cfg(i).a field is set
      // to TOR, the entry matches any address y such that entry_address(i-1) <= y < entry_address(i)
      is_valid_addr_range = prev_entry_address < curr_entry_address;
    end
  end

  //****************************************************************************************************
  // LZC block calculates the number of trailing zeros in the current entry address
  //****************************************************************************************************
  iopmp_lzc #(
    .WIDTH (AXI_ADDR_WIDTH-2),
    .MODE  (0)
  ) iopmp_lzc
  (
    .in_i    (~{curr_entry_address[AXI_ADDR_WIDTH-4:0],1'b1}),
    .cnt_o   (trail_zeros)
  );

  //****************************************************************************************************
  // Registers/Fields SW Write Data Signals
  //****************************************************************************************************
  for (genvar ea_reg_index = 0; ea_reg_index < ((int'(CFG.ENTRY_NUM) + 1)/2); ea_reg_index++) begin : gen_entry_array_swdata_0

    // ENTRY_ADDR(i) SW Write Data Signals
    assign entry_addr_swdata[ea_reg_index] = entry_addr_0_swdata_q;

    // ENTRY_ADDRH(i) SW Write Data Signals
    assign entry_addrh_swdata[ea_reg_index] = entry_addrh_0_swdata_q;

    // ENTRY_CFG(i) SW Write Data Signals
    assign entry_cfg_r_swdata[ea_reg_index] = entry_cfg_0_swdata_q[0];
    assign entry_cfg_w_swdata[ea_reg_index] = entry_cfg_0_swdata_q[1];
    assign entry_cfg_x_swdata[ea_reg_index] = entry_cfg_0_swdata_q[2];

    if (CFG.TOR_EN) begin
      assign entry_cfg_a_swdata[ea_reg_index] = entry_cfg_0_swdata_q[4:3];
    end
    else begin
      assign entry_cfg_a_swdata[ea_reg_index] = ((entry_cfg_0_swdata_q[4:3] != rfm_pkg::IOPMP_TOR) ?    // When TOR_EN is 0, the data 2'b01 becomes illegal
                                                entry_cfg_0_swdata_q[4:3] :               // Write new data
                                                entry_array[ea_reg_index].entry_cfg.a);   // Retain the old data when new data is 2'b01
    end

    assign entry_cfg_sire_swdata[ea_reg_index] = entry_cfg_0_swdata_q[5];
    assign entry_cfg_siwe_swdata[ea_reg_index] = entry_cfg_0_swdata_q[6];
    assign entry_cfg_sixe_swdata[ea_reg_index] = entry_cfg_0_swdata_q[7];

    assign napot_size_swdata[ea_reg_index] = trail_zeros;
  end

  for (genvar ea_reg_index = ((int'(CFG.ENTRY_NUM) + 1)/2); ea_reg_index < int'(CFG.ENTRY_NUM); ea_reg_index++) begin : gen_entry_array_swdata_1

    // ENTRY_ADDR(i) SW Write Data Signals
    assign entry_addr_swdata[ea_reg_index] = entry_addr_1_swdata_q;

    // ENTRY_ADDRH(i) SW Write Data Signals
    assign entry_addrh_swdata[ea_reg_index] = entry_addrh_1_swdata_q;

    // ENTRY_CFG(i) SW Write Data Signals
    assign entry_cfg_r_swdata[ea_reg_index] = entry_cfg_1_swdata_q[0];
    assign entry_cfg_w_swdata[ea_reg_index] = entry_cfg_1_swdata_q[1];
    assign entry_cfg_x_swdata[ea_reg_index] = entry_cfg_1_swdata_q[2];

    if (CFG.TOR_EN) begin
      assign entry_cfg_a_swdata[ea_reg_index] = entry_cfg_1_swdata_q[4:3];
    end
    else begin
      assign entry_cfg_a_swdata[ea_reg_index] = ((entry_cfg_1_swdata_q[4:3] != rfm_pkg::IOPMP_TOR) ?    // When TOR_EN is 0, the data 2'b01 becomes illegal
                                                entry_cfg_1_swdata_q[4:3] :               // Write new data
                                                entry_array[ea_reg_index].entry_cfg.a);   // Retain the old data when new data is 2'b01
    end

    assign entry_cfg_sire_swdata[ea_reg_index] = entry_cfg_1_swdata_q[5];
    assign entry_cfg_siwe_swdata[ea_reg_index] = entry_cfg_1_swdata_q[6];
    assign entry_cfg_sixe_swdata[ea_reg_index] = entry_cfg_1_swdata_q[7];

    assign napot_size_swdata[ea_reg_index] = trail_zeros;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      entry_array_reg_write_valid_q <= '0;
      entry_addr_0_swdata_q         <= '0;
      entry_addr_1_swdata_q         <= '0;
      entry_addrh_0_swdata_q        <= '0;
      entry_addrh_1_swdata_q        <= '0;
      entry_cfg_0_swdata_q          <= '0;
      entry_cfg_1_swdata_q          <= '0;
      entry_array_reg_demux_sel_q   <= '0;
      entry_array_selected_demux_q  <= '0;
      entry_array_legal_q           <= '0;
      napot_size_swen_q             <= '0;
    end
    else begin
      entry_array_reg_write_valid_q <= {ENTRY_NUM_BY_16{entry_array_reg_write_valid}};
      entry_addr_0_swdata_q         <= entry_array_reg_swdata;
      entry_addr_1_swdata_q         <= entry_array_reg_swdata;
      entry_addrh_0_swdata_q        <= entry_array_reg_swdata[17:0];
      entry_addrh_1_swdata_q        <= entry_array_reg_swdata[17:0];
      entry_cfg_0_swdata_q          <= entry_array_reg_swdata[7:0];
      entry_cfg_1_swdata_q          <= entry_array_reg_swdata[7:0];
      entry_array_reg_demux_sel_q   <= {ENTRY_NUM_BY_16{entry_array_reg_demux_sel}};
      entry_array_selected_demux_q  <= {ENTRY_NUM_BY_16{entry_array_selected_demux}};
      entry_array_legal_q           <= {ENTRY_NUM_BY_16{entry_array_legal}};
      napot_size_swen_q             <= napot_size_swen_n;
    end
  end

  //****************************************************************************************************
  // ENTRY ARRAY REGISTERS
  //****************************************************************************************************
  generate

    // Generate ENTRY ARRAY registers based on ENTRY_NUM
    for (genvar curr_index = 0; curr_index < int'(CFG.ENTRY_NUM); curr_index++) begin : gen_entry_array_reg

      // ########### ENTRY_ADDR ###########
      regfield #(
        .DW      (32),
        .SWACCESS("RW"),
        .RESVAL  ('0)
      ) u_entry_addr
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (entry_addr_swen[curr_index]),
        .swdata  (entry_addr_swdata[curr_index]),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (entry_array[curr_index].entry_addr.addr)
      );

      // ENTRY_ADDRH registers will be generated if ADDRH_EN is 1
      if (CFG.ADDRH_EN) begin : gen_entry_addrh_reg

        // ########### ENTRY_ADDRH ###########
        regfield #(
          .DW      (18),
          .SWACCESS("RW"),
          .RESVAL  ('0)
        ) u_entry_addrh
        (
          .clk     (clk),
          .rst_n   (rst_n),

          .swen    (entry_addrh_swen[curr_index]),
          .swdata  (entry_addrh_swdata[curr_index]),

          .hwen    (1'b0),
          .hwdata  ('0),

          .hwrdata (entry_array[curr_index].entry_addrh.addrh)
        );
      end
      else begin : gen_entry_addrh_reg_hardwired_zeros
        assign entry_array[curr_index].entry_addrh.addrh = '0;
      end

      // ########### ENTRY_CFG ###########
      regfield #(
        .DW      (1),
        .SWACCESS("RW"),
        .RESVAL  (1'b0)
      ) u_entry_cfg_r
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (entry_cfg_r_swen[curr_index]),
        .swdata  (entry_cfg_r_swdata[curr_index]),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (entry_array[curr_index].entry_cfg.r)
      );

      regfield #(
        .DW      (1),
        .SWACCESS("RW"),
        .RESVAL  (1'b0)
      ) u_entry_cfg_w
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (entry_cfg_w_swen[curr_index]),
        .swdata  (entry_cfg_w_swdata[curr_index]),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (entry_array[curr_index].entry_cfg.w)
      );

      regfield #(
        .DW      (1),
        .SWACCESS("RW"),
        .RESVAL  (1'b0)
      ) u_entry_cfg_x
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (entry_cfg_x_swen[curr_index]),
        .swdata  (entry_cfg_x_swdata[curr_index]),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (entry_array[curr_index].entry_cfg.x)
      );

      regfield #(
        .DW      (2),
        .SWACCESS("RW"),
        .RESVAL  ('0)
      ) u_entry_cfg_a
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (entry_cfg_a_swen[curr_index]),
        .swdata  (entry_cfg_a_swdata[curr_index]),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (entry_array[curr_index].entry_cfg.a)
      );

      if (CFG.PEIS) begin : gen_intrpt_supp_bits
        regfield #(
          .DW      (1),
          .SWACCESS("RW"),
          .RESVAL  (1'b0)
        ) u_entry_cfg_sire
        (
          .clk     (clk),
          .rst_n   (rst_n),

          .swen    (entry_cfg_sire_swen[curr_index]),
          .swdata  (entry_cfg_sire_swdata[curr_index]),

          .hwen    (1'b0),
          .hwdata  ('0),

          .hwrdata (entry_array[curr_index].entry_cfg.sire)
        );

        regfield #(
          .DW      (1),
          .SWACCESS("RW"),
          .RESVAL  (1'b0)
        ) u_entry_cfg_siwe
        (
          .clk     (clk),
          .rst_n   (rst_n),

          .swen    (entry_cfg_siwe_swen[curr_index]),
          .swdata  (entry_cfg_siwe_swdata[curr_index]),

          .hwen    (1'b0),
          .hwdata  ('0),

          .hwrdata (entry_array[curr_index].entry_cfg.siwe)
        );

        regfield #(
          .DW      (1),
          .SWACCESS("RW"),
          .RESVAL  (1'b0)
        ) u_entry_cfg_sixe
        (
          .clk     (clk),
          .rst_n   (rst_n),

          .swen    (entry_cfg_sixe_swen[curr_index]),
          .swdata  (entry_cfg_sixe_swdata[curr_index]),

          .hwen    (1'b0),
          .hwdata  ('0),

          .hwrdata (entry_array[curr_index].entry_cfg.sixe)
        );
      end
      else begin : gen_intrpt_supp_bits_hardwired_zeros
        assign entry_array[curr_index].entry_cfg.sire = 1'b0;
        assign entry_array[curr_index].entry_cfg.siwe = 1'b0;
        assign entry_array[curr_index].entry_cfg.sixe = 1'b0;
      end

      assign entry_array[curr_index].entry_cfg.sere = 1'b0;
      assign entry_array[curr_index].entry_cfg.sewe = 1'b0;
      assign entry_array[curr_index].entry_cfg.sexe = 1'b0;

      // ########### NAPOT_SIZE ###########
      regfield #(
        .DW      ($clog2(AXI_ADDR_WIDTH)),
        .SWACCESS("RW"),
        .RESVAL  ('0)
      ) u_napot_size
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (napot_size_swen_q[curr_index]),
        .swdata  (napot_size_swdata[curr_index]),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (napot_size[curr_index])
      );

      if (CFG.TOR_EN) begin : gen_valid_range_vec

        // ########### VALID_RANGE_VECTOR ###########
        regfield #(
          .DW      (1),
          .SWACCESS("RW"),
          .RESVAL  ('0)
        ) u_valid_range_vec
        (
          .clk     (clk),
          .rst_n   (rst_n),

          .swen    (napot_size_swen_q[curr_index]),
          .swdata  (is_valid_addr_range),

          .hwen    (1'b0),
          .hwdata  ('0),

          .hwrdata (valid_range_vec[curr_index])
        );
      end
      else begin : gen_valid_range_vec_hardwired_zero
        assign valid_range_vec[curr_index] = 1'b0;
      end
    end

    for (genvar curr_index = int'(CFG.ENTRY_NUM); curr_index < int'(128); curr_index++) begin : gen_entry_array_regs_hardwired_zeros
      assign entry_array[curr_index].entry_addr.addr   = '0;
      assign entry_array[curr_index].entry_addrh.addrh = '0;
      assign entry_array[curr_index].entry_cfg         = '0;
    end
  endgenerate

endmodule
