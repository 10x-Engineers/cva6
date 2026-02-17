class axi_s_agent extends uvm_agent;
    `uvm_component_utils(axi_s_agent)


    axi_s_sequencer sequencer;
    axi_s_driver    driver;
    axi_s_monitor   monitor;
    // uvm_active_passive_enum agent_mode;

    function new(string name = "axi_s_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // uvm_config_db #(uvm_active_passive_enum) :: get(this, "*", "agent_mode", agent_mode);
        sequencer = axi_s_sequencer::type_id::create("sequencer", this);
        driver    = axi_s_driver::type_id::create("driver", this);
        monitor = axi_s_monitor::type_id::create("monitor", this);
        `uvm_info(get_name(), "Build phase completed for Slave Axi Agent", UVM_LOW)
    endfunction

    virtual function void connect_phase (uvm_phase phase);
            driver.seq_item_port.connect(sequencer.aw_sequencer.seq_item_export);
            driver.seq_item_port0.connect(sequencer.w_sequencer.seq_item_export);
            driver.seq_item_port1.connect(sequencer.b_sequencer.seq_item_export);
            driver.seq_item_port2.connect(sequencer.ar_sequencer.seq_item_export);
            driver.seq_item_port3.connect(sequencer.r_sequencer.seq_item_export);
    endfunction
endclass