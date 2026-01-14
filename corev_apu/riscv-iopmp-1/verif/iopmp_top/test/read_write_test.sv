`include "uvm_macros.svh"
import uvm_pkg::*;

class read_write_test extends uvm_test;
    `uvm_component_utils(read_write_test)
        
        iopmp_env     env;   
        read_write_seq  rwh;
    function new(string name = "read_write_test", uvm_component parent = null);
       super.new(name, parent);
     
        rwh = read_write_seq::type_id::create("rwh");
        env = iopmp_env::type_id::create("env", this);
     endfunction

    task main_phase(uvm_phase phase); 
      `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");
     // fork
        // fork
        //   fix_wr_beat1_h.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);
        //   fix_wr_data_beat1_h.start(env.axi_env.wr_data_agnt.wr_data_sqr);
        //   wr_rsp_seq.start( env.axi_env.wr_rsp_agnt.wr_rsp_sqr);
        // join
      rwh.start(env.ahb_env.ahb_agnt.ahb_sqr);
      // join_any
      #50;
      phase.drop_objection(this, "MAIN - drop_objection");
      `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase

endclass