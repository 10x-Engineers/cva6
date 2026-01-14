/*************************************************************************
   > File Name:   wr_addr_monitor.sv
   > Description: AXI write address channel monitor for capturing transactions
   > Author:      Ahmed Raza
   > Modified:    Malik Faayez Muhammad
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef WR_ADDR_MONITOR
`define WR_ADDR_MONITOR

`define MON_IF axi_vif.monitor_cb
class wr_addr_monitor extends uvm_monitor;

    `uvm_component_utils(wr_addr_monitor)

    // Virtual Interface Declaration
    virtual axi_interface axi_vif;

    // Analysis Port Declaration
    uvm_analysis_port #(axi_seq_item) wr_addr_ap;
    uvm_analysis_port #(axi_seq_item) wr_addr_ap_cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //-------------------------------------------------------------------------
    // Function: build_phase
    //-------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_addr_ap = new("wr_addr_ap", this);
        wr_addr_ap_cov = new("wr_addr_ap_cov", this);
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


    //-------------------------------------------------------------------------
    // Task: main_phase
    // Purpose: Main phase of simulation to monitor transactions
    //-------------------------------------------------------------------------
    task main_phase(uvm_phase phase);
        forever begin
            monitor_wr_addr();
        end
    endtask

    //-------------------------------------------------------------------------
    // Task: monitor_wr_addr
    // Purpose: Monitors write address channel signals
    //-------------------------------------------------------------------------
    task monitor_wr_addr();
        axi_seq_item temp_wr_addr_item;

        // Create a new sequence item
        temp_wr_addr_item        = axi_seq_item::type_id::create("write_addr_monitor");
        temp_wr_addr_item.addr   = `MON_IF.AWADDR;
        temp_wr_addr_item.id     = `MON_IF.AWID;
        temp_wr_addr_item.size   = `MON_IF.AWSIZE;
        temp_wr_addr_item.w_user = `MON_IF.AWUSER;
        temp_wr_addr_item.prot   = `MON_IF.AWPROT;
        temp_wr_addr_item.region = `MON_IF.AWREGION;
        temp_wr_addr_item.qos    = `MON_IF.AWQOS;
        temp_wr_addr_item.access = WRITE_TRAN;
        temp_wr_addr_item.burst_length  = `MON_IF.AWLEN;

        // Decode burst type
        case (`MON_IF.AWBURST)
            2'b00: temp_wr_addr_item.burst = FIXED;
            2'b01: temp_wr_addr_item.burst = INCR;
            2'b10: temp_wr_addr_item.burst = WRAP;
        endcase

        // Write the monitored item to functional cov analysis port
        wr_addr_ap_cov.write(temp_wr_addr_item);
        
        // Write the monitored item to analysis port
        if(`MON_IF.AWVALID && `MON_IF.AWREADY) begin
            wr_addr_ap.write(temp_wr_addr_item);
            temp_wr_addr_item.print();
            `uvm_info(get_name(), "Completed Monitoring AXI_write_data_monitor transactions", UVM_LOW)
        end
        @(posedge axi_vif.ACLK);
    endtask
endclass

`endif
