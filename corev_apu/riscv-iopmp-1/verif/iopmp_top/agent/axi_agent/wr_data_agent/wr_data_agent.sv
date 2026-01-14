/*************************************************************************
   > File Name:   wr_data_agent.sv
   > Description: This file defines the `wr_data_agent` class, which encapsulates
                  the driver, sequencer, and monitor for driving and monitoring 
                  AXI write data transactions.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef WR_DATA_AGENT
`define WR_DATA_AGENT

class wr_data_agent extends uvm_agent;

  `uvm_component_utils(wr_data_agent)

  // Agent components
  wr_data_driver    wr_data_driv;   // Driver instance
  wr_data_sequencer wr_data_sqr;    // Sequencer instance
  wr_data_monitor   wr_data_mon;    // Monitor instance

  // Constructor
  function new(string name = "wr_data_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //-----------------------------------------------------------------------------
  // Build Phase
  //-----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create agent components
    if(get_is_active() == UVM_ACTIVE) begin
      wr_data_driv = wr_data_driver::type_id::create(   "wr_data_driv", this);
      wr_data_sqr  = wr_data_sequencer::type_id::create("wr_data_sqr", this);
    end
    wr_data_mon  = wr_data_monitor::type_id::create(  "wr_data_mon", this);
    `uvm_info(get_name(), "Build phase completed for Write Data Agent", UVM_LOW)
  endfunction

  //-----------------------------------------------------------------------------
  // Connect Phase
  //-----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);

    // Connect driver to sequencer
    if(get_is_active() == UVM_ACTIVE) begin
      wr_data_driv.seq_item_port.connect(wr_data_sqr.seq_item_export);
    end
    else begin
      `uvm_info(get_name(), "Agent is Passive", UVM_LOW)
    end
    
    `uvm_info(get_name(), "Connect phase completed for Write Data Agent", UVM_LOW)
  endfunction

endclass

`endif
