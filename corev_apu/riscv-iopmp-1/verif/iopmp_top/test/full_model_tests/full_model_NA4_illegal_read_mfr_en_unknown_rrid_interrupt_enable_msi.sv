/*************************************************************************
   > File Name:   full_model_NA4_illegal_read_mfr_en_unknown_rrid_interrupt_enable_msi.sv
   > Description: Send read address for Full MOdel with NA4 Addressing mode with read permission in entry_cfg. Also Enable interrupt enable and msi_en bit in error capture register then check if interrupt is reported or not. Send request with unknown rrid.
   >              Change RRID_NUM in format 0 -> 30
   >              Also in Reference model config file
   1. Configure the IOPMP Register.
   2. Send a read/write/instruction fetch transaction that must generate unknown RRID error.
   3. Send a write request on ERR_MFR to set ERR_MFR.svi to a value 2.
   4. Send a read request on ERR_MFR register.
   5. Send the same transaction again to generate the subsequent violation.
   6. Send a read request on ERR_MFR. 
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class full_model_NA4_illegal_read_mfr_en_unknown_rrid_interrupt_enable_msi extends full_model_base_test;
  `uvm_component_utils(full_model_NA4_illegal_read_mfr_en_unknown_rrid_interrupt_enable_msi)
    hwcfg0_reg_seq        hwcfg0;
    srcmden_reg_seq       srcmden;
    srcmdr_reg_seq        srcmdr;
    mdcfg_reg_seq         mdcfg;
    entry_addr_reg_seq    entry_addr;
    entry_cfg_reg_seq     entry_cfg;
    errcfg_reg_seq        err_cfg;
    err_msiaddr_reg_seq   err_msiaddr;
    err_mfr_reg_seq       err_mfr;

    axi_req_seq           ar_seq;
    axi_s_sanity_seq      s_seq;

  function new(string name = "full_model_NA4_illegal_read_mfr_en_unknown_rrid_interrupt_enable_msi", uvm_component parent = null);
     super.new(name, parent);
      hwcfg0            = hwcfg0_reg_seq::type_id::create("hwcfg0");
      srcmden           = srcmden_reg_seq::type_id::create("srcmden");
      srcmdr            = srcmdr_reg_seq::type_id::create("srcmdr");
      mdcfg             = mdcfg_reg_seq::type_id::create("mdcfg");
      entry_addr        = entry_addr_reg_seq::type_id::create("entry_addr");
      entry_cfg         = entry_cfg_reg_seq::type_id::create("entry_cfg");
      err_cfg           = errcfg_reg_seq::type_id::create("err_cfg");
      err_msiaddr       = err_msiaddr_reg_seq::type_id::create("err_msiaddr");
      err_mfr           = err_mfr_reg_seq::type_id::create("err_mfr");
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

      entry_cfg.b_data   = 32'h11;                     // NA4 address mode with read permissions granted
      entry_cfg.index    = 3;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      err_cfg.b_data     = 32'h4010A;                      // interrupt enable
      err_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      err_msiaddr.b_data = 32'h4;
      err_msiaddr.start(env.reg_env.ahb_agnt.ahb_sqr);

      err_mfr.b_data= 32'h20000;
      err_mfr.start(env.reg_env.ahb_agnt.ahb_sqr);

      hwcfg0.b_data = 32'h80000000;                   //Setting IOPMP Enable 1
      hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);

      // This transaction will be a match
      #50;
      ar_seq.rrid                 = 50;
      ar_seq.seq_addr             = 364;
      ar_seq.seq_id               = 3;
      ar_seq.seq_prot             = 0;
      ar_seq.seq_size             = 4;
      ar_seq.data_size            = 4;
      ar_seq.length               = 0;    //pass burst length manually
      ar_seq.has_length           = 1;    //pass flag to sequence
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

      // This transaction will be a match
      #50;
      ar_seq.rrid                 = 50;
      ar_seq.seq_addr             = 364;
      ar_seq.seq_id               = 3;
      ar_seq.seq_prot             = 0;
      ar_seq.seq_size             = 4;
      ar_seq.data_size            = 4;
      ar_seq.length               = 0;    //pass burst length manually
      ar_seq.has_length           = 1;    //pass flag to sequence
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

      #20;
      err_mfr.read= 1;
      err_mfr.start(env.reg_env.ahb_agnt.ahb_sqr);

      
      fork
        s_seq.start(env.axi_s_env.agent.sequencer);
      #300;
      join_any
      #100;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass