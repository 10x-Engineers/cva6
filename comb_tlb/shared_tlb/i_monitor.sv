class i_monitor extends uvm_monitor;

    `uvm_component_utils(i_monitor);
     virtual shared_tlb_if shared_tlb_vif;
     virtual comb_tlb_if comb_tlb_vif;
     uvm_analysis_port #(seq_item) ap;
     seq_item sq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
  
        if (!uvm_config_db #(virtual shared_tlb_if)::get(null, "*", "shared_tlb_vif", shared_tlb_vif))
            `uvm_fatal("Monitor", "monitor::failed to get shared_tlb_vif");
        if(!uvm_config_db #(virtual comb_tlb_if ):: get(null, "*", "comb_tlb_vif", comb_tlb_vif))
            `uvm_fatal("base_test", "base_test::Failed to get comb_tlb_vif")
            
        ap = new("ap", this);
    
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
        sq = seq_item::type_id::create("sq");
        
        comb_tlb_vif.clk_pos(1);

        sq.itlb_req_o = shared_tlb_vif.mon_cb.itlb_req_o;
        sq.itlb_update_io = comb_tlb_vif.itlb_update_io;
        sq.itlb_miss_o = shared_tlb_vif.mon_cb.itlb_miss_o;
        sq.dtlb_update_io = comb_tlb_vif.dtlb_update_io;
        sq.dtlb_miss_o = shared_tlb_vif.mon_cb.dtlb_miss_o;
        sq.shared_tlb_access_o = shared_tlb_vif.mon_cb.shared_tlb_access_o;
        sq.shared_tlb_hit_o = shared_tlb_vif.mon_cb.shared_tlb_hit_o;
        sq.shared_tlb_vaddr_o = shared_tlb_vif.mon_cb.shared_tlb_vaddr_o;

        ap.write(sq);
                
        end 
    
  endtask

endclass