/*************************************************************************
   > File Name:   rd_addr_agent.sv
   > Description: This file defines the `rd_addr_agent` class, which encapsulates
                  the driver, sequencer, and monitor for driving and monitoring 
                  AXI read address transactions.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef RD_ADDR_AGENT
`define RD_ADDR_AGENT

class rd_addr_agent extends uvm_agent;

  `uvm_component_utils(rd_addr_agent)

  // Agent components
  rd_addr_driver    rd_addr_driv;   // Driver instance
  rd_addr_sequencer rd_addr_sqr;    // Sequencer instance
  rd_addr_monitor   rd_addr_mon;    // Monitor instance

  // Constructor
  function new(string name = "rd_addr_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //-----------------------------------------------------------------------------
  // Build Phase
  //-----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create agent components based on agent nature of being active/passive
    if(get_is_active() == UVM_ACTIVE) begin
      rd_addr_driv = rd_addr_driver::type_id::create("rd_addr_driv", this);
      rd_addr_sqr  = rd_addr_sequencer::type_id::create("rd_addr_sqr", this);
    end
    rd_addr_mon  = rd_addr_monitor::type_id::create("rd_addr_mon", this);

    `uvm_info(get_name(), "Build phase completed for Read Address Agent", UVM_LOW)
  endfunction

  //-----------------------------------------------------------------------------
  // Connect Phase
  //-----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);

    // Connect driver to sequencer if the agent is active
    if(get_is_active() == UVM_ACTIVE) begin
      rd_addr_driv.seq_item_port.connect(rd_addr_sqr.seq_item_export);
    end
    else begin
      `uvm_info(get_name(), "Agent is Passive", UVM_LOW)
    end

    `uvm_info(get_name(), "Connect phase completed for Read Address Agent", UVM_LOW)
  endfunction

endclass

`endif
