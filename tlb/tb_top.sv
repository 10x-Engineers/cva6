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
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"

`include "mem_model.sv"
`include "env.sv"

`include "base_test.sv"
`include "/mmu_sv32/cva6_tlb_sv32.sv"

module top;
  reg clk;
  tlb_if tlb_vif(clk);

  always #10 clk=~clk;
  initial begin
    clk =0;
    uvm_config_db #(virtual tlb_if)::set(null, "*", "tlb_vif", tlb_vif);    
    run_test("base_test");
  end

  cva6_tlb_sv32 #
  (
    .CVA6Cfg     (cva6_config_pkg::cva6_cfg),
    .TLB_ENTRIES (2),
    .ASID_WIDTH  (1)
  ) DUT (
    .clk_i                  (clk), 
    .rst_ni                 (tlb_vif.rst_ni), 
    .flush_i                (tlb_vif.flush_i),
    .update_i               (tlb_vif.update_i),
    .lu_access_i            (tlb_vif.lu_access_i),
    .lu_asid_i              (tlb_vif.lu_asid_i),
    .lu_vaddr_i             (tlb_vif.lu_vaddr_i),
    .lu_content_o           (tlb_vif.lu_content_o),
    .asid_to_be_flushed_i   (tlb_vif.asid_to_be_flushed_i),
    .vaddr_to_be_flushed_i  (tlb_vif.vaddr_to_be_flushed_i),
    .lu_is_4M_o             (tlb_vif.lu_is_4M_o),
    .lu_hit_o               (tlb_vif.lu_hit_o)
);
  
endmodule
   
 