/*************************************************************************
   > File Name:   wr_rsp_sequencer.sv
   > Description: This file defines the `wr_rsp_sequencer` class, responsible for 
                  managing the sequence items for AXI write response transactions.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef WR_RSP_SEQUENCER
`define WR_RSP_SEQUENCER

class wr_rsp_sequencer extends uvm_sequencer #(axi_seq_item);

  `uvm_component_utils(wr_rsp_sequencer)

  // Constructor
  function new(string name = "wr_rsp_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass

`endif
