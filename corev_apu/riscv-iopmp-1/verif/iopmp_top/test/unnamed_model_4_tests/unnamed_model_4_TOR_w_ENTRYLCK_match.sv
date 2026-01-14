class unnamed_model_4_TOR_w_ENTRYLCK_match extends unnamed_model_4_base_test;
  `uvm_component_utils(unnamed_model_4_TOR_w_ENTRYLCK_match)
    srcmdperm_reg_write      srcmdperm;
    entrylck_reg_write       entrylck;
    entry_addr_reg_write     entry_addr;
    entry_cfg_reg_write      entry_cfg;
    axi_req_seq_w_napot      aw_seq;
    axi_req_seq_w_data_napot aw_seq_data;
    //  iopmp_env     env;

  function new(string name = "unnamed_model_4_TOR_w_ENTRYLCK_match", uvm_component parent = null);
     super.new(name, parent);
      entrylck    = entrylck_reg_write::type_id::create("entrylck");
      srcmdperm   = srcmdperm_reg_write::type_id::create("srcmdperm");
      entry_addr  = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg   = entry_cfg_reg_write::type_id::create("entry_cfg");
      aw_seq      = axi_req_seq_w_napot::type_id::create("aw_seq");
      aw_seq_data = axi_req_seq_w_data_napot::type_id::create("aw_seq_data");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      entrylck.wdata = 64'h400000000;
      entrylck.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // locking the entrylck register
      entrylck.wdata = 64'h500000000;
      entrylck.start(env.ahb_env.ahb_agnt.ahb_sqr);
      
      // trying to write the locked register
      entrylck.wdata = 64'h800000000;
      entrylck.start(env.ahb_env.ahb_agnt.ahb_sqr);
      
      srcmdperm.wdata = 32'h10;                       
      srcmdperm.index = 2;
      srcmdperm.start(env.ahb_env.ahb_agnt.ahb_sqr);

     // hwcfg2.prio_entry = 16
      entry_addr.wdata = (32'd368)>>2;
      entry_addr.index = 2;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'hB;                      // TOR address mode with read write permission granted
      entry_cfg.index = 2;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // This transaction will be a match
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