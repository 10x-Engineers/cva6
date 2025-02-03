`define MON_IF tlb_vif.MON.mon_cb
class i_monitor extends uvm_monitor;

    `uvm_component_utils(i_monitor);
     virtual tlb_if tlb_vif;
     uvm_analysis_port #(seq_item) ap;
     seq_item sq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
  
        if (!uvm_config_db #(virtual tlb_if)::get(null, "*", "tlb_vif", tlb_vif))
            `uvm_fatal("Monitor", "monitor::failed to get tlb_vif");
        ap = new("ap", this);
    
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
        sq = seq_item::type_id::create("sq");
        
        tlb_vif.clk_pos(1);
        
        sq.itlb_req_o = `MON_IF.itlb_req_o;
        sq.itlb_update_o = `MON_IF.itlb_update_o;
        sq.itlb_miss_o = `MON_IF.itlb_miss_o;
        sq.dtlb_update_o = `MON_IF.dtlb_update_o;
        sq.dtlb_miss_o = `MON_IF.dtlb_miss_o;
        sq.shared_tlb_access_o = `MON_IF.shared_tlb_access_o;
        sq.shared_tlb_hit_o = `MON_IF.shared_tlb_hit_o;
        sq.shared_tlb_vaddr_o = `MON_IF.shared_tlb_vaddr_o;

        ap.write(sq);
                
        end 
    
  endtask

endclass