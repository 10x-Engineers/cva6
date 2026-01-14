class iopmp_wr_rd_reg_test extends full_model_base_test;
    `uvm_component_utils(iopmp_wr_rd_reg_test)
reg_wr_rd_seq reg_rw_seq;

    function new(string name = "iopmp_wr_rd_reg_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        reg_rw_seq = reg_wr_rd_seq::type_id::create("reg_rw_seq");
        // reg_rw_seq.regmodel=regmodel;
    endfunction

    task main_phase(uvm_phase phase);
        super.main_phase(phase);
        `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
        phase.raise_objection(this, "MAIN - raise_objection");
        env.reg_env.ahb_agnt.ahb_drv.HSIZE     = 'd2;
        env.reg_env.ahb_agnt.ahb_drv.HBURST    = 0;
        env.reg_env.ahb_agnt.ahb_drv.HTRANS    = 'd2;
        env.reg_env.ahb_agnt.ahb_drv.HPROT     = 'd3;
        env.reg_env.ahb_agnt.ahb_drv.HMASTLOCK = 0;
        env.reg_env.ahb_agnt.ahb_drv.HSEL = 1;
        reg_rw_seq.start(env.reg_env.ahb_agnt.ahb_sqr);
        #1000
        phase.drop_objection(this, "MAIN - drop_objection");
        `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
    endtask : main_phase


endclass