/*************************************************************************
   > File Name:   ahb_environment.sv
   > Description: Environment class for AHB Side.
                  Manages agent, and connections.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef AHB_ENVIRONMENT
`define AHB_ENVIRONMENT

//-----------------------------------------------------------------------------
// AXI2AHB Environment Class
//-----------------------------------------------------------------------------
class ahb_environment extends uvm_env;

    `uvm_component_utils(ahb_environment)

    //-------------------------------------------------------------------------
    // Member Variables
    //-------------------------------------------------------------------------
    ahb_agent          ahb_agnt;          // AHB Agent

    //-------------------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //-------------------------------------------------------------------------
    // Build Phase
    // Creates AXI agents, AHB agent, and the scoreboard
    //-------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "BUILD Phase of Env", UVM_HIGH);

        // Create Agent
        ahb_agnt     = ahb_agent::type_id::create("ahb_agnt", this);
    endfunction

    //-------------------------------------------------------------------------
    // Connect Phase
    // Connects AXI channel's monitor analysis ports to the scoreboard
    //-------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_name(), "CONNECT Phase of AHB Env", UVM_HIGH);
    endfunction

endclass

`endif
