class unnamed_model_3_TOR_r_0x01_error extends unnamed_model_3_base_test;
  `uvm_component_utils(unnamed_model_3_TOR_r_0x01_error)
    srcmdperm_reg_write  srcmdperm;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq          ar_seq;
    //  iopmp_env     env;

  function new(string name = "unnamed_model_3_TOR_r_0x01_error", uvm_component parent = null);
     super.new(name, parent);
      srcmdperm  = srcmdperm_reg_write::type_id::create("srcmdperm");
      entry_addr = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_write::type_id::create("entry_cfg");
      ar_seq     = axi_req_seq::type_id::create("ar_seq");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      // srcmdperm.wdata = 32'h10;
      // srcmdperm.index = 2;
      // srcmdperm.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = (32'd368)>>2;
      entry_addr.index = 0;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'h8;                      // TOR address mode with no permissions granted
      entry_cfg.index = 0;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // Illegal Read Access Error on this transaction
      #50ns;
      ar_seq.rrid      = 2;
      ar_seq.addr      = 364;
      ar_seq.id        = 3;
      ar_seq.user_perm = 0;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);              //read access test
        // fix_wr_data_beat19_h.start(env.axi_env.wr_data_agnt.wr_data_sqr);
        // wr_rsp_seq.start( env.axi_env.wr_rsp_agnt.wr_rsp_sqr);

      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass