/*************************************************************************
   > File Name:   full_model_base_test.sv
   > Description: full_model_base_test to test full model.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
`include "uvm_macros.svh"
import uvm_pkg::*;

class full_model_base_test extends uvm_test;
    `uvm_component_utils(full_model_base_test)

    iopmp_env             env;               // Environment handle
    virtual axi_interface axi_vif;           // Virtual interface for AXI signals
    virtual ahb_interface ahb_vif;           // Virtual interface for AXI signals
    configurations        cnfg;              // Configurations
    ahb_base_seq          reg_seqnc;
    iopmp_reg regmodel;
    uvm_reg rg;
    axi_s_config cfg;

    logic [2:0] HSIZE;
    logic [2:0] HBURST;
    logic [1:0] HTRANS;
    logic [3:0] HPROT;
    logic       HMASTLOCK;

    //-----------------------------------------------------------------------------
    // Function: build_phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "BUILD PHASE STARTED", UVM_LOW);
        $readmemh("./../tb/BOOT_IMG0",cfg.mem_0);
        $readmemh("./../tb/BOOT_IMG1",cfg.mem_1);
        uvm_config_db#(axi_s_config)::set(null, "*", "cfg", cfg);
        if (!uvm_config_db#(virtual axi_interface)::get(null, "*", "axi_vif", axi_vif))
            `uvm_error(get_name(), "Failed to connect axi_vif interface")
        if (!uvm_config_db#(virtual ahb_interface#(.ADDR_WIDTH(`AHB_ADDR_WIDTH),.DATA_WIDTH(`AHB_DATA_WIDTH)))::get(null, "*", "ahb_vif", ahb_vif))
            `uvm_error(get_name(), "Failed to connect ahb_vif interface")
        // Create environment
        env = iopmp_env::type_id::create("env", this);
        regmodel = iopmp_reg::type_id::create("regmodel", this);
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);
        reg_seqnc = ahb_base_seq::type_id::create("reg_seqnc", this);
        // reg_seqnc.regmodel = regmodel;
        
    endfunction : build_phase

    //-----------------------------------------------------------------------------
    // Function: end_of_elaboration_phase
    //-----------------------------------------------------------------------------

    function new(string name = "full_model_base_test", uvm_component parent = null);
       super.new(name, parent);
     endfunction

    //  task reset_phase(uvm_phase phase);
    //     phase.raise_objection(this);
    //     `uvm_info(get_name(), "<reset_phase> started, objection raised.", UVM_NONE)   
    //     clk_if.apply_reset(.reset_width_clks (10));    
    //     phase.drop_objection(this);
    //     `uvm_info(get_name(), "<reset_phase> finished, objection dropped.", UVM_NONE)
    // endtask: reset_phase 

    task main_phase(uvm_phase phase);
      `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");
    //   rg = reg_seqnc.regmodel.default_map.get_reg_by_offset(0, 0);
    //     `uvm_info(get_type_name(),$sformatf("BASE_TEST RAL_REG_ENV:::: %s", rg.get_full_name()),UVM_LOW);

      // #50;
      phase.drop_objection(this, "MAIN - drop_objection");
      `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase

    function void connect_phase(uvm_phase phase);
		// uvm_config_db#(iopmp_reg)::get(this, "", "regmodel", reg_seqnc.regmodel);
        // rg = reg_seqnc.regmodel.default_map.get_reg_by_offset(0, 0);
        // `uvm_info(get_type_name(),$sformatf("RAL_REG_ENV:::: %s", rg.get_full_name()),UVM_LOW);
    endfunction : connect_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info(get_name(), "------------------------- Topology Report -------------------------", UVM_LOW);
        uvm_top.print_topology();
    endfunction: end_of_elaboration_phase

endclass