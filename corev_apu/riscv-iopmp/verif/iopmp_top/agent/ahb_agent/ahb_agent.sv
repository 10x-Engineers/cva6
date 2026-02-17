/*************************************************************************
   > File Name:   ahb_agent.sv
   > Description: This file defines the `ahb_agent` class, which encapsulates
                  the AHB sequencer, driver, and monitor for AXI verification.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef AHB_AGENT
`define AHB_AGENT

class ahb_agent extends uvm_agent;

  `uvm_component_utils(ahb_agent)

  // Components
  ahb_sequencer ahb_sqr;
  ahb_driver    ahb_drv;
  ahb_monitor   ahb_mon;
  configurations  cnfg;

  // Constructor
  function new(string name = "ahb_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //-----------------------------------------------------------------------------
  // Build Phase
  //-----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // if (!uvm_config_db #(configurations)::get(this,"*","configurations", cnfg))
    //   `uvm_fatal("FATAL MSG", "Configuration object is not set properly");

    if(get_is_active() == UVM_ACTIVE) begin
      ahb_drv = ahb_driver::type_id::create("ahb_drv", this);
      ahb_sqr = ahb_sequencer::type_id::create("ahb_sqr", this);
    end

    ahb_mon = ahb_monitor::type_id::create("ahb_mon", this);
    `uvm_info(get_name(), "Build Phase completed for AHB Agent", UVM_LOW)
  endfunction : build_phase

  //-----------------------------------------------------------------------------
  // Connect Phase
  //-----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);

    if(get_is_active() == UVM_ACTIVE) begin
      ahb_drv.seq_item_port.connect(ahb_sqr.seq_item_export);
    end
    else begin
      `uvm_info(get_name(), "Agent is Passive", UVM_HIGH)
    end

    `uvm_info(get_name(), "Connect Phase completed for AHB Agent", UVM_HIGH)
  endfunction : connect_phase

endclass : ahb_agent

`endif
