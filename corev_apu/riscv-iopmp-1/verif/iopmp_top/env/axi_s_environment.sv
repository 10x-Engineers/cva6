
`ifndef AXI_S_ENVIRONMENT
`define AXI_S_ENVIRONMENT

class axi_s_environment extends uvm_env;
    `uvm_component_utils(axi_s_environment)

    axi_s_agent    agent;

    function new(string name = "axi_s_environment", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = axi_s_agent::type_id::create("agent", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_name(), "CONNECT Phase of Env", UVM_LOW);
    endfunction
endclass

`endif