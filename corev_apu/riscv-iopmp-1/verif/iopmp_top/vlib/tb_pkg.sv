


package tb_pkg;
    import uvm_pkg::*;
     `include "uvm_macros.svh"
    //  `include "/../../../design/include/iopmp_pkg.sv"
    import config_iopmp_pkg::*;
    // Bus Parameters and Memory Model

    //cov_model
    // `include "/coverage/interface_functional_cov.sv"
   
    `include "/config/configurations.sv"
    // `include "/config/axi_s_config.sv"

    `include "/vlib/iopmp_reg.sv"

    // Sequences and Sequence Items
    `include "/agent/axi_seq_item.sv"
    `include "/agent/axi_s_seq_item.sv"
    `include "/agent/ahb_seq_item.sv"
    `include "/sequence/iopmp_seqs_lib.svh"

    //AXI Slave Agent
    // `include "/agent/axi_s_agent/axi_s_sequencer.sv"
    `include "/agent/axi_s_agent/axi_s_driver.sv"
    `include "/agent/axi_s_agent/axi_s_monitor.sv"
    `include "/agent/axi_s_agent/axi_s_agent.sv"

    // Write Address Agent
    `include "/agent/axi_agent/wr_addr_agent/wr_addr_sequencer.sv"
    `include "/agent/axi_agent/wr_addr_agent/wr_addr_driver.sv"
    `include "/agent/axi_agent/wr_addr_agent/wr_addr_monitor.sv"
    `include "/agent/axi_agent/wr_addr_agent/wr_addr_agent.sv"
    
    // Read Address Agent
    `include "/agent/axi_agent/rd_addr_agent/rd_addr_sequencer.sv"
    `include "/agent/axi_agent/rd_addr_agent/rd_addr_driver.sv"
    `include "/agent/axi_agent/rd_addr_agent/rd_addr_monitor.sv"
    `include "/agent/axi_agent/rd_addr_agent/rd_addr_agent.sv"
    
    // Write Data Agent
    `include "/agent/axi_agent/wr_data_agent/wr_data_sequencer.sv"
    `include "/agent/axi_agent/wr_data_agent/wr_data_driver.sv"
    `include "/agent/axi_agent/wr_data_agent/wr_data_monitor.sv"
    `include "/agent/axi_agent/wr_data_agent/wr_data_agent.sv"
    
    // Read Data Agent
    `include "/agent/axi_agent/rd_data_agent/rd_data_sequencer.sv"
    `include "/agent/axi_agent/rd_data_agent/rd_data_driver.sv"
    `include "/agent/axi_agent/rd_data_agent/rd_data_monitor.sv"
    `include "/agent/axi_agent/rd_data_agent/rd_data_agent.sv"
    
    // Write Response Agent
    `include "/agent/axi_agent/wr_rsp_agent/wr_rsp_sequencer.sv"
    `include "/agent/axi_agent/wr_rsp_agent/wr_rsp_driver.sv"
    `include "/agent/axi_agent/wr_rsp_agent/wr_rsp_monitor.sv"
    `include "/agent/axi_agent/wr_rsp_agent/wr_rsp_agent.sv"
    
    // AHB Agent
    `include "/agent/ahb_agent/ahb_sequencer.sv"
    `include "/agent/ahb_agent/ahb_driver.sv"
    `include "/agent/ahb_agent/ahb_monitor.sv"
    `include "/agent/ahb_agent/ahb_agent.sv"

    
    
    //Environment and Test
    `include "/scoreboard/iopmp_scoreboard.sv"

    //Adapter
    `include "/env/top_adapter.sv"

    //`include "../env/func_coverage.sv"
    `include "/env/ral_reg_env.sv"
    `include "/env/axi_environment.sv"
    `include "/env/axi_s_environment.sv"
    `include "/env/ahb_environment.sv"
    `include "/env/iopmp_env.sv"
    `include "/test/iopmp_tests.svh"
    `include "./../coverage/interface_functional_cov.sv"

    


endpackage: tb_pkg