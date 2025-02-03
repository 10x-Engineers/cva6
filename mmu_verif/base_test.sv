class base_test extends uvm_test;

    `uvm_component_utils(base_test);
    
    virtual mmu_if mmu_vif;
    env env_h;
    scoreboard scb;
    coverage cov;
    ptw_hit_seq p_h_seq;
    all_miss_seq a_m_seq;
    ptw_flush_seq p_f_seq;
    sh_tlb_flush_seq sh_tlb_f_seq;
    tlb_flush_seq tlb_f_seq;
    all_flush_seq a_f_seq;
    priority_seq p_seq;
    dis_trans_seq d_t_seq;
    tlb_update_seq t_u_seq;
    sh_tlb_upd_seq sh_tlb_u_seq;
    ptw_fsm_seq p_fsm_seq;
    rand_seq r_seq;
    sh_tlb_full_seq sh_tlb_ful_seq;

    sequence_h seq_h;

    function new(string name, uvm_component parent);
          super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db #(virtual mmu_if ):: get(null, "*", "mmu_vif", mmu_vif))
            `uvm_fatal("base_test", "base_test::Failed to get mmu_vif")
            
      seq_h = sequence_h:: type_id::create("seq_h",this);
      env_h = env:: type_id::create("env_h",this);
      scb = scoreboard:: type_id::create("scb",this);
      cov = coverage:: type_id::create("cov",this);
      p_h_seq = ptw_hit_seq:: type_id::create("p_h_seq", this);
      a_m_seq = all_miss_seq:: type_id::create("a_m_seq", this);
      p_f_seq = ptw_flush_seq:: type_id::create("p_f_seq",this);
      sh_tlb_f_seq = sh_tlb_flush_seq:: type_id::create("sh_tlb_f_seq",this);
      tlb_f_seq = tlb_flush_seq:: type_id::create("tlb_f_seq",this);
      a_f_seq = all_flush_seq:: type_id::create("a_f_seq",this);
      p_seq = priority_seq:: type_id::create("p_seq", this);
      d_t_seq = dis_trans_seq:: type_id::create("d_t_seq",this);
      t_u_seq = tlb_update_seq:: type_id::create("t_u_seq",this);
      sh_tlb_u_seq = sh_tlb_upd_seq:: type_id::create("sh_tlb_u_seq",this);
      p_fsm_seq = ptw_fsm_seq:: type_id::create("p_fsm_seq",this);
      r_seq = rand_seq:: type_id::create("r_seq", this);
      sh_tlb_ful_seq = sh_tlb_full_seq:: type_id::create("sh_tlb_ful_seq",this);

    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      uvm_top.print_topology();
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      env_h.agent_h.mon.ap.connect(scb.tlb_ms);
      env_h.i_agent_h.mon.ap.connect(scb.sh_ms);
      env_h.p_agent_h.mon.ap.connect(scb.ptw_ms);
      cov.mmu_vif = mmu_vif;
    endfunction

 endclass

