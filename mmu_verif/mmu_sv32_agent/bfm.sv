interface mmu_if(input logic clk_i); // bfm

    logic rst_ni;
    logic flush_i;
    logic enable_translation_i;
    logic en_ld_st_translation_i;
   
    // IF interface
    icache_arsp_t icache_areq_i;
    icache_areq_t icache_areq_o;

    // LSU interface
    // this is a more minimalistic interface because the actual addressing logic is handled
    // in the LSU as we distinguish load and stores, what we do here is simple address translation
    exception_t misaligned_ex_i;
    logic lsu_req_i;
    logic [riscv::VLEN-1:0] lsu_vaddr_i;
    logic lsu_is_store_i;

    // if we need to walk the page table we can't grant in the same cycle
    // Cycle 0
    logic lsu_dtlb_hit_o;
    logic [riscv::PPNW-1:0] lsu_dtlb_ppn_o;

    // Cycle 1
    logic lsu_valid_o;
    logic [riscv::PLEN-1:0] lsu_paddr_o;
    exception_t lsu_exception_o;

    // General control signals
    riscv::priv_lvl_t priv_lvl_i;
    riscv::priv_lvl_t ld_st_priv_lvl_i;
    logic sum_i;
    logic mxr_i;

    // input logic flag_mprv_i,
    logic [riscv::PPNW-1:0] satp_ppn_i;
    logic  [ASID_WIDTH-1:0] asid_i;
    logic  [ASID_WIDTH-1:0] asid_to_be_flushed_i;
    logic [riscv::VLEN-1:0] vaddr_to_be_flushed_i;
    logic flush_tlb_i;

    // Performance counters
    logic itlb_miss_o;
    logic dtlb_miss_o;

    // PTW memory interface
    dcache_req_o_t req_port_i;
    dcache_req_i_t req_port_o;

    // PMP
    riscv::pmpcfg_t [15:0] pmpcfg_i;
    logic [15:0][riscv::PLEN-3:0] pmpaddr_i;



task clk_pos(input int count);
    repeat (count) @(posedge clk_i);
endtask

clocking mon_cb @(posedge clk_i) ;

    default input #1ns output #1ns;

    input flush_i;
    input enable_translation_i;
    input en_ld_st_translation_i;
    input icache_areq_i;
    input pmpcfg_i;
    input pmpaddr_i;
    input misaligned_ex_i;
    input lsu_req_i;
    input lsu_vaddr_i;
    input lsu_is_store_i;
    input priv_lvl_i;
    input ld_st_priv_lvl_i;
    input sum_i;
    input mxr_i;
    input satp_ppn_i;
    input asid_i;
    input asid_to_be_flushed_i;
    input vaddr_to_be_flushed_i;
    input flush_tlb_i;
    input req_port_i;

    input icache_areq_o;
    input lsu_dtlb_hit_o;
    input lsu_dtlb_ppn_o;
    input lsu_valid_o;
    input lsu_paddr_o;
    input lsu_exception_o;
    input itlb_miss_o;
    input dtlb_miss_o;
    input req_port_o;      

endclocking

modport MON (clocking mon_cb,input clk_i, input rst_ni);


task drive(seq_item sq, dcache_req_o_t data);

    rst_ni <= sq.rst_ni; 

    if(!sq.rst_ni) begin

        flush_tlb_i <=0;
        asid_i <=0;
        icache_areq_i <=0;
        asid_to_be_flushed_i <=0;
        vaddr_to_be_flushed_i <=0;

        lsu_req_i <=0;
        lsu_vaddr_i <=0;

        enable_translation_i <=0;
        en_ld_st_translation_i <=0;

        flush_i                 <=  0;
        req_port_i              <=  0;
        satp_ppn_i              <=  0;  
        lsu_is_store_i          <=  0;
        mxr_i                   <=  0;
        pmpcfg_i                <=  0;
        pmpaddr_i               <=  0;
        priv_lvl_i              <=  0;
        ld_st_priv_lvl_i        <=  0;
        sum_i                   <=  0;
        misaligned_ex_i         <=  0;

        clk_pos(1);

    end

      
else begin

    flush_tlb_i <= sq.flush_tlb_i;
    asid_to_be_flushed_i <= sq.asid_to_be_flushed_i;
    vaddr_to_be_flushed_i <= sq.vaddr_to_be_flushed_i;
    icache_areq_i <= sq.icache_areq_i;
    asid_i <= sq.asid_i;

    lsu_req_i <= sq.lsu_req_i;
    lsu_vaddr_i <= sq.lsu_vaddr_i;

    enable_translation_i <= sq.enable_translation_i;
    en_ld_st_translation_i <= sq.en_ld_st_translation_i;

    flush_i                 <= sq.flush_i;
    satp_ppn_i              <= sq.satp_ppn_i;

    clk_pos(1);

    if(req_port_o.data_req) begin
        sq.req_port_i <= data;
        req_port_i    <= data;
    end
    else begin
        sq.req_port_i.data_gnt = 1'b0;
        sq.req_port_i.data_rvalid = 1'b0;
        sq.req_port_i.data_rdata = data.data_rdata;
        req_port_i.data_gnt = 1'b0;
        req_port_i.data_rvalid = 1'b0;
        req_port_i.data_rdata = data.data_rdata;
    end

    if (data.data_gnt && data.data_rvalid) begin

        clk_pos(1);


        lsu_is_store_i          <= sq.lsu_is_store_i;
        mxr_i                   <= sq.mxr_i;
        pmpcfg_i                <= sq.pmpcfg_i;
        pmpaddr_i               <= sq.pmpaddr_i;
        
        priv_lvl_i              <= sq.priv_lvl_i;
        ld_st_priv_lvl_i        <= sq.ld_st_priv_lvl_i;
        sum_i                   <= sq.sum_i;
        misaligned_ex_i         <= sq.misaligned_ex_i;

    end 

    clk_pos(1);


end  

endtask 

endinterface