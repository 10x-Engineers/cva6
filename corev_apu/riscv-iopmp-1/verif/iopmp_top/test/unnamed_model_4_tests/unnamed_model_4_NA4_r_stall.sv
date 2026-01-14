class unnamed_model_4_NA4_r_stall extends unnamed_model_4_base_test;
  `uvm_component_utils(unnamed_model_4_NA4_r_stall)
    mdstall_reg_write    mdstall;
    srcmdperm_reg_write  srcmdperm;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq          ar_seq;
    //  iopmp_env     env;

  function new(string name = "unnamed_model_4_NA4_r_stall", uvm_component parent = null);
     super.new(name, parent);
      mdstall    = mdstall_reg_write::type_id::create("mdstall");
      srcmdperm  = srcmdperm_reg_write::type_id::create("srcmdperm");
      entry_addr = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_write::type_id::create("entry_cfg");
      ar_seq     = axi_req_seq::type_id::create("ar_seq");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      srcmdperm.wdata=32'h10;
      srcmdperm.index=32;
      srcmdperm.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata=(32'd364)>>2;
      entry_addr.index=1;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata=32'h11;
      entry_cfg.index=1;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      #50ns;
      ar_seq.rrid     = 32;
      ar_seq.addr  = 364;
      ar_seq.id   = 3;
      ar_seq.user_perm   = 0;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);              //read access test
        // fix_wr_data_beat19_h.start(env.axi_env.wr_data_agnt.wr_data_sqr);
        // wr_rsp_seq.start( env.axi_env.wr_rsp_agnt.wr_rsp_sqr);

      #50ns;
      mdstall.wdata = 32'h10;
      mdstall.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdperm.wdata=32'h8;
      srcmdperm.index=30;
      srcmdperm.start(env.ahb_env.ahb_agnt.ahb_sqr);

      
      
      

      // hwcfg2.prio_entry = 16
      entry_addr.wdata=(32'd364)>>2;
      entry_addr.index=1;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata=32'h11;
      entry_cfg.index=1;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdstall.wdata = 32'h00000000;
      mdstall.start(env.ahb_env.ahb_agnt.ahb_sqr);

      #50ns;
      ar_seq.rrid     = 30;
      ar_seq.addr  = 364;
      ar_seq.id   = 3;
      ar_seq.user_perm   = 0;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

      #50ns;
      ar_seq.rrid      = 32;
      ar_seq.addr      = 364;
      ar_seq.id        = 3;
      ar_seq.user_perm = 0;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);
      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass