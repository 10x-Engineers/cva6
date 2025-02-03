interface tlb_if(input logic clk_i);

 logic [ASID_WIDTH-1:0] asid_to_be_flushed_i;
 logic [riscv::VLEN-1:0] vaddr_to_be_flushed_i;
 riscv::pte_sv32_t lu_content_itlb_o;
 logic lu_is_4M_itlb_o;
 riscv::pte_sv32_t lu_content_dtlb_o;
 logic lu_is_4M_dtlb_o;

clocking drv_cb @(posedge clk_i) ;

    default input #1ns output #1ns;

    output asid_to_be_flushed_i;
    output vaddr_to_be_flushed_i;
    input lu_content_itlb_o;
    input lu_is_4M_itlb_o;
    input lu_content_dtlb_o;
    input lu_is_4M_dtlb_o;

endclocking

clocking mon_cb @(posedge clk_i) ;

    default input #1ns output #1ns;

    input asid_to_be_flushed_i;
    input vaddr_to_be_flushed_i;
    input lu_content_itlb_o;
    input lu_is_4M_itlb_o;
    input lu_content_dtlb_o;
    input lu_is_4M_dtlb_o;

endclocking

endinterface