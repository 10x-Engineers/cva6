class full_model_TOR_x_0x05_error extends full_model_base_test;
  `uvm_component_utils(full_model_TOR_x_0x05_error)
    srcmden_reg_write    srcmden;
    srcmdr_reg_write     srcmdr;
    mdcfg_reg_write      mdcfg;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq          ar_seq;
    //  iopmp_env     env;

  function new(string name = "full_model_TOR_x_0x05_error", uvm_component parent = null);
     super.new(name, parent);
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

      srcmden.wdata = 32'h8;                       // Traverse MD 2
      srcmden.index = 2;
      srcmden.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdr.wdata = 32'h8;
      srcmdr.index = 2;
      srcmdr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata = 64'h800000000;                         
      mdcfg.index = 1;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata = 64'hB;                          // 3 entries associated with this md   entry 8,9,10
      mdcfg.index = 2;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // Not Hit Any Rule Error on this transaction
      #50ns;
      ar_seq.rrid      = 2;
      ar_seq.addr      = 368;
      ar_seq.id        = 3;
      ar_seq.user_perm = 1;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);
      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass