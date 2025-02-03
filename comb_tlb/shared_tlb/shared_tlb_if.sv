interface shared_tlb_if(input logic clk_i);

 logic                   enable_translation_i;
 logic                   en_ld_st_translation_i;

 logic                   itlb_miss_o;
 logic                   dtlb_miss_o;

 logic                   shared_tlb_access_o;
 logic                   shared_tlb_hit_o;
 logic [riscv::VLEN-1:0] shared_tlb_vaddr_o;

 logic                   itlb_req_o;

 tlb_update_sv32_t       shared_tlb_update_i;

clocking drv_cb @(posedge clk_i) ;

    default input #1ns output #1ns;
 
    output enable_translation_i;   
    output en_ld_st_translation_i; 
    output shared_tlb_update_i; 
    input itlb_miss_o;
    input dtlb_miss_o;
    input shared_tlb_access_o;
    input shared_tlb_hit_o;
    input shared_tlb_vaddr_o;
    input itlb_req_o;    

endclocking

clocking mon_cb @(posedge clk_i) ;

    default input #1ns output #1ns;

    input enable_translation_i;   
    input en_ld_st_translation_i; 
    input shared_tlb_update_i; 
    input itlb_miss_o;
    input dtlb_miss_o;
    input shared_tlb_access_o;
    input shared_tlb_hit_o;
    input shared_tlb_vaddr_o;
    input itlb_req_o;      

endclocking

endinterface