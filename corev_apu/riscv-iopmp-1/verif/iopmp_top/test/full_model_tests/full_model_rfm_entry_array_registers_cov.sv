/*************************************************************************
   > File Name:   full_model_rfm_entry_array_registers_cov.sv
   > Description: 
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class ill_addr1;
  randc [31:0] illegal_addr;
  randc [31:0] illegal_addr1;
  randc [31:0] illegal_addr2;

  constraint ill{ illegal_addr inside  {32'h20, 32'h24, 32'h28};}

  constraint ill1{ illegal_addr1 inside  {32'h40, 32'h44};}

  constraint ill2{ 
    illegal_addr2 inside  {[32'h50:32'h5C]};
    illegal_addr2 % 4 ==0;
    }
endclass

class full_model_rfm_entry_array_registers_cov extends full_model_base_test;
  `uvm_component_utils(full_model_rfm_entry_array_registers_cov)
    entry_addr_reg_seq    entry_addr;
    entry_addrh_reg_seq   entry_addrh;
    entry_cfg_reg_seq     entry_cfg;

    ill_addr rand_addr;

  function new(string name = "full_model_rfm_entry_array_registers_cov", uvm_component parent = null);
     super.new(name, parent);
      entry_addr = entry_addr_reg_seq::type_id::create("entry_addr");
      entry_addrh = entry_addrh_reg_seq::type_id::create("entry_addrh");
      entry_cfg = entry_cfg_reg_seq::type_id::create("entry_cfg");
      rand_addr   = new();
  endfunction
   

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      env.reg_env.ahb_agnt.ahb_drv.HSIZE     = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HBURST    = 0;
      env.reg_env.ahb_agnt.ahb_drv.HTRANS    = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HPROT     = 'd3;
      env.reg_env.ahb_agnt.ahb_drv.HMASTLOCK = 0;
      env.reg_env.ahb_agnt.ahb_drv.HSEL = 1;

      rand_addr.randomize();

      // Entry registers read coverage hit.

      for(int i = 0; i<128; i++)
      begin
        entry_addr.read = 1;
        entry_addr.index = i;
        entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

        entry_addrh.read = 1;
        entry_addrh.index = i;
        entry_addrh.start(env.reg_env.ahb_agnt.ahb_sqr);

        entry_cfg.read = 1;
        entry_cfg.index = i;
        entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);
      end

      #100;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass