/*************************************************************************
   > File Name:   rd_data_sequencer.sv
   > Description: This file defines the `rd_data_sequencer` class, responsible for 
                  managing the sequence items for AXI read data transactions.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef RD_DATA_SEQUENCER
`define RD_DATA_SEQUENCER

class rd_data_sequencer extends uvm_sequencer #(axi_seq_item);

  `uvm_component_utils(rd_data_sequencer)

  // Constructor
  function new(string name = "rd_data_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass

`endif
