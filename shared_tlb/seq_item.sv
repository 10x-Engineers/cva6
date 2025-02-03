class seq_item extends uvm_sequence_item;

 `uvm_object_utils(seq_item);  

    function new(string name = "seq_item");
        super.new(name);
    endfunction
    

    rand logic                   rst_ni; 
    rand logic              flush_i;
    
    rand logic [ASID_WIDTH-1:0]  asid_i;
    rand tlb_update_sv32_t       shared_tlb_update_i;

    rand logic                   enable_translation_i;
    rand logic                   itlb_access_i;
    rand logic                   itlb_hit_i;
    rand logic [riscv::VLEN-1:0] itlb_vaddr_i;

    rand logic                   en_ld_st_translation_i;
    rand logic                   dtlb_access_i;
    rand logic                   dtlb_hit_i;
    rand logic [riscv::VLEN-1:0] dtlb_vaddr_i;

    tlb_update_sv32_t       itlb_update_o;
    logic                   itlb_miss_o;
    logic                   itlb_req_o;

    tlb_update_sv32_t       dtlb_update_o;
    logic                   dtlb_miss_o;

    logic                   shared_tlb_access_o;
    logic                   shared_tlb_hit_o;
    logic [riscv::VLEN-1:0] shared_tlb_vaddr_o;

endclass