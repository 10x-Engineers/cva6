class seq_item extends uvm_sequence_item;

 `uvm_object_utils(seq_item);  

    function new(string name = "seq_item");
        super.new(name);
    endfunction
    

    rand logic rst_ni;
    rand logic flush_i;
    rand tlb_update_sv32_t update_i;
    rand logic lu_access_i;
    rand logic [ASID_WIDTH-1:0] lu_asid_i;
    rand logic [riscv::VLEN-1:0] lu_vaddr_i;
    rand logic [ASID_WIDTH-1:0] asid_to_be_flushed_i;
    rand logic [riscv::VLEN-1:0] vaddr_to_be_flushed_i;
    riscv::pte_sv32_t lu_content_o;
    logic lu_is_4M_o;
    logic lu_hit_o;


endclass