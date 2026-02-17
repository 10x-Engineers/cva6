/*************************************************************************
   > File Name:   test_ad2_unsuppt_md_1.sv
   > Description: "1. Configure MD_NUM to let say 63 in the IOPMP Configuration.
2. Configure MDCFLCK.f to a value of 64.
2. Configure MDCFLCK.f to a value of 32.
3. Re-configure the MDCFGLCK.f to a value of 10.
4. Read the register."
Set MD_NUM = 63 in config_iopmp
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class test_ad2_unsuppt_md_1 extends full_model_base_test;
    `uvm_component_utils(test_ad2_unsuppt_md_1)

    mdcfglck_reg_seq      mdcfg;

    function new(string name = "test_ad2_unsuppt_md_1", uvm_component parent = null);
        super.new(name, parent);
        mdcfg      = mdcfglck_reg_seq::type_id::create("mdcfg");
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


        mdcfg.b_data = 32'h64;                          
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdcfg.b_data = 32'h32;                          
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        mdcfg.b_data = 32'h16;                          
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
        
        #100;
        phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
    endtask : main_phase


endclass