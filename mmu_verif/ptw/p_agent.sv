class p_agent extends uvm_agent;

    `uvm_component_utils(p_agent)

    p_monitor mon;

    function new(string name = "p_agent", uvm_component parent = null);
            super.new(name,parent);   
     endfunction

     virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = p_monitor::type_id::create("mon", this);
     endfunction

endclass
