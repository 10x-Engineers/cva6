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

`include "/mmu_sv32/cf_math_pkg.sv"
import cf_math_pkg::*;


`include "/tlb/tlb_if.sv"
`include "/shared_tlb/shared_tlb_if.sv"
`include "comb_tlb_if.sv"
`include "seq_item.sv"
`include "sequencer.sv"
`include "sequence_h.sv"

`include "/tlb/driver.sv"
`include "/shared_tlb/i_driver.sv"
`include "/tlb/monitor.sv"
`include "/shared_tlb/i_monitor.sv"
`include "/tlb/agent.sv"
`include "/shared_tlb/i_agent.sv"

`include "env.sv"
`include "base_test.sv"
`include "/mmu_sv32/cva6_tlb_sv32.sv"
`include "/mmu_sv32/sram.sv"
`include "/mmu_sv32/tc_sram.sv"
`include "/mmu_sv32/tc_sram_wrapper.sv"
`include "/mmu_sv32/lfsr.sv"
`include "/mmu_sv32/lzc.sv"
`include "/mmu_sv32/cva6_shared_tlb_sv32.sv"
  
module top;
  reg clk;
  tlb_if tlb_vif(clk);
  shared_tlb_if shared_tlb_vif(clk);
  comb_tlb_if comb_tlb_vif(clk);

  always #10 clk=~clk;
  initial begin
    clk =0;
    uvm_config_db #(virtual tlb_if)::set(null, "*", "tlb_vif", tlb_vif);   
    uvm_config_db #(virtual shared_tlb_if)::set(null, "*", "shared_tlb_vif", shared_tlb_vif);   
    uvm_config_db #(virtual comb_tlb_if)::set(null, "*", "comb_tlb_vif", comb_tlb_vif);       
    run_test("base_test");
  end

  cva6_tlb_sv32 #
  (
    .TLB_ENTRIES (2),
    .ASID_WIDTH  (1)
  ) i_itlb (
      .clk_i  (clk),
      .rst_ni (comb_tlb_vif.rst_ni),
      .flush_i(comb_tlb_vif.flush_tlb_i),

      .update_i(comb_tlb_vif.itlb_update_io),

      .lu_access_i          (comb_tlb_vif.itlb_lu_access_i),
      .lu_asid_i            (comb_tlb_vif.asid_i),
      .asid_to_be_flushed_i (tlb_vif.asid_to_be_flushed_i),
      .vaddr_to_be_flushed_i(tlb_vif.vaddr_to_be_flushed_i),
      .lu_vaddr_i           (comb_tlb_vif.itlb_vaddr_i),
      .lu_content_o         (tlb_vif.lu_content_itlb_o),

      .lu_is_4M_o(tlb_vif.lu_is_4M_itlb_o),
      .lu_hit_o  (comb_tlb_vif.itlb_lu_hit_o)
  );

  cva6_tlb_sv32 #
  (
    .TLB_ENTRIES (2),
    .ASID_WIDTH  (1)
  ) i_dtlb (
      .clk_i  (clk),
      .rst_ni (comb_tlb_vif.rst_ni),
      .flush_i(comb_tlb_vif.flush_tlb_i),

      .update_i(comb_tlb_vif.dtlb_update_io),

      .lu_access_i          (comb_tlb_vif.dtlb_lu_access_i),
      .lu_asid_i            (comb_tlb_vif.asid_i),
      .asid_to_be_flushed_i (tlb_vif.asid_to_be_flushed_i),
      .vaddr_to_be_flushed_i(tlb_vif.vaddr_to_be_flushed_i),
      .lu_vaddr_i           (comb_tlb_vif.dtlb_vaddr_i),
      .lu_content_o         (tlb_vif.lu_content_dtlb_o),
      
      .lu_is_4M_o(tlb_vif.lu_is_4M_dtlb_o),
      .lu_hit_o  (comb_tlb_vif.dtlb_lu_hit_o)
  );

  cva6_shared_tlb_sv32 i_shared_tlb (
      .clk_i  (clk),
      .rst_ni (comb_tlb_vif.rst_ni),
      .flush_i(comb_tlb_vif.flush_tlb_i),

      .enable_translation_i  (shared_tlb_vif.enable_translation_i),
      .en_ld_st_translation_i(shared_tlb_vif.en_ld_st_translation_i),

      .asid_i       (comb_tlb_vif.asid_i),
      // from TLBs
      // did we miss?
      .itlb_access_i(comb_tlb_vif.itlb_lu_access_i),
      .itlb_hit_i   (comb_tlb_vif.itlb_lu_hit_o),
      .itlb_vaddr_i (comb_tlb_vif.itlb_vaddr_i),

      .dtlb_access_i(comb_tlb_vif.dtlb_lu_access_i),
      .dtlb_hit_i   (comb_tlb_vif.dtlb_lu_hit_o),
      .dtlb_vaddr_i (comb_tlb_vif.dtlb_vaddr_i),

      // to TLBs, update logic
      .itlb_update_o(comb_tlb_vif.itlb_update_io),
      .dtlb_update_o(comb_tlb_vif.dtlb_update_io),

      // Performance counters
      .itlb_miss_o(shared_tlb_vif.itlb_miss_o),
      .dtlb_miss_o(shared_tlb_vif.dtlb_miss_o),

      .shared_tlb_access_o(shared_tlb_vif.shared_tlb_access_o),
      .shared_tlb_hit_o   (shared_tlb_vif.shared_tlb_hit_o),
      .shared_tlb_vaddr_o (shared_tlb_vif.shared_tlb_vaddr_o),

      .itlb_req_o         (shared_tlb_vif.itlb_req_o),
      // to update shared tlb
      .shared_tlb_update_i(shared_tlb_vif.shared_tlb_update_i)
  );

endmodule
   
 