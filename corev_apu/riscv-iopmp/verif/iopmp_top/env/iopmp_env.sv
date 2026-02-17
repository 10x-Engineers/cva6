/*************************************************************************
   > File Name:   iopmp_env.sv
   > Description: Environment class for the IOMPMP verification setup.
                  Manages agents, scoreboard, and connections.
   > Author:      Muhammad Hassan
   > Modified:    Muhammad Hassan
   > Mail:        muhammad.hassan@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef IOPMP_ENV
`define IOPMP_ENV

//-----------------------------------------------------------------------------
// iopmp_scoreboard Environment Class
//-----------------------------------------------------------------------------
class iopmp_env extends uvm_env;

    `uvm_component_utils(iopmp_env)

    //-------------------------------------------------------------------------
    // Member Variables
    //-------------------------------------------------------------------------
    axi_environment axi_env;                // Axi Enivronemnt
    axi_s_environment axi_s_env;                // Axi Slave Enivronemnt
    // ahb_environment ahb_env;               // AHB Enivronemnt - without uvm ral
    ral_reg_env reg_env   ;          // Registers env
    iopmp_scoreboard scoreboard;        // Scoreboard
    // func_coverage func_cov;               // Coverage Monitor


    //-------------------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //-------------------------------------------------------------------------
    // Build Phase
    // Creates AXI agents, AHB agent, and the scoreboard
    //-------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "BUILD Phase of Env", UVM_LOW);

        // Create Env and  Scoreboard and Cov mon
        axi_env      =  axi_environment::type_id::create("axi_env", this);
        axi_s_env      =  axi_s_environment::type_id::create("axi_s_env", this);
        // ahb_env      =  ahb_environment::type_id::create("ahb_env", this);
        reg_env     =  ral_reg_env::type_id::create("reg_env", this);
        scoreboard   =  iopmp_scoreboard::type_id::create("scoreboard", this);
        // func_cov     =  func_coverage::type_id::create("func_cov", this);
        uvm_reg::include_coverage ("*", UVM_CVR_ALL);
    endfunction

    //-------------------------------------------------------------------------
    // Connect Phase
    // Connects AXI channel's monitor analysis ports to the scoreboard
    //-------------------------------------------------------------------------

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_name(), "CONNECT Phase of Env", UVM_LOW);

        // Connect AXI Monitors to Scoreboard
        axi_env.wr_addr_agnt.wr_addr_mon.wr_addr_ap.connect(scoreboard.axi_wr_addr_imp);
        axi_env.rd_addr_agnt.rd_addr_mon.rd_addr_ap.connect(scoreboard.axi_rd_addr_imp);
        axi_env.wr_data_agnt.wr_data_mon.wr_data_ap.connect(scoreboard.axi_wr_data_imp);
        axi_env.rd_data_agnt.rd_data_mon.rd_data_ap.connect(scoreboard.axi_rd_data_imp);
        axi_env.wr_rsp_agnt.wr_rsp_mon.wr_rsp_ap.connect(scoreboard.axi_wr_rsp_imp);

        //AXI slave ports
        axi_s_env.agent.monitor.analysis_port_aw.connect(scoreboard.axi_s_aw_imp);
        axi_s_env.agent.monitor.analysis_port_w.connect(scoreboard.axi_s_w_imp);
        axi_s_env.agent.monitor.analysis_port_b.connect(scoreboard.axi_s_b_imp);
        axi_s_env.agent.monitor.analysis_port_ar.connect(scoreboard.axi_s_ar_imp);
        axi_s_env.agent.monitor.analysis_port_r.connect(scoreboard.axi_s_r_imp);

        // Connect AHB Monitor to Scoreboard
        // ahb_env.ahb_agnt.ahb_mon.ahb_ap.connect(scoreboard.ahb_data_imp);  // without uvm ral
        reg_env.ahb_agnt.ahb_mon.ahb_ap.connect(scoreboard.ahb_data_imp);
        reg_env.ahb_agnt.ahb_mon.ahb_ap.connect(reg_env.predictor.bus_in);

        // ahb_env.ahb_agnt.ahb_mon.ahb_ap_addr.connect(scoreboard.ahb_addr_imp);

        // // Connect AXI Monitors to Functional Coverage
        // axi_env.wr_addr_agnt.wr_addr_mon.wr_addr_ap.connect(func_cov.axi_wr_addr_imp_cov);
        // axi_env.rd_addr_agnt.rd_addr_mon.rd_addr_ap.connect(func_cov.axi_rd_addr_imp_cov);
        // axi_env.wr_rsp_agnt.wr_rsp_mon.wr_rsp_ap.connect(func_cov.axi_wr_rsp_imp_cov);
    endfunction

endclass

`endif
