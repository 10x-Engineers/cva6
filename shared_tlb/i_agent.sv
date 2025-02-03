class i_agent extends uvm_agent;

    `uvm_component_utils(i_agent)
    
    i_sequencer sqr;
    i_driver drv;
    i_monitor mon;

    function new(string name = "i_agent", uvm_component parent = null);
            super.new(name,parent);   
     endfunction

     virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = i_sequencer::type_id::create("sqr",this);
        drv = i_driver::type_id:: create("drv",this);
        mon = i_monitor::type_id::create("mon", this);
     endfunction

    virtual function void connect_phase(uvm_phase phase);  
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass
