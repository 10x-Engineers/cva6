/*************************************************************************
   > File Name:   test_ad2_r0_w0_x0_mdstall_exempt_5.sv
   > Description: 1. Program IOPMP Registers with this association
-> RRID = 0 is associated with MD = 0 and MD = 0 with Entry = 0
-> RRID = 1 is associated with MD = 1 and MD = 1 with Entry = 1
-> RRID = 2 is associated with MD = 2 and MD = 2 with Entry = 2
-> RRID = 3 is associated with MD = 3 and MD = 3 with Entry = 3
-> RRID = 4 is associated with MD = 4 and MD = 4 with Entry = 4
2. Program Entry_CFG registers where address should be full match and no permissions
3. Enable IOPMP 
4. Write MDSTALL register with exempt = 0 and set corresponding bit positions in reg
5. Send a read transaction with RRID = 0
6. Send a write transaction with RRID = 1
7. Send a eX transaction with RRID = 2
8. Send a read transaction with RRID = 3
9. Send a write transaction with RRID = 4
10. All above RRID's will be stalled and stored into the Stall buffer
11. Program entry_cfg register and set the required permissions
12. Write all zero's on MDSTALL register
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class test_ad2_r0_w0_x0_mdstall_exempt_5 extends full_model_base_test;
  `uvm_component_utils(test_ad2_r0_w0_x0_mdstall_exempt_5)
    hwcfg0_reg_seq        hwcfg0;
    srcmden_reg_seq       srcmden;
    srcmdr_reg_seq        srcmdr;
    srcmdw_reg_seq        srcmdw;
    mdcfg_reg_seq         mdcfg;
    entry_addr_reg_seq    entry_addr;
    entry_cfg_reg_seq     entry_cfg;
    mdstall_reg_seq       mdstall;

    axi_req_seq           ar_seq;
    axi_req_seq_w         aw_seq;
    axi_req_seq_w_data    aw_seq_data;
    axi_s_sanity_seq      s_seq;

  function new(string name = "test_ad2_r0_w0_x0_mdstall_exempt_5", uvm_component parent = null);
     super.new(name, parent);
      hwcfg0      = hwcfg0_reg_seq::type_id::create("hwcfg0");
      srcmden    = srcmden_reg_seq::type_id::create("srcmden");
      srcmdr     = srcmdr_reg_seq::type_id::create("srcmdr");
      srcmdw     = srcmdw_reg_seq::type_id::create("srcmdw");
      mdcfg      = mdcfg_reg_seq::type_id::create("mdcfg");
      entry_addr = entry_addr_reg_seq::type_id::create("entry_addr");
      entry_cfg  = entry_cfg_reg_seq::type_id::create("entry_cfg");
      mdstall    = mdstall_reg_seq::type_id::create("mdstall");

      ar_seq     = axi_req_seq::type_id::create("ar_seq");
      aw_seq      = axi_req_seq_w::type_id::create("aw_seq");
      aw_seq_data = axi_req_seq_w_data::type_id::create("aw_seq_data");
      s_seq      = axi_s_sanity_seq::type_id::create("s_seq");

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
//FOR RRID = 0
      srcmden.b_data = 32'h2;                        // Traverse MD 0
      srcmden.index = 0;
      srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

      srcmdr.b_data = 32'h2;
      srcmdr.index = 0;
      srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);


      mdcfg.b_data = 32'h1;                          // 1 entrY associated with this md   entry 0
      mdcfg.index = 0;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_addr.b_data = (32'd364)>>2;
      entry_addr.index = 0;
      entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data = 32'h10;                     // NA4 address mode with no permission granted
      entry_cfg.index = 0;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

//For RRID = 1

      srcmden.b_data = 32'h4;                        // Traverse MD 1
      srcmden.index = 1;
      srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

      srcmdw.b_data = 32'h4;
      srcmdw.index = 1;
      srcmdw.start(env.reg_env.ahb_agnt.ahb_sqr);


      mdcfg.b_data = 32'h2;                          // 1 entries associated with this md   entry 1
      mdcfg.index = 1;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);


      entry_addr.b_data = (32'd372)>>2;
      entry_addr.index = 1;
      entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data = 32'h10;                     // NA4 address mode with no permission granted
      entry_cfg.index = 1;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

//FOR RRID = 2

      srcmden.b_data = 32'h8;                        // Traverse MD 2
      srcmden.index = 2;
      srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

      srcmdr.b_data = 32'h8;
      srcmdr.index = 2;
      srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);


      mdcfg.b_data = 32'h3;                          // 1 entry associated with this md   entry 2
      mdcfg.index = 2;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);


     // hwcfg2.prio_entry = 16
      entry_addr.b_data = (32'd380)>>2;
      entry_addr.index = 2;
      entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data = 32'h10;                     // NA4 address mode with read permission granted
      entry_cfg.index = 2;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

//FOR RRID = 3
      srcmden.b_data = 32'h10;                        // Traverse MD 3
      srcmden.index = 3;
      srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

      srcmdr.b_data = 32'h10;
      srcmdr.index = 3;
      srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);


      mdcfg.b_data = 32'h4;                          // 1 entry associated with this md   entry 3
      mdcfg.index = 3;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_addr.b_data = (32'd388)>>2;
      entry_addr.index = 3;
      entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data = 32'h10;                     // NA4 address mode with read permission granted
      entry_cfg.index = 3;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);
//FOR RRID = 4
      srcmden.b_data = 32'h20;                        // Traverse MD 2
      srcmden.index = 4;
      srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

      srcmdw.b_data = 32'h20;
      srcmdw.index = 4;
      srcmdw.start(env.reg_env.ahb_agnt.ahb_sqr);


      mdcfg.b_data = 32'h5;                          // 1 entries associated with this md   entry 4
      mdcfg.index = 4;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);


      entry_addr.b_data = (32'd396)>>2;
      entry_addr.index = 4;
      entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data = 32'h10;                     // NA4 address mode with read permission granted
      entry_cfg.index = 4;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

//FOR RRID = 5
      srcmden.b_data = 32'h40;                        // Traverse MD 5
      srcmden.index = 5;
      srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

      srcmdr.b_data = 32'h40;
      srcmdr.index = 5;
      srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);


      mdcfg.b_data = 32'h6;                          // 1 entries associated with this md   entry 5
      mdcfg.index = 5;
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);


      entry_addr.b_data = (32'd404)>>2;
      entry_addr.index = 5;
      entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data = 32'h10;                     // NA4 address mode with read permission granted
      entry_cfg.index = 5;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      hwcfg0.b_data = 32'h80000000;                   //Setting IOPMP Enable 1
      hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);

      mdstall.b_data    = 32'h3F;
      mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

      // This transaction will be a match
      #50;
      ar_seq.rrid                 = 0;
      ar_seq.seq_addr             = 364;
      ar_seq.seq_id               = 1;
      ar_seq.seq_prot             = 0;
      ar_seq.seq_size             = 4;
      ar_seq.data_size            = 4;
      ar_seq.length               = 0;    //pass burst length manually
      ar_seq.has_length           = 0;    //pass flag to sequence
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

      //AW Channel
      aw_seq.rrid       = 1;
      aw_seq.seq_addr   = 372;
      aw_seq.seq_id     = 2;
      aw_seq.burst_t    = 0;
      aw_seq.seq_size   = 4;
      aw_seq.data_size  = 4;     //Assign Data size to be written
      aw_seq.length     = 0;    //pass burst length manually
      aw_seq.has_length = 0;    //pass flag to sequence  (0 to not)
      //W data channel
      aw_seq_data.seq_addr   = 372;
      aw_seq_data.seq_size   = 4;
      aw_seq_data.data_size  = 4;    //Assign Data size to be written
      aw_seq_data.length     = 0;    //pass burst length manually
      aw_seq_data.has_length = 0;    //pass flag to sequence (0 to not)
      fork
          aw_seq.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);              //write access test
          aw_seq_data.start(env.axi_env.wr_data_agnt.wr_data_sqr);
          #300;
      join_any
      #100;
      // This transaction will be a match
      #50;
      ar_seq.rrid                 = 2;
      ar_seq.seq_addr             = 380;
      ar_seq.seq_id               = 3;
      ar_seq.seq_prot             = 'b100;
      ar_seq.seq_size             = 4;
      ar_seq.data_size            = 4;
      ar_seq.length               = 0;    //pass burst length manually
      ar_seq.has_length           = 0;    //pass flag to sequence
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

      // This transaction will be a match
      #50;
      ar_seq.rrid                 = 3;
      ar_seq.seq_addr             = 388;
      ar_seq.seq_id               = 4;
      ar_seq.seq_prot             = 0;
      ar_seq.seq_size             = 4;
      ar_seq.data_size            = 4;
      ar_seq.length               = 0;    //pass burst length manually
      ar_seq.has_length           = 0;    //pass flag to sequence
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

      //AW Channel
      aw_seq.rrid       = 4;
      aw_seq.seq_addr   = 396;
      aw_seq.seq_id     = 5;
      aw_seq.burst_t    = 0;
      aw_seq.seq_size   = 4;
      aw_seq.data_size  = 4;     //Assign Data size to be written
      aw_seq.length     = 0;    //pass burst length manually
      aw_seq.has_length = 0;    //pass flag to sequence  (0 to not)
      //W data channel
      aw_seq_data.seq_addr   = 396;
      aw_seq_data.seq_size   = 4;
      aw_seq_data.data_size  = 4;    //Assign Data size to be written
      aw_seq_data.length     = 0;    //pass burst length manually
      aw_seq_data.has_length = 0;    //pass flag to sequence (0 to not)

      fork
          aw_seq.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);              //write access test
          aw_seq_data.start(env.axi_env.wr_data_agnt.wr_data_sqr);
          #300;
      join_any
      #100;

      // This transaction will be a match
      #50;
      ar_seq.rrid                 = 5;
      ar_seq.seq_addr             = 404;
      ar_seq.seq_id               = 6;
      ar_seq.seq_prot             = 0;
      ar_seq.seq_size             = 4;
      ar_seq.data_size            = 4;
      ar_seq.length               = 0;    //pass burst length manually
      ar_seq.has_length           = 0;    //pass flag to sequence
      ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

      fork
        s_seq.start(env.axi_s_env.agent.sequencer);
      #300;
      join_any
      #100;

      //
      // entry_cfg.b_data = 32'h11;                     // NA4 address mode with read permission granted
      // entry_cfg.index = 0;
      // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      // entry_cfg.b_data = 32'h12;                     // NA4 address mode with write permission granted
      // entry_cfg.index = 1;
      // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      // entry_cfg.b_data = 32'h14;                     // NA4 address mode with ex permission granted
      // entry_cfg.index = 2;
      // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      // entry_cfg.b_data = 32'h11;                     // NA4 address mode with read permission granted
      // entry_cfg.index = 3;
      // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      // entry_cfg.b_data = 32'h12;                     // NA4 address mode with write permission granted
      // entry_cfg.index = 4;
      // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      entry_cfg.b_data = 32'h11;                     // NA4 address mode with write permission granted
      entry_cfg.index = 5;
      entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

      mdstall.b_data    = 32'h00;
      mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

      #100;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass