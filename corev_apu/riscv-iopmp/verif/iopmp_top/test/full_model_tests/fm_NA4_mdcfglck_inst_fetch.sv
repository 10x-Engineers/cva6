/*************************************************************************
   > File Name:   fm_NA4_mdcfglck_inst_fetch.sv
   > Description: Send instruction fetch address for Full MOdel with NA4 Addressing mode with r permission in entry_cfg. Set f=4 in MDCFGLCK after setting MD to 2 by writting srcmden = 8 and setting mdcfg = 5. After this try to set mdcfg = 3. Then try to set f in MDCFGLCK smaller than the previous one. 
   >               Also set MDCFG lower than the previous one. Then set value higher than the highest value set before. Then set l bit in MDCFGlck and try to write the value higher than it is set now.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class fm_NA4_mdcfglck_inst_fetch extends full_model_base_test;
    `uvm_component_utils(fm_NA4_mdcfglck_inst_fetch)
    hwcfg0_reg_seq        hwcfg0;
    srcmden_reg_seq       srcmden;
    srcmdr_reg_seq        srcmdr;
    mdcfg_reg_seq         mdcfg;
    entry_addr_reg_seq    entry_addr;
    entry_cfg_reg_seq     entry_cfg;
    mdlck_reg_seq         mdlck;
    mdcfglck_reg_seq      mdcfglck;
    mdstall_reg_seq       mdstall;

    axi_req_seq           ar_seq;
    axi_s_sanity_seq      s_seq;

    function new(string name = "fm_NA4_mdcfglck_inst_fetch", uvm_component parent = null);
        super.new(name, parent);
        hwcfg0      = hwcfg0_reg_seq::type_id::create("hwcfg0");
        srcmden = srcmden_reg_seq::type_id::create("srcmden");
        srcmdr  = srcmdr_reg_seq::type_id::create("srcmdr");
        mdcfg      = mdcfg_reg_seq::type_id::create("mdcfg");
        entry_addr = entry_addr_reg_seq::type_id::create("entry_addr");
        entry_cfg  = entry_cfg_reg_seq::type_id::create("entry_cfg");
        mdlck      = mdlck_reg_seq::type_id::create("mdlck");
        mdcfglck   = mdcfglck_reg_seq::type_id::create("mdcfglck");
        mdstall    = mdstall_reg_seq::type_id::create("mdstall");
        ar_seq     = axi_req_seq::type_id::create("ar_seq");
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

        mdcfg.b_data = 32'h5;                          // 5 entries associated with this md   entry 0,1,2,3,4
        mdcfg.index = 2;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdcfglck.b_data = 32'h8;                          // 5 entries associated with this md   entry 0,1,2
        mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);

        // hwcfg2.prio_entry = 16
        entry_addr.b_data = (32'd364)>>2;
        entry_addr.index = 2;
        entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

        entry_cfg.b_data = 32'h15;                     // NA4 address mode with read permission granted
        entry_cfg.index = 2;
        entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        hwcfg0.b_data = 32'h80000000;                   //Setting IOPMP Enable 1
        hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);

        // This transaction will be a match
        #50;
        ar_seq.rrid                 = 5;
        ar_seq.seq_addr             = 364;
        ar_seq.seq_id               = 2;
        ar_seq.seq_prot             = 'b100;
        ar_seq.seq_size             = 4;
        ar_seq.data_size            = 4;
        ar_seq.length               = 0;    //pass burst length manually
        ar_seq.has_length           = 1;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

        mdstall.b_data    = 32'h8;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);


        //Now send request with MDcfgLCK with setting f = 4

        // mdcfglck.b_data = 5'h4;                          // 5 entries associated with this md   entry 0,1,2,3,4
        // mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdcfg.b_data = 32'h4;                          // 4 entries associated with this md   entry 0,1,2,3
        mdcfg.index = 2;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        // // hwcfg2.prio_entry = 16
        // entry_addr.b_data = (32'd364)>>2;
        // entry_addr.index = 2;
        // entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

        // entry_cfg.b_data = 32'h11;                     // NA4 address mode with read permission granted
        // entry_cfg.index = 2;
        // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h0;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        // This transaction will not be a match
        #50;
        ar_seq.rrid                 = 5;
        ar_seq.seq_addr             = 364;
        ar_seq.seq_id               = 2;
        ar_seq.seq_prot             = 'b100;
        ar_seq.seq_size             = 4;
        ar_seq.data_size            = 4;
        ar_seq.length               = 0;    //pass burst length manually
        ar_seq.has_length           = 1;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

        //Now send request with MDcfgLCK with setting f = 3

        mdcfglck.b_data = 32'h6;                          // 5 entries associated with this md   entry 0,1,2
        mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h8;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        mdcfg.b_data = 32'h6;                          // 5 entries associated with this md   entry 4,5
        mdcfg.index = 3;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        // hwcfg2.prio_entry = 16
        // entry_addr.b_data = (32'd364)>>2;
        // entry_addr.index = 2;
        // entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);
// 
        // entry_cfg.b_data = 32'h11;                     // NA4 address mode with read permission granted
        // entry_cfg.index = 2;
        // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h0;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        // This transaction will not be a match
        #50;
        ar_seq.rrid                 = 5;
        ar_seq.seq_addr             = 364;
        ar_seq.seq_id               = 2;
        ar_seq.seq_prot             = 'b100;
        ar_seq.seq_size             = 4;
        ar_seq.data_size            = 4;
        ar_seq.length               = 0;    //pass burst length manually
        ar_seq.has_length           = 1;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction


//Now send request with MDcfgLCK with setting f = 8

        mdcfglck.b_data = 32'h8;                          // lock
        mdcfglck.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h8;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        mdcfg.b_data = 32'h8;                          // 2 entries associated with this md   entry 6,7
        mdcfg.index = 4;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        // hwcfg2.prio_entry = 16
        // entry_addr.b_data = (32'd364)>>2;
        // entry_addr.index = 2;
        // entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);
// 
        // entry_cfg.b_data = 32'h11;                     // NA4 address mode with read permission granted
        // entry_cfg.index = 2;
        // entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h0;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        // This transaction will be a match
        #50;
        ar_seq.rrid                 = 5;
        ar_seq.seq_addr             = 364;
        ar_seq.seq_id               = 2;
        ar_seq.seq_prot             = 'b100;
        ar_seq.seq_size             = 4;
        ar_seq.data_size            = 4;
        ar_seq.length               = 0;    //pass burst length manually
        ar_seq.has_length           = 1;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

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