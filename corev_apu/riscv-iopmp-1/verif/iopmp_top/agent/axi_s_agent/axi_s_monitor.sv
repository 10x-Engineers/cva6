class axi_s_monitor extends uvm_monitor;
    `uvm_component_utils(axi_s_monitor)
     // analysis ports for all channels
    uvm_analysis_port#(axi_s_seq_item) analysis_port_aw;
    uvm_analysis_port#(axi_s_seq_item) analysis_port_w;
    uvm_analysis_port#(axi_s_seq_item) analysis_port_b;
    uvm_analysis_port#(axi_s_seq_item) analysis_port_ar;
    uvm_analysis_port#(axi_s_seq_item) analysis_port_r;

    virtual axi_s_interface vif;

    function new(string name = "axi_s_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port_aw = new("analysis_port_aw", this);
        analysis_port_w = new("analysis_port_w", this);
        analysis_port_b = new("analysis_port_b", this);
        analysis_port_ar = new("analysis_port_ar", this);
        analysis_port_r = new("analysis_port_r", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_s_interface)::get(this, "", "axi_s_vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
    endfunction

    virtual task run_phase(uvm_phase phase);
    $display("AXI_s_MONITOR:::");
        forever begin
            fork
                begin  // Write Address Channel
                    axi_s_seq_item trans_aw;
                    trans_aw = axi_s_seq_item::type_id::create("trans_aw");

                    trans_aw.AWADDR     = vif.AWADDR;
                    trans_aw.AWPROT     = vif.AWPROT;
                    trans_aw.AWVALID    = vif.AWVALID;
                    trans_aw.AWLEN      = vif.AWLEN;
                    trans_aw.AWBURST    = vif.AWBURST;
                    trans_aw.AWID       = vif.AWID;
                    trans_aw.AWSIZE     = vif.AWSIZE;
                    trans_aw.AWUSER       = vif.AWUSER;
                    trans_aw.AWLOCK       = vif.AWLOCK;
                    trans_aw.AWCACHE      = vif.AWCACHE;
                    if (vif.AWREADY && vif.AWVALID)  // Send to Scoreboard only when AWREADY and AWVALID are asserted
                        analysis_port_aw.write(trans_aw);
                end

                begin  // Write Data Channel
                    axi_s_seq_item trans_w;
                    trans_w = axi_s_seq_item::type_id::create("trans_w");

                    trans_w.WVALID = vif.WVALID;
                    trans_w.WDATA = vif.WDATA;
                    trans_w.WSTRB = vif.WSTRB;
                    trans_w.WID = vif.WID;
                    trans_w.WLAST = vif.WLAST;
                    if (vif.WREADY && vif.WVALID)  // Send to Scoreboard only when WREADY and WVALID are asserted
                        analysis_port_w.write(trans_w);
                end

                begin  // Write Response Channel
                    axi_s_seq_item trans_b;
                    trans_b = axi_s_seq_item::type_id::create("trans_b");

                    trans_b.BVALID  = vif.BVALID;
                    trans_b.BRESP   = vif.BRESP;
                    trans_b.BID     = vif.BID;
                    trans_b.BUSER   = vif.BUSER;
                    if (vif.BREADY && vif.BVALID)  // Send to Scoreboard only when BREADY and BVALID are asserted
                        analysis_port_b.write(trans_b);
                end

                begin  // Read Address Channel
                    axi_s_seq_item trans_ar;
                    trans_ar = axi_s_seq_item::type_id::create("trans_ar");

                    trans_ar.ARADDR     = vif.ARADDR;
                    trans_ar.ARPROT     = vif.ARPROT;
                    trans_ar.ARVALID    = vif.ARVALID;
                    trans_ar.ARLEN      = vif.ARLEN;
                    trans_ar.ARBURST    = vif.ARBURST;
                    trans_ar.ARID       = vif.ARID;
                    trans_ar.ARSIZE     = vif.ARSIZE;
                    trans_ar.ARUSER       = vif.ARUSER;
                    trans_ar.ARLOCK       = vif.ARLOCK;
                    trans_ar.ARCACHE      = vif.ARCACHE;
                    if (vif.ARREADY && vif.ARVALID)  // Send to Scoreboard only when ARREADY and ARVALID are asserted
                        analysis_port_ar.write(trans_ar);
                end

                begin  // Read Data Channel        
                    axi_s_seq_item trans_r;
                    trans_r = axi_s_seq_item::type_id::create("trans_r");

                    trans_r.RVALID = vif.RVALID;
                    trans_r.RDATA = vif.RDATA;
                    trans_r.RRESP = vif.RRESP;
                    trans_r.RID = vif.RID;
                    trans_r.RLAST = vif.RLAST;
                    trans_r.RUSER  = vif.RUSER;
                    if (vif.RREADY && vif.RVALID)  // Send to Scoreboard only when RREADY and RVALID are asserted
                        analysis_port_r.write(trans_r);
                end

            join
            @(posedge vif.ACLK);
        end
    endtask
endclass