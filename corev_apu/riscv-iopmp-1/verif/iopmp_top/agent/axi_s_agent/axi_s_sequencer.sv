class axi_s_sequencer extends uvm_sequencer#(axi_s_seq_item);
    `uvm_component_utils(axi_s_sequencer)

    // Sequencer handles for all of the channels
    uvm_sequencer #(axi_s_seq_item) aw_sequencer;
    uvm_sequencer #(axi_s_seq_item) w_sequencer;
    uvm_sequencer #(axi_s_seq_item) b_sequencer;
    uvm_sequencer #(axi_s_seq_item) ar_sequencer;
    uvm_sequencer #(axi_s_seq_item) r_sequencer;

    virtual axi_s_interface vif;

    function new(string name = "axi_s_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_s_interface)::get(this, "", "axi_s_vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
        aw_sequencer = uvm_sequencer#(axi_s_seq_item)::type_id::create("aw_sequencer", this);
        w_sequencer  = uvm_sequencer#(axi_s_seq_item)::type_id::create("w_sequencer", this);
        b_sequencer  = uvm_sequencer#(axi_s_seq_item)::type_id::create("b_sequencer", this);
        ar_sequencer = uvm_sequencer#(axi_s_seq_item)::type_id::create("ar_sequencer", this);
        r_sequencer  = uvm_sequencer#(axi_s_seq_item)::type_id::create("r_sequencer", this);
    endfunction

endclass

