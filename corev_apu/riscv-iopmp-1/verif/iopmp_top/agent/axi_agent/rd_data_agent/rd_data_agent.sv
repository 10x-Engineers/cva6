/*************************************************************************
   > File Name:   rd_data_agent.sv
   > Description: This file defines the `rd_data_agent` class, which encapsulates
                  the driver, sequencer, and monitor for driving and monitoring 
                  AXI read data transactions.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef RD_DATA_AGENT
`define RD_DATA_AGENT

class rd_data_agent extends uvm_agent;

  `uvm_component_utils(rd_data_agent)

  // Agent components
  rd_data_driver    rd_data_driv;   // Driver instance
  rd_data_sequencer rd_data_sqr;    // Sequencer instance
  rd_data_monitor   rd_data_mon;    // Monitor instance

  // Constructor
  function new(string name = "rd_data_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //-----------------------------------------------------------------------------
  // Build Phase
  //-----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create agent components
    if(get_is_active() == UVM_ACTIVE) begin
      rd_data_driv = rd_data_driver::type_id::create(   "rd_data_driv", this);
      rd_data_sqr  = rd_data_sequencer::type_id::create("rd_data_sqr", this);
    end
    rd_data_mon  = rd_data_monitor::type_id::create(  "rd_data_mon", this);
    `uvm_info(get_name(), "Build phase completed for rdite Data Agent", UVM_LOW)
  endfunction

  //-----------------------------------------------------------------------------
  // Connect Phase
  //-----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);

    // Connect driver to sequencer
    if(get_is_active() == UVM_ACTIVE) begin
      rd_data_driv.seq_item_port.connect(rd_data_sqr.seq_item_export);
    end
    else begin
      `uvm_info(get_name(), "Agent is Passive", UVM_LOW)
    end

    `uvm_info(get_name(), "Connect phase completed for rdite Data Agent", UVM_LOW)
  endfunction

endclass

`endif
