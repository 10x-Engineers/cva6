/*************************************************************************
   > File Name:   fm_NA4_mdlckh_inst_fetch.sv
   > Description: Send instruction fetch for Full MOdel with NA4 Addressing mode with r permission in entry_cfg. INitially don't set the MDLCK. Set f=4 in MDLCK after setting srcmden = 8 and mdcfg 5. After this try to set srcmden = 4. Then set mdlck = D. 
   >              Then TRY TO WRITE SRCMDEN = 2. Then set l bit in mdlck. Then write 'h10.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class fm_NA4_mdlckh_inst_fetch extends full_model_base_test;
    `uvm_component_utils(fm_NA4_mdlckh_inst_fetch)
    hwcfg0_reg_seq         hwcfg0;
    srcmdenh_reg_seq       srcmden;
    srcmdrh_reg_seq        srcmdr;
    mdcfg_reg_seq          mdcfg;
    entry_addr_reg_seq     entry_addr;
    entry_cfg_reg_seq      entry_cfg;
    mdlck_reg_seq          mdlckl;
    mdhlck_reg_seq         mdlck;
    mdstallh_reg_seq       mdstall;

    axi_req_seq            ar_seq;
    axi_s_sanity_seq       s_seq;

    function new(string name = "fm_NA4_mdlckh_inst_fetch", uvm_component parent = null);
        super.new(name, parent);
        hwcfg0     = hwcfg0_reg_seq::type_id::create("hwcfg0");
        srcmden    = srcmdenh_reg_seq::type_id::create("srcmden");
        srcmdr     = srcmdrh_reg_seq::type_id::create("srcmdr");
        mdcfg      = mdcfg_reg_seq::type_id::create("mdcfg");
        entry_addr = entry_addr_reg_seq::type_id::create("entry_addr");
        entry_cfg  = entry_cfg_reg_seq::type_id::create("entry_cfg");
        mdlckl     = mdlck_reg_seq::type_id::create("mdlckl");
        mdlck      = mdhlck_reg_seq::type_id::create("mdlck");
        mdstall    = mdstallh_reg_seq::type_id::create("mdstall");
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

        srcmden.b_data = 32'h8;                        // Traverse MD 3
        srcmden.index = 5;
        srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdr.b_data = 32'h8;
        srcmdr.index = 5;
        srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdcfg.b_data = 32'h5;                          // 5 entries associated with this md   entry 0,1,2,3,4
        mdcfg.index = 34;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        // hwcfg2.prio_entry = 16
        entry_addr.b_data = (32'd364)>>2;
        entry_addr.index = 3;
        entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

        entry_cfg.b_data = 32'h15;                     // NA4 address mode with read permission granted
        entry_cfg.index = 3;
        entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        hwcfg0.b_data = 32'h80000000;                   //Setting IOPMP Enable 1
        hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);


        // This transaction will be a match
        #50;
        ar_seq.rrid                 = 5;
        ar_seq.seq_addr             = 364;
        ar_seq.seq_id               = 3;
        ar_seq.seq_prot             = 'b100;
        ar_seq.seq_size             = 4;
        ar_seq.data_size            = 4;
        ar_seq.length               = 0;    //pass burst length manually
        ar_seq.has_length           = 1;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction


        //Now send request with MDLCK with setting MD with l = 0

        mdlck.b_data = 32'h8;                       //MD 2
        mdlck.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h8;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        //Change MD In srcmden and srcmdr
        srcmden.b_data = 32'h4;                        // Traverse MD 2
        srcmden.index = 5;
        srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdr.b_data = 32'h4;
        srcmdr.index = 5;
        srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h0;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        // This transaction will not be a match
        #50;
        ar_seq.rrid                 = 5;
        ar_seq.seq_addr             = 364;
        ar_seq.seq_id               = 3;
        ar_seq.seq_prot             = 'b100;
        ar_seq.seq_size             = 4;
        ar_seq.data_size            = 4;
        ar_seq.length               = 0;    //pass burst length manually
        ar_seq.has_length           = 1;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

        //Now send request with MDLCK with setting MD with l = 0

        mdlck.b_data = 32'hD;                       //MD 2
        mdlck.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h8;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        //Change MD In srcmden and srcmdr
        srcmden.b_data = 32'h2;                        // Traverse MD 0
        srcmden.index = 5;
        srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdr.b_data = 32'h2;
        srcmdr.index = 5;
        srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h0;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        // This transaction will not be a match
        #50;
        ar_seq.rrid                 = 5;
        ar_seq.seq_addr             = 364;
        ar_seq.seq_id               = 3;
        ar_seq.seq_prot             = 'b100;
        ar_seq.seq_size             = 4;
        ar_seq.data_size            = 4;
        ar_seq.length               = 0;    //pass burst length manually
        ar_seq.has_length           = 1;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

        mdlckl.b_data = 32'h1;                       //l=1
        mdlckl.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdlck.b_data = 32'h10;                       //MD 2
        mdlck.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h8;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        //Change MD In srcmden and srcmdr
        srcmden.b_data = 32'h10;                        // Traverse MD 0
        srcmden.index = 5;
        srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdr.b_data = 32'h10;
        srcmdr.index = 5;
        srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdstall.b_data    = 32'h0;
        mdstall.start(env.axi_env.rd_addr_agnt.rd_addr_sqr);

        // This transaction will not be a match
        #50;
        ar_seq.rrid                 = 5;
        ar_seq.seq_addr             = 364;
        ar_seq.seq_id               = 3;
        ar_seq.seq_prot             = 'b100;
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