/*************************************************************************
   > File Name:   wr_addr_agent.sv
   > Description: This file defines the `wr_addr_agent` class, which encapsulates
                  the driver, sequencer, and monitor for driving and monitoring 
                  AXI write address transactions.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef WR_ADDR_AGENT
`define WR_ADDR_AGENT

class wr_addr_agent extends uvm_agent;

  `uvm_component_utils(wr_addr_agent)

  // Agent components
  wr_addr_driver    wr_addr_driv;   // Driver instance
  wr_addr_sequencer wr_addr_sqr;    // Sequencer instance
  wr_addr_monitor   wr_addr_mon;    // Monitor instance

  // Constructor
  function new(string name = "wr_addr_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //-----------------------------------------------------------------------------
  // Build Phase
  //-----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create agent components
    if(get_is_active() == UVM_ACTIVE) begin
      wr_addr_driv = wr_addr_driver::type_id::create("wr_addr_driv", this);
      wr_addr_sqr  = wr_addr_sequencer::type_id::create("wr_addr_sqr", this);
    end
    wr_addr_mon  = wr_addr_monitor::type_id::create("wr_addr_mon", this);

    `uvm_info(get_name(), "Build phase completed for Write Address Agent", UVM_LOW)
  endfunction

  //-----------------------------------------------------------------------------
  // Connect Phase
  //-----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);

    // Connect driver to sequencer
    if(get_is_active() == UVM_ACTIVE) begin
      wr_addr_driv.seq_item_port.connect(wr_addr_sqr.seq_item_export);
    end
    else begin
      `uvm_info(get_name(), "Agent is Passive", UVM_LOW)
    end

    `uvm_info(get_name(), "Connect phase completed for Write Address Agent", UVM_LOW)
  endfunction

endclass

`endif
