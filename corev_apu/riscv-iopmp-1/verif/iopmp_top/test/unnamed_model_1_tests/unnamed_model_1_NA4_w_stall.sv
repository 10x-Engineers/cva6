class unnamed_model_1_NA4_w_stall extends unnamed_model_1_base_test;
  `uvm_component_utils(unnamed_model_1_NA4_w_stall)
    mdstall_reg_write    mdstall;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq_w        aw_seq;
    axi_req_seq_w_data   aw_seq_data;
    //  iopmp_env     env;

  function new(string name = "unnamed_model_1_NA4_w_stall", uvm_component parent = null);
     super.new(name, parent);
      mdstall     = mdstall_reg_write::type_id::create("mdstall");
      entry_addr  = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg   = entry_cfg_reg_write::type_id::create("entry_cfg");
      aw_seq      = axi_req_seq_w::type_id::create("aw_seq");
      aw_seq_data = axi_req_seq_w_data::type_id::create("aw_seq_data");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      mdstall.wdata = 32'h80000000;
      mdstall.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata=(32'd364)>>2;
      entry_addr.index=3;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata=32'h13;
      entry_cfg.index=3;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      #50ns;
      aw_seq.rrid     = 30;
      aw_seq.addr  = 364;
      aw_seq.id   = 3;
      // aw_seq.user_perm   = 7;
      fork
          aw_seq.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);              //write access test
          aw_seq_data.start(env.axi_env.wr_data_agnt.wr_data_sqr);
      join_any
      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass