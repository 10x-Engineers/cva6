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

module mem1r1w #(
  parameter WIDTH = 64,
  parameter DEPTH = 64,
  parameter ADDR_W = $clog2(DEPTH)
) (
  input  logic                  clk,
  input  logic                  rst_n,
  input  logic                  wren,
  input  logic                  rden,
  input  logic [ADDR_W-1:0]     waddr,
  input  logic [ADDR_W-1:0]     raddr,
  input  logic [WIDTH-1:0]      wdata,
  output logic [WIDTH-1:0]      rdata,
  output logic                  initd
);

  logic [DEPTH-1:0] [WIDTH-1:0] mem;

  logic wren_int, rden_int;
  logic [WIDTH-1:0] wdata_int;
  logic [ADDR_W-1:0] waddr_int, raddr_int;
  typedef enum {INIT, ACTIVE} states;
  states mem_state, n_state;
  logic [DEPTH-1:0] read_vec;
  logic [ADDR_W-1:0] cntr;

  always_ff @(posedge clk) begin
    if(wren_int) begin
      mem[waddr_int] <= wdata_int;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cntr <= 'd0;
    end
    else begin
      if(mem_state == INIT) cntr <= cntr + 'd1;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      mem_state <= INIT;
    end
    else begin
      mem_state <= n_state;
    end
  end

  always_comb begin
    rdata     = '0;
    n_state   = mem_state;
    waddr_int = '0;
    wdata_int = '0;
    wren_int  = '0;
    initd     = '0;
    case(mem_state)
      INIT: begin
        if(int'(cntr) == DEPTH-1) begin
          n_state = ACTIVE;
        end
        wren_int  = 1'b1;
        waddr_int = cntr;
        wdata_int = 'd0;
        initd     = 1'b0;
        rden_int  = 1'b0;
        raddr_int = 'd0;
      end
      ACTIVE: begin
        initd     = 1'b1;
        wren_int  = wren;
        wdata_int = wdata;
        waddr_int = waddr;
        n_state   = ACTIVE;
        rden_int  = rden;
        raddr_int = raddr;
        read_vec  = 'b1 << raddr_int;
        for (int i = 0; i < DEPTH; i++)
          rdata |= read_vec[i] ? mem[i] : '0;
      end
    endcase
  end

endmodule