class i_env extends uvm_env;
    
    i_agent agent_h;

   `uvm_component_utils(i_env);
    
    function new(string name = "i_env", uvm_component parent = null);
        super.new(name , parent);
    endfunction:new

    virtual function void build_phase(uvm_phase phase);  
        super.build_phase(phase);
        agent_h = i_agent::type_id::create("agent_h",this);
    endfunction

endclass