/*************************************************************************
   > File Name:   test_ad2_unsuppt_mdh.sv
   > Description: "1. Configure MD_NUM to let say 40 in the IOPMP Configuration.
2. Set MDLCKH.mdh[8] and update SRCMD_ENH.mdh[8]/SRCMD_RH.mdh[8]/SRCMD_WH.mdh[8].
3. Set MDLCKH.mdh[9] and update SRCMD_ENH.mdh[9]/SRCMD_RH.mdh[9]/SRCMD_WH.mdh[9]."
Set MD_NUM = 40 in config_iopmp
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class test_ad2_unsuppt_mdh extends full_model_base_test;
    `uvm_component_utils(test_ad2_unsuppt_mdh)
    hwcfg0_reg_seq        hwcfg0;
    srcmdenh_reg_seq       srcmdenh;
    srcmdrh_reg_seq        srcmdrh;
    mdcfg_reg_seq         mdcfg;
    entry_addr_reg_seq    entry_addr;
    entry_cfg_reg_seq     entry_cfg;
    mdhlck_reg_seq         mdlckh;

    axi_req_seq           ar_seq;
    axi_s_sanity_seq      s_seq;

    function new(string name = "test_ad2_unsuppt_mdh", uvm_component parent = null);
        super.new(name, parent);
        hwcfg0     = hwcfg0_reg_seq::type_id::create("hwcfg0");
        srcmdenh    = srcmdenh_reg_seq::type_id::create("srcmdenh");
        srcmdrh     = srcmdrh_reg_seq::type_id::create("srcmdrh");
        mdcfg      = mdcfg_reg_seq::type_id::create("mdcfg");
        entry_addr = entry_addr_reg_seq::type_id::create("entry_addr");
        entry_cfg  = entry_cfg_reg_seq::type_id::create("entry_cfg");
        mdlckh      = mdhlck_reg_seq::type_id::create("mdlckh");
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

        mdlckh.b_data = 32'h100;                       //MD 
        mdlckh.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdenh.b_data = 32'h100;                        // Traverse MD 39
        srcmdenh.index = 5;
        srcmdenh.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdrh.b_data = 32'h100;
        srcmdrh.index = 5;
        srcmdrh.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdcfg.b_data = 32'h5;                          // 5 entries associated with this md   entry 0,1,2,3,4
        mdcfg.index = 39;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);



        //Now send request with MDLCK with setting MD with l = 0

        mdlckh.b_data = 32'h200;                       //MD 2
        mdlckh.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdenh.b_data = 32'h200;                        // Traverse MD 40
        srcmdenh.index = 5;
        srcmdenh.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdrh.b_data = 32'h200;
        srcmdrh.index = 5;
        srcmdrh.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdcfg.b_data = 32'h6;                          // 5 entries associated with this md   entry 0,1,2,3,4
        mdcfg.index = 40;
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);



        
        #100;
        phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
    endtask : main_phase


endclass