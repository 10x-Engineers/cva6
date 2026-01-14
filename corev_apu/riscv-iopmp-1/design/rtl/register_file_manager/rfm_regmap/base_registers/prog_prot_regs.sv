///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 20-June-2025
/// Description:
///////////////////////////////////////////////////////////////////////////

module prog_prot_regs
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import rfm_pkg::change_state_e;
  import rfm_pkg::srcmd_table_0_t;
  import rfm_pkg::prog_prot_reg_t;
  import rfm_pkg::IOPMP_MDSTALL;
  import rfm_pkg::IOPMP_MDSTALLH;
  import rfm_pkg::IOPMP_RRIDSCP;
  import rfm_pkg::NONE;
  import rfm_pkg::FORWARD;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default,

  // Inidcates the implementation status of an MD (1 bit per MD) based on read-only field hwcfg0.md_num
  parameter logic [62:0] MD_NUM_MASK = 0
) (
  input  logic                              clk,                          // Clock Rising Edge
  input  logic                              rst_n,                        // Reset Active Low

  // Address Check ==> PROGRAMMING PROTECTION Registers
  input  logic                              prog_prot_legal,              // Indicates whether incoming address belongs to a legal PROGRAMMING PROTECTION register

  // Base Registers ==> PROGRAMMING PROTECTION Registers
  input  logic [2:0]                        prog_prot_reg_demux_sel,      // PROGRAMMING PROTECTION register write path demux select signal
  input  logic                              prog_prot_reg_write_valid,    // PROGRAMMING PROTECTION register Write valid signal
  input  logic [AHB_LITE_DATA_WIDTH-1:0]    prog_prot_reg_swdata,         // Write data for PROGRAMMING PROTECTION registers

  // INFO Registers ==> PROGRAMMING PROTECTION Registers
  input  logic [6:0]                        hwcfg1_rrid_num,              // Indicates the number of supported RRIDs

  // SRCMD Format 0 Registers ==> PROGRAMMING PROTECTION Registers
  input  [CFG.RRID_NUM-1:0][CFG.MD_NUM-1:0] srcmd_en_enh,                // SRCMD Table in SRCMD Format 0 required to handle the RRID stall

  // PROGRAMMING PROTECTION Registers ==> AXI Master Request Manager
  output change_state_e                     change_state,                 // Indicates the Master Request Manager about the IOPMP state transition
  output logic [CFG.RRID_NUM-1:0]           rrid_stall,                   // Stall signal required in AXI Master Request Manager to determine whether to stall the transaction for specific RRID or not

  output prog_prot_reg_t                    prog_prot_reg                 // PROGRAMMING PROTECTION Registers
);

  // Stall Counter maximum value is determined by number of stages in Execution Pipeline
  localparam logic [4:0] MAX_COUNTER_VALUE = ((((CFG.MD_NUM + 20)/21) - 1) + ((CFG.ENTRY_NUM + 7)/8));

  // FSM State for stall counter
  typedef enum bit {
    COUNTER_IDLE = 1'b0,
    COUNT_DOWN   = 1'b1
  } stall_state_e;

  //###############################
  // Internal Signals Declarations
  //###############################

  // Registers/Fields SW write enable and write data signals
  logic        mdstall_exempt_swdata;
  logic        mdstall_exempt_swen;
  logic [30:0] mdstall_md_swdata;
  logic        mdstall_md_swen;
  logic [31:0] mdstallh_mdh_swdata;
  logic        mdstallh_mdh_swen;
  logic [15:0] rridscp_rrid_swdata;
  logic        rridscp_rrid_swen;
  logic [1:0]  rridscp_op_swdata;
  logic        rridscp_op_swen;
  logic        mdstall_is_busy_hwdata;
  logic        mdstall_is_busy_hwen;
  logic        rridscp_stat_hwen;
  logic [1:0]  rridscp_stat_hwdata;

  // Signals involve in stall handling
  logic [CFG.MD_NUM-1:0] stall_by_md;   // MDSTALL.md and MDSTALLH.mdh register value
  logic [4:0]            stall_cntr_n, stall_cntr_q;    // Stall counter value
  stall_state_e          stall_counter_state_q, stall_counter_state_n;    // Indicates the stall counter state. 0: IDLE, 1: COUNTING
  logic                  is_stall_state_n, is_stall_state_q;   // Indicates the IOPMP is in the STALL state, if asserted
  logic                  is_mdstall_swdata_non_zero, is_mdstallh_swdata_non_zero;
  logic                  start_counter, is_stall_counter_zero, is_mdstall_write_valid, is_mdstallh_write_valid, tune_rrid_stall;

  if (CFG.STALL_EN) begin : gen_stall_regs_write_path

    //****************************************************************************************************
    // Registers/Fields SW Write Data Signals
    //****************************************************************************************************

    // MDSTALL Register Fields SW Write Data Signals
    assign mdstall_exempt_swdata = prog_prot_reg_swdata[0];

    // The field MDSTALL.md[m] is writable only if implementation supports MD m
    assign mdstall_md_swdata = prog_prot_reg_swdata[31:1] & MD_NUM_MASK[30:0];

    // MDSTALLH Register SW Write Data Signals
    assign mdstallh_mdh_swdata = prog_prot_reg_swdata & MD_NUM_MASK[62:31];   // The field MDSTALLH.mdh[m] is writable only if implementation supports MD m

    // RRIDSCP Register Fields SW Write Data Signals
    assign rridscp_op_swdata = (&prog_prot_reg_swdata[31:30]) ?   // rridscp.op == 2'b11 is reserved
                                prog_prot_reg.rridscp.op :        // Retain the old value
                                prog_prot_reg_swdata[31:30];      // Write new data

    // The range of legal values for rridscp.rrid is defined by hwcfg1.rrid_num
    assign rridscp_rrid_swdata = (prog_prot_reg_swdata[15:0] <= hwcfg1_rrid_num) ?
                                  prog_prot_reg_swdata[15:0] :      // Write new value
                                  {{9{1'b0}}, hwcfg1_rrid_num};     // Configure to maximum supported value

    // Indicates if SW Write Data value on MDSTALL is non-zero
    assign is_mdstall_swdata_non_zero = |({mdstall_md_swdata, mdstall_exempt_swdata});

    // Indicates if SW Write Data value on MDSTALLH is non-zero
    assign is_mdstallh_swdata_non_zero = |mdstallh_mdh_swdata;

    // A write on MDSTALL happens only if the write data is non-zero when IOPMP is in NORMAL State and write data is zero when IOPMP is in STALL state
    // Otherwise the write on MDSTALL is ignored
    assign is_mdstall_write_valid = (((!is_mdstall_swdata_non_zero) && is_stall_state_q) || (is_mdstall_swdata_non_zero && (!prog_prot_reg.mdstall.is_busy))) && prog_prot_reg_write_valid;

    // A write on MDSTALLH happens only if the write data is non-zero when IOPMP is in NORMAL State and write data is zero when IOPMP is in STALL state
    // Otherwise the write on MDSTALLH is ignored
    assign is_mdstallh_write_valid = (((!is_mdstallh_swdata_non_zero) && is_stall_state_q) || (is_mdstallh_swdata_non_zero && (!prog_prot_reg.mdstall.is_busy))) && prog_prot_reg_write_valid;

    // Indicates that rrid_stall can be tuned as IOPMP is in HOLD or STALL state
    assign tune_rrid_stall = prog_prot_reg.mdstall.is_busy || is_stall_state_q;

    //****************************************************************************************************
    // DEMUX for Registers/Fields SW Write Enable Signals
    //****************************************************************************************************
    always_comb begin

      // The signal prog_prot_legal act as an enable signal to PROGRAMMING PROTECTION registers demux
      // When high it indicates demux is enabled and determine the PROGRAMMING PROTECTION register/fields to write based on prog_prot_demux_sel signal
      if (prog_prot_legal) begin

        // Drive all SW write enable signals of PROGRAMMING PROTECTION registers/fields low before matching any case
        // The case statement only handles the SW write enable signal for the particular register/fields it matches
        mdstall_exempt_swen = 1'b0;
        mdstall_md_swen     = 1'b0;
        mdstallh_mdh_swen   = 1'b0;
        rridscp_rrid_swen   = 1'b0;
        rridscp_op_swen     = 1'b0;

        // Determine the PROGRAMMING PROTECTION register/fields to write based on prog_prot_demux_sel signal
        unique case (prog_prot_reg_demux_sel)

          IOPMP_MDSTALL: begin

            // Drive MDSTALL register fields sw write enables
            mdstall_exempt_swen = is_mdstall_write_valid;
            mdstall_md_swen     = is_mdstall_write_valid;
          end

          IOPMP_MDSTALLH: begin

            // Drive MDSTALLH register sw write enables
            mdstallh_mdh_swen = is_mdstallh_write_valid;
          end

          IOPMP_RRIDSCP: begin

            // Drive RRIDSCP register fields sw write enables when IOPMP is in STALL or HOLD State
            rridscp_op_swen   = tune_rrid_stall && prog_prot_reg_write_valid;
            rridscp_rrid_swen = rridscp_op_swen;
          end

          default: ;
        endcase
      end

      // Drive all SW enable signals of PROGRAMMING PROTECTION registers/fields low as prog_prot_legal is low
      else begin
        mdstall_exempt_swen = 1'b0;
        mdstall_md_swen     = 1'b0;
        mdstallh_mdh_swen   = 1'b0;
        rridscp_rrid_swen   = 1'b0;
        rridscp_op_swen     = 1'b0;
      end
    end

    //****************************************************************************************************
    // Handle RRID Stall
    //****************************************************************************************************

    // Concatenation of MDSTALL.md and MDSTALLH.mddh
    assign stall_by_md = {prog_prot_reg.mdstallh.mdh,prog_prot_reg.mdstall.md};

    // Indicates if stall counter reached zero
    assign is_stall_counter_zero = (!(|stall_cntr_q));

    always_comb begin : stall_handling

      // Stall counter starts counting down when:
      //  Case 1: When MDSTALL is written with a non-zero value in NORMAL state
      //  Case 2: When RRIDSCP.op is written 1 in STALL state, i.e. stall the transaction ascociated with rridscp.rrid
      start_counter = ((!is_stall_state_q) && mdstall_exempt_swen) || (rridscp_op_swen && rridscp_op_swdata[0]);

      // MDSTALL.is_busy is written 1 when a non-zero value is written on MDSTALL or RRIDSCP.op is written 1 in STALL state
      // For both cases, the counter starts counting down and when counter reaches zero, MDSTALL.is_busy is deasseted
      mdstall_is_busy_hwen   = start_counter || is_stall_counter_zero;
      mdstall_is_busy_hwdata = start_counter && (!is_stall_counter_zero);

      // The IOPMP changes the state to FORWARD when:
      //  Case 1: A write on MDSTALL happens
      //  Case 2: Counter value is 0
      // The IOPMP changes the state to BACKWARD when:
      //  Case: A write value of 1 happens on RRIDSCP.op in STALL state
      change_state = change_state_e'({(rridscp_op_swen && rridscp_op_swdata[0]),(mdstall_exempt_swen || is_stall_counter_zero)});   // FORWARD: 2'b01   BACKWARD: 2'b10

      is_stall_state_n = is_stall_state_q;    // Indicates the IOPMP is in the STALL state, if asserted

      // When stall counter reaches zero, update the stall status to indicate that IOPMP is in STALL state
      if (is_stall_counter_zero) begin
        is_stall_state_n = 1'b1;
      end

      // When IOPMP is out of the STALL state, update the stall status to indicate that IOPMP is out of STALL state
      if (start_counter || mdstall_exempt_swen) begin
        is_stall_state_n = 1'b0;
      end

      //****************************************************************************************************
      // Generate RRID STALL Signal
      //****************************************************************************************************

      // Generate rrid_stall for SRCMD Format 0
      if (CFG.SRCMD_FMT_0) begin : gen_srcmd_fmt_0_stall

        // Iterate through all RRIDs to update the stall status
        for (int rrid_stall_index = '0; rrid_stall_index < CFG.RRID_NUM; rrid_stall_index++) begin : iterate_over_rrids

          // Format 0: Combine srcmd_enh and srcmd_en fields to evaluate stall conditions
          // This forms a 63-bit value representing memory domain stall conditions
          // Update the rrid_stall array based on the combined stall conditions, considering the exempt flag
          rrid_stall[rrid_stall_index] = (prog_prot_reg.mdstall.exempt ^ (|(srcmd_en_enh[rrid_stall_index] & stall_by_md)));
        end
      end

      // Generate rrid_stall for SRCMD Format 1
      if (CFG.SRCMD_FMT_1) begin : gen_srcmd_fmt_1_stall

        // Format 1: Extend the exempt field MD_NUM times and XOR it with `stall_by_md` mask for the RRID stall condition
        // Because in format 1. RRID i is directly mapped with MD i
        rrid_stall = ({CFG.MD_NUM{prog_prot_reg.mdstall.exempt}} ^ stall_by_md);
      end

      // Generate rrid_stall for SRCMD Format 2
      if (CFG.SRCMD_FMT_2) begin : gen_srcmd_fmt_2_stall

        // Any bit in stall_by_md is 1, all rrids are stalled
        rrid_stall = {CFG.RRID_NUM{prog_prot_reg.mdstall.exempt ^ (|stall_by_md)}};
      end

      // Check if RRIDSCP.op is written 1 in STALL or HOLD mode.
      if (tune_rrid_stall && prog_prot_reg.rridscp.op[0]) begin

        // Stall transactions associated with selected RRID when rridscp.op is written 1
        rrid_stall[prog_prot_reg.rridscp.rrid] = 1'b1;
      end

      // Check if RRIDSCP.op is written 2 in STALL or HOLD mode.
      if (tune_rrid_stall && prog_prot_reg.rridscp.op[1]) begin

        // Do not stall transactions associated with selected RRID when rridscp.op is written 2
        rrid_stall[prog_prot_reg.rridscp.rrid] = 1'b0;
      end

      // Query the status of rrid_stall for selected RRID when rridscp.op is written zero and store the result in rridscp.stat
      rridscp_stat_hwdata = {~rrid_stall[rridscp_rrid_swdata[5:0]],rrid_stall[rridscp_rrid_swdata[5:0]]};
      rridscp_stat_hwen   = rridscp_op_swen && (!(|rridscp_op_swdata));
    end

    always_comb begin : stall_counter_comb

      // Default Assignment
      stall_cntr_n          = stall_cntr_q;
      stall_counter_state_n = stall_counter_state_q;

      case (stall_counter_state_q)

        COUNTER_IDLE: begin

          // The stall counter starts counting down:
          //  Case 1: When MDSTALL is written with a non-zero value in NORMAL state
          //  Case 2: When RRIDSCP.op is written 1, i.e. stall the transaction ascociated with rridscp.rrid in STALL state
          if (start_counter)
            stall_counter_state_n = COUNT_DOWN;
        end

        COUNT_DOWN: begin

          stall_cntr_n = stall_cntr_q - 5'h1;

          // When the counter value reaches zero, reset the counter and change the counter state to IDLE
          if (is_stall_counter_zero) begin
            stall_counter_state_n = COUNTER_IDLE;
            stall_cntr_n          = MAX_COUNTER_VALUE;
          end
        end
      endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin : stall_counter_flop
      if (!rst_n) begin
        stall_counter_state_q <= COUNTER_IDLE;
        stall_cntr_q          <= MAX_COUNTER_VALUE;
        is_stall_state_q      <= 1'b0;
      end
      else begin
        stall_counter_state_q <= stall_counter_state_n;
        stall_cntr_q          <= stall_cntr_n;
        is_stall_state_q      <= is_stall_state_n;
      end
    end
  end
  else begin : drive_stall_signals_zero

    assign change_state = NONE;
    assign rrid_stall   = '0;
  end

  //****************************************************************************************************
  // PROGRAMMING PROTECTION REGISTERS
  //****************************************************************************************************

  if (CFG.STALL_EN) begin : gen_stall_regs

    // ########### MDSTALL ###########
    regfield #(
      .DW      (1),
      .SWACCESS("WO"),
      .RESVAL  (1'b0)
    ) u_mdstall_exempt
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (mdstall_exempt_swen),
      .swdata  (mdstall_exempt_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (prog_prot_reg.mdstall.exempt)
    );

    regfield #(
      .DW      (1),
      .SWACCESS("RO"),
      .RESVAL  (1'b0)
    ) u_mdstall_is_busy
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (1'b0),
      .swdata  ('0),

      .hwen    (mdstall_is_busy_hwen),
      .hwdata  (mdstall_is_busy_hwdata),

      .hwrdata (prog_prot_reg.mdstall.is_busy)
    );

    regfield #(
      .DW      (31),
      .SWACCESS("RW"),
      .RESVAL  ('0)
    ) u_mdstall_md
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (mdstall_md_swen),
      .swdata  (mdstall_md_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (prog_prot_reg.mdstall.md)
    );

    // ########### MDSTALLH ###########
    regfield #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  ('0)
    ) u_mdstallh_mdh
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (mdstallh_mdh_swen),
      .swdata  (mdstallh_mdh_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (prog_prot_reg.mdstallh.mdh)
    );

    // ########### RRIDSCP ###########
    regfield #(
      .DW      (16),
      .SWACCESS("RW"),
      .RESVAL  ('0)
    ) u_rridscp_rrid
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (rridscp_rrid_swen),
      .swdata  (rridscp_rrid_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (prog_prot_reg.rridscp.rrid)
    );

    regfield #(
      .DW      (2),
      .SWACCESS("WO"),
      .RESVAL  ('0)
    ) u_rridscp_op
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (rridscp_op_swen),
      .swdata  (rridscp_op_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (prog_prot_reg.rridscp.op)
    );

    regfield #(
      .DW      (2),
      .SWACCESS("RO"),
      .RESVAL  ('0)
    ) u_rridscp_stat
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (1'b0),
      .swdata  ('0),

      .hwen    (rridscp_stat_hwen),
      .hwdata  (rridscp_stat_hwdata),

      .hwrdata (prog_prot_reg.rridscp.stat)
    );
  end
  else begin : gen_stall_regs_hardwired_zeros
    assign prog_prot_reg.mdstall  = '0;
    assign prog_prot_reg.mdstallh = '0;
    assign prog_prot_reg.rridscp  = '0;
  end

endmodule