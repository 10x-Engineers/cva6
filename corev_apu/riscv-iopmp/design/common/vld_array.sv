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

module vld_array #(
  parameter WIDTH = 64,
  parameter DEPTH = 64,
  parameter ADDR_W = $clog2(DEPTH)
) (
  input  logic                  clk,
  input  logic                  rst_n,
  input  logic                  wren_a,
  input  logic                  wren_b,
  input  logic [ADDR_W-1:0]     waddr_a,
  input  logic [ADDR_W-1:0]     waddr_b,
  input  logic [ADDR_W-1:0]     raddr,
  input  logic [WIDTH-1:0]      wdata_a,
  input  logic [WIDTH-1:0]      wdata_b,
  output logic [WIDTH-1:0]      rdata
);

  logic [DEPTH-1:0] [WIDTH-1:0] mem;
  logic [DEPTH-1:0] read_vec;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem <= '0;
    end
    else begin
      if(wren_a) begin
        mem[waddr_a] <= wdata_a;
      end

      if(wren_b) begin
        mem[waddr_b] <= wdata_b;
      end
    end
  end

  always_comb begin
    rdata    = '0;
    read_vec = 'b1 << raddr;
    for (int i = 0; i < DEPTH; i++)
      rdata |= read_vec[i] ? mem[i] : '0;
  end

endmodule
