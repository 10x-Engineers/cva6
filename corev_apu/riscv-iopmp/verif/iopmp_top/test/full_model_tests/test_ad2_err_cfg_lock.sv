/*************************************************************************
   > File Name:   test_ad2_err_cfg_lock.sv
   > Description: Set ERR_CFG.l bit low and update the value of ERR_CFG register.
Set ERR_CFG.l bit high and update the value of ERR_CFG register.
Set ERR_CFG.l bit low and update the value of ERR_MSIADDR and ERR_MSIADDRH registers.
Set ERR_CFG.l bit high and update the value of ERR_MSIADDR and ERR_MSIADDRH registers.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class test_ad2_err_cfg_lock extends full_model_base_test;
    `uvm_component_utils(test_ad2_err_cfg_lock)

    errcfg_reg_seq          err_cfg;
    err_msiaddr_reg_seq     err_msi;
    err_msiaddrh_reg_seq    err_msih;

    function new(string name = "test_ad2_err_cfg_lock", uvm_component parent = null);
        super.new(name, parent);
        err_cfg      = errcfg_reg_seq::type_id::create("err_cfg");
        err_msi      = err_msiaddr_reg_seq::type_id::create("err_msi");
        err_msih      = err_msiaddrh_reg_seq::type_id::create("err_msih");
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


        err_cfg.b_data = 32'h1E;                          
        err_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        err_msi.b_data = 32'h2;                          
        err_msi.start(env.reg_env.ahb_agnt.ahb_sqr);

        err_msih.b_data = 32'h4;                          
        err_msih.start(env.reg_env.ahb_agnt.ahb_sqr);

        err_cfg.b_data = 32'h1F;                          
        err_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        err_cfg.b_data = 32'h71E;                          
        err_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);

        err_msi.b_data = 32'h9;                          
        err_msi.start(env.reg_env.ahb_agnt.ahb_sqr);

        err_msih.b_data = 32'h12;                          
        err_msih.start(env.reg_env.ahb_agnt.ahb_sqr);
        
        #100;
        phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
    endtask : main_phase


endclass