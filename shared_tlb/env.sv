class env extends uvm_env;
    
    i_agent agent_h;
    //d_agent agent_d;     

   `uvm_component_utils(env);
    
    function new(string name = "env", uvm_component parent = null);
        super.new(name , parent);
    endfunction:new

    virtual function void build_phase(uvm_phase phase);  
        super.build_phase(phase);
        agent_h = i_agent::type_id::create("agent_h",this);
        //agent_d = d_agent::type_id::create("agent_d",this);
    endfunction

endclass