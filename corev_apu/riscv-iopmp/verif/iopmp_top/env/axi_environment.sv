/*************************************************************************
   > File Name:   axi_environment.sv
   > Description: Environment class for the AXI setup. 
                  Manages agents, and connections.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef AXI_ENVIRONMENT
`define AXI_ENVIRONMENT

//-----------------------------------------------------------------------------
// AXI2AHB Environment Class
//-----------------------------------------------------------------------------
class axi_environment extends uvm_env;

    `uvm_component_utils(axi_environment)

    //-------------------------------------------------------------------------
    // Member Variables
    //-------------------------------------------------------------------------
    wr_addr_agent      wr_addr_agnt;      // AXI Write Address Agent
    rd_addr_agent      rd_addr_agnt;      // AXI Read Address Agent
    wr_data_agent      wr_data_agnt;      // AXI Write Data Agent
    rd_data_agent      rd_data_agnt;      // AXI Read Data Agent
    wr_rsp_agent       wr_rsp_agnt;       // AXI Write Response Agent

    //-------------------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------------------
    function new(string name = "axi_environment", uvm_component parent);
        super.new(name, parent);
    endfunction

    //-------------------------------------------------------------------------
    // Build Phase
    // Creates AXI agents, AHB agent, and the scoreboard
    //-------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "BUILD Phase of Env", UVM_LOW);

        // Create Agents
        wr_addr_agnt = wr_addr_agent::type_id::create("wr_addr_agnt", this);
        rd_addr_agnt = rd_addr_agent::type_id::create("rd_addr_agnt", this);
        wr_data_agnt = wr_data_agent::type_id::create("wr_data_agnt", this);
        rd_data_agnt = rd_data_agent::type_id::create("rd_data_agnt", this);
        wr_rsp_agnt  = wr_rsp_agent::type_id::create("wr_rsp_agnt", this);

    endfunction

    //-------------------------------------------------------------------------
    // Connect Phase
    // Connects AXI channel's monitor analysis ports to the scoreboard
    //-------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_name(), "CONNECT Phase of Env", UVM_LOW);
    endfunction

endclass

`endif
