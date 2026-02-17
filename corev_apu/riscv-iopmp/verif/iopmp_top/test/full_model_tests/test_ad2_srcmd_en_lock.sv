/*************************************************************************
   > File Name:   test_ad2_srcmd_en_lock.sv
   > Description: Set SRCMD_EN(s).l bit low and update the SRCMD_EN(s), SRCMD_ENH(s), SRCMD_R(s), SRCMD_RH(s), SRCMD_W(s) and SRCMD_WH(s) registers, where s < 64
Set SRCMD_EN(s).l bit high and update the SRCMD_EN(s), SRCMD_ENH(s), SRCMD_R(s), SRCMD_RH(s), SRCMD_W(s) and SRCMD_WH(s) registers, where s < 64
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class test_ad2_srcmd_en_lock extends full_model_base_test;
    `uvm_component_utils(test_ad2_srcmd_en_lock)

    srcmden_reg_seq       srcmden;
    srcmdenh_reg_seq      srcmdenh;
    srcmdr_reg_seq        srcmdr;
    srcmdrh_reg_seq       srcmdrh;
    srcmdw_reg_seq        srcmdw;
    srcmdwh_reg_seq       srcmdwh;

    function new(string name = "test_ad2_srcmd_en_lock", uvm_component parent = null);
        super.new(name, parent);
        srcmden    = srcmden_reg_seq::type_id::create("srcmden");
        srcmdenh   = srcmdenh_reg_seq::type_id::create("srcmdenh");
        srcmdr     = srcmdr_reg_seq::type_id::create("srcmdr");
        srcmdrh    = srcmdrh_reg_seq::type_id::create("srcmdrh");
        srcmdw     = srcmdw_reg_seq::type_id::create("srcmdw");
        srcmdwh    = srcmdwh_reg_seq::type_id::create("srcmdwh");
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
        srcmden.index = 0;
        srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdenh.b_data = 32'h8;                        // Traverse MD 2
        srcmdenh.index = 0;
        srcmdenh.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdr.b_data = 32'h8;
        srcmdr.index = 0;
        srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdrh.b_data = 32'h8;
        srcmdrh.index = 0;
        srcmdrh.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdw.b_data = 32'h8;
        srcmdw.index = 0;
        srcmdw.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdwh.b_data = 32'h8;
        srcmdwh.index = 0;
        srcmdwh.start(env.reg_env.ahb_agnt.ahb_sqr);

        //lock 
        srcmden.b_data = 32'h9;                        
        srcmden.index = 0;
        srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmden.b_data = 32'hE;                        
        srcmden.index = 0;
        srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdenh.b_data = 32'hE;                        
        srcmdenh.index = 0;
        srcmdenh.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdr.b_data = 32'hE;
        srcmdr.index = 0;
        srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdrh.b_data = 32'hE;
        srcmdrh.index = 0;
        srcmdrh.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdw.b_data = 32'hE;
        srcmdw.index = 0;
        srcmdw.start(env.reg_env.ahb_agnt.ahb_sqr);

        srcmdwh.b_data = 32'hE;
        srcmdwh.index = 0;
        srcmdwh.start(env.reg_env.ahb_agnt.ahb_sqr);
        
        #100;
        phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
    endtask : main_phase


endclass