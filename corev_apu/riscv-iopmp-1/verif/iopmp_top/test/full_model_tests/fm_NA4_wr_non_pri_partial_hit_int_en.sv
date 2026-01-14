/*************************************************************************
   > File Name:   fm_NA4_wr_non_pri_partial_hit_int_en.sv
   > Description: Send write address for Full Model with NA4 Addressing mode with read/write permission in entry_cfg.
     Set size of data such that it gives partial hit. Also Enable interrupt enable bit in error capture register then check if interrupt is reported or not. Set entry non priority
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class fm_NA4_wr_non_pri_partial_hit_int_en extends full_model_base_test;
  `uvm_component_utils(fm_NA4_wr_non_pri_partial_hit_int_en)
    hwcfg0_reg_seq     hwcfg0;
    srcmdenh_reg_seq       srcmden;
    srcmdrh_reg_seq        srcmdr;
    mdcfg_reg_seq         mdcfg;
    entry_addr_reg_seq    entry_addr;
    entry_cfg_reg_seq     entry_cfg;
    errcfg_reg_seq        err_cfg;

    axi_req_seq_w        aw_seq;
    axi_req_seq_w_data   aw_seq_data;
    axi_s_sanity_seq      s_seq;

  function new(string name = "fm_NA4_wr_non_pri_partial_hit_int_en", uvm_component parent = null);
     super.new(name, parent);
      hwcfg0      = hwcfg0_reg_seq::type_id::create("hwcfg0");
      srcmden           = srcmdenh_reg_seq::type_id::create("srcmden");
      srcmdr            = srcmdrh_reg_seq::type_id::create("srcmdr");
      mdcfg             = mdcfg_reg_seq::type_id::create("mdcfg");
      entry_addr        = entry_addr_reg_seq::type_id::create("entry_addr");
      entry_cfg         = entry_cfg_reg_seq::type_id::create("entry_cfg");
      err_cfg           = errcfg_reg_seq::type_id::create("err_cfg");
      aw_seq            = axi_req_seq_w::type_id::create("aw_seq");
      aw_seq_data       = axi_req_seq_w_data::type_id::create("aw_seq_data");
      s_seq             = axi_s_sanity_seq::type_id::create("s_seq");

   endfunction

   

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      env.reg_env.ahb_agnt.ahb_drv.HSIZE     = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HBURST    = 0;
      env.reg_env.ahb_agnt.ahb_drv.HTRANS    = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HPROT     = 'd3;
      env.reg_env.ahb_agnt.ahb_drv.HMASTLOCK = 0;
      env.reg_env.ahb_agnt.ahb_drv.HSEL = 1;

      srcmden.b_data = 32'h2000000;                        // Traverse MD 56
      srcmden.index  = 5;
      srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

      srcmdr.b_data      = 32'h2000000;
      srcmdr.index       = 5;
      srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

      mdcfg.b_data       = 32'h31;                          // 5 entries associated with this md   entry 0,1,2,3,4
      mdcfg.index        = 55;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
      
      mdcfg.b_data       = 32'h32;                          // 5 entries associated with this md   entry 0,1,2,3,4
      mdcfg.index        = 56;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

     // hwcfg2.prio_entry = 16
      entry_addr.b_data  = (32'd364)>>2;
      entry_addr.index   = 49;
      entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data   = 32'h11;                     // NA4 address mode with no permissions granted
      entry_cfg.index    = 49;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      err_cfg.b_data     = 32'h2;                      // interrupt enable
      err_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      hwcfg0.b_data = 32'h80000000;                   //Setting IOPMP Enable 1
      hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);

      // This transaction will be a partial match
      #50;
      aw_seq.rrid       = 5;
      aw_seq.seq_addr   = 364;
      aw_seq.seq_id     = 49;
      aw_seq.seq_size   = 4;
      aw_seq.data_size  = 8;     //Assign Data size to be written
      aw_seq.length     = 0;    //pass burst length manually
      aw_seq.has_length = 0;    //pass flag to sequence  (0 to not)

      aw_seq_data.seq_addr   = 364;
      aw_seq_data.seq_size   = 4;
      aw_seq_data.data_size  = 8;    //Assign Data size to be written
      aw_seq_data.length     = 0;    //pass burst length manually
      aw_seq_data.has_length = 0;    //pass flag to sequence (0 to not)

      fork
          aw_seq.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);              //write access test
          aw_seq_data.start(env.axi_env.wr_data_agnt.wr_data_sqr);
          #300;
      join_any
      
      fork
        s_seq.start(env.axi_s_env.agent.sequencer);
      #300;
      join_any
      #100;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass