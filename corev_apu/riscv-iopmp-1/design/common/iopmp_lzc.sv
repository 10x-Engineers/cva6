//////////////////////////////////////////////////////////////////////////////
// Copyright 2023 DreamBig Semiconductor, Inc. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of DreamBig Semiconductor Inc.
// All information contained in this document is DreamBig Semiconductor Inc.
// company confidential, proprietary and trade secret.
//
//////////////////////////////////////////////////////////////////////////////
//
// Author (name and email): shaheer@dreambigsemi.com
// Date Created: 5/05/23
// Description: leading zero count with a complexity of O(log n).
// This module can be used to count the number of leading/trailing 0 or 1
// or in other words determine the position of the first or last 0 or 1
// MODE     Value
// Leading Zero Count    0
// Trailing Zero Count   1
// Leading One Count     2
// Trailing One Count    3
//
//////////////////////////////////////////////////////////////////////////////

// Main module that is to be instantiated in user design
// The module takes input vector width as parameter. It can be any integer
// as the block will automatically pad 1's on the LSB side to reach the closest power of 2 width

module iopmp_lzc
    #(
      parameter WIDTH = 32,
      parameter MODE = 0
    )
    (
        input [WIDTH-1:0] in_i,
        output logic [$clog2(WIDTH)-1:0] cnt_o,
        output logic empty_o
    );

    //Calculate nearest power of two width from user given width
    localparam LZC_WIDTH = 2**$clog2(WIDTH);
    //Calculate required number of 1's to pad
    localparam LSB_PAD = LZC_WIDTH-WIDTH;
    logic zero;
    logic [$clog2(WIDTH)-1:0] cnt;
    logic [LZC_WIDTH-1:0] padded_val;
    always_comb
    begin
        case (MODE)
            0:padded_val = {in_i,{LSB_PAD{1'b1}}};       //LZC
            1:padded_val = {{LSB_PAD{1'b1}},in_i};       //TZC
            2:padded_val = {in_i,{LSB_PAD{1'b0}}};       //LOC
            3:padded_val = {{LSB_PAD{1'b0}},in_i};       //TOC
        endcase
    end

    // LZC generate block wrapper
    gen_lzc #(.MODE_TYPE(MODE), .WIDTH(LZC_WIDTH)) gen_lzc_inst
    (
        .a_i(padded_val),
        .cnt_o(cnt),
        .zero_o(zero)
    );

    //Determine if input is zero
    assign empty_o = (in_i == {WIDTH{1'b0}});
    //Count is zero if input is zero
    assign cnt_o = empty_o ? 0 : cnt;

  endmodule


  module gen_lzc
  #(
    parameter MODE_TYPE = 0,
    parameter WIDTH = 32
  )
  (
    input [WIDTH-1:0] a_i,
    output logic [$clog2(WIDTH)-1:0] cnt_o,
    output logic zero_o
  );
  //a recursive function that takes WIDTH as input
  //generates lzc4 until only 2 are left
  //then create select logic
  //Let's take an 8 bit input vector
  //The idea is to split it into half until a 4bit block is achieved
  //and then create a mux
  //
  // 0 0 1 0 1 1 1 1
  // |-----|-----|
  // 4bits   4bits
  // Z1 C1  Z0 C0 (Z=Z are 4bits zero, C=Leading one count in 4bits)
  //  ''''  ''
  //   |    |
  //   |   C1  C0  |
  //   |--->\'2:1'' MUX
  //   |
  //FC={Z1,   MUX_OUT} Final count
  //FZ=Z1 & Z0     Final zero
  //More details on confluence (Search for LZC)

  generate
    if(WIDTH == 4) // stop when unit size block which is 4bits is achieved and instantiate its block
    begin
        lzc_4 #(.MODE_TYPE(MODE_TYPE)) leaf(.a_i(a_i), .cnt_o(cnt_o), .zero_o(zero_o));
    end
    else //keep splitting and recursively instantiate gen_lzc block with half width and half vector as inputs
    begin
        logic [$clog2(WIDTH/2)-1:0] c[1:0];
        logic [1:0] z;

        gen_lzc #(.MODE_TYPE(MODE_TYPE), .WIDTH(WIDTH/2)) h(.a_i(a_i[WIDTH-1:(WIDTH/2)]), .cnt_o(c[1]), .zero_o(z[1]));
        gen_lzc #(.MODE_TYPE(MODE_TYPE), .WIDTH(WIDTH/2)) l(.a_i(a_i[(WIDTH/2) - 1:0] ), .cnt_o(c[0]), .zero_o(z[0]));

        if((MODE_TYPE & 1) == 0)
            assign cnt_o = {z[1], z[1] ? c[0] : c[1]};
        else
            assign cnt_o = {z[0], z[0] ? c[1] : c[0]};

        assign zero_o = &z;
    end
  endgenerate

  endmodule

  //unit block
  module lzc_4
    #(parameter MODE_TYPE = 0)
    (
        input  [3:0] a_i,
        output logic [1:0] cnt_o,
        output logic zero_o
    );
    generate
      if(MODE_TYPE == 0)
      begin
          always_comb
          begin : LZC_leaf
              casez(a_i)
                  4'b0000: begin zero_o = 'h1; cnt_o = 'h0; end
                  4'b0001: begin zero_o = 'h0; cnt_o = 'h3; end
                  4'b001?: begin zero_o = 'h0; cnt_o = 'h2; end
                  4'b01??: begin zero_o = 'h0; cnt_o = 'h1; end
                  4'b1???: begin zero_o = 'h0; cnt_o = 'h0; end
                  default: begin zero_o = 'h0; cnt_o = 'h0; end
              endcase
          end
      end
      else if(MODE_TYPE == 1)
      begin
          always_comb
          begin : TZC_leaf
              casez(a_i)
                  4'b0000: begin zero_o = 'h1; cnt_o = 'h0; end
                  4'b1000: begin zero_o = 'h0; cnt_o = 'h3; end
                  4'b?100: begin zero_o = 'h0; cnt_o = 'h2; end
                  4'b??10: begin zero_o = 'h0; cnt_o = 'h1; end
                  4'b???1: begin zero_o = 'h0; cnt_o = 'h0; end
                  default: begin zero_o = 'h0; cnt_o = 'h0; end
              endcase
          end
      end
      else if(MODE_TYPE == 2)
      begin
        always_comb
        begin : LOC_leaf
            casez(a_i)
                4'b1111: begin zero_o = 'h1; cnt_o = 'h0; end
                4'b1110: begin zero_o = 'h0; cnt_o = 'h0; end
                4'b11?0: begin zero_o = 'h0; cnt_o = 'h1; end
                4'b1??0: begin zero_o = 'h0; cnt_o = 'h2; end
                4'b???0: begin zero_o = 'h0; cnt_o = 'h3; end
                default: begin zero_o = 'h0; cnt_o = 'h0; end
            endcase
        end
      end
      else if(MODE_TYPE == 3)
      begin
          always_comb
          begin : TOC_leaf
              casez(a_i)
                  4'b1111: begin zero_o = 'h1; cnt_o = 'h0; end
                  4'b0111: begin zero_o = 'h0; cnt_o = 'h0; end
                  4'b?111: begin zero_o = 'h0; cnt_o = 'h1; end
                  4'b??11: begin zero_o = 'h0; cnt_o = 'h2; end
                  4'b???1: begin zero_o = 'h0; cnt_o = 'h3; end
                  default: begin zero_o = 'h0; cnt_o = 'h0; end
              endcase
          end
      end
    endgenerate
  endmodule