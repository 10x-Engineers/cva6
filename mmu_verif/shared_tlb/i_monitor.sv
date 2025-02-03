class i_monitor extends uvm_monitor;

    `uvm_component_utils(i_monitor);
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

            sq.itlb_miss_o = mmu_vif.MON.mon_cb.itlb_miss_o;
            sq.dtlb_miss_o = mmu_vif.MON.mon_cb.dtlb_miss_o;

            if(~sq.itlb_miss_o || ~sq.dtlb_miss_o)
                ap.write(sq);

        end 
    
  endtask
   
endclass