class hits_test extends base_test;

  `uvm_component_utils(hits_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = p_h_seq.mem;
    fork 
      begin
        p_h_seq.start(env_h.agent_h.sqr);
      end
      forever
        cov.sample_1();
    join_any
    
    phase.drop_objection(this);
   
  endtask
endclass

class all_miss_test extends base_test;

  `uvm_component_utils(all_miss_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = a_m_seq.mem;
    fork 
      begin
        a_m_seq.start(env_h.agent_h.sqr);
        mmu_vif.clk_pos(3); 
      end
      forever
        cov.sample_1();
    join_any
    
    phase.drop_objection(this);
   
  endtask

endclass

class ptw_flush_test extends base_test;

  `uvm_component_utils(ptw_flush_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = p_h_seq.mem;
    fork 
      begin
        p_h_seq.start(env_h.agent_h.sqr);
        p_f_seq.start(env_h.agent_h.sqr);
      end
      begin
      wait(mmu_vif.flush_i)
      #50;
        forever
          cov.sample_1();
      end
    join_any
    
    phase.drop_objection(this);
   
  endtask

endclass

class sh_tlb_flush_test extends base_test;

  `uvm_component_utils(sh_tlb_flush_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = p_h_seq.mem;
    fork 
      begin
        p_h_seq.start(env_h.agent_h.sqr);
        sh_tlb_f_seq.start(env_h.agent_h.sqr);
      end
      begin
      wait(mmu_vif.flush_tlb_i)
      #50;
        forever
          cov.sample_1();
      end
    join_any
    
    phase.drop_objection(this);
   
  endtask

endclass

class all_flush_test extends base_test;

  `uvm_component_utils(all_flush_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = p_h_seq.mem;
    fork 
      begin
        p_h_seq.start(env_h.agent_h.sqr);
        a_f_seq.start(env_h.agent_h.sqr);
      end
      begin
      wait(mmu_vif.flush_tlb_i)
      #50;
        forever
          cov.sample_1();
      end
    join_any
    
    phase.drop_objection(this);
   
  endtask

endclass

class tlb_flush_test extends base_test;

  `uvm_component_utils(tlb_flush_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = tlb_f_seq.mem;
    fork 
      begin
        tlb_f_seq.start(env_h.agent_h.sqr);
      end
      begin
      wait(mmu_vif.flush_tlb_i)
      #40;
        forever
          cov.sample_1();
      end
    join_any
    
    phase.drop_objection(this);
   
  endtask

endclass

class priority_test extends base_test;

  `uvm_component_utils(priority_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = p_seq.mem;
    fork 
      begin
        p_seq.start(env_h.agent_h.sqr);
      end
      begin
        forever
          cov.sample_1();
      end
    join_any
    
    phase.drop_objection(this);
   
  endtask

endclass

class dis_trans_test extends base_test;

  `uvm_component_utils(dis_trans_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = d_t_seq.mem;
    fork 
      begin
        d_t_seq.start(env_h.agent_h.sqr);
      end
      begin
        forever
          cov.sample_1();
      end
    join_any
    
    phase.drop_objection(this);
   
  endtask

endclass

class tlb_update_test extends base_test;

  `uvm_component_utils(tlb_update_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = p_h_seq.mem;

    p_h_seq.start(env_h.agent_h.sqr);
    t_u_seq.start(env_h.agent_h.sqr);
    
    phase.drop_objection(this);
   
  endtask

endclass

class sh_tlb_upd_test extends base_test;

  `uvm_component_utils(sh_tlb_upd_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = p_h_seq.mem;

        p_h_seq.start(env_h.agent_h.sqr);
        p_f_seq.start(env_h.agent_h.sqr);
        sh_tlb_u_seq.start(env_h.agent_h.sqr);

    phase.drop_objection(this);
   
  endtask

endclass

class ptw_fsm_test extends base_test;

  `uvm_component_utils(ptw_fsm_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = p_fsm_seq.mem;
    fork 
       p_fsm_seq.start(env_h.agent_h.sqr);
       forever
         cov.sample_fsm();
    join_any
    
    phase.drop_objection(this);
   
  endtask

endclass

class rand_test extends base_test;

  `uvm_component_utils(rand_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = r_seq.mem;
    fork 
       r_seq.start(env_h.agent_h.sqr);
       forever
         cov.sample_sig();
    join_any
    
    phase.drop_objection(this);
   
  endtask

endclass

class sh_tlb_full_test extends base_test;

  `uvm_component_utils(sh_tlb_full_test);

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction
  

  virtual task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    env_h.agent_h.drv.mem = sh_tlb_ful_seq.mem;
    fork 
       sh_tlb_ful_seq.start(env_h.agent_h.sqr);
       forever
         cov.sample_sig();
    join_any
    
    phase.drop_objection(this);
   
  endtask

endclass