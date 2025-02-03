    
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

    `include "cf_math_pkg.sv"
    import cf_math_pkg::*;

    `include "cva6_tlb_sv32.sv"
    `include "sram.sv"
    `include "tc_sram.sv"
    `include "tc_sram_wrapper.sv"
    `include "lfsr.sv"
    `include "lzc.sv"
    `include "cva6_shared_tlb_sv32.sv"
    `include "pmp_entry.sv"
    `include "pmp.sv"
    `include "cva6_ptw_sv32.sv"
    `include "cva6_mmu_sv32.sv"

     `include "seq_item.sv"
     `include "bfm.sv"
     `include "mem_model.sv"
     `include "sequencer.sv"
     `include "sequence_h.sv"

     `include "driver.sv"
     `include "monitor.sv"
     `include "i_monitor.sv"
     `include "p_monitor.sv"
     `include "agent.sv"
     `include "i_agent.sv"
     `include "p_agent.sv"

     `include "env.sv"
     `include "coverage.sv"
     `include "scoreboard.sv"
     `include "base_test.sv"



module top;
  reg clk;
  mmu_if mmu_vif(clk);

  always #10 clk=~clk;
  initial begin
    clk =0;
   uvm_config_db #(virtual mmu_if)::set(null, "*", "mmu_vif", mmu_vif);    
   run_test("ptw_fsm_test");
  end

cva6_mmu_sv32 # (
    .CVA6Cfg            (cva6_config_pkg::cva6_cfg),
    .INSTR_TLB_ENTRIES  (2),
    .DATA_TLB_ENTRIES   (2),
    .ASID_WIDTH         (1)
) DUT (
  .clk_i                    (clk),
  .rst_ni                   (mmu_vif.rst_ni                ),
  .flush_i                  (mmu_vif.flush_i               ),
  .enable_translation_i     (mmu_vif.enable_translation_i  ),
  .en_ld_st_translation_i   (mmu_vif.en_ld_st_translation_i),
  .icache_areq_i            (mmu_vif.icache_areq_i         ),
  .icache_areq_o            (mmu_vif.icache_areq_o         ),
  .misaligned_ex_i          (mmu_vif.misaligned_ex_i       ),
  .lsu_req_i                (mmu_vif.lsu_req_i             ),
  .lsu_vaddr_i              (mmu_vif.lsu_vaddr_i           ),
  .lsu_is_store_i           (mmu_vif.lsu_is_store_i        ),
  .lsu_dtlb_hit_o           (mmu_vif.lsu_dtlb_hit_o        ),
  .lsu_dtlb_ppn_o           (mmu_vif.lsu_dtlb_ppn_o        ),
  .lsu_valid_o              (mmu_vif.lsu_valid_o           ),
  .lsu_paddr_o              (mmu_vif.lsu_paddr_o           ),
  .lsu_exception_o          (mmu_vif.lsu_exception_o       ),
  .priv_lvl_i               (mmu_vif.priv_lvl_i            ),
  .ld_st_priv_lvl_i         (mmu_vif.ld_st_priv_lvl_i      ),
  .sum_i                    (mmu_vif.sum_i                 ),
  .mxr_i                    (mmu_vif.mxr_i                 ),
  .satp_ppn_i               (mmu_vif.satp_ppn_i            ),
  .asid_i                   (mmu_vif.asid_i                ),
  .asid_to_be_flushed_i     (mmu_vif.asid_to_be_flushed_i  ),
  .vaddr_to_be_flushed_i    (mmu_vif.vaddr_to_be_flushed_i ),
  .flush_tlb_i              (mmu_vif.flush_tlb_i           ),
  .itlb_miss_o              (mmu_vif.itlb_miss_o           ),
  .dtlb_miss_o              (mmu_vif.dtlb_miss_o           ),
  .req_port_i               (mmu_vif.req_port_i            ),
  .req_port_o               (mmu_vif.req_port_o            ),
  .pmpcfg_i                 (mmu_vif.pmpcfg_i              ),
  .pmpaddr_i                (mmu_vif.pmpaddr_i             ) 

);
  
endmodule
   
 