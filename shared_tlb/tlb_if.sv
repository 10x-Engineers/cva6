interface tlb_if(input logic clk_i);

 logic                   rst_ni;  // Asynchronous reset active low
 logic                   flush_i;  // Flush signal
 logic                   enable_translation_i;   // CSRs indicate to enable SV32
 logic                   en_ld_st_translation_i; // enable virtual memory translation for load/stores

 logic [ASID_WIDTH-1:0] asid_i;

     // from TLBs
    // did we miss?
 logic                   itlb_access_i;
 logic                   itlb_hit_i;
 logic [riscv::VLEN-1:0] itlb_vaddr_i;

 logic                   dtlb_access_i;
 logic                   dtlb_hit_i;
 logic [riscv::VLEN-1:0] dtlb_vaddr_i;

    // to TLBs, update logic
 tlb_update_sv32_t       itlb_update_o;
 tlb_update_sv32_t       dtlb_update_o;

    // Performance counters
 logic                   itlb_miss_o;
 logic                   dtlb_miss_o;

 logic                   shared_tlb_access_o;
 logic                   shared_tlb_hit_o;
 logic [riscv::VLEN-1:0] shared_tlb_vaddr_o;

 logic                   itlb_req_o;

    // Update shared TLB in case of miss
 tlb_update_sv32_t       shared_tlb_update_i;


task clk_pos(input int count);
    repeat (count) @(posedge clk_i);
endtask

clocking drv_cb @(posedge clk_i) ;

    default input #1ns output #1ns;

    output flush_i;  
    output enable_translation_i;   
    output en_ld_st_translation_i; 
    output asid_i;
    output itlb_access_i;
    output itlb_hit_i;
    output itlb_vaddr_i;
    output dtlb_access_i;
    output dtlb_hit_i;
    output dtlb_vaddr_i;
    output shared_tlb_update_i; 
    input itlb_update_o;
    input dtlb_update_o;
    input itlb_miss_o;
    input dtlb_miss_o;
    input shared_tlb_access_o;
    input shared_tlb_hit_o;
    input shared_tlb_vaddr_o;
    input itlb_req_o;
       

endclocking

clocking mon_cb @(posedge clk_i) ;

    default input #1ns output #1ns;

    input flush_i;  
    input enable_translation_i;   
    input en_ld_st_translation_i; 
    input asid_i;
    input itlb_access_i;
    input itlb_hit_i;
    input itlb_vaddr_i;
    input dtlb_access_i;
    input dtlb_hit_i;
    input dtlb_vaddr_i;
    input shared_tlb_update_i; 
    input itlb_update_o;
    input dtlb_update_o;
    input itlb_miss_o;
    input dtlb_miss_o;
    input shared_tlb_access_o;
    input shared_tlb_hit_o;
    input shared_tlb_vaddr_o;
    input itlb_req_o;      

endclocking

modport DRIV (clocking drv_cb,input clk_i, output rst_ni);
modport MON (clocking mon_cb,input clk_i, input rst_ni);

endinterface