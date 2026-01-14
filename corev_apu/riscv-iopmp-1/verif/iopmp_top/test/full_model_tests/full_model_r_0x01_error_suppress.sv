class full_model_r_0x01_error_suppress extends full_model_base_test;
  `uvm_component_utils(full_model_r_0x01_error_suppress)
    err_cfg_reg_write    err_cfg;
    srcmden_reg_write    srcmden;
    srcmdr_reg_write     srcmdr;
    mdcfg_reg_write      mdcfg;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq          ar_seq;
    //  iopmp_env     env;

  function new(string name = "full_model_r_0x01_error_suppress", uvm_component parent = null);
     super.new(name, parent);
      err_cfg    = err_cfg_reg_write::type_id::create("err_cfg");
      srcmden    = srcmden_reg_write::type_id::create("srcmden");
      srcmdr     = srcmdr_reg_write::type_id::create("srcmdr");
      mdcfg      = mdcfg_reg_write::type_id::create("mdcfg");
      entry_addr = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_write::type_id::create("entry_cfg");
      ar_seq     = axi_req_seq::type_id::create("ar_seq");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      err_cfg.wdata = 32'h4;
      err_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmden.wdata = 32'h10;                       // Traverse MD 3
      srcmden.index = 3;
      srcmden.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdr.wdata = 32'h10;
      srcmdr.index = 3;
      srcmdr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata = 32'h5;                 
      mdcfg.index = 2;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata = 64'h700000000;                 // 2 entries associated with this md   entry 5,6
      mdcfg.index = 3;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = (32'd364)>>2;
      entry_addr.index = 5;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'h110;                     // NA4 address mode with ere suppression and no permissions granted
      entry_cfg.index = 5;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // The transaction is a success but error is reported to EIC Block
      #50ns;
      ar_seq.rrid      = 3;
      ar_seq.addr      = 364;
      ar_seq.id        = 3;
      ar_seq.user_perm = 0;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);
      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass