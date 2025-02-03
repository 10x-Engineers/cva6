`define DRV_IF tlb_vif.DRIV.drv_cb
class driver extends uvm_driver #(seq_item) ;

    `uvm_component_utils(driver);

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
        `DRV_IF.flush_i                 <=  0;
        `DRV_IF.shared_tlb_access_i     <=  0;
        `DRV_IF.shared_tlb_hit_i        <=  0;
        `DRV_IF.shared_tlb_vaddr_i      <=  0;
        `DRV_IF.asid_i                  <=  0;
        `DRV_IF.itlb_req_i              <=  0;
        `DRV_IF.satp_ppn_i              <=  0;
        `DRV_IF.req_port_i              <=  0;
        `DRV_IF.lsu_is_store_i          <=  0;
        `DRV_IF.mxr_i                   <=  0;
        `DRV_IF.pmpcfg_i                <=  0;
        `DRV_IF.pmpaddr_i               <=  0;

        tlb_vif.clk_pos(1);

    end

      
else begin
    `DRV_IF.flush_i                 <= sq.flush_i;
    `DRV_IF.shared_tlb_access_i     <= sq.shared_tlb_access_i;
    `DRV_IF.shared_tlb_hit_i        <= sq.shared_tlb_hit_i;
    `DRV_IF.shared_tlb_vaddr_i      <= sq.shared_tlb_vaddr_i;
    `DRV_IF.asid_i                  <= sq.asid_i;
    `DRV_IF.itlb_req_i              <= sq.itlb_req_i;
    `DRV_IF.satp_ppn_i              <= sq.satp_ppn_i;

    tlb_vif.clk_pos(1);
    
    `DRV_IF.req_port_i              <= sq.req_port_i;
     if (sq.req_port_i.data_gnt && sq.req_port_i.data_rvalid) begin
        tlb_vif.clk_pos(1);
        `DRV_IF.lsu_is_store_i          <= sq.lsu_is_store_i;
        `DRV_IF.mxr_i                   <= sq.mxr_i;
        `DRV_IF.pmpcfg_i                <= sq.pmpcfg_i;
        `DRV_IF.pmpaddr_i               <= sq.pmpaddr_i;
     end 

    tlb_vif.clk_pos(1);
end

  endtask   

endclass
