class rapid_k_model_TOR_r_ENTRYLCK_match extends rapid_k_model_base_test;
  `uvm_component_utils(rapid_k_model_TOR_r_ENTRYLCK_match)
    srcmden_reg_write    srcmden;
    srcmdr_reg_write     srcmdr;
    entrylck_reg_write   entrylck;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq          ar_seq;
    //  iopmp_env     env;

  function new(string name = "rapid_k_model_TOR_r_ENTRYLCK_match", uvm_component parent = null);
     super.new(name, parent);
      entrylck   = entrylck_reg_write::type_id::create("entrylck");
      srcmden    = srcmden_reg_write::type_id::create("srcmden");
      srcmdr     = srcmdr_reg_write::type_id::create("srcmdr");
      entry_addr = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_write::type_id::create("entry_cfg");
      ar_seq     = axi_req_seq::type_id::create("ar_seq");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      entrylck.wdata = 64'h800000000;
      entrylck.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // locking the entrylck register
      entrylck.wdata = 64'h100000000;
      entrylck.start(env.ahb_env.ahb_agnt.ahb_sqr);
      
      // trying to write the locked register
      entrylck.wdata = 64'hA00000000;
      entrylck.start(env.ahb_env.ahb_agnt.ahb_sqr);
      
      srcmden.wdata = 32'h10;                       // Traverse MD 3
      srcmden.index = 2;
      srcmden.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdr.wdata = 32'h10;
      srcmdr.index = 2;
      srcmdr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = (32'd368)>>2;
      entry_addr.index = 9;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'h9;                      // TOR address mode with read permission granted
      entry_cfg.index = 9;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      #50ns;
      ar_seq.rrid      = 2;
      ar_seq.addr      = 364;
      ar_seq.id        = 3;
      ar_seq.user_perm = 0;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);
      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass