class full_model_NA4_w_stall extends full_model_base_test;
  `uvm_component_utils(full_model_NA4_w_stall)
    srcmden_reg_write srcmden;
    srcmdr_reg_write  srcmdr;
    srcmdw_reg_write  srcmdw;
    mdcfg_reg_write   mdcfg;
    mdstall_reg_write mdstall;

    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write entry_cfg;
    axi_req_seq_w aw_seq;
    axi_req_seq_w_data aw_seq_data;
    //  iopmp_env     env;

  function new(string name = "full_model_NA4_w_stall", uvm_component parent = null);
     super.new(name, parent);
      srcmden = srcmden_reg_write::type_id::create("srcmden");
      srcmdr = srcmdr_reg_write::type_id::create("srcmdr");
      srcmdw = srcmdw_reg_write::type_id::create("srcmdw");
      mdcfg = mdcfg_reg_write::type_id::create("mdcfg");
      mdstall = mdstall_reg_write::type_id::create("mdstall");
      entry_addr = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg = entry_cfg_reg_write::type_id::create("entry_cfg");
      aw_seq = axi_req_seq_w::type_id::create("aw_seq");
      aw_seq_data = axi_req_seq_w_data::type_id::create("aw_seq_data");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
     phase.raise_objection(this, "MAIN - raise_objection");

      srcmden.wdata = 32'h10;                       // Traverse MD 3
      srcmden.index = 32;
      srcmden.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdr.wdata = 32'h10;
      srcmdr.index = 32;
      srcmdr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdw.wdata = 32'h10;
      srcmdw.index = 32;
      srcmdw.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdstall.wdata = 32'h10;
      mdstall.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata = 64'h500000000;                  // 5 entries associated with this md   entry 0,1,2,3,4
      mdcfg.index = 3;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

     // hwcfg2.prio_entry = 16
      entry_addr.wdata = (32'd364)>>2;
      entry_addr.index = 3;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'h13;
      entry_cfg.index = 3;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      #50ns;
      aw_seq.rrid = 32;
      aw_seq.addr = 364;
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