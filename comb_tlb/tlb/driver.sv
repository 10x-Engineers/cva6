//`define DRV_IF tlb_vif.drv_cb
class driver extends uvm_driver #(seq_item) ;

    `uvm_component_utils(driver);

    virtual tlb_if tlb_vif;
    virtual comb_tlb_if comb_tlb_vif;

    seq_item  sq;

    function new(string name , uvm_component parent);
        super.new(name,parent);
    endfunction:new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual tlb_if):: get(this,"*","tlb_vif",tlb_vif))begin
        	`uvm_fatal ("DRIVER","driver:Failed to get tlb_vif")
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

    comb_tlb_vif.rst_ni <= sq.rst_ni; 

    if(!sq.rst_ni) begin

        comb_tlb_vif.flush_tlb_i <=0;
        comb_tlb_vif.asid_i <= 0;
        tlb_vif.drv_cb.asid_to_be_flushed_i <= 0;
        tlb_vif.drv_cb.vaddr_to_be_flushed_i <= 0;
        comb_tlb_vif.itlb_lu_access_i <= 0;
        comb_tlb_vif.dtlb_lu_access_i <= 0;   
        comb_tlb_vif.itlb_vaddr_i <= 0;
        comb_tlb_vif.dtlb_vaddr_i <= 0;
        comb_tlb_vif.itlb_update_io <= 0;
        comb_tlb_vif.dtlb_update_io <= 0;
        
        comb_tlb_vif.clk_pos(1);

    end

      
else begin
    
    comb_tlb_vif.flush_tlb_i <= sq.flush_tlb_i;
    comb_tlb_vif.asid_i <= sq.asid_i;
    tlb_vif.drv_cb.asid_to_be_flushed_i <= sq.asid_to_be_flushed_i;
    tlb_vif.drv_cb.vaddr_to_be_flushed_i <= sq.vaddr_to_be_flushed_i;


    comb_tlb_vif.itlb_lu_access_i <= sq.itlb_lu_access_i;
    comb_tlb_vif.dtlb_lu_access_i <= sq.dtlb_lu_access_i;   
    comb_tlb_vif.itlb_vaddr_i <= sq.itlb_vaddr_i;
    comb_tlb_vif.dtlb_vaddr_i <= sq.dtlb_vaddr_i;

    comb_tlb_vif.clk_pos(1);

    comb_tlb_vif.itlb_update_io <= comb_tlb_vif.itlb_update_io;
    comb_tlb_vif.dtlb_update_io <= comb_tlb_vif.dtlb_update_io;
    
    comb_tlb_vif.clk_pos(1);

end

endtask   

endclass
