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
        sq.shared_tlb_miss_o      = `MON_IF.shared_tlb_miss_o;
        sq.walking_instr_o        = `MON_IF.walking_instr_o;
        sq.ptw_active_o           = `MON_IF.ptw_active_o;
        sq.update_vaddr_o         = `MON_IF.update_vaddr_o;
        
        tlb_vif.clk_pos(1);
        sq.req_port_o             = `MON_IF.req_port_o;

        if (tlb_vif.req_port_i.data_gnt && tlb_vif.req_port_i.data_rvalid) begin
            tlb_vif.clk_pos(1);
            sq.shared_tlb_update_o    = `MON_IF.shared_tlb_update_o;
            tlb_vif.clk_pos(1);
            sq.ptw_error_o            = `MON_IF.ptw_error_o;
            sq.ptw_access_exception_o = `MON_IF.ptw_access_exception_o;
            sq.bad_paddr_o            = `MON_IF.bad_paddr_o;        
        end 
        
        ap.write(sq);
                
        end 
    
  endtask

endclass