/*************************************************************************
   > File Name:   full_model_rfm_read_registers_cov.sv
   > Description: Send read address for Full MOdel with NA4 Addressing mode with r permission in entry_cfg. Set address to illegal 1C.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

class full_model_rfm_read_registers_cov extends full_model_base_test;
  `uvm_component_utils(full_model_rfm_read_registers_cov)
    hwcfg1_reg_seq        hwcfg1;
    entryoffset_reg_seq   entryoff;
    base_addr_reg_seq     base_addr;
    err_info_reg_seq      err_info;
    err_reqaddr_reg_seq   err_reqaddr;
    err_reqaddrh_reg_seq  err_reqaddrh;
    err_reqid_reg_seq     err_reqid;


  function new(string name = "full_model_rfm_read_registers_cov", uvm_component parent = null);
     super.new(name, parent);
      hwcfg1      = hwcfg1_reg_seq::type_id::create("hwcfg1");
      entryoff    = entryoffset_reg_seq::type_id::create("entryoffset_reg_seq");
      base_addr   = base_addr_reg_seq::type_id::create("base_addr");
      err_info    = err_info_reg_seq::type_id::create("err_info");
      err_reqaddr = err_reqaddr_reg_seq::type_id::create("err_reqaddr");
      err_reqaddrh= err_reqaddrh_reg_seq::type_id::create("err_reqaddrh");
      err_reqid   = err_reqid_reg_seq::type_id::create("err_reqid");
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


      //rfm_cover_hwcfg1
      hwcfg1.read = 1;                        
      hwcfg1.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_entry_offset
      entryoff.read = 1;                        
      entryoff.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_base_addr
      base_addr.read = 1;                        
      base_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_err_info
      err_info.read = 1;                        
      err_info.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_err_reqaddr
      err_reqaddr.read = 1;                        
      err_reqaddr.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_err_reqaddrh
      err_reqaddrh.read = 1;                        
      err_reqaddrh.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_offset_70
      err_reqid.read = 1;                        
      err_reqid.start(env.reg_env.ahb_agnt.ahb_sqr);



      

      #100;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass