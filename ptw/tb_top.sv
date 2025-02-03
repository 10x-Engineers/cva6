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

`include "/mmu_sv32/cf_math_pkg.sv"
import cf_math_pkg::*;

`include "/mmu_sv32/lzc.sv"
`include "/mmu_sv32/pmp_entry.sv"
`include "/mmu_sv32/pmp.sv"
`include "/mmu_sv32/cva6_ptw_sv32.sv"

module top;
  reg clk;
  tlb_if tlb_vif(clk);

  always #10 clk=~clk;
  initial begin
    clk =0;
    uvm_config_db #(virtual tlb_if)::set(null, "*", "tlb_vif", tlb_vif);    
    run_test("base_test");
  end

  cva6_ptw_sv32 #
  (
    .CVA6Cfg     (cva6_config_pkg::cva6_cfg)

  ) DUT (
    .clk_i                  (clk),
    .rst_ni                 (tlb_vif.rst_ni),
    .flush_i                (tlb_vif.flush_i),
    .ptw_active_o           (tlb_vif.ptw_active_o),
    .walking_instr_o        (tlb_vif.walking_instr_o),
    .ptw_error_o            (tlb_vif.ptw_error_o),
    .ptw_access_exception_o (tlb_vif.ptw_access_exception_o),
    .lsu_is_store_i         (tlb_vif.lsu_is_store_i),
    .req_port_i             (tlb_vif.req_port_i),
    .req_port_o             (tlb_vif.req_port_o),
    .shared_tlb_update_o    (tlb_vif.shared_tlb_update_o),
    .update_vaddr_o         (tlb_vif.update_vaddr_o),
    .asid_i                 (tlb_vif.asid_i),
    .shared_tlb_access_i    (tlb_vif.shared_tlb_access_i),
    .shared_tlb_hit_i       (tlb_vif.shared_tlb_hit_i),
    .shared_tlb_vaddr_i     (tlb_vif.shared_tlb_vaddr_i),
    .itlb_req_i             (tlb_vif.itlb_req_i),
    .satp_ppn_i             (tlb_vif.satp_ppn_i),
    .mxr_i                  (tlb_vif.mxr_i),
    .shared_tlb_miss_o      (tlb_vif.shared_tlb_miss_o),
    .pmpcfg_i               (tlb_vif.pmpcfg_i),
    .pmpaddr_i              (tlb_vif.pmpaddr_i),
    .bad_paddr_o            (tlb_vif.bad_paddr_o)
);
  
endmodule
   
 