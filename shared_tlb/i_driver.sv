`define DRV_IF tlb_vif.DRIV.drv_cb
class i_driver extends uvm_driver #(seq_item) ;

    `uvm_component_utils(i_driver);

    virtual tlb_if tlb_vif;
    seq_item  sq;

    function new(string name , uvm_component parent);
        super.new(name,parent);
    endfunction:new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual tlb_if):: get(this,"*","tlb_vif",tlb_vif))begin
        		`uvm_fatal ("DRIVER","driver:Failed to get tlb_vif")
        end

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
    
    
    tlb_vif.DRIV.rst_ni <= sq.rst_ni; 

    if(!sq.rst_ni) begin
        `DRV_IF.flush_i <=0;
        `DRV_IF.enable_translation_i <=0;
        `DRV_IF.en_ld_st_translation_i <=0;
        `DRV_IF.asid_i<=0;
        `DRV_IF.itlb_access_i<=0;
        `DRV_IF.itlb_hit_i<=0;
        `DRV_IF.itlb_vaddr_i<=0;
        `DRV_IF.dtlb_access_i<=0;
        `DRV_IF.dtlb_hit_i<=0;
        `DRV_IF.dtlb_vaddr_i<=0;
        `DRV_IF.shared_tlb_update_i<=0;
        tlb_vif.clk_pos(1);

    end

      
else begin
    `DRV_IF.asid_i <= sq.asid_i;
    `DRV_IF.flush_i <= sq.flush_i; 
    `DRV_IF.enable_translation_i <= sq.enable_translation_i;
    `DRV_IF.itlb_hit_i <= sq.itlb_hit_i;
    `DRV_IF.itlb_vaddr_i <= sq.itlb_vaddr_i;
    `DRV_IF.itlb_access_i <= sq.itlb_access_i;
    `DRV_IF.en_ld_st_translation_i <= sq.en_ld_st_translation_i;
    `DRV_IF.dtlb_hit_i <= sq.dtlb_hit_i;
    `DRV_IF.dtlb_vaddr_i <= sq.dtlb_vaddr_i;
    `DRV_IF.dtlb_access_i <= sq.dtlb_access_i;

    tlb_vif.clk_pos(1);

    `DRV_IF.shared_tlb_update_i <= sq.shared_tlb_update_i;

    tlb_vif.clk_pos(1);

    end


  endtask   

endclass
