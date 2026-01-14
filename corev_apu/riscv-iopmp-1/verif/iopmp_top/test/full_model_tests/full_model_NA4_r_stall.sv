class full_model_NA4_r_stall extends full_model_base_test;
  `uvm_component_utils(full_model_NA4_r_stall)
    mdstall_reg_write    mdstall_w;
    read_write_seq   mdstall_r;
    srcmden_reg_write    srcmden;
    srcmdr_reg_write     srcmdr;
    mdcfg_reg_write      mdcfg;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq          ar_seq;
    logic [31:0]         read_mdstall;

  function new(string name = "full_model_NA4_r_stall", uvm_component parent = null);
     super.new(name, parent);
      mdstall_w  = mdstall_reg_write::type_id::create("mdstall_w");
      mdstall_r  = read_write_seq::type_id::create("mdstall_r");
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

      srcmden.wdata=32'h10;                         // Traverse MD 3
      srcmden.index=32;
      srcmden.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdstall_w.wdata = 32'h10;
      mdstall_w.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdr.wdata=32'h10;
      srcmdr.index=32;
      srcmdr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata=64'h300000000;                    // 3 entries associated with this md   entry 0,1,2
      mdcfg.index=3;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata=(32'd364)>>2;
      entry_addr.index=3;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata=32'h11;
      entry_cfg.index=3;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      #30ns;
      ar_seq.rrid     = 32;
      ar_seq.addr  = 364;
      ar_seq.id   = 3;
      ar_seq.user_perm   = 0;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

      #210ns;
      //read_mdstall = mdstall_r.start(env.ahb_env.ahb_agnt.ahb_sqr);

      //for (integer i=0; (read_mdstall[0] != 1); i++) begin
      //  read_mdstall = mdstall_r.start(env.ahb_env.ahb_agnt.ahb_sqr);
      //end

      srcmden.wdata=32'h8;                         // Traverse MD 3
      srcmden.index=32;
      srcmden.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdr.wdata=32'h8;
      srcmdr.index=32;
      srcmdr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata=32'h4;                    // 4 entries associated with this md   entry 0,1,2,3
      mdcfg.index=2;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdstall_w.wdata = 32'h0;
      mdstall_w.start(env.ahb_env.ahb_agnt.ahb_sqr);

      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass