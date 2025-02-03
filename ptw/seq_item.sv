class seq_item extends uvm_sequence_item;

 `uvm_object_utils(seq_item);  

    function new(string name = "seq_item");
        super.new(name);
    endfunction
    

    rand logic                            rst_ni;
    rand logic                            flush_i;
    rand logic                            lsu_is_store_i;
    rand dcache_req_o_t                   req_port_i;
    rand logic [ASID_WIDTH-1:0]           asid_i;
    rand logic                            shared_tlb_access_i;
    rand logic                            shared_tlb_hit_i;
    rand logic [riscv::VLEN-1:0]          shared_tlb_vaddr_i;
    rand logic                            itlb_req_i;
    rand logic [riscv::PPNW-1:0]          satp_ppn_i;
    rand logic                            mxr_i;
    rand riscv::pmpcfg_t [15:0]           pmpcfg_i;
    rand logic [15:0][riscv::PLEN-3:0]    pmpaddr_i;
    
    logic [riscv::PLEN-1:0]          bad_paddr_o;
    logic                            ptw_active_o;
    logic                            walking_instr_o;
    logic                            ptw_error_o;
    logic                            ptw_access_exception_o;
    dcache_req_i_t                   req_port_o;
    tlb_update_sv32_t                shared_tlb_update_o;
    logic [riscv::VLEN-1:0]          update_vaddr_o;
    logic                            shared_tlb_miss_o;


endclass