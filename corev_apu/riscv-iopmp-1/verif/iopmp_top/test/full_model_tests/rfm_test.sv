class rfm_test extends full_model_base_test;
  `uvm_component_utils(rfm_test)
    // srcmden_reg_seq     srcmden;
    // srcmdr_reg_seq      srcmdr;
    mdcfg_reg_seq       mdcfg;
    // entry_addr_reg_seq  entry_addr;
    // entry_cfg_reg_seq   entry_cfg;
    // errcfg_reg_seq      err_cfg;
    // mdstall_reg_seq     mdstall;
    // mdstallh_reg_seq    mdstallh;
    // rridscp_reg_seq     rridscp;
    // version_reg_seq     version;
    // imp_reg_seq         imp;
    // hwcfg0_reg_seq      hwcfg0;
    // hwcfg1_reg_seq      hwcfg1;
    // hwcfg2_reg_seq      hwcfg2;
    // entryoffset_reg_seq entryoffset;
    // mdlck_reg_seq       mdlck;
    // mdlckh_reg_seq      mdlckh;
    // mdcfglck_reg_seq    mdcfglck;
    // entrylck_reg_seq    entrylck;
    //entry_cfg_reg_write  entry_cfg;



  function new(string name = "rfm_test", uvm_component parent = null);
     super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // entry_cfg  = entry_cfg_reg_write::type_id::create("entry_cfg");
    // srcmden     = srcmden_reg_seq::type_id::create("srcmden");
    // srcmdr      = srcmdr_reg_seq::type_id::create("srcmdr");
    mdcfg       = mdcfg_reg_seq::type_id::create("mdcfg");
    // entry_addr  = entry_addr_reg_seq::type_id::create("entry_addr");
    // entry_cfg   = entry_cfg_reg_seq::type_id::create("entry_cfg");
    // err_cfg     = errcfg_reg_seq::type_id::create("err_cfg");
    // mdstall     = mdstall_reg_seq::type_id::create("mdstall");
    // mdstallh    = mdstallh_reg_seq::type_id::create("mdstallh");
    // rridscp     = rridscp_reg_seq::type_id::create("rridscp");
    // version     = version_reg_seq::type_id::create("version");
    // imp         = imp_reg_seq::type_id::create("imp");
    // hwcfg0      = hwcfg0_reg_seq::type_id::create("hwcfg0");
    // hwcfg1      = hwcfg1_reg_seq::type_id::create("hwcfg1");
    // hwcfg2      = hwcfg2_reg_seq::type_id::create("hwcfg2");
    // entryoffset = entryoffset_reg_seq::type_id::create("entryoffset");
    // mdlck       = mdlck_reg_seq::type_id::create("mdlck");
    // mdlckh      = mdlckh_reg_seq::type_id::create("mdlckh");
    // mdcfglck    = mdcfglck_reg_seq::type_id::create("mdcfglck");
    // entrylck    = entrylck_reg_seq::type_id::create("entrylck");
  endfunction

  task main_phase(uvm_phase phase);
  super.main_phase(phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      env.reg_env.ahb_agnt.ahb_drv.HSIZE     = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HBURST    = 0;
      env.reg_env.ahb_agnt.ahb_drv.HTRANS    = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HPROT     = 'd1;
      env.reg_env.ahb_agnt.ahb_drv.HMASTLOCK = 0;
      env.reg_env.ahb_agnt.ahb_drv.HSEL = 1;

      // entry_cfg.wdata=32'h11;
      // entry_cfg.index=3;
      // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #5ns;

      // srcmden.b_data = 32'hDDDDDD;
      // srcmden.index = 2;
      // srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10

      // srcmden.b_data = 32'hEDDDDE;
      // srcmden.index = 2;
      // srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10

      // srcmdr.b_data = 32'hFFFFFFFFF;
      // srcmdr.index = 2;
      // srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10

      mdcfg.b_data = 32'd15;
      mdcfg.index = 62;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
      #10

      // entry_addr.b_data = 32'hFFFFFF;
      // entry_addr.index = 3;
      // entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10

      // entry_cfg.b_data = 32'hFFFF;
      // entry_cfg.index = 3;
      // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10

      // err_cfg.b_data = 32'd30;
      // err_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // mdstall.b_data = 32'd15;
      // mdstall.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // mdstallh.b_data = 32'd15;
      // mdstallh.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // rridscp.b_data = 32'd15;
      // rridscp.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // version.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // imp.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // hwcfg0.b_data = '1;
      // hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // hwcfg1.b_data = 32'd15;
      // hwcfg1.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // hwcfg2.b_data = 32'd10;
      // hwcfg2.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // entryoffset.b_data = 32'd10;
      // entryoffset.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // mdlck.b_data = 32'd10;
      // mdlck.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // mdlckh.b_data = 32'd10;
      // mdlckh.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // mdcfglck.b_data = 32'd10;
      // mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      // entrylck.b_data = 32'd10;
      // entrylck.start(env.reg_env.ahb_agnt.ahb_sqr);
      // #10;

      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase

endclass