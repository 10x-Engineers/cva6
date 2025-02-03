class i_driver extends uvm_driver #(seq_item) ;

    `uvm_component_utils(i_driver);

    virtual shared_tlb_if shared_tlb_vif;
    virtual comb_tlb_if comb_tlb_vif;

    seq_item  sq;

    function new(string name , uvm_component parent);
        super.new(name,parent);
    endfunction:new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual shared_tlb_if):: get(this,"*","shared_tlb_vif",shared_tlb_vif))begin
        	`uvm_fatal ("DRIVER","driver:Failed to get shared_tlb_vif")
        end
        if(!uvm_config_db #(virtual comb_tlb_if ):: get(null, "*", "comb_tlb_vif", comb_tlb_vif))
            `uvm_fatal("base_test", "base_test::Failed to get comb_tlb_vif")
            

    endfunction
         
virtual task run_phase (uvm_phase phase);

    forever 
        begin
            sq = seq_item::type_id::create("sq");
            seq_item_port.get_next_item(sq);
            drive();
            seq_item_port.item_done();
        end
        
endtask

task drive();

    if(!sq.rst_ni) begin

        shared_tlb_vif.drv_cb.enable_translation_i <=0;
        shared_tlb_vif.drv_cb.en_ld_st_translation_i <= 0;
        comb_tlb_vif.itlb_lu_hit_o <= 0;
        comb_tlb_vif.dtlb_lu_hit_o <= 0;        
        comb_tlb_vif.clk_pos(1);

    end

    else begin

        comb_tlb_vif.itlb_lu_hit_o <= comb_tlb_vif.itlb_lu_hit_o;
        comb_tlb_vif.dtlb_lu_hit_o <= comb_tlb_vif.dtlb_lu_hit_o; 
        shared_tlb_vif.drv_cb.enable_translation_i <= sq.enable_translation_i;
        shared_tlb_vif.drv_cb.en_ld_st_translation_i <= sq.en_ld_st_translation_i;

        comb_tlb_vif.clk_pos(1);

        shared_tlb_vif.drv_cb.shared_tlb_update_i <= sq.shared_tlb_update_i;

        comb_tlb_vif.clk_pos(1);

    end

endtask   

endclass
