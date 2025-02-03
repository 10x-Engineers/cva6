class env extends uvm_env;
    
    agent agent_h;
         
   `uvm_component_utils(env);
    
    function new(string name = "env", uvm_component parent = null);
        super.new(name , parent);
    endfunction:new

    virtual function void build_phase(uvm_phase phase);  
        super.build_phase(phase);
        agent_h = agent::type_id::create("agent_h",this);
    endfunction

endclass