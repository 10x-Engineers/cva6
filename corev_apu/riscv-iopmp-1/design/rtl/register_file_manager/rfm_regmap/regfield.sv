///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 17-Jan-2025
/// Description: This module computes write enable and data for a register
/// field based on software/hardware access type and current register value.
///////////////////////////////////////////////////////////////////////////

module regfield #(
  parameter int            DW       = 32  ,  // Data Width
  parameter                SWACCESS = "RW",  // {RW, RO, WO, W1C, W1S, W1SS, W1CS}
  parameter logic [DW-1:0] RESVAL   = '0     // Reset value
)
(
  input  logic          clk,
  input  logic          rst_n,

  //From SW: valid for RW, RO, WO, W1C, W1S, W1SS, W1CS
  input  logic          swen,
  input  logic [DW-1:0] swdata,

  //From HW: valid for HRW, HWO
  input  logic          hwen,
  input  logic [DW-1:0] hwdata,

  //Output
  output logic [DW-1:0] hwrdata  //HW Read Port
);

  logic [DW-1:0] wr_data;
  logic [DW-1:0] data;
  logic          wr_en;

  regfield_arb #(
    .DW       (DW),
    .SWACCESS (SWACCESS)
  ) wr_en_data_arb
  (
    .swen   (swen),
    .swdata (swdata),
    .hwen   (hwen),
    .hwdata (hwdata),
    .hwrdata(hwrdata),
    .wr_en  (wr_en),
    .wr_data(wr_data)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data <= RESVAL;
    end
    else if (wr_en) begin
      data <= wr_data;
    end
  end

  assign hwrdata = data;

endmodule