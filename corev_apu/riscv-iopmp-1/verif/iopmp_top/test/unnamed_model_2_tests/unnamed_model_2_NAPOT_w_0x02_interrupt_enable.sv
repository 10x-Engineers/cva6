class unnamed_model_2_NAPOT_w_0x02_interrupt_enable extends unnamed_model_2_base_test;
  `uvm_component_utils(unnamed_model_2_NAPOT_w_0x02_interrupt_enable)
    srcmdperm_reg_write      srcmdperm;
    mdcfg_reg_write          mdcfg;
    err_cfg_reg_write        err_cfg;
    entry_addr_reg_write     entry_addr;
    entry_cfg_reg_write      entry_cfg;
    axi_req_seq_w_napot      aw_seq;
    axi_req_seq_w_data_napot aw_seq_data;
    //  iopmp_env     env;

  function new(string name = "unnamed_model_2_NAPOT_w_0x02_interrupt_enable", uvm_component parent = null);
     super.new(name, parent);
      err_cfg     = err_cfg_reg_write::type_id::create("err_cfg");
      srcmdperm   = srcmdperm_reg_write::type_id::create("srcmdperm");
      mdcfg       = mdcfg_reg_write::type_id::create("mdcfg");
      entry_addr  = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg   = entry_cfg_reg_write::type_id::create("entry_cfg");
      aw_seq      = axi_req_seq_w_napot::type_id::create("aw_seq");
      aw_seq_data = axi_req_seq_w_data_napot::type_id::create("aw_seq_data");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      err_cfg.wdata = 32'h2;
      err_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdperm.wdata = 32'h1;
      srcmdperm.index = 31;
      srcmdperm.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata = 64'h200000000;                          // 3 entries associated with this md   entry 0,1,2
      mdcfg.index = 31;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = 32'd90;
      entry_addr.index = 0;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // PEIS is disbaled
      entry_cfg.wdata = 32'h18;                     // NAPOT address mode and no permissions granted
      entry_cfg.index = 0;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // The transaction is a success but error is reported to EIC Block
      #50ns;
      aw_seq.rrid = 2;
      aw_seq.addr = 360;
      aw_seq.id   = 3;
      fork
          aw_seq.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);              //write access test
          aw_seq_data.start(env.axi_env.wr_data_agnt.wr_data_sqr);
      join_any
      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass