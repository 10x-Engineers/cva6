class base_test extends uvm_test;

    `uvm_component_utils(base_test);
    
    virtual tlb_if tlb_vif;
    env env_h;
    virtual shared_tlb_if shared_tlb_vif;
    virtual comb_tlb_if comb_tlb_vif;

    sequence_h seq_h;
    sequence_h i_seq_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db #(virtual tlb_if ):: get(null, "*", "tlb_vif", tlb_vif))
            `uvm_fatal("base_test", "base_test::Failed to get tlb_vif")

      if(!uvm_config_db #(virtual shared_tlb_if ):: get(null, "*", "shared_tlb_vif", shared_tlb_vif))
            `uvm_fatal("base_test", "base_test::Failed to get shared_tlb_vif")

      if(!uvm_config_db #(virtual comb_tlb_if ):: get(null, "*", "comb_tlb_vif", comb_tlb_vif))
            `uvm_fatal("base_test", "base_test::Failed to get comb_tlb_vif")
            
      seq_h = sequence_h:: type_id::create("seq_h",this);
      i_seq_h = sequence_h:: type_id::create("i_seq_h",this);
      env_h = env:: type_id::create("env_h",this);

    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      uvm_top.print_topology();
    endfunction

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    fork
    seq_h.start(env_h.agent_h.sqr);
    i_seq_h.start(env_h.i_agent_h.i_sqr);
    comb_tlb_vif.clk_pos(10);
    join
    phase.drop_objection(this);
   
  endtask

endclass