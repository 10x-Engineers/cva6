class rapid_k_model_NA4_w_0x02_error extends rapid_k_model_base_test;
  `uvm_component_utils(rapid_k_model_NA4_w_0x02_error)
    srcmden_reg_write    srcmden;
    srcmdr_reg_write     srcmdr;
    srcmdw_reg_write     srcmdw;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq_w        aw_seq;
    axi_req_seq_w_data   aw_seq_data;
    //  iopmp_env     env;

  function new(string name = "rapid_k_model_NA4_w_0x02_error", uvm_component parent = null);
     super.new(name, parent);
      srcmden     = srcmden_reg_write::type_id::create("srcmden");
      srcmdr      = srcmdr_reg_write::type_id::create("srcmdr");
      srcmdw      = srcmdw_reg_write::type_id::create("srcmdw");
      entry_addr  = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg   = entry_cfg_reg_write::type_id::create("entry_cfg");
      aw_seq      = axi_req_seq_w::type_id::create("aw_seq");
      aw_seq_data = axi_req_seq_w_data::type_id::create("aw_seq_data");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
    phase.raise_objection(this, "MAIN - raise_objection");

      srcmden.wdata = 32'h20;                       // Traverse MD 4
      srcmden.index = 32;
      srcmden.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdr.wdata = 32'h20;
      srcmdr.index = 32;
      srcmdr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdw.wdata = 32'h20;
      srcmdw.index = 32;
      srcmdw.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = (32'd364)>>2;
      entry_addr.index = 12;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'h11;                     // NA4 address mode with read permission granted and no write permission
      entry_cfg.index = 12;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // Illegal Write Access Error on this transaction
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