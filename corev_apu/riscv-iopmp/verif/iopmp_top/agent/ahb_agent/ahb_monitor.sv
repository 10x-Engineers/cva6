/*************************************************************************
   > File Name:   ahb_monitor.sv
   > Description: AHB protocol monitor for verifying write and read operations.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef AHB_MONITOR
`define AHB_MONITOR

`define MON_IF ahb_vif.monitor_cb

//-----------------------------------------------------------------------------
// Class: ahb_monitor
//-----------------------------------------------------------------------------
class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)

    virtual ahb_interface ahb_vif;
    ahb_seq_item ahb_mon_item;
    reg [31:0] h_addr_pre=0,h_addr_new=0;
    reg h_write_new=0,h_write_pre=0;
    reg [1:0] h_resp_new=0,h_resp_pre=0;
    reg [2:0] h_burst_pre, h_burst_new;
    reg [1:0] h_trans_pre, h_trans_new;
    reg [1:0] h_size_pre, h_size_new;

    // Analysis port
    uvm_analysis_port #(ahb_seq_item) ahb_ap;

    //-----------------------------------------------------------------------------
    // Function: new
    //-----------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //-----------------------------------------------------------------------------
    // Function: build_phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ahb_ap = new("ahb_ap", this);
        // ahb_ap_addr = new("ahb_ap_addr", this);
        ahb_mon_item = ahb_seq_item::type_id::create("ahb_mon_item", this);
    endfunction

    //-----------------------------------------------------------------------------
    // Function: connect_phase
    //-----------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (!uvm_config_db#(virtual ahb_interface#(.ADDR_WIDTH(`AHB_ADDR_WIDTH),.DATA_WIDTH(`AHB_DATA_WIDTH)))::get(this, "*", "ahb_vif", ahb_vif)) begin
            `uvm_fatal(get_name(), "Configuration failed for ahb_monitor")
        end
    endfunction

    //-----------------------------------------------------------------------------
    // Task: main_phase
    //-----------------------------------------------------------------------------
    task main_phase(uvm_phase phase);
    // @(posedge ahb_vif.HCLK);
        forever begin
            @(posedge ahb_vif.HCLK);
            monitor();
        end
    endtask

    //-----------------------------------------------------------------------------
    // Task: monitor
    //-----------------------------------------------------------------------------
    task monitor();
            `uvm_info(get_name(), "Monitoring ahb transactions", UVM_HIGH)
            // Address Phase, monitor control signals
        if (ahb_vif.HTRANS!=0 && ahb_vif.HREADY) begin
            ahb_mon_item.HADDR_o  = ahb_vif.HADDR;
            ahb_mon_item.ACCESS_o = (ahb_vif.HWRITE == 1)? write : read;
            ahb_mon_item.HBURST_o = ahb_vif.HBURST;
            ahb_mon_item.HSIZE_o  = ahb_vif.HSIZE;
            ahb_mon_item.HRDATA_i = ahb_vif.HRDATA;
            ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? error : okay;
            $display("AHB_MON::::");

            // Data Phase
            if(ahb_mon_item.ACCESS_o==write)begin
                @(posedge ahb_vif.HCLK);
                ahb_mon_item.HWDATA_o = ahb_vif.HWDATA;
                `uvm_info(get_type_name (), $sformatf ("MON_dAta , %h",ahb_mon_item.HWDATA_o), UVM_HIGH);
                if (ahb_vif.HREADY) begin
                    $display("AHB_MON::::");
                    // ahb_mon_item.HTRANS_o = ahb_vif.HTRANS;
                    // ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? error : okay;
                end
            end else begin
                if (ahb_vif.HTRANS==2) begin
                    @(posedge ahb_vif.HCLK);
                    @(ahb_vif.HREADY == 1)
                    ahb_mon_item.HTRANS_o = ahb_vif.HTRANS;
                    `uvm_info(get_type_name (), $sformatf ("MON_dAta_Read, %h",ahb_mon_item.HRDATA_i), UVM_HIGH);
                    // ahb_ap.write(ahb_mon_item);
                    // ahb_mon_item.print();  // Print the monitored data
                end
            end
            ahb_ap.write(ahb_mon_item);
            ahb_mon_item.print();  // Print the monitored data
            // `uvm_info(get_type_name (), $sformatf ("MON_trans , %d",ahb_mon_item.HTRANS_o), UVM_HIGH);
        end
    endtask
//-----------------------------------------------------------------------------
// Task: monitor
//-----------------------------------------------------------------------------
    // task monitor();
    //     `uvm_info(get_name(), "Monitoring AHB transactions...", UVM_HIGH)

    //     // Only valid transfer if HTRANS != IDLE and HREADY is high
    //     if (ahb_vif.HTRANS != 2'b00 && ahb_vif.HREADY) begin
    //         // ---------------------------
    //         // Address phase capture
    //         // ---------------------------
    //         ahb_mon_item.HADDR_o  = ahb_vif.HADDR;
    //         ahb_mon_item.ACCESS_o = (ahb_vif.HWRITE == 1) ? write : read;
    //         ahb_mon_item.HBURST_o = ahb_vif.HBURST;
    //         ahb_mon_item.HSIZE_o  = ahb_vif.HSIZE;

    //         `uvm_info(get_type_name(),
    //           $sformatf("ADDR_PHASE: ADDR=%h ACCESS=%s HWRITE=%0b",
    //             ahb_mon_item.HADDR_o,
    //             (ahb_mon_item.ACCESS_o==write)?"WRITE":"READ",
    //             ahb_vif.HWRITE),
    //           UVM_MEDIUM)

    //         // ---------------------------
    //         // Data phase for WRITE
    //         // ---------------------------
    //         if (ahb_mon_item.ACCESS_o == write) begin
    //             @(posedge ahb_vif.HCLK);
    //             wait (ahb_vif.HREADY);
    //             ahb_mon_item.HWDATA_o = ahb_vif.HWDATA;
    //             ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? error : okay;

    //             `uvm_info(get_type_name(),
    //               $sformatf("WRITE_DATA_PHASE: ADDR=%h WDATA=%h RESP=%0d",
    //                 ahb_mon_item.HADDR_o,
    //                 ahb_mon_item.HWDATA_o,
    //                 ahb_mon_item.RESP_i),
    //               UVM_HIGH)

    //         end
    //         // ---------------------------
    //         // Data phase for READ
    //         // ---------------------------
    //         else begin
    //             @(posedge ahb_vif.HCLK);
    //             wait (ahb_vif.HREADY);
    //             ahb_mon_item.HTRANS_o = ahb_vif.HTRANS;
    //             ahb_mon_item.HRDATA_i = ahb_vif.HRDATA;
    //             ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? error : okay;

    //             `uvm_info(get_type_name(),
    //               $sformatf("READ_DATA_PHASE: ADDR=%h RDATA=%h RESP=%0d",
    //                 ahb_mon_item.HADDR_o,
    //                 ahb_mon_item.HRDATA_i,
    //                 ahb_mon_item.RESP_i),
    //               UVM_HIGH)
    //         end

    //         // ---------------------------
    //         // Send out the transaction
    //         // ---------------------------
    //         ahb_ap.write(ahb_mon_item);
    //         // ahb_mon_item.print();

    //     end // if valid HTRANS
    // endtask
endclass

`endif