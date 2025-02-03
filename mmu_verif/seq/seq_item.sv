class seq_item extends uvm_sequence_item;

 `uvm_object_utils(seq_item);  

    function new(string name = "seq_item");
        super.new(name);
    endfunction
    

    rand logic rst_ni;
    rand logic flush_i;
    rand logic enable_translation_i;
    rand logic en_ld_st_translation_i;
   
    // IF interface
    rand icache_arsp_t icache_areq_i;
    icache_areq_t icache_areq_o;

    // LSU interface
    // this is a more minimalistic interface because the actual addressing logic is handled
    // in the LSU as we distinguish load and stores, what we do here is simple address translation
    rand exception_t misaligned_ex_i;
    rand logic lsu_req_i;
    rand logic [riscv::VLEN-1:0] lsu_vaddr_i;
    rand logic lsu_is_store_i;

    // if we need to walk the page table we can't grant in the same cycle
    // Cycle 0
    logic lsu_dtlb_hit_o;
    logic [riscv::PPNW-1:0] lsu_dtlb_ppn_o;

    // Cycle 1
    logic lsu_valid_o;
    logic [riscv::PLEN-1:0] lsu_paddr_o;
    exception_t lsu_exception_o;

    // General control signals
    rand riscv::priv_lvl_t priv_lvl_i;
    rand riscv::priv_lvl_t ld_st_priv_lvl_i;
    rand logic sum_i;
    rand logic mxr_i;

    // input logic flag_mprv_i,
    rand logic [riscv::PPNW-1:0] satp_ppn_i;
    rand logic [ASID_WIDTH-1:0] asid_i;
    rand logic [ASID_WIDTH-1:0] asid_to_be_flushed_i;
    rand logic [riscv::VLEN-1:0] vaddr_to_be_flushed_i;
    rand logic flush_tlb_i;

    // Performance counters
    logic itlb_miss_o;
    logic dtlb_miss_o;

    // PTW memory interface
    rand dcache_req_o_t req_port_i;
    dcache_req_i_t req_port_o;

    // PMP
    rand riscv::pmpcfg_t [15:0] pmpcfg_i;
    rand logic [15:0][riscv::PLEN-3:0] pmpaddr_i;


endclass