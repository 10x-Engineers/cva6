class driver extends uvm_driver #(seq_item) ;

    `uvm_component_utils(driver);

    virtual mmu_if mmu_vif;
    seq_item  sq;
    seq_item fifo_item;
    mem_model mem;
    dcache_req_o_t data;
    logic [riscv::PLEN-1:0] addr;
    uvm_analysis_port #(seq_item) ap;


    function new(string name , uvm_component parent);
        super.new(name,parent);
        mem = new();
    endfunction:new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual mmu_if):: get(this,"*","mmu_vif",mmu_vif))begin
        		`uvm_fatal ("DRIVER","driver:Failed to get mmu_vif")
        end
        ap = new("ap",this);
    endfunction
         
virtual task run_phase (uvm_phase phase);

    forever 
        begin
            sq = seq_item::type_id::create("sq");
            seq_item_port.get_next_item(sq);
            if (sq.lsu_req_i && mmu_vif.rst_ni) begin
                addr = {sq.satp_ppn_i, sq.lsu_vaddr_i[riscv::SV-1:22], 2'b0};
                data = mem.read(addr);
            end
            else if (sq.icache_areq_i.fetch_req && mmu_vif.rst_ni)begin
                addr = {sq.satp_ppn_i, sq.icache_areq_i.fetch_vaddr[riscv::SV-1:22], 2'b0};
                data = mem.read(addr);
            end
            
            mmu_vif.drive(sq, data);
            seq_item_port.item_done();

        end
        
endtask  

endclass
