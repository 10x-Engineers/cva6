class axi_s_driver extends uvm_driver#(axi_s_seq_item);
    `uvm_component_utils(axi_s_driver)

    // seq item ports for multiple sequencers
    uvm_seq_item_pull_port #(REQ,RSP) seq_item_port0; // Write Data Channel
    uvm_seq_item_pull_port #(REQ,RSP) seq_item_port1; // Write Response Channel
    uvm_seq_item_pull_port #(REQ,RSP) seq_item_port2; // Read Address Channel
    uvm_seq_item_pull_port #(REQ,RSP) seq_item_port3; // Read Data Channel
    
    virtual axi_s_interface vif; // Virtual interface handle

    // transaction item handles for all channels reqs and rsps
    axi_s_seq_item aw_req;
    axi_s_seq_item w_req;
    axi_s_seq_item b_req;
    axi_s_seq_item ar_req;
    axi_s_seq_item r_req;
    axi_s_seq_item ready_trans;

    function new(string name = "axi_s_driver", uvm_component parent);
        super.new(name, parent);
        seq_item_port0 = new("seq_item_port0", this);
        seq_item_port1 = new("seq_item_port1", this);
        seq_item_port2 = new("seq_item_port2", this);
        seq_item_port3 = new("seq_item_port3", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_s_interface)::get(this, "", "axi_s_vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
        `uvm_info(get_name(), "Build phase completed for Slave Axi DRIVER", UVM_LOW)
    endfunction

    //-----------------------------------------------------------------------------
  // Reset Phase
  //-----------------------------------------------------------------------------
  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    vif.reset_axi_s();  // Reset the Axi SLAVE signals to defualt
   `uvm_info(get_name(), "Reset phase: Signals reset to default", UVM_LOW)
    phase.drop_objection(this);
  endtask : reset_phase

    virtual task run_phase(uvm_phase phase);
        // Configuring Ready signals at start
        seq_item_port.get_next_item(ready_trans);
        vif.AWREADY <= ready_trans.AWREADY;
        vif.ARREADY <= ready_trans.ARREADY;
        vif.WREADY  <= ready_trans.WREADY;
        $display("AXI_s_DRIVER:::%h", ready_trans.ARREADY);
        seq_item_port.item_done(ready_trans);

        fork // Monitor the AXI4 signals and respond with slave sequences
        forever begin  // Write Address Channel
                seq_item_port.get_next_item(aw_req);
                #0.1;
                @(vif.AWVALID == 1)
                #0.1;
                aw_req.AWADDR  = 0;
                aw_req.AWPROT  = vif.AWPROT;
                aw_req.AWVALID = vif.AWVALID;
                aw_req.AWLEN   = vif.AWLEN;
                aw_req.AWBURST = vif.AWBURST;
                aw_req.AWID    = vif.AWID;
                aw_req.AWSIZE  = vif.AWSIZE;
                aw_req.AWUSER  = vif.AWUSER;
                aw_req.AWLOCK  = vif.AWLOCK;
                aw_req.AWCACHE = vif.AWCACHE;
                $display("AXI_s_DRIVER:::AW%h", aw_req.AWADDR);
                @(posedge vif.ACLK);
                seq_item_port.item_done(aw_req);
        end
        forever begin  // Write Data Channel
                seq_item_port0.get_next_item(w_req);
                w_req.WVALID <= vif.WVALID;
                w_req.WDATA  <= vif.WDATA;
                w_req.WSTRB  <= vif.WSTRB;
                // w_req.WID    <= vif.WID;
                w_req.WLAST  <= vif.WLAST;
                w_req.WUSER  <= vif.WUSER;
                seq_item_port0.item_done(w_req);
                @(posedge vif.ACLK);
        end
        forever begin  // Write Response Channel
            seq_item_port1.get_next_item(b_req);
            vif.BVALID <= b_req.BVALID;
            vif.BRESP  <= b_req.BRESP;
            vif.BID    <= b_req.BID;
            vif.BUSER  <= b_req.BUSER;
            wait (vif.BREADY == 1);
            seq_item_port1.item_done(b_req);
            @(posedge vif.ACLK);
            vif.BVALID <= 0;
            @(posedge vif.ACLK);
        end
        forever begin  // Read Address Channel
                seq_item_port2.get_next_item(ar_req);
                wait(vif.ARVALID == 1);
                ar_req.ARADDR  <= 0;
                ar_req.ARPROT  <= vif.ARPROT;
                ar_req.ARVALID <= vif.ARVALID;
                ar_req.ARLEN   <= vif.ARLEN;
                ar_req.ARBURST <= vif.ARBURST;
                ar_req.ARID    <= vif.ARID;
                ar_req.ARSIZE  <= vif.ARSIZE;
                ar_req.ARUSER  <= vif.ARUSER;
                ar_req.ARLOCK  <= vif.ARLOCK;
                ar_req.ARCACHE <= vif.ARCACHE;
                
                @(posedge vif.ACLK);
                #2ps;
                seq_item_port2.item_done(ar_req);
        end
        forever begin  // Read Data Channel
            seq_item_port3.get_next_item(r_req);
            vif.RVALID <= r_req.RVALID;
            vif.RDATA  <= r_req.RDATA;
            vif.RRESP  <= r_req.RRESP;
            vif.RID    <= r_req.RID;
            vif.RLAST  <= r_req.RLAST;
            vif.RUSER  <= r_req.RUSER;
            wait (vif.RREADY == 1);
            seq_item_port3.item_done(r_req);
            @(posedge vif.ACLK);
            vif.RVALID <= 0;
            @(posedge vif.ACLK);
        end
        join_any
    endtask

endclass