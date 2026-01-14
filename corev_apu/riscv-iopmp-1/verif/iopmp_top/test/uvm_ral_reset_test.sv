`include "uvm_macros.svh"
import uvm_pkg::*;

class uvm_ral_reset_test extends uvm_test;
    `uvm_component_utils(uvm_ral_reset_test)

    uvm_reg_hw_reset_seq reset_seq; //buit-in sequence

    iopmp_env             env;               // Environment handle
    virtual axi_interface axi_vif;           // Virtual interface for AXI signals
    virtual ahb_interface ahb_vif;           // Virtual interface for AXI signals
    configurations        cnfg;              // Configurations

    //-----------------------------------------------------------------------------
    // Function: build_phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "BUILD PHASE STARTED", UVM_LOW);
        reset_seq = uvm_reg_hw_reset_seq::type_id::create("uvm_reset_seq");
        uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
        if (!uvm_config_db#(virtual axi_interface)::get(null, "*", "axi_vif", axi_vif))
            `uvm_error(get_name(), "Failed to connect axi_vif interface")
        if (!uvm_config_db#(virtual ahb_interface#(.ADDR_WIDTH(`AHB_ADDR_WIDTH),.DATA_WIDTH(`AHB_DATA_WIDTH)))::get(null, "*", "ahb_vif", ahb_vif))
            `uvm_error(get_name(), "Failed to connect ahb_vif interface")

        // Create environment
        env = iopmp_env::type_id::create("env", this);
    endfunction : build_phase
    

    //-----------------------------------------------------------------------------
    // Function: end_of_elaboration_phase
    //-----------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

    function new(string name = "uvm_ral_reset_test", uvm_component parent = null);
       super.new(name, parent);
     endfunction

    task main_phase(uvm_phase phase);
      `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");
      reset_seq.model = env.reg_env.regmodel;
      reset_seq.start(null);
      #100ns;
      phase.drop_objection(this, "MAIN - drop_objection");
      `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase

endclass