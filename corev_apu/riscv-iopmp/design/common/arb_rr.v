//////////////////////////////////////////////////////////////////////
// Copyright 2023 DreamBig Semiconductor, Inc. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of DreamBig Semiconductor Inc.
// All information contained in this document is DreamBig Semiconductor Inc.
// company confidential, proprietary and trade secret.
//////////////////////////////////////////////////////////////////////
//
// Author: Aaron Rother
// Date Created: Sept 2021
//
// Description: Round-Robin Arbiter
// Combinational round-robin priority arbiter with parameterizable number of requesters
// and parameterizable priority source.
//
// If external priority source, user-provided priority governs arbitration. No internal flops. This option
// is best used for a large number of requesters (> 256) and when user does not require arbitration every cycle,
// so that storing priority next to requests can be relaxed (assuming it is stored encoded).
// Must be in thermometer format: 1...1,0...0.
// Can be all zeros or all ones, in which cases LSB requester gets highest priority.
// Otherwise, least significant '1' indicates highest priority.
//
// If internal priority source, for every grant, priority advances to the subsequent requester
// (moving from lowest to highest index). Best used for arbiters with a small number of requesters.
// Internal priority may be stored encoded as BCD (number of flops == log2 REQS, but added combinational delay).
// or as a bit vector (number of flops == REQS, but less combinational delay).
//
// Default configuration is internal priority, stored as BCD encoded.
//
// Grant only asserts when one or more requesters are active. No grant parking.
//
// Latency:
// Maximum latency, in clocks, for any requester is equal to the number of requesters minus one.
// Minimum latency is 0 clocks
//////////////////////////////////////////////////////////////////////

module arb_rr #(
  parameter REQS = 4,    // Number of requesters
  parameter EXT_PRI = 0, // 0: Priority vector stored internally; 1: Priority vector supplied as input
  parameter PRI_VEC = 0) // 0: Priority stored as BCD encoded; 1: Priority stored as bit vector. Unused if EXT_PRI==1
(
  input  logic          clk,
  input  logic          rst_n,
  input  logic [REQS-1:0] req,
  input  logic [REQS-1:0] pri, // Unused if EXT_PRI==0
  output logic [REQS-1:0] gnt
);

  // ================================================================
  // Declarations
  // ================================================================
  localparam REQS_IDX = $clog2(REQS);
  localparam REQS_P2  = 2**REQS_IDX; // Extend to next power-of-2

  logic                req_masked_ne0;
  logic [REQS-1:0]     req_masked_ppc, req_unmasked_ppc, req_masked_ppc_shift, req_unmasked_ppc_shift, gnt_masked, gnt_unmasked, pri_mask;
  logic [REQS_P2-1:0]  req_p2, req_p2_masked, req_p2_unmasked_ppc_pass1, req_p2_masked_ppc_pass1,
                       req_p2_unmasked_ppc_pass2, req_p2_masked_ppc_pass2, req_p2_masked_ppc, req_p2_unmasked_ppc;
  logic [REQS_P2-1:0]  req_p2_masked_ppc_pass1_msb, req_p2_unmasked_ppc_pass1_msb;

  //=================================================================
  // Arbitration
  //=================================================================
  always_comb req_p2_masked = req_p2 & REQS_P2'(pri_mask);
  always_comb req_p2        = REQS_P2'(req);

  // Parallel Prefix Computation
  // OR operation. Yields thermometer decoded vector in (2 * log2 REQS) levels.
  // First Pass
  always_comb begin
    req_p2_masked_ppc_pass1   = req_p2_masked;
    req_p2_unmasked_ppc_pass1 = req_p2;

    for (int unsigned d = 0; d < REQS_IDX; d++) begin: outer_ppc_up
      for (int unsigned i = 0; i < REQS_P2; i=i + (2**(d+1))) begin: inner_ppc_up
        req_p2_masked_ppc_pass1[i + 2**(d+1) - 1] |= req_p2_masked_ppc_pass1[i + 2**d - 1];
        req_p2_unmasked_ppc_pass1[i + 2**(d+1) - 1] |= req_p2_unmasked_ppc_pass1[i + 2**d - 1];
      end: inner_ppc_up
    end: outer_ppc_up
  end

  always_comb req_p2_masked_ppc_pass1_msb   = req_p2_masked_ppc_pass1[REQS_P2-1];
  always_comb req_p2_unmasked_ppc_pass1_msb = req_p2_unmasked_ppc_pass1[REQS_P2-1];

  // Second Pass
  always_comb begin
    logic temp_masked, temp_unmasked;

    req_p2_masked_ppc_pass2   = {1'b0, req_p2_masked_ppc_pass1[REQS_P2-2:0]}; // 0 is identity for OR (0 | X = X)
    req_p2_unmasked_ppc_pass2 = {1'b0, req_p2_unmasked_ppc_pass1[REQS_P2-2:0]};

    for (int signed d = REQS_IDX-1; d >= 0; d--) begin: outer_ppc_down
      for (int unsigned i = 0; i < REQS_P2; i = i + (2**(d+1))) begin: inner_ppc_down
        temp_masked   = req_p2_masked_ppc_pass2[i + 2**d - 1];
        req_p2_masked_ppc_pass2[i + 2**d - 1] = req_p2_masked_ppc_pass2[i + 2**(d+1) - 1];
        req_p2_masked_ppc_pass2[i + 2**(d+1) - 1] |= temp_masked;
        temp_unmasked = req_p2_unmasked_ppc_pass2[i + 2**d - 1];
        req_p2_unmasked_ppc_pass2[i + 2**d - 1] = req_p2_unmasked_ppc_pass2[i + 2**(d+1) - 1];
        req_p2_unmasked_ppc_pass2[i + 2**(d+1) - 1] |= temp_unmasked;
      end: inner_ppc_down
    end: outer_ppc_down
  end

  always_comb begin
    req_p2_masked_ppc  = req_p2_masked_ppc_pass2 >> 1;
    req_p2_masked_ppc[REQS_P2-1] = req_p2_masked_ppc_pass1_msb;
    req_p2_unmasked_ppc = req_p2_unmasked_ppc_pass2 >> 1;
    req_p2_unmasked_ppc[REQS_P2-1] = req_p2_unmasked_ppc_pass1_msb;
  end

  always_comb req_masked_ppc  = REQS'(req_p2_masked_ppc);
  always_comb req_masked_ppc_shift  = REQS'(req_masked_ppc << 1);

  always_comb req_unmasked_ppc = REQS'(req_p2_unmasked_ppc);
  always_comb req_unmasked_ppc_shift = REQS'(req_unmasked_ppc << 1);

  always_comb gnt_masked = req_masked_ppc ^ req_masked_ppc_shift;
  always_comb gnt_unmasked = req_unmasked_ppc ^ req_unmasked_ppc_shift;

  always_comb req_masked_ne0 = req_p2_masked_ppc_pass1_msb;

  always_comb gnt = req_masked_ne0 ? gnt_masked : gnt_unmasked;

  //#############################################################################
  // Priority
  //#############################################################################
  generate
    if (EXT_PRI == 0) begin: pri_int
      if (PRI_VEC == 1) begin: pri_int_vec
        logic [REQS-1:0] pri_mask_nxt;
        always_ff @(posedge clk or negedge rst_n)
          if (~rst_n) begin
            pri_mask <= '0;
          end
          else begin
            pri_mask <= pri_mask_nxt;
          end
        always_comb begin
          if (req_p2_unmasked_ppc_pass1_msb) // Any req
            pri_mask_nxt = req_masked_ne0 ? req_masked_ppc_shift : req_unmasked_ppc_shift;
          else
            pri_mask_nxt = pri_mask;
        end
      end: pri_int_vec
        else begin: pri_int_bcd

          logic [REQS_IDX-1:0] pri_bcd, pri_bcd_nxt;

          always_ff @(posedge clk or negedge rst_n)
            if (~rst_n) begin
              pri_bcd <= '0;
            end
            else begin
              pri_bcd <= pri_bcd_nxt;
            end

          always_comb begin
            for (int unsigned i = 0; i < REQS; i++) begin
              pri_mask[i] = i >= pri_bcd;
            end
          end

          always_comb begin
            logic [REQS-1:0] gnt_shift;

            pri_bcd_nxt = pri_bcd;
            gnt_shift = {gnt[0 +: REQS-1], gnt[REQS-1]};

            for (int unsigned i = 0; i < REQS; i++) begin
              if (gnt_shift[i])
                pri_bcd_nxt = i;
            end
          end

        end: pri_int_bcd
      end: pri_int
    else begin: pri_ext
      always_comb pri_mask = pri;
    end:pri_ext
  endgenerate

endmodule
