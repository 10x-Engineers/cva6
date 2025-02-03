class monitor extends uvm_monitor;

    `uvm_component_utils(monitor);
     virtual tlb_if tlb_vif;
     virtual comb_tlb_if comb_tlb_vif;

     uvm_analysis_port #(seq_item) ap;
     seq_item sq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
  
        if (!uvm_config_db #(virtual tlb_if)::get(null, "*", "tlb_vif", tlb_vif))
            `uvm_fatal("Monitor", "monitor::failed to get tlb_vif");
        if(!uvm_config_db #(virtual comb_tlb_if ):: get(null, "*", "comb_tlb_vif", comb_tlb_vif))
            `uvm_fatal("base_test", "base_test::Failed to get comb_tlb_vif")
            
        ap = new("ap", this);
    
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
        sq = seq_item::type_id::create("sq");
        
        comb_tlb_vif.clk_pos(1);

        sq.lu_content_itlb_o = tlb_vif.mon_cb.lu_content_itlb_o;
        sq.lu_is_4M_itlb_o   = tlb_vif.mon_cb.lu_is_4M_itlb_o;
        sq.lu_content_dtlb_o = tlb_vif.mon_cb.lu_content_dtlb_o;
        sq.lu_is_4M_dtlb_o   = tlb_vif.mon_cb.lu_is_4M_dtlb_o;
        sq.itlb_lu_hit_o     = comb_tlb_vif.itlb_lu_hit_o;
        sq.dtlb_lu_hit_o     = comb_tlb_vif.dtlb_lu_hit_o;

        ap.write(sq);
                
        end 
    
  endtask

endclass