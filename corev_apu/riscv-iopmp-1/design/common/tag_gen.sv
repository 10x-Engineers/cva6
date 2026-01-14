///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Gull Ahmed <gull.ahmed@10xengineers.ai>
/// Date Created: 08-May-2025
/// Description:
///////////////////////////////////////////////////////////////////////////

module tag_gen #(
  parameter int unsigned WIDTH = 32
  )(
  input  logic                     clk,
  input  logic                     rst_n,

  // Generate Tag
  input  logic                     gen_tag,
  output logic [$clog2(WIDTH)-1:0] tag_out,

  // Clear Tag
  input  logic                     clr_tag,
  input  logic [$clog2(WIDTH)-1:0] tag_in
);

  logic [WIDTH-1:0] available_tags_q,available_tags_n;

  always_comb begin
    available_tags_n = available_tags_q;
    if (gen_tag) begin
      available_tags_n = (available_tags_q | (32'h1 << tag_out));
    end
    if (clr_tag) begin
      available_tags_n = (available_tags_q & ~(32'h1 << tag_in));
    end
  end

  iopmp_lzc #(
    .WIDTH     (WIDTH),
    .MODE      (1)
  ) iopmp_lzc
	(
    .in_i      (~available_tags_q),
    .cnt_o     (tag_out),
    .empty_o   ()
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      available_tags_q <= '0;
    end
    else begin
      available_tags_q <= available_tags_n;
    end
  end

endmodule