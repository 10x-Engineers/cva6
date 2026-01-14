class full_model_NA4_r_0x01_error extends full_model_base_test;
  `uvm_component_utils(full_model_NA4_r_0x01_error)
    srcmden_reg_seq    srcmden;
    srcmdr_reg_seq     srcmdr;
    mdcfg_reg_seq      mdcfg;
    entry_addr_reg_seq entry_addr;
    entry_cfg_reg_seq  entry_cfg;
    axi_req_seq          ar_seq;
    axi_s_sanity_seq      s_seq;

  function new(string name = "full_model_NA4_r_0x01_error", uvm_component parent = null);
     super.new(name, parent);
      srcmden    = srcmden_reg_seq::type_id::create("srcmden");
      srcmdr     = srcmdr_reg_seq::type_id::create("srcmdr");
      mdcfg      = mdcfg_reg_seq::type_id::create("mdcfg");
      entry_addr = entry_addr_reg_seq::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_seq::type_id::create("entry_cfg");
      ar_seq     = axi_req_seq::type_id::create("ar_seq");
      s_seq      = axi_s_sanity_seq::type_id::create("s_Seq");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      env.reg_env.ahb_agnt.ahb_drv.HSIZE     = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HBURST    = 0;
      env.reg_env.ahb_agnt.ahb_drv.HTRANS    = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HPROT     = 'd1;
      env.reg_env.ahb_agnt.ahb_drv.HMASTLOCK = 0;
      env.reg_env.ahb_agnt.ahb_drv.HSEL = 1;

      srcmden.b_data = 32'h10;                       // Traverse MD 3
      srcmden.index = 32;
      srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

      srcmdr.b_data = 32'h10;
      srcmdr.index = 32;
      srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

      mdcfg.b_data = 32'h10;
      mdcfg.index = 2;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      mdcfg.b_data = 64'h1300000000;                 // 3 entries associated with this md   entry 16,17, 18
      mdcfg.index = 3;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.b_data = (32'd364)>>2;
      entry_addr.index = 17;
      entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data = 32'h10;                     // NA4 address mode with no permission granted
      entry_cfg.index = 17;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      // Illegal Read Access Error on this transaction
      #50;
      ar_seq.rrid      = 32;
      ar_seq.addr      = 364;
      ar_seq.id        = 3;
      ar_seq.user_perm = 0;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);              //read access test

      fork
        s_seq.start(env.axi_s_env.agent.sequencer);
      #300;
      join_any
      #100;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass