import uvm_pkg::*;
`include "uvm_macros.svh"

`include "config_pkg.sv"
import config_pkg::*;

`include "cv32a6_imac_sv32_config_pkg.sv"
import cva6_config_pkg::*;

`include "riscv_pkg.sv"
import riscv::*;

`include "ariane_pkg.sv"
import ariane_pkg::*;

`include "tlb_if.sv"
`include "seq_item.sv"
`include "sequence_h.sv"

`include "i_sequencer.sv"
`include "i_driver.sv"
`include "i_monitor.sv"
`include "i_agent.sv"

// `include "d_sequencer.sv"
// `include "d_driver.sv"
// `include "d_monitor.sv"
// `include "d_agent.sv"

`include "mem_model.sv"
`include "env.sv"
`include "base_test.sv"

`include "/mmu_sv32/cf_math_pkg.sv"
import cf_math_pkg::*;

`include "/mmu_sv32/sram.sv"
`include "/mmu_sv32/tc_sram.sv"
`include "/mmu_sv32/tc_sram_wrapper.sv"
`include "/mmu_sv32/lfsr.sv"
`include "/mmu_sv32/lzc.sv"
`include "/mmu_sv32/cva6_shared_tlb_sv32.sv"

module top;
  reg clk;
  tlb_if tlb_vif(clk);

  always #10 clk=~clk;
  initial begin
    clk =0;
    uvm_config_db #(virtual tlb_if)::set(null, "*", "tlb_vif", tlb_vif);    
    run_test("base_test");
  end

  cva6_shared_tlb_sv32 DUT (
    .clk_i                  (clk), 
    .rst_ni                 (tlb_vif.rst_ni), 
    .flush_i                (tlb_vif.flush_i),
    .enable_translation_i   (tlb_vif.enable_translation_i),
    .en_ld_st_translation_i (tlb_vif.en_ld_st_translation_i ),
    .asid_i                 (tlb_vif.asid_i),
    .itlb_access_i          (tlb_vif.itlb_access_i),
    .itlb_hit_i             (tlb_vif.itlb_hit_i),
    .itlb_vaddr_i           (tlb_vif.itlb_vaddr_i),
    .dtlb_access_i          (tlb_vif.dtlb_access_i),
    .dtlb_hit_i             (tlb_vif.dtlb_hit_i),
    .dtlb_vaddr_i           (tlb_vif.dtlb_vaddr_i),
    .itlb_update_o          (tlb_vif.itlb_update_o),
    .dtlb_update_o          (tlb_vif.dtlb_update_o),
    .itlb_miss_o            (tlb_vif.itlb_miss_o),
    .dtlb_miss_o            (tlb_vif.dtlb_miss_o),
    .shared_tlb_access_o    (tlb_vif.shared_tlb_access_o),
    .shared_tlb_hit_o       (tlb_vif.shared_tlb_hit_o),
    .shared_tlb_vaddr_o     (tlb_vif.shared_tlb_vaddr_o),
    .itlb_req_o             (tlb_vif.itlb_req_o),
    .shared_tlb_update_i    (tlb_vif.shared_tlb_update_i)
);
  
endmodule
   
 