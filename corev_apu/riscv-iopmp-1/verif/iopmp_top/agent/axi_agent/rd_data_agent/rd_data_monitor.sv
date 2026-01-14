/*************************************************************************
   > File Name:   rd_data_monitor.sv
   > Description: Monitors AXI read data channel transactions.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef RD_DATA_MONITOR
`define RD_DATA_MONITOR

`define MON_IF this.axi_vif
class rd_data_monitor extends uvm_monitor;
    `uvm_component_utils(rd_data_monitor)

    virtual axi_interface axi_vif;
    uvm_analysis_port #(axi_seq_item) rd_data_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rd_data_ap = new("rd_data_ap", this);
    endfunction

    //-----------------------------------------------------------------------------
    // Function: connect_phase
    //-----------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (!uvm_config_db#(virtual axi_interface#(.ID_WIDTH(`AXI_ID_WIDTH),.ADDR_WIDTH(`AXI_ADDR_WIDTH),.R_USER_WIDTH(`R_USER_WIDTH),.W_USER_WIDTH(`W_USER_WIDTH),.DATA_WIDTH(`AXI_DATA_WIDTH)))::get(this, "*", "axi_vif", axi_vif)) begin
            `uvm_fatal(get_name(), "Configuration failed for axi_rd_data_monitor")
        end
    endfunction


    //----------------------------------------------------------------------------- 
    // Task: main_phase 
    //----------------------------------------------------------------------------- 
    task main_phase(uvm_phase phase);
        forever begin
            monitor_rd_data();
        end
    endtask

     //----------------------------------------------------------------------------- 
    // Task: monitor_rd_data
    // Description: Captures Read data transactions and sends them via analysis port
    //-----------------------------------------------------------------------------
    task monitor_rd_data();

        
        axi_seq_item temp_rd_data_item;
        temp_rd_data_item         = axi_seq_item::type_id::create("read_data_monitor");

        `uvm_info(get_name(), "Monitoring AXI_Read_data_monitor transactions", UVM_LOW)
        temp_rd_data_item.id            = `MON_IF.RID;
        temp_rd_data_item.r_user        = `MON_IF.RUSER;
        temp_rd_data_item.last          = `MON_IF.RLAST;
        temp_rd_data_item.write_data[0] = `MON_IF.RDATA;
        temp_rd_data_item.access        = READ_TRAN;
        temp_rd_data_item.r_valid       = `MON_IF.RVALID;
        temp_rd_data_item.response      = `MON_IF.RRESP;
        case (`MON_IF.RRESP)
            2'b00 : temp_rd_data_item.response = OKAY;
            2'b01 : temp_rd_data_item.response = EXOKAY;
            2'b10 : temp_rd_data_item.response = SLVERR;
            2'b11 : temp_rd_data_item.response = DECERR;
        endcase

        if(`MON_IF.RVALID && `MON_IF.RREADY) begin
        // Write the monitored item to functional cov analysis port
            rd_data_ap.write(temp_rd_data_item);
            temp_rd_data_item.print();
            `uvm_info(get_name(), "Completed AXI_Read_data_monitor transactions", UVM_LOW)
            $display("AXI ITEM ID IN MON %h",temp_rd_data_item.response);
        // `uvm_info(get_type_name (), $sformatf ("AXI DATA ITEM  IN MON %h",axi_rd_data_item.write_data[0]), UVM_NONE);
        end
        @(posedge axi_vif.ACLK);
        
    endtask
endclass

`endif
