/*************************************************************************
   > File Name:   wr_rsp_monitor.sv
   > Description: AXI write response channel monitor for capturing transactions
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef WR_RSP_MONITOR
`define WR_RSP_MONITOR

`define MON_IF axi_vif.monitor_cb
class wr_rsp_monitor extends uvm_monitor;

    `uvm_component_utils(wr_rsp_monitor)

    // Virtual Interface Declaration
    virtual axi_interface axi_vif;

    // Analysis Port Declaration
    uvm_analysis_port #(axi_seq_item) wr_rsp_ap;
    uvm_analysis_port #(axi_seq_item) wr_rsp_ap_cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //-------------------------------------------------------------------------
    // Function: build_phase
    //-------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_rsp_ap = new("wr_rsp_ap", this);
        wr_rsp_ap_cov = new("wr_rsp_ap_cov", this);
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
            monitor_wr_rsp();
        end
    endtask

    //-------------------------------------------------------------------------
    // Task: monitor_wr_rsp
    // Purpose: Monitors write response channel signals
    //-------------------------------------------------------------------------
    task monitor_wr_rsp();
        axi_seq_item temp_wr_rsp_item;
        temp_wr_rsp_item       = axi_seq_item::type_id::create("write_rsp_monitor");

        `uvm_info(get_name(), "Monitoring AXI_write_rsp_monitor transactions", UVM_LOW)
        temp_wr_rsp_item.b_valid  = `MON_IF.BVALID;
        temp_wr_rsp_item.id       = `MON_IF.BID;
        temp_wr_rsp_item.w_user   = `MON_IF.BUSER;
        case (`MON_IF.BRESP)
            2'b00 : temp_wr_rsp_item.response = OKAY;
            2'b01 : temp_wr_rsp_item.response = EXOKAY;
            2'b10 : temp_wr_rsp_item.response = SLVERR;
            2'b11 : temp_wr_rsp_item.response = DECERR;
        endcase

        // Write the monitored item to functional cov analysis port
        wr_rsp_ap_cov.write(temp_wr_rsp_item);

        if (`MON_IF.BVALID) begin
            // Write the monitored item to functional cov analysis port
            wr_rsp_ap.write(temp_wr_rsp_item);
            temp_wr_rsp_item.print();
            `uvm_info(get_name(), "Completed Monitoring AXI_write_rsp_monitor transactions", UVM_LOW)
        end
        @(posedge axi_vif.ACLK);
    endtask

endclass

`endif
