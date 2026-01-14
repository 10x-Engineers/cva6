/*************************************************************************
   > File Name:   fm_NA4_mdcfglck_write.sv
   > Description: Send write address for Full MOdel with NA4 Addressing mode with rw permission in entry_cfg. Set f=4 in MDCFGLCK after setting MD to 2 by writting srcmden = 8 and setting mdcfg = 5. After this try to set mdcfg = 3. Then try to set f in MDCFGLCK smaller than the previous one. 
   >               Also set MDCFG lower than the previous one. Then set value higher than the highest value set before. Then set l bit in MDCFGlck and try to write the value higher than it is set now.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class fm_NA4_mdcfglck_write extends full_model_base_test;
    `uvm_component_utils(fm_NA4_mdcfglck_write)
    hwcfg0_reg_seq        hwcfg0;
    srcmden_reg_seq       srcmden;
    srcmdr_reg_seq        srcmdr;
    srcmdw_reg_seq        srcmdw;
    mdcfg_reg_seq         mdcfg;
    entry_addr_reg_seq    entry_addr;
    entry_cfg_reg_seq     entry_cfg;
    mdlck_reg_seq         mdlck;
    mdcfglck_reg_seq      mdcfglck;
    mdstall_reg_seq       mdstall;

    axi_req_seq_w         aw_seq;
    axi_req_seq_w_data    aw_seq_data;
    axi_s_sanity_seq      s_seq;

    function new(string name = "fm_NA4_mdcfglck_write", uvm_component parent = null);
        super.new(name, parent);
        hwcfg0      = hwcfg0_reg_seq::type_id::create("hwcfg0");
        srcmden = srcmden_reg_seq::type_id::create("srcmden");
        srcmdr  = srcmdr_reg_seq::type_id::create("srcmdr");
        srcmdw  = srcmdw_reg_seq::type_id::create("srcmdw");
        mdcfg      = mdcfg_reg_seq::type_id::create("mdcfg");
        entry_addr = entry_addr_reg_seq::type_id::create("entry_addr");
        entry_cfg  = entry_cfg_reg_seq::type_id::create("entry_cfg");
        mdlck      = mdlck_reg_seq::type_id::create("mdlck");
        mdcfglck   = mdcfglck_reg_seq::type_id::create("mdcfglck");
        mdstall    = mdstall_reg_seq::type_id::create("mdstall");
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

        srcmden.b_data = 32'h8;                        // Traverse MD 2
        srcmden.index = 5;
        srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdr.b_data = 32'h8;
        srcmdr.index = 5;
        srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdw.b_data = 32'h8;
        srcmdw.index = 5;
        srcmdw.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdcfg.b_data = 32'h5;                          // 5 entries associated with this md   entry 0,1,2,3,4
        mdcfg.index = 2;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdcfglck.b_data = 32'h8;                          // 5 entries associated with this md   entry 0,1,2,3
        mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);

        // hwcfg2.prio_entry = 16
        entry_addr.b_data = (32'd364)>>2;
        entry_addr.index = 2;
        entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

        entry_cfg.b_data = 32'h13;                     // NA4 address mode with read permission granted
        entry_cfg.index = 2;
        entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        hwcfg0.b_data = 32'h80000000;                   //Setting IOPMP Enable 1
        hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);


        // This transaction will be a match
        #50;
        aw_seq.rrid       = 5;
        aw_seq.seq_addr   = 364;
        aw_seq.seq_id     = 2;
        aw_seq.seq_size   = 4;
        aw_seq.data_size  = 4;     //Assign Data size to be written
        aw_seq.length     = 0;    //pass burst length manually
        aw_seq.has_length = 0;    //pass flag to sequence  (0 to not)

        aw_seq_data.seq_addr   = 364;
        aw_seq_data.seq_size   = 4;
        aw_seq_data.data_size  = 4;    //Assign Data size to be written
        aw_seq_data.length     = 0;    //pass burst length manually
        aw_seq_data.has_length = 0;    //pass flag to sequence (0 to not)

        fork
          aw_seq.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);              //write access test
          aw_seq_data.start(env.axi_env.wr_data_agnt.wr_data_sqr);
          #300ns;
        join_any

        //Now send request with MDcfgLCK with setting f = 4

        // mdcfglck.b_data = 5'h4;                          // 5 entries associated with this md   entry 0,1,2,3,4
        // mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h8;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);
        
        mdcfg.b_data = 32'h4;                          // 5 entries associated with this md   entry 0,1,2
        mdcfg.index = 2;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        // hwcfg2.prio_entry = 16
        // entry_addr.b_data = (32'd364)>>2;
        // entry_addr.index = 2;
        // entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);
// 
        // entry_cfg.b_data = 32'h13;                     // NA4 address mode with read permission granted
        // entry_cfg.index = 2;
        // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h0;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        // This transaction will be a match
        #50;
        aw_seq.rrid       = 5;
        aw_seq.seq_addr   = 364;
        aw_seq.seq_id     = 2;
        aw_seq.seq_size   = 4;
        aw_seq.data_size  = 4;     //Assign Data size to be written
        aw_seq.length     = 0;    //pass burst length manually
        aw_seq.has_length = 0;    //pass flag to sequence  (0 to not)

        aw_seq_data.seq_addr   = 364;
        aw_seq_data.seq_size   = 4;
        aw_seq_data.data_size  = 4;    //Assign Data size to be written
        aw_seq_data.length     = 0;    //pass burst length manually
        aw_seq_data.has_length = 0;    //pass flag to sequence (0 to not)

        fork
          aw_seq.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);              //write access test
          aw_seq_data.start(env.axi_env.wr_data_agnt.wr_data_sqr);
          #300ns;
        join_any
        

        //Now send request with MDcfgLCK with setting f = 3

        mdcfglck.b_data = 32'h6;                          // 5 entries associated with this md   entry 0,1,2
        mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h8;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        mdcfg.b_data = 32'h6;                          // 5 entries associated with this md   entry 5
        mdcfg.index = 3;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        // hwcfg2.prio_entry = 16
        // entry_addr.b_data = (32'd364)>>2;
        // entry_addr.index = 2;
        // entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);
// 
        // entry_cfg.b_data = 32'h13;                     // NA4 address mode with read permission granted
        // entry_cfg.index = 2;
        // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h0;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);


        // This transaction will be a match
        #50;
        aw_seq.rrid       = 5;
        aw_seq.seq_addr   = 364;
        aw_seq.seq_id     = 2;
        aw_seq.seq_size   = 4;
        aw_seq.data_size  = 4;     //Assign Data size to be written
        aw_seq.length     = 0;    //pass burst length manually
        aw_seq.has_length = 0;    //pass flag to sequence  (0 to not)

        aw_seq_data.seq_addr   = 364;
        aw_seq_data.seq_size   = 4;
        aw_seq_data.data_size  = 4;    //Assign Data size to be written
        aw_seq_data.length     = 0;    //pass burst length manually
        aw_seq_data.has_length = 0;    //pass flag to sequence (0 to not)

        fork
          aw_seq.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);              //write access test
          aw_seq_data.start(env.axi_env.wr_data_agnt.wr_data_sqr);
          #300ns;
        join_any


//Now send request with MDcfgLCK with setting f = 8

        mdcfglck.b_data = 32'h8;                          // lock
        mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h8;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        mdcfg.b_data = 32'h8;                          // 5 entries associated with this md   entry 6,7
        mdcfg.index = 4;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        // hwcfg2.prio_entry = 16
        // entry_addr.b_data = (32'd364)>>2;
        // entry_addr.index = 7;
        // entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);
// 
        // entry_cfg.b_data = 32'h13;                     // NA4 address mode with read permission granted
        // entry_cfg.index = 7;
        // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h0;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);


        // This transaction will be a match
        #50;
        aw_seq.rrid       = 5;
        aw_seq.seq_addr   = 364;
        aw_seq.seq_id     = 2;
        aw_seq.seq_size   = 4;
        aw_seq.data_size  = 4;     //Assign Data size to be written
        aw_seq.length     = 0;    //pass burst length manually
        aw_seq.has_length = 0;    //pass flag to sequence  (0 to not)

        aw_seq_data.seq_addr   = 364;
        aw_seq_data.seq_size   = 4;
        aw_seq_data.data_size  = 4;    //Assign Data size to be written
        aw_seq_data.length     = 0;    //pass burst length manually
        aw_seq_data.has_length = 0;    //pass flag to sequence (0 to not)

        fork
          aw_seq.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);              //write access test
          aw_seq_data.start(env.axi_env.wr_data_agnt.wr_data_sqr);
          #300ns;
        join_any

        mdcfglck.b_data = 32'hA;                          // lock
        mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);

        //set mdcfglck = 1
        mdcfglck.b_data = 32'h1;                          // lock
        mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdcfglck.b_data = 32'hc;                          // lock
        mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);
        fork
          s_seq.start(env.axi_s_env.agent.sequencer);
        #300;
        join_any
        #100;
        phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
    endtask : main_phase


endclass