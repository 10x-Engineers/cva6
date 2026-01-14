/*************************************************************************
   > File Name:   fm_NA4_entrylck_read.sv
   > Description: Send read address for Full MOdel with NA4 Addressing mode with r permission in entry_cfg. INitially don't set the ENTRYLCK. Set f=4 in ENTRYLCK after setting entry addr to index 3. After this try to set entry addr index less than f value. Then try to set entry addr index higher than or equal to f. 
   >              Then try to change f in Entrylck to lower then the value set before. Then try to change value of f in Entrylck higher than value set in first iteration. Then set l bit in ENtrylck and try to write the value higher than it is set now.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class fm_NA4_entrylck_read extends full_model_base_test;
    `uvm_component_utils(fm_NA4_entrylck_read)
    hwcfg0_reg_seq     hwcfg0;
    srcmden_reg_seq       srcmden;
    srcmdr_reg_seq        srcmdr;
    mdcfg_reg_seq         mdcfg;
    entry_addr_reg_seq    entry_addr;
    entry_cfg_reg_seq     entry_cfg;
    mdlck_reg_seq         mdlck;
    entrylck_reg_seq      entrylck;

    axi_req_seq           ar_seq;
    axi_s_sanity_seq      s_seq;

    function new(string name = "fm_NA4_entrylck_read", uvm_component parent = null);
        super.new(name, parent);
        hwcfg0      = hwcfg0_reg_seq::type_id::create("hwcfg0");
        srcmden     = srcmden_reg_seq::type_id::create("srcmden");
        srcmdr      = srcmdr_reg_seq::type_id::create("srcmdr");
        mdcfg       = mdcfg_reg_seq::type_id::create("mdcfg");
        entry_addr  = entry_addr_reg_seq::type_id::create("entry_addr");
        entry_cfg   = entry_cfg_reg_seq::type_id::create("entry_cfg");
        mdlck       = mdlck_reg_seq::type_id::create("mdlck");
        entrylck    = entrylck_reg_seq::type_id::create("entrylck");
        ar_seq      = axi_req_seq::type_id::create("ar_seq");
        s_seq       = axi_s_sanity_seq::type_id::create("s_seq");
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

        // hwcfg2.prio_entry = 16
        entry_addr.b_data = (32'd364)>>2;
        entry_addr.index = 3;
        entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

        entry_cfg.b_data = 32'h11;                     // NA4 address mode with read permission granted
        entry_cfg.index = 3;
        entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        entrylck.b_data = 5'h8;                          // 5 entries associated with this md   entry 0,1,2,3,4
        entrylck.start(env.reg_env.ahb_agnt.ahb_sqr);

        // hwcfg2.prio_entry = 16
        entry_addr.b_data = (32'd364)>>2;
        entry_addr.index = 2;
        entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

        entry_cfg.b_data = 32'h11;                     // NA4 address mode with read permission granted
        entry_cfg.index = 2;
        entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        entry_addr.b_data = (32'd364)>>2;
        entry_addr.index = 4;
        entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);

        entry_cfg.b_data = 32'h11;                     // NA4 address mode with read permission granted
        entry_cfg.index = 4;
        entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        hwcfg0.b_data = 32'h80000000;                   //Setting IOPMP Enable 1
        hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);

        // This transaction will be a match
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

        // This transaction will be a match
        #50;
        ar_seq.rrid                 = 5;
        ar_seq.seq_addr             = 364;
        ar_seq.seq_id               = 2;
        ar_seq.seq_prot             = 0;
        ar_seq.seq_size             = 4;
        ar_seq.data_size            = 4;
        ar_seq.length               = 0;    //pass burst length manually
        ar_seq.has_length           = 1;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

        // This transaction will be a match
        #50;
        ar_seq.rrid                 = 5;
        ar_seq.seq_addr             = 364;
        ar_seq.seq_id               = 4;
        ar_seq.seq_prot             = 0;
        ar_seq.seq_size             = 4;
        ar_seq.data_size            = 4;
        ar_seq.length               = 0;    //pass burst length manually
        ar_seq.has_length           = 1;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction

        entrylck.b_data = 5'h6;                          // 5 entries associated with this md   entry 0,1,2,3,4
        entrylck.start(env.reg_env.ahb_agnt.ahb_sqr);

        entrylck.b_data = 5'hA;                          // 5 entries associated with this md   entry 0,1,2,3,4
        entrylck.start(env.reg_env.ahb_agnt.ahb_sqr);

        entrylck.b_data = 5'h1;                          // 5 entries associated with this md   entry 0,1,2,3,4
        entrylck.start(env.reg_env.ahb_agnt.ahb_sqr);

        entrylck.b_data = 5'hC;                          // 5 entries associated with this md   entry 0,1,2,3,4
        entrylck.start(env.reg_env.ahb_agnt.ahb_sqr);

        //Now send request with MDcfgLCK with setting f = 4

        
        fork
          s_seq.start(env.axi_s_env.agent.sequencer);
        #300;
        join_any
        #100;
        phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
    endtask : main_phase


endclass