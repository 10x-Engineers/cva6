/*************************************************************************
   > File Name:   ral_reg_env.sv
   > Description: Environment class for registers.
                  Manages agent, and connections.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef RAL_ENVIRONMENT
`define RAL_ENVIRONMENT

//-----------------------------------------------------------------------------
// ral_reg_env Environment Class
//-----------------------------------------------------------------------------
class ral_reg_env extends uvm_env;
    `uvm_component_utils(ral_reg_env)

    //-------------------------------------------------------------------------
    // Member Variables
    //-------------------------------------------------------------------------
    ahb_agent          ahb_agnt;          // AHB Agent
    //-------------------------------------------------------------------------
    //UVM RAL components
    //-------------------------------------------------------------------------
    top_adapter adapter;
    iopmp_reg regmodel;

    uvm_reg rg;
    uvm_reg_predictor #(ahb_seq_item) predictor;






    //-------------------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------------------
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //-------------------------------------------------------------------------
    // Build Phase
    // Creates AXI agents, AHB agent, and the scoreboard
    //-------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "BUILD Phase of Env", UVM_LOW);

        // Create Agent
        ahb_agnt = ahb_agent::type_id::create("ahb_agnt", this);

        //RAL
        // regmodel = iopmp_reg::type_id::create("regmodel", this);

        adapter = top_adapter::type_id::create("adapter",, get_full_name());
        predictor = uvm_reg_predictor #(ahb_seq_item) :: type_id:: create("predictor", this);

        // regmodel = iopmp_reg::type_id::create("regmodel", this);
        // regmodel.build();
        // regmodel.reset();
        // regmodel.default_map.set_base_addr(0);
        // regmodel.lock_model();

        // Try to get regmodel from config_db
        if (!uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel)) begin
            `uvm_fatal("RAL_ENV", "regmodel not found in config_db")
          end else begin
            `uvm_info("RAL_ENV", $sformatf("regmodel retrieved: %s, using map: %s",
                        regmodel.get_name(), regmodel.default_map.get_name()), UVM_LOW)
            predictor.map     = regmodel.default_map;
            predictor.adapter = adapter;
          end

    endfunction

    //-------------------------------------------------------------------------
    // Connect Phase
    // Connects AXI channel's monitor analysis ports to the scoreboard
    //-------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_name(), "CONNECT Phase of AHB Env", UVM_LOW);
        regmodel.default_map.set_sequencer( .sequencer(ahb_agnt.ahb_sqr), .adapter(adapter) );
    endfunction

endclass

`endif
