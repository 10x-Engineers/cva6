covergroup mmu_cg;

    // Coverpoints for clock and reset signals
  cp_clk: coverpoint clk_i iff  !rst_ni {
    bins clk_active = {1'b1};  // Clock Active (when not in reset)
    bins clk_inactive = {1'b0}; // Clock Inactive
  }
  cp_rst: coverpoint rst_ni {
    bins reset_asserted = {1'b0};  // Reset Asserted
    bins reset_deasserted = {1'b1}; // Reset Deasserted
  }

  // Coverpoints for flush signal
  cp_flush: coverpoint flush_i {
    bins flush_asserted = {1'b1};  // Flush Asserted
    bins flush_deasserted = {1'b0}; // Flush Deasserted
  }
  
  // Coverpoints for translation-related signals
  en_trans: coverpoint enable_translation_i {
    bins translation_enabled = {1'b1};  // Translation Enabled
    bins translation_disabled = {1'b0}; // Translation Disabled
  }
  ld/st_trans: coverpoint en_ld_st_translation_i {
    bins ld_st_translation_enabled = {1'b1};  // LD/ST Translation Enabled
    bins ld_st_translation_disabled = {1'b0}; // LD/ST Translation Disabled
  }

  // Coverpoints for IF interface signals
  icache_rsp: coverpoint icache_areq_i;
  icache_req: coverpoint icache_areq_o;

  // Coverpoints for LSU interface signals
  exception: coverpoint misaligned_ex_i

  lsu_req: coverpoint lsu_req_i {
    bins lsu_translation_requested = {1'b1};  // LSU Translation Requested
    bins lsu_translation_not_requested = {1'b0}; // LSU Translation Not Requested
  }

  lsu_va: coverpoint lsu_vaddr_i;

  lsu_store: coverpoint lsu_is_store_i {
    bins store_translation_requested = {1'b1};  // Store Translation Requested
    bins load_translation_requested = {1'b0};   // Load Translation Requested
  }
  dtlb_hit: coverpoint lsu_dtlb_hit_o {
    bins dtlb_translation_hit = {1'b1};  // DTLB Translation Hit
    bins dtlb_translation_miss = {1'b0}; // DTLB Translation Miss
  }

  dtlb_ppn: coverpoint lsu_dtlb_ppn_o;

  lsu_valid: coverpoint lsu_valid_o {
    bins translation_valid = {1'b1};  // Translation Valid
    bins translation_invalid = {1'b0}; // Translation Invalid
  }

  lsu_pa: coverpoint lsu_paddr_o;

  lsu_exception: coverpoint lsu_exception_o {
    bins translation_exception = {1'b1};  // Translation Exception
    bins no_translation_exception = {1'b0}; // No Translation Exception
  }

  // Coverpoints for general control signals
  priv_lvl: coverpoint priv_lvl_i;
  lsu_priv_lvl: coverpoint ld_st_priv_lvl_i;
  sum: coverpoint sum_i;
  mxr: coverpoint mxr_i;
  satp_ppn: coverpoint satp_ppn_i;
  ASID: coverpoint asid_i;
  ASID_flush: coverpoint asid_to_be_flushed_i;
  va_flush: coverpoint vaddr_to_be_flushed_i;
  flush_tlb: coverpoint flush_tlb_i;

  // Coverpoints for performance counters
  itlb_miss: coverpoint itlb_miss_o {
    bins itlb_miss = {1'b1};  // ITLB Miss
    bins no_itlb_miss = {1'b0}; // No ITLB Miss
  }
  dtlb_miss:coverpoint dtlb_miss_o {
    bins dtlb_miss = {1'b1};  // DTLB Miss
    bins no_dtlb_miss = {1'b0}; // No DTLB Miss
  }

  // Coverpoints for PTW memory interface signals
  ptw_req_i: coverpoint req_port_i;
  ptw_req_o: coverpoint req_port_o;

  // Coverpoints for PMP-related signals
  pmpcfg: coverpoint pmpcfg_i;
  pmpaddr: coverpoint pmpaddr_i;
endgroup : mmu_cg

covergroup itlb_cg;

  // Coverpoint for flush signal
  itlb_flush: coverpoint flush_i {
    bins flush_asserted = {1'b1};  // Flush Asserted
    bins flush_deasserted = {1'b0}; // Flush Deasserted
  }
  
  // Coverpoint for itlb update signal
  itlb_update: coverpoint update_i;

  // Coverpoints for itlb lookup signals
  itlb_lu_access: coverpoint lu_access_i;
  itlb_ASID: coverpoint lu_asid_i;
  itlb_lu_va: coverpoint lu_vaddr_i;

  // Coverpoint for itlb lookup result  content
  itlb_lu_content: coverpoint lu_content_o;

  // Coverpoints for ASID and virtual address to be flushed
  itlb_ASID_flush: coverpoint asid_to_be_flushed_i;
  itlb_vaddr_flush: coverpoint vaddr_to_be_flushed_i;

  // Coverpoint for lu_is_4M signal
  itlb_lu_4M: coverpoint lu_is_4M_o;

  // Coverpoint for lu_hit signal
  itlb_lu_hit: coverpoint lu_hit_o;

endgroup


covergroup dtlb_cg;

  // Coverpoint for flush signal
  dtlb_flush: coverpoint flush_i {
    bins flush_asserted = {1'b1};  // Flush Asserted
    bins flush_deasserted = {1'b0}; // Flush Deasserted
  }
  
  // Coverpoint for dtlb update signal
  dtlb_update: coverpoint update_i;

  // Coverpoints for dtlb lookup signals
  dtlb_lu_access: coverpoint lu_access_i;
  dtlb_ASID: coverpoint lu_asid_i;
  dtlb_lu_va: coverpoint lu_vaddr_i;

  // Coverpoint for dtlb lookup result  content
  dtlb_lu_content: coverpoint lu_content_o;

  // Coverpoints for ASID and virtual address to be flushed
  dtlb_ASID_flush: coverpoint asid_to_be_flushed_i;
  dtlb_vaddr_flush: coverpoint vaddr_to_be_flushed_i;

  // Coverpoint for lu_is_4M signal
  dtlb_lu_4M: coverpoint lu_is_4M_o;

  // Coverpoint for lu_hit signal
  dtlb_lu_hit: coverpoint lu_hit_o;

endgroup

covergroup shared_tlb_cg;

  // Coverpoint for flush signal
  shtlb_flush: coverpoint flush_i {
    bins flush_asserted = {1'b1};  // Flush Asserted
    bins flush_deasserted = {1'b0}; // Flush Deasserted
  }
  
  // Coverpoints for translation-related signals
  shtlb_en_trans: coverpoint enable_translation_i;
  shtlb_en_ldst_trans: coverpoint en_ld_st_translation_i;

  // Coverpoint for ASID  Address Space Identifier
  shtlb_ASID: coverpoint asid_i;

  // Coverpoints for ITLB access, hit, and virtual address signals
  shtlb_itlb_access: coverpoint itlb_access_i;
  shtlb_itlb_hit: coverpoint itlb_hit_i;
  shtlb_itlb_vaddr: coverpoint itlb_vaddr_i;

  // Coverpoints for DTLB access, hit, and virtual address signals
  shtlb_dtlb_access: coverpoint dtlb_access_i;
  shtlb_dtlb_hit: coverpoint dtlb_hit_i;
  shtlb_dtlb_vaddr: coverpoint dtlb_vaddr_i;

  // Coverpoints for ITLB and DTLB updates
  shtlb_itlb_update: coverpoint itlb_update_o;
  shtlb_dtlb_update: coverpoint dtlb_update_o;

  // Coverpoints for performance counters
  shtlb_itlb_miss: coverpoint itlb_miss_o;
  shtlb_dtlb_miss: coverpoint dtlb_miss_o;

  // Coverpoints for shared TLB access, hit, and virtual address signals
  shtlb_access: coverpoint shared_tlb_access_o;
  shtlb_hit: coverpoint shared_tlb_hit_o;
  shtlb_vaddr: coverpoint shared_tlb_vaddr_o;

  // Coverpoint for ITLB request signal
  shtlb_itlb_req: coverpoint itlb_req_o;

  // Coverpoint for shared TLB update signal
  shtlb_update: coverpoint shared_tlb_update_i;

endgroup

covergroup ptw_cg;

  // Coverpoint for flush signal
  ptw_flush: coverpoint flush_i {
    bins flush_asserted = {1'b1};  // Flush Asserted
    bins flush_deasserted = {1'b0}; // Flush Deasserted
  }
  
  // Coverpoints for PTW control signals
  ptw_active: coverpoint ptw_active_o;
  walking_instr: coverpoint walking_instr_o;
  ptw_error: coverpoint ptw_error_o;
  ptw_exception: coverpoint ptw_access_exception_o;

  // Coverpoint for LSU is_store signal
  ptw_lsu_store: coverpoint lsu_is_store_i;

  // Coverpoints for PTW memory interface signals
  ptw_req_i: coverpoint req_port_i;
  ptw_req_o: coverpoint req_port_o;

  // Coverpoint for Shared TLB update logic
  shared_tlb_update: coverpoint shared_tlb_update_o;

  // Coverpoint for update_vaddr signal
  update_vaddr: coverpoint update_vaddr_o;

  // Coverpoint for ASID  Address Space Identifier
  ptw_ASID: coverpoint asid_i;

  // Coverpoints for Shared TLB access and hit signals
  shared_tlb_access: coverpoint shared_tlb_access_i;
  shared_tlb_hit: coverpoint shared_tlb_hit_i;

  // Coverpoint for shared_tlb_vaddr signal
  shared_tlb_va: coverpoint shared_tlb_vaddr_i;

  // Coverpoint for itlb_req_i signal
  itlb_req: coverpoint itlb_req_i;

  // Coverpoints for CSR-related signals
  ptw_satp_ppn: coverpoint satp_ppn_i;
  ptw_mxr: coverpoint mxr_i;

  // Coverpoint for performance counters
  shared_tlb_miss: coverpoint shared_tlb_miss_o;

  // Coverpoints for PMP-related signals
  ptw_pmpcfg: coverpoint pmpcfg_i;
  ptw_pmpaddr: coverpoint pmpaddr_i;

  // Coverpoint for bad_paddr signal
  bad_paddr: coverpoint bad_paddr_o;

endgroup

covergroup sram_cg;

  // Coverpoint for request signal
  sram_req: coverpoint req_i;

  // Coverpoint for write enable signal
  sram_we: coverpoint we_i;

  // Coverpoint for address input signal
  sram_addr: coverpoint addr_i;

  // Coverpoint for write user signal
  sram_wuser: coverpoint wuser_i;

  // Coverpoint for write data signal
  sram_wdata: coverpoint wdata_i;

  // Coverpoint for byte enable signal
  sram_be: coverpoint be_i;

  // Coverpoint for read user output signal
  sram_ruser: coverpoint ruser_o;

  // Coverpoint for read data output signal
  sram_rdata: coverpoint rdata_o;

endgroup

covergroup pmp_cg;

  // Coverpoint for address input signal
  pmp_addr: coverpoint addr_i;

  // Coverpoint for access type signal
  pmp_access_type: coverpoint access_type_i;

  // Coverpoint for privilege level signal
  pmp_priv_lvl: coverpoint priv_lvl_i;

  // Coverpoints for configuration address and configuration signals
  pmp_conf_addr: coverpoint conf_addr_i;
  pmp_conf: coverpoint conf_i;

  // Coverpoint for the allow output signal
  pmp_allow: coverpoint allow_o;

endgroup
