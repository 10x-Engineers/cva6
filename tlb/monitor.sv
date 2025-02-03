`define MON_IF tlb_vif.MON.mon_cb
class monitor extends uvm_monitor;

    `uvm_component_utils(monitor);
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
        sq.lu_content_o = `MON_IF.lu_content_o;
        sq.lu_is_4M_o   = `MON_IF.lu_is_4M_o;
        sq.lu_hit_o     = `MON_IF.lu_hit_o;
        ap.write(sq);
                
        end 
    
  endtask

endclass