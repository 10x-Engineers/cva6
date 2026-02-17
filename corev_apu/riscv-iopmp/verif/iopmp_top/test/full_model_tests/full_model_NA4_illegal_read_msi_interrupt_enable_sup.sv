/*************************************************************************
   > File Name:   full_model_NA4_illegal_read_msi_interrupt_enable_sup.sv
   > Description: 
    1. Set MSI_EN flag in the IOPMP Configurations.
    2. Program the MSI DATA and MSI ADDR(H) registers.
    3. Program IOPMP Registers and enable global interrupt but suppress the local interrupt in corresponding associated entry.
    4. Send a read transaction to the IOPMP that should generate an error type = 0x01
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class full_model_NA4_illegal_read_msi_interrupt_enable_sup extends full_model_base_test;
  `uvm_component_utils(full_model_NA4_illegal_read_msi_interrupt_enable_sup)
    hwcfg0_reg_seq        hwcfg0;
    srcmden_reg_seq       srcmden;
    srcmdr_reg_seq        srcmdr;
    mdcfg_reg_seq         mdcfg;
    entry_addr_reg_seq    entry_addr;
    entry_cfg_reg_seq     entry_cfg;
    errcfg_reg_seq        err_cfg;
    err_msiaddr_reg_seq   err_msiaddr;

    axi_req_seq           ar_seq;
    axi_s_sanity_seq      s_seq;

  function new(string name = "full_model_NA4_illegal_read_msi_interrupt_enable_sup", uvm_component parent = null);
     super.new(name, parent);
      hwcfg0      = hwcfg0_reg_seq::type_id::create("hwcfg0");
      srcmden           = srcmden_reg_seq::type_id::create("srcmden");
      srcmdr            = srcmdr_reg_seq::type_id::create("srcmdr");
      mdcfg             = mdcfg_reg_seq::type_id::create("mdcfg");
      entry_addr        = entry_addr_reg_seq::type_id::create("entry_addr");
      entry_cfg         = entry_cfg_reg_seq::type_id::create("entry_cfg");
      err_cfg           = errcfg_reg_seq::type_id::create("err_cfg");
      err_msiaddr       = err_msiaddr_reg_seq::type_id::create("err_msiaddr");
      ar_seq            = axi_req_seq::type_id::create("ar_seq");
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

      srcmden.b_data = 32'h8;                        // Traverse MD 2
      srcmden.index  = 5;
      srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

      srcmdr.b_data      = 32'h8;
      srcmdr.index       = 5;
      srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

      mdcfg.b_data       = 32'h5;                          // 5 entries associated with this md   entry 0,1,2,3,4
      mdcfg.index        = 2;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

     // hwcfg2.prio_entry = 16
      entry_addr.b_data  = (32'd364)>>2;
      entry_addr.index   = 3;
      entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data   = 32'h30;                     // NA4 address mode with no permissions granted and sire enabled.
      entry_cfg.index    = 3;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      err_cfg.b_data     = 32'h4010A;                      // interrupt enable
      err_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      err_msiaddr.b_data = 32'h4;
      err_msiaddr.start(env.reg_env.ahb_agnt.ahb_sqr);

      hwcfg0.b_data = 32'h80000000;                   //Setting IOPMP Enable 1
      hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);

      // This transaction will be not a match
      #50;
      ar_seq.rrid                 = 5;
      ar_seq.seq_addr             = 364;
      ar_seq.seq_id               = 3;
      ar_seq.seq_prot             = 0;
      ar_seq.seq_size             = 4;
      ar_seq.data_size            = 4;
      ar_seq.length               = 0;    //pass burst length manually
      ar_seq.has_length           = 1;    //pass flag to sequence
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

      
      fork
        s_seq.start(env.axi_s_env.agent.sequencer);
      #300;
      join_any
      #100;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass