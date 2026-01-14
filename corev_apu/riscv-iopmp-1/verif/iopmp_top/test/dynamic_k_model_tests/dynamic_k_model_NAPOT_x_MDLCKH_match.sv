// Test MDLCK, updating locked srcmd_en field
class dynamic_k_model_NAPOT_x_MDLCKH_match extends dynamic_k_model_base_test;
  `uvm_component_utils(dynamic_k_model_NAPOT_x_MDLCKH_match)
    srcmdenh_reg_write   srcmdenh;
    srcmdrh_reg_write    srcmdrh;
    mdlck_reg_write      mdlck;
    mdlckh_reg_write     mdlckh;
    entry_addr_reg_write entry_addr;
    entry_cfg_reg_write  entry_cfg;
    axi_req_seq_napot    ar_seq;
    //  iopmp_env     env;

  function new(string name = "dynamic_k_model_NAPOT_x_MDLCKH_match", uvm_component parent = null);
     super.new(name, parent);
      mdlck      = mdlck_reg_write::type_id::create("mdlck");
      mdlckh     = mdlckh_reg_write::type_id::create("mdlckh");
      srcmdenh   = srcmdenh_reg_write::type_id::create("srcmdenh");
      srcmdrh    = srcmdrh_reg_write::type_id::create("srcmdrh");
      entry_addr = entry_addr_reg_write::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_write::type_id::create("entry_cfg");
      ar_seq     = axi_req_seq_napot::type_id::create("ar_seq");
   endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      mdlck.wdata = 32'h1;
      mdlck.start(env.ahb_env.ahb_agnt.ahb_sqr);

      mdlckh.wdata = 64'h200000000;
      mdlckh.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdenh.wdata = 64'h100000000;
      srcmdenh.index = 2;
      srcmdenh.start(env.ahb_env.ahb_agnt.ahb_sqr);

      srcmdrh.wdata = 64'h100000000;
      srcmdrh.index = 2;
      srcmdrh.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.wdata = 32'd90;
      entry_addr.index = 93;
      entry_addr.start(env.ahb_env.ahb_agnt.ahb_sqr);

      entry_cfg.wdata = 32'h1C;                     // NAPOT address mode with instruction fetch permission granted
      entry_cfg.index = 93;
      entry_cfg.start(env.ahb_env.ahb_agnt.ahb_sqr);

      // This transaction will be a match
      #50ns;
      ar_seq.rrid      = 2;
      ar_seq.addr      = 360;
      ar_seq.id        = 3;
      ar_seq.user_perm = 1;
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);
      #700;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass