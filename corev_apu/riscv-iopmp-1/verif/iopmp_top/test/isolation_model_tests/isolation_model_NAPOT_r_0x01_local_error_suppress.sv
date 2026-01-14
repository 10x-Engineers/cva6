class isolation_model_NAPOT_r_0x01_local_error_suppress extends isolation_model_base_test;
  `uvm_component_utils(isolation_model_NAPOT_r_0x01_local_error_suppress)
    mdcfg_reg_write      mdcfg;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq_napot    ar_seq;
    //  iopmp_env     env;

  function new(string name = "isolation_model_NAPOT_r_0x01_local_error_suppress", uvm_component parent = null);
     super.new(name, parent);
      mdcfg      = mdcfg_reg_write::type_id::create("mdcfg");
      entry_addr = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_write::type_id::create("entry_cfg");
      ar_seq     = axi_req_seq_napot::type_id::create("ar_seq");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");
      
      mdcfg.wdata = 32'h5;                 
      mdcfg.index = 2;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata = 64'h700000000;                 // 2 entries associated with this md   entry 5,6
      mdcfg.index = 3;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = 32'd90;
      entry_addr.index = 5;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'h118;                     // NAPOT address mode with ere suppression and no permissions granted
      entry_cfg.index = 5;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // The transaction is a success but error is reported to EIC Block
      #50ns;
      ar_seq.rrid      = 3;
      ar_seq.addr      = 360;
      ar_seq.id        = 3;
      ar_seq.user_perm = 0;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);
      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass