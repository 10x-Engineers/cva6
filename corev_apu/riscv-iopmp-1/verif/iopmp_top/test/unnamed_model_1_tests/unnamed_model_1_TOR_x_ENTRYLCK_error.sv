class unnamed_model_1_TOR_x_ENTRYLCK_error extends unnamed_model_1_base_test;
  `uvm_component_utils(unnamed_model_1_TOR_x_ENTRYLCK_error)
    entrylck_reg_write   entrylck;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq          ar_seq;
    //  iopmp_env     env;

  function new(string name = "unnamed_model_1_TOR_x_ENTRYLCK_error", uvm_component parent = null);
     super.new(name, parent);
      entrylck   = entrylck_reg_write::type_id::create("entrylck");
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
      entrylck.wdata = 64'h900000000;
      entrylck.start(env.ahb_env.ahb_agnt.ahb_sqr);
      
      // trying to write the locked register
      entrylck.wdata = 64'h1000000000;
      entrylck.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = (32'd368)>>2;
      entry_addr.index = 10;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'hC;                      // TOR address mode with read permission granted
      entry_cfg.index = 10;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      #50ns;
      ar_seq.rrid      = 3;
      ar_seq.addr      = 364;
      ar_seq.id        = 3;
      ar_seq.user_perm = 0;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);
      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass