class isolation_model_TOR_x_MDCFGLCK_match extends isolation_model_base_test;
  `uvm_component_utils(isolation_model_TOR_x_MDCFGLCK_match)
    mdcfg_reg_write      mdcfg;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    mdcfglck_reg_write   mdcfglck;
    axi_req_seq          ar_seq;
    //  iopmp_env     env;

  function new(string name = "isolation_model_TOR_x_MDCFGLCK_match", uvm_component parent = null);
     super.new(name, parent);
      mdcfglck   = mdcfglck_reg_write::type_id::create("mdcfglck");
      mdcfg      = mdcfg_reg_write::type_id::create("mdcfg");
      entry_addr = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_write::type_id::create("entry_cfg");
      ar_seq     = axi_req_seq::type_id::create("ar_seq");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      // 2 mdcfg registers (0,1) are locked
      mdcfglck.wdata = 32'h4;
      mdcfglck.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata = 64'h200000000;                  // 2 entries associated with this md   entry 0,1
      mdcfg.index = 3;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = (32'd368)>>2;
      entry_addr.index = 1;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'hC;                      // TOR address mode with instruction fetch permission granted
      entry_cfg.index = 1;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      #50ns;
      ar_seq.rrid      = 3;
      ar_seq.addr      = 364;
      ar_seq.id        = 3;
      ar_seq.user_perm = 1;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);              //read access test
        // fix_wr_data_beat19_h.start(env.axi_env.wr_data_agnt.wr_data_sqr);
        // wr_rsp_seq.start( env.axi_env.wr_rsp_agnt.wr_rsp_sqr);

      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass