/*************************************************************************
   > File Name:   wr_rsp_agent.sv
   > Description: This file defines the `wr_rsp_agent` class, which encapsulates
                  the driver, sequencer, and monitor for driving and monitoring 
                  AXI write response transactions.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef WR_RSP_AGENT
`define WR_RSP_AGENT

class wr_rsp_agent extends uvm_agent;

  `uvm_component_utils(wr_rsp_agent)

  // Agent components
  wr_rsp_driver    wr_rsp_driv;   // Driver instance
  wr_rsp_sequencer wr_rsp_sqr;    // Sequencer instance
  wr_rsp_monitor   wr_rsp_mon;    // Monitor instance

  // Constructor
  function new(string name = "wr_rsp_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //-----------------------------------------------------------------------------
  // Build Phase
  //-----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create agent components
    if(get_is_active() == UVM_ACTIVE) begin
      wr_rsp_driv = wr_rsp_driver::type_id::create("wr_rsp_driv", this);
      wr_rsp_sqr  = wr_rsp_sequencer::type_id::create("wr_rsp_sqr", this);
    end
    wr_rsp_mon  = wr_rsp_monitor::type_id::create("wr_rsp_mon", this);
    `uvm_info(get_name(), "Build phase completed for Write Response Agent", UVM_LOW)
  endfunction

  //-----------------------------------------------------------------------------
  // Connect Phase
  //-----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);

    // Connect driver to sequencer
    if(get_is_active() == UVM_ACTIVE) begin
      wr_rsp_driv.seq_item_port.connect(wr_rsp_sqr.seq_item_export);
    end
    else begin
      `uvm_info(get_name(), "Agent is Passive", UVM_LOW)
    end

    `uvm_info(get_name(), "Connect phase completed for Write Address Agent", UVM_LOW)
  endfunction

endclass

`endif
