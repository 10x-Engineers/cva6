/*************************************************************************
   > File Name:   wr_addr_sequencer.sv
   > Description: This file defines the `wr_addr_sequencer` class, responsible for 
                  managing the sequence items for AXI write address transactions.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef WR_ADDR_SEQUENCER
`define WR_ADDR_SEQUENCER

class wr_addr_sequencer extends uvm_sequencer #(axi_seq_item);

  `uvm_component_utils(wr_addr_sequencer)

  // Constructor
  function new(string name = "wr_addr_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass

`endif
