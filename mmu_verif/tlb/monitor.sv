class monitor extends uvm_monitor;

    `uvm_component_utils(monitor);
     virtual mmu_if mmu_vif;
     uvm_analysis_port #(seq_item) ap;
     seq_item sq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
  
        if (!uvm_config_db #(virtual mmu_if)::get(null, "*", "mmu_vif", mmu_vif))
            `uvm_fatal("Monitor", "monitor::failed to get mmu_vif");
        ap = new("ap", this);
    
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
        sq = seq_item::type_id::create("sq");
        
        mmu_vif.clk_pos(1);
        
        sq.lsu_dtlb_hit_o = mmu_vif.MON.mon_cb.lsu_dtlb_hit_o;
        
        mmu_vif.clk_pos(1);

        sq.icache_areq_o = mmu_vif.MON.mon_cb.icache_areq_o;

        sq.lsu_dtlb_ppn_o = mmu_vif.MON.mon_cb.lsu_dtlb_ppn_o;  
        sq.lsu_paddr_o = mmu_vif.MON.mon_cb.lsu_paddr_o;


        ap.write(sq);

                
        end 
    
  endtask

endclass