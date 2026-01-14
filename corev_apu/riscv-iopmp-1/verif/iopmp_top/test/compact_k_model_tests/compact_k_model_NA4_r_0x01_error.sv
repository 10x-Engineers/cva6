class compact_k_model_NA4_r_0x01_error extends compact_k_model_base_test;
  `uvm_component_utils(compact_k_model_NA4_r_0x01_error)
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq          ar_seq;
    //  iopmp_env     env;

  function new(string name = "compact_k_model_NA4_r_0x01_error", uvm_component parent = null);
     super.new(name, parent);
      entry_addr = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_write::type_id::create("entry_cfg");
      ar_seq     = axi_req_seq::type_id::create("ar_seq");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      // hwcfg2.prio_entry = 16
      // Illegal Read Access Error
      entry_addr.wdata = (32'd364)>>2;
      entry_addr.index = 12;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'h10;
      entry_cfg.index = 12;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      #50ns;
      ar_seq.rrid      = 32;
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