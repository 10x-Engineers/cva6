`include "uvm_macros.svh"
import uvm_pkg::*;

class rapid_k_model_base_test extends uvm_test;
    `uvm_component_utils(rapid_k_model_base_test)

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

    function new(string name = "rapid_k_model_base_test", uvm_component parent = null);
       super.new(name, parent);
     endfunction

    task main_phase(uvm_phase phase);
      `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");
      // fork
      //   fork
      //     fix_wr_beat1_h.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);
      //     fix_wr_data_beat1_h.start(env.axi_env.wr_data_agnt.wr_data_sqr);
      //     wr_rsp_seq.start( env.axi_env.wr_rsp_agnt.wr_rsp_sqr);
      //   join
      //   ahb_seq.start(env.ahb_env.ahb_agnt.ahb_sqr);
      // join_any
      // #50;
      phase.drop_objection(this, "MAIN - drop_objection");
      `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase

endclass