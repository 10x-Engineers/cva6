interface comb_tlb_if(input logic clk_i);

 logic                   rst_ni;
 logic                   flush_tlb_i;
 logic                   itlb_lu_access_i;
 logic                   dtlb_lu_access_i;
 logic [ASID_WIDTH-1:0]  asid_i;

 logic                   itlb_lu_hit_o;
 logic                   dtlb_lu_hit_o;


 logic [riscv::VLEN-1:0] itlb_vaddr_i;
 logic [riscv::VLEN-1:0] dtlb_vaddr_i;


 tlb_update_sv32_t       itlb_update_io;
 tlb_update_sv32_t       dtlb_update_io;
 

task clk_pos(input int count);
    repeat (count) @(posedge clk_i);
endtask

// clocking drv_cb @(posedge clk_i) ;

//     default input #1ns output #1ns;

//     output flush_tlb_i;
//     output itlb_lu_access_i;
//     output dtlb_lu_access_i;
//     output asid_i;
//     output itlb_vaddr_i;
//     output dtlb_vaddr_i;

// endclocking

// clocking mon_cb @(posedge clk_i) ;

//     default input #1ns output #1ns;

//     input flush_tlb_i;
//     input itlb_lu_access_i;
//     input dtlb_lu_access_i;
//     input asid_i;
//     input itlb_vaddr_i;
//     input dtlb_vaddr_i;
//     input itlb_lu_hit_o;
//     input dtlb_lu_hit_o;
//     input itlb_update_io;
//     input dtlb_update_io; 

// endclocking

// clocking drv_cb_tlb @(posedge clk_i) ;

//     default input #1ns output #1ns;

//     input itlb_lu_hit_o;
//     input dtlb_lu_hit_o;
    
//     output itlb_update_io;
//     output dtlb_update_io;
       
// endclocking

// clocking drv_cb_shtlb @(posedge clk_i) ;

//     default input #1ns output #1ns;

//     output itlb_lu_hit_o;
//     output dtlb_lu_hit_o;
    
//     input itlb_update_io;
//     input dtlb_update_io;
       
// endclocking

// modport DRIV_tlb (clocking drv_cb, clocking drv_cb_tlb, input clk_i, output rst_ni);
// modport DRIV_shtlb (clocking drv_cb_shtlb, input clk_i, output rst_ni);
// modport MON (clocking mon_cb,input clk_i, input rst_ni);

endinterface