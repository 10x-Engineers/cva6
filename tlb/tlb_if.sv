interface tlb_if(input logic clk_i);

//input logic clk_i;  // Clock
 logic rst_ni;  // Asynchronous reset active low
 logic flush_i;  // Flush signal
// Update TLB
 tlb_update_sv32_t update_i;
// Lookup signals
 logic lu_access_i;
 logic [ASID_WIDTH-1:0] lu_asid_i;
 logic [riscv::VLEN-1:0] lu_vaddr_i;
 logic [ASID_WIDTH-1:0] asid_to_be_flushed_i;
 logic [riscv::VLEN-1:0] vaddr_to_be_flushed_i;
 riscv::pte_sv32_t lu_content_o;
 logic lu_is_4M_o;
 logic lu_hit_o;

task clk_pos(input int count);
    repeat (count) @(posedge clk_i);
endtask

clocking drv_cb @(posedge clk_i) ;

    default input #1ns output #1ns;

    output flush_i;
    output update_i;
    output lu_access_i;
    output lu_asid_i;
    output lu_vaddr_i;
    output asid_to_be_flushed_i;
    output vaddr_to_be_flushed_i;
    input lu_content_o;
    input lu_is_4M_o;
    input lu_hit_o;        

endclocking

clocking mon_cb @(posedge clk_i) ;

    default input #1ns output #1ns;

    input flush_i;
    input update_i;
    input lu_access_i;
    input lu_asid_i;
    input  lu_vaddr_i;
    input asid_to_be_flushed_i;
    input  vaddr_to_be_flushed_i;
    input lu_content_o;
    input lu_is_4M_o;
    input lu_hit_o;        

endclocking

modport DRIV (clocking drv_cb,input clk_i, output rst_ni);
modport MON (clocking mon_cb,input clk_i, input rst_ni);


endinterface