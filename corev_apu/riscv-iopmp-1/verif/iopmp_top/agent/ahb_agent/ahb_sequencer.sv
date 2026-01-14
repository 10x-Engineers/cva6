/*************************************************************************
   > File Name:   ahb_sequencer.sv
   > Description: This file defines the `ahb_sequencer` class, which extends 
                  the UVM sequencer for handling AHB sequence items.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef AHB_SEQUENCER
`define AHB_SEQUENCER

class ahb_sequencer extends uvm_sequencer #(ahb_seq_item);

  `uvm_component_utils(ahb_sequencer)

  // Constructor
  function new(string name = "ahb_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : ahb_sequencer

`endif
