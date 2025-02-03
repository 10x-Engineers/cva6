interface tlb_if(input logic clk_i);

//input logic clk_i;  // Clock
 logic rst_ni;  // Asynchronous reset active low
 logic flush_i;  // Flush signal
 
 logic ptw_active_o;
 logic walking_instr_o;        // set when walking for TLB
 logic ptw_error_o;            // set when an error occurred
 logic ptw_access_exception_o; // set when an PMP access exception occured

 logic          lsu_is_store_i;  // this translation was triggered by a store
    // PTW memory interface
 dcache_req_o_t req_port_i;
 dcache_req_i_t req_port_o;

    // to Shared TLB, update logic
 tlb_update_sv32_t shared_tlb_update_o;

 logic [riscv::VLEN-1:0] update_vaddr_o;

 logic [ASID_WIDTH-1:0] asid_i;

    // from shared TLB
 logic                   shared_tlb_access_i;
 logic                   shared_tlb_hit_i;
 logic [riscv::VLEN-1:0] shared_tlb_vaddr_i;

 logic itlb_req_i;

    // from CSR file
 logic [riscv::PPNW-1:0] satp_ppn_i;  // ppn from satp
 logic                   mxr_i;

    // Performance counters
 logic shared_tlb_miss_o;

    // PMP
 riscv::pmpcfg_t [15:0] pmpcfg_i;
 logic [15:0][riscv::PLEN-3:0] pmpaddr_i;
 logic [riscv::PLEN-1:0] bad_paddr_o;

task clk_pos(input int count);
    repeat (count) @(posedge clk_i);
endtask

clocking drv_cb @(posedge clk_i) ;

    default input #1ns output #1ns;

    output  flush_i;
    output  lsu_is_store_i;
    output  req_port_i;
    output  asid_i;
    output  shared_tlb_access_i;
    output  shared_tlb_hit_i;
    output  shared_tlb_vaddr_i;
    output  itlb_req_i;
    output  satp_ppn_i;
    output  mxr_i;
    output  pmpcfg_i;
    output  pmpaddr_i;

    input bad_paddr_o;
    input ptw_active_o;
    input walking_instr_o;
    input ptw_error_o;
    input ptw_access_exception_o;
    input req_port_o;
    input shared_tlb_update_o;
    input update_vaddr_o;
    input shared_tlb_miss_o;
endclocking

clocking mon_cb @(posedge clk_i) ;

    default input #1ns output #1ns;

    input  flush_i;
    input  lsu_is_store_i;
    input  req_port_i;
    input  asid_i;
    input  shared_tlb_access_i;
    input  shared_tlb_hit_i;
    input  shared_tlb_vaddr_i;
    input  itlb_req_i;
    input  satp_ppn_i;
    input  mxr_i;
    input  pmpcfg_i;
    input  pmpaddr_i;
    
    input bad_paddr_o;
    input ptw_active_o;
    input walking_instr_o;
    input ptw_error_o;
    input ptw_access_exception_o;
    input req_port_o;
    input shared_tlb_update_o;
    input update_vaddr_o;
    input shared_tlb_miss_o;   

endclocking

modport DRIV (clocking drv_cb,input clk_i, output rst_ni);
modport MON (clocking mon_cb,input clk_i, input rst_ni);

endinterface