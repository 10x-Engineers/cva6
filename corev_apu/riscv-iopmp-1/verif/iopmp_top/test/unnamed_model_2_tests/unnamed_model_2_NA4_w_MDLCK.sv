class unnamed_model_2_NA4_w_MDLCK extends unnamed_model_2_base_test;
  `uvm_component_utils(unnamed_model_2_NA4_w_MDLCK)
    srcmdperm_reg_write  srcmdperm;
    mdlck_reg_write      mdlck;
    mdcfg_reg_write      mdcfg;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq_w        aw_seq;
    axi_req_seq_w_data   aw_seq_data;
    //  iopmp_env     env;

  function new(string name = "unnamed_model_2_NA4_w_MDLCK", uvm_component parent = null);
     super.new(name, parent);
      mdlck      = mdlck_reg_write::type_id::create("mdlck");
      srcmdperm   = srcmdperm_reg_write::type_id::create("srcmdperm");
      mdcfg       = mdcfg_reg_write::type_id::create("mdcfg");
      entry_addr  = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg   = entry_cfg_reg_write::type_id::create("entry_cfg");
      aw_seq      = axi_req_seq_w::type_id::create("aw_seq");
      aw_seq_data = axi_req_seq_w_data::type_id::create("aw_seq_data");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      mdlck.wdata = 32'h8;
      mdlck.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdlck.wdata = 32'h9;
      mdlck.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdlck.wdata = 32'h10;
      mdlck.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdperm.wdata = 32'h30;
      srcmdperm.index = 2;
      srcmdperm.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdcfg.wdata = 32'h3;                          // 3 entries associated with this md   entry 0,1,2
      mdcfg.index = 2;
      mdcfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = (32'd364)>>2;
      entry_addr.index = 2;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'h13;                      // NA4 address mode with read and write permission granted
      entry_cfg.index = 2;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // This transaction will be a match as permissions are granted by entry_cfg
      #50ns;
      aw_seq.rrid = 2;
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