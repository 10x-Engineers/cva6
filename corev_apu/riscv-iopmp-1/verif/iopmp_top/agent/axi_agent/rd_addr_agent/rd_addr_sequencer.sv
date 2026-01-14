/*************************************************************************
   > File Name:   rd_addr_sequencer.sv
   > Description: This file defines the `rd_addr_sequencer` class, responsible for 
                  managing the sequence items for AXI read address transactions.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef RD_ADDR_SEQUENCER
`define RD_ADDR_SEQUENCER

class rd_addr_sequencer extends uvm_sequencer #(axi_seq_item);

  `uvm_component_utils(rd_addr_sequencer)

  // Constructor
  function new(string name = "rd_addr_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass

`endif
