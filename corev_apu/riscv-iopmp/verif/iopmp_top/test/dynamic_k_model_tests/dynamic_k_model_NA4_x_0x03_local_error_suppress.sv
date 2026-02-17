class dynamic_k_model_NA4_x_0x03_local_error_suppress extends dynamic_k_model_base_test;
  `uvm_component_utils(dynamic_k_model_NA4_x_0x03_local_error_suppress)
    srcmden_reg_write    srcmden;
    srcmdr_reg_write     srcmdr;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq          ar_seq;
    //  iopmp_env     env;

  function new(string name = "dynamic_k_model_NA4_x_0x03_local_error_suppress", uvm_component parent = null);
     super.new(name, parent);
      srcmden    = srcmden_reg_write::type_id::create("srcmden");
      srcmdr     = srcmdr_reg_write::type_id::create("srcmdr");
      entry_addr = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_write::type_id::create("entry_cfg");
      ar_seq     = axi_req_seq::type_id::create("ar_seq");
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

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = (32'd364)>>2;
      entry_addr.index = 9;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'h410;                     // NA4 address mode with no permission granted
      entry_cfg.index = 9;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // Illegal Read Access Error on this transaction
      #50ns;
      ar_seq.rrid      = 32;
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