/*************************************************************************
   > File Name:   wr_data_monitor.sv
   > Description: AXI write data channel monitor for capturing transactions
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef WR_DATA_MONITOR
`define WR_DATA_MONITOR

class wr_data_monitor extends uvm_monitor;
    `uvm_component_utils(wr_data_monitor)

    // Virtual interface for AXI signals
    virtual axi_interface axi_vif;

    // Analysis port to send captured transactions
    uvm_analysis_port #(axi_seq_item) wr_data_ap;
    uvm_analysis_port #(axi_seq_item) wr_data_ap_cov;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase to initialize analysis port
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_data_ap = new("wr_data_ap", this);
        wr_data_ap_cov = new("wr_data_ap_cov", this);
    endfunction

    //-----------------------------------------------------------------------------
    // Function: connect_phase
    //-----------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (!uvm_config_db#(virtual axi_interface#(.ID_WIDTH(`AXI_ID_WIDTH),.ADDR_WIDTH(`AXI_ADDR_WIDTH),.R_USER_WIDTH(`R_USER_WIDTH),.W_USER_WIDTH(`W_USER_WIDTH),.DATA_WIDTH(`AXI_DATA_WIDTH)))::get(this, "*", "axi_vif", axi_vif)) begin
            `uvm_error("Connect Phase", "Configuration failed for axi_monitor")
        end
    endfunction

    //----------------------------------------------------------------------------- 
    // Task: main_phase
    // Description: Continuously monitors write data channel
    //-----------------------------------------------------------------------------
    task main_phase(uvm_phase phase);
        forever begin
            monitor_wr_data();
        end
    endtask

    //----------------------------------------------------------------------------- 
    // Task: monitor_wr_data
    // Description: Captures write data transactions and sends them via analysis port
    //-----------------------------------------------------------------------------
    task monitor_wr_data();
        axi_seq_item temp_data_item;
        temp_data_item = axi_seq_item::type_id::create("AXI_write_data_monitor");

        `uvm_info(get_name(), "Monitoring AXI_write_data_monitor transactions", UVM_LOW)
        temp_data_item.id = axi_vif.WID;
        temp_data_item.w_user = axi_vif.WUSER;
        temp_data_item.write_data[0] = axi_vif.WDATA;
        temp_data_item.write_strobe[0] = axi_vif.WSTRB;
        temp_data_item.access = WRITE_TRAN;
        
        if(axi_vif.WVALID && axi_vif.WREADY) begin
        // Write the monitored item to scb analysis port
            wr_data_ap.write(temp_data_item);
            temp_data_item.print();
            `uvm_info(get_name(), "Completed Monitoring AXI_write_data_monitor transactions", UVM_LOW)
        end
        @(posedge axi_vif.ACLK);
    endtask
endclass

`endif
