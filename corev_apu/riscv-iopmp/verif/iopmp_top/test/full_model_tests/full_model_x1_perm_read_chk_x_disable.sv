/*************************************************************************
   > File Name:   full_model_x1_perm_read_chk_x_disable.sv
   > Description: Send read address with prot b100 for Full MOdel with NA4 Addressing mode by passing read permission and disabling chk_x in HWCFG->(x permission will become don't care) in entry_cfg.
   >              Set CHK_X -> 0      
   >              Set      OPMP_CHK_X -> 0      
   >              Set CHK_X -> 0      
   >              Set      OPMP_CHK_X -> 0  
   1. Configure full address match and entry with read=1 and execute=1.
   2. SRCMD_R=1.
   3. HWCFG0.chk_x=0.
   4. Send an instruction fetch.    
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class full_model_x1_perm_read_chk_x_disable extends full_model_base_test;
  `uvm_component_utils(full_model_x1_perm_read_chk_x_disable)
    hwcfg0_reg_seq        hwcfg0;
    srcmden_reg_seq       srcmden;
    srcmdr_reg_seq        srcmdr;
    mdcfg_reg_seq         mdcfg;
    entry_addr_reg_seq    entry_addr;
    entry_cfg_reg_seq     entry_cfg;

    axi_req_seq          ar_seq;
    axi_s_sanity_seq      s_seq;
  

  function new(string name = "full_model_x1_perm_read_chk_x_disable", uvm_component parent = null);
     super.new(name, parent);
   endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    hwcfg0     = hwcfg0_reg_seq::type_id::create("hwcfg0");
    srcmden    = srcmden_reg_seq::type_id::create("srcmden");
    srcmdr     = srcmdr_reg_seq::type_id::create("srcmdr");
    mdcfg      = mdcfg_reg_seq::type_id::create("mdcfg");
    entry_addr = entry_addr_reg_seq::type_id::create("entry_addr");
    entry_cfg  = entry_cfg_reg_seq::type_id::create("entry_cfg");
    ar_seq     = axi_req_seq::type_id::create("ar_seq");
    s_seq      = axi_s_sanity_seq::type_id::create("s_seq");

  endfunction

  task main_phase(uvm_phase phase);
  super.main_phase(phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      env.reg_env.ahb_agnt.ahb_drv.HSIZE     = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HBURST    = 0;
      env.reg_env.ahb_agnt.ahb_drv.HTRANS    = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HPROT     = 'd3;
      env.reg_env.ahb_agnt.ahb_drv.HMASTLOCK = 0;
      env.reg_env.ahb_agnt.ahb_drv.HSEL = 1;

      //-------------------------------------------------
      //                            Assign 
      //                   CHK_X           = 0; Also chnage parameter in reference model folder file config.h
      //                     Then run test
      //-------------------------------------------------

      srcmden.b_data = 32'h10;                       //Traverse MD 3
      srcmden.index = 32;
      srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

      srcmdr.b_data = 32'h10;
      srcmdr.index = 32;
      srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

      mdcfg.b_data = 32'h5;                  // 5 entries associated with this md   entry 0,1,2,3,4
      mdcfg.index = 3;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      // hwcfg2.prio_entry = 16
      entry_addr.b_data = (32'd364)>>2;
      entry_addr.index = 3;
      entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data = 32'h15;                     // NA4 address mode with read and execute permission granted
      entry_cfg.index = 3;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      hwcfg0.b_data = 32'h80000000;                   //Setting IOPMP Enable 1
      hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);


      // This transaction is a success as permissions are granted by entry_cfg.r
      #50;
      ar_seq.rrid      = 32;
      ar_seq.seq_addr             = 364;
      ar_seq.seq_id               = 3;
      ar_seq.seq_prot             = 'b100;
      ar_seq.seq_size             = 4;
      ar_seq.data_size            = 4;
      ar_seq.length               = 0;    //pass burst length manually
      ar_seq.has_length           = 0;    //pass flag to sequence

      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);              //read access test

      fork
        s_seq.start(env.axi_s_env.agent.sequencer);
        #300;
      join_any
      #100;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase

endclass