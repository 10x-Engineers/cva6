class i_agent extends uvm_agent;

    `uvm_component_utils(i_agent)
    
    i_monitor mon;

    function new(string name = "i_agent", uvm_component parent = null);
            super.new(name,parent);   
     endfunction

     virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = i_monitor::type_id::create("mon", this);
     endfunction

endclass
