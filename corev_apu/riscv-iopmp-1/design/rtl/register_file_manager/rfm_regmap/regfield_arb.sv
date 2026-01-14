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
/// Description: This module Parameterized the register field that supports
/// software and hardware writes based on configurable access policies
/// (e.g., RW, W1C, RO).
///////////////////////////////////////////////////////////////////////////

module regfield_arb #(
  parameter int DW       = 32  ,  // Data Width
  parameter     SWACCESS = "RW"   // {RW, RO, WO, W1C, W1S, W1SS, W1CS}
)
(
  // From SW: valid for RW, RO, WO, W1C, W1S, W1SS, W1CS.
  input  logic          swen,
  input  logic [DW-1:0] swdata,

  // From HW: valid for HRW, HWO.
  input  logic          hwen,
  input  logic [DW-1:0] hwdata,

  // From register: actual reg value.
  input  logic [DW-1:0] hwrdata,

  // To register: actual write enable and write data.
  output logic          wr_en,
  output logic [DW-1:0] wr_data
);

  if ((SWACCESS == "RW") || (SWACCESS == "WO")) begin : gen_sw_access_RW_WO
    assign wr_en   = swen | hwen;
    assign wr_data = swen ? swdata : hwdata; // SW higher priority
  end
  else if (SWACCESS == "RO") begin : gen_sw_access_RO
    assign wr_en   = hwen;
    assign wr_data = hwdata;
  end
  else if (SWACCESS == "W1C") begin : gen_sw_access_W1C
    // If SWACCESS is W1C, then assume hw tries to set.
    // So, give a chance HW to set when SW tries to clear.
    // If both try to set/clr at the same bit pos, SW wins.
    assign wr_en   = swen | hwen;
    assign wr_data = (hwen ? hwdata : hwrdata) & (swen ? ~swdata : '1);
  end
  else if (SWACCESS == "W1SS") begin : gen_sw_access_W1SS
    // If SWACCESS is W1SS, writing is illegal if the bit is set
    assign wr_en   = hwrdata ? 1'b0: swen | hwen;
    assign wr_data = (hwen ? hwdata : hwrdata) | (swen ? swdata : '0);
  end
  else if (SWACCESS == "W1CS") begin : gen_sw_access_W1CS
    // If SWACCESS is W1CS, writing is illegal if the bit is 0
    assign wr_en   = hwrdata ? swen | hwen : 1'b0;
    assign wr_data = (hwen ? hwdata : hwrdata) & (swen ? ~swdata : '1);
  end
  else begin
    assign wr_en   = hwen;
    assign wr_data = hwdata;
  end

endmodule