..
   Copyright 2024 Thales DIS France SAS
   Licensed under the Solderpad Hardware License, Version 2.1 (the "License");
   you may not use this file except in compliance with the License.
   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
   You may obtain a copy of the License at https://solderpad.org/licenses/

   Original Author: Jean-Roch COULON - Thales

.. _CVA6_ex_stage_ports:

.. list-table:: **ex_stage module** IO ports
   :header-rows: 1

   * - Signal
     - IO
     - Description
     - connexion
     - Type

   * - ``clk_i``
     - in
     - Subsystem Clock
     - SUBSYSTEM
     - logic

   * - ``rst_ni``
     - in
     - Asynchronous reset active low
     - SUBSYSTEM
     - logic

   * - ``flush_i``
     - in
     - Fetch flush request
     - CONTROLLER
     - logic

   * - ``rs1_forwarding_i``
     - in
     - rs1 forwarding
     - ISSUE_STAGE
     - logic[CVA6Cfg.NrIssuePorts-1:0][CVA6Cfg.VLEN-1:0]

   * - ``rs2_forwarding_i``
     - in
     - rs2 forwarding
     - ISSUE_STAGE
     - logic[CVA6Cfg.NrIssuePorts-1:0][CVA6Cfg.VLEN-1:0]

   * - ``fu_data_i``
     - in
     - FU data useful to execute instruction
     - ISSUE_STAGE
     - fu_data_t[CVA6Cfg.NrIssuePorts-1:0]

   * - ``pc_i``
     - in
     - PC of the current instruction
     - ISSUE_STAGE
     - logic[CVA6Cfg.VLEN-1:0]

   * - ``is_compressed_instr_i``
     - in
     - Report whether instruction is compressed
     - ISSUE_STAGE
     - logic

   * - ``flu_result_o``
     - out
     - Fixed Latency Unit result
     - ISSUE_STAGE
     - logic[CVA6Cfg.XLEN-1:0]

   * - ``flu_trans_id_o``
     - out
     - ID of the scoreboard entry at which a=to write back
     - ISSUE_STAGE
     - logic[CVA6Cfg.TRANS_ID_BITS-1:0]

   * - ``flu_exception_o``
     - out
     - Fixed Latency Unit exception
     - ISSUE_STAGE
     - exception_t

   * - ``flu_ready_o``
     - out
     - FLU is ready
     - ISSUE_STAGE
     - logic

   * - ``flu_valid_o``
     - out
     - FLU result is valid
     - ISSUE_STAGE
     - logic

   * - ``alu_valid_i``
     - in
     - ALU instruction is valid
     - ISSUE_STAGE
     - logic[CVA6Cfg.NrIssuePorts-1:0]

   * - ``branch_valid_i``
     - in
     - Branch unit instruction is valid
     - ISSUE_STAGE
     - logic[CVA6Cfg.NrIssuePorts-1:0]

   * - ``branch_predict_i``
     - in
     - Information of branch prediction
     - ISSUE_STAGE
     - branchpredict_sbe_t

   * - ``resolved_branch_o``
     - out
     - The branch engine uses the write back from the ALU
     - several_modules
     - bp_resolve_t

   * - ``resolve_branch_o``
     - out
     - Signaling that we resolved the branch
     - ISSUE_STAGE
     - logic

   * - ``csr_valid_i``
     - in
     - CSR instruction is valid
     - ISSUE_STAGE
     - logic[CVA6Cfg.NrIssuePorts-1:0]

   * - ``csr_addr_o``
     - out
     - CSR address to write
     - COMMIT_STAGE
     - logic[11:0]

   * - ``csr_commit_i``
     - in
     - CSR commit
     - COMMIT_STAGE
     - logic

   * - ``mult_valid_i``
     - in
     - MULT instruction is valid
     - ISSUE_STAGE
     - logic[CVA6Cfg.NrIssuePorts-1:0]

   * - ``lsu_ready_o``
     - out
     - LSU is ready
     - ISSUE_STAGE
     - logic

   * - ``lsu_valid_i``
     - in
     - LSU instruction is valid
     - ISSUE_STAGE
     - logic[CVA6Cfg.NrIssuePorts-1:0]

   * - ``load_valid_o``
     - out
     - Load result is valid
     - ISSUE_STAGE
     - logic

   * - ``load_result_o``
     - out
     - Load result valid
     - ISSUE_STAGE
     - logic[CVA6Cfg.XLEN-1:0]

   * - ``load_trans_id_o``
     - out
     - Load instruction ID
     - ISSUE_STAGE
     - logic[CVA6Cfg.TRANS_ID_BITS-1:0]

   * - ``load_exception_o``
     - out
     - Exception generated by load instruction
     - ISSUE_STAGE
     - exception_t

   * - ``store_valid_o``
     - out
     - Store result is valid
     - ISSUe_STAGE
     - logic

   * - ``store_result_o``
     - out
     - Store result
     - ISSUE_STAGE
     - logic[CVA6Cfg.XLEN-1:0]

   * - ``store_trans_id_o``
     - out
     - Store instruction ID
     - ISSUE_STAGE
     - logic[CVA6Cfg.TRANS_ID_BITS-1:0]

   * - ``store_exception_o``
     - out
     - Exception generated by store instruction
     - ISSUE_STAGE
     - exception_t

   * - ``lsu_commit_i``
     - in
     - LSU commit
     - COMMIT_STAGE
     - logic

   * - ``lsu_commit_ready_o``
     - out
     - Commit queue ready to accept another commit request
     - COMMIT_STAGE
     - logic

   * - ``commit_tran_id_i``
     - in
     - Commit transaction ID
     - COMMIT_STAGE
     - logic[CVA6Cfg.TRANS_ID_BITS-1:0]

   * - ``no_st_pending_o``
     - out
     - TO_BE_COMPLETED
     - COMMIT_STAGE
     - logic

   * - ``alu2_valid_i``
     - in
     - ALU2 instruction is valid
     - ISSUE_STAGE
     - logic[CVA6Cfg.NrIssuePorts-1:0]

   * - ``x_valid_i``
     - in
     - CVXIF instruction is valid
     - ISSUE_STAGE
     - logic[CVA6Cfg.NrIssuePorts-1:0]

   * - ``x_ready_o``
     - out
     - CVXIF is ready
     - ISSUE_STAGE
     - logic

   * - ``x_off_instr_i``
     - in
     - undecoded instruction
     - ISSUE_STAGE
     - logic[31:0]

   * - ``x_trans_id_o``
     - out
     - CVXIF transaction ID
     - ISSUE_STAGE
     - logic[CVA6Cfg.TRANS_ID_BITS-1:0]

   * - ``x_exception_o``
     - out
     - CVXIF exception
     - ISSUE_STAGE
     - exception_t

   * - ``x_result_o``
     - out
     - CVXIF result
     - ISSUE_STAGE
     - logic[CVA6Cfg.XLEN-1:0]

   * - ``x_valid_o``
     - out
     - CVXIF result valid
     - ISSUE_STAGE
     - logic

   * - ``x_we_o``
     - out
     - CVXIF write enable
     - ISSUE_STAGE
     - logic

   * - ``cvxif_req_o``
     - out
     - CVXIF request
     - SUBSYSTEM
     - cvxif_pkg::cvxif_req_t

   * - ``cvxif_resp_i``
     - in
     - CVXIF response
     - SUBSYSTEM
     - cvxif_pkg::cvxif_resp_t

   * - ``icache_areq_i``
     - in
     - icache translation response
     - CACHE
     - icache_arsp_t

   * - ``icache_areq_o``
     - out
     - icache translation request
     - CACHE
     - icache_areq_t

   * - ``dcache_req_ports_i``
     - in
     - Data cache request ouput
     - CACHE
     - dcache_req_o_t[2:0]

   * - ``dcache_req_ports_o``
     - out
     - Data cache request input
     - CACHE
     - dcache_req_i_t[2:0]

   * - ``dcache_wbuffer_empty_i``
     - in
     - Write buffer is empty
     - CACHE
     - logic

   * - ``dcache_wbuffer_not_ni_i``
     - in
     - TO_BE_COMPLETED
     - CACHE
     - logic

   * - ``pmpcfg_i``
     - in
     - Report the PMP configuration
     - CSR_REGFILE
     - riscv::pmpcfg_t[CVA6Cfg.NrPMPEntries:0]

   * - ``pmpaddr_i``
     - in
     - Report the PMP addresses
     - CSR_REGFILE
     - logic[CVA6Cfg.NrPMPEntries:0][CVA6Cfg.PLEN-3:0]

Due to cv32a65x configuration, some ports are tied to a static value. These ports do not appear in the above table, they are listed below

| As DebugEn = False,
|   ``debug_mode_i`` input is tied to 0
| As RVH = False,
|   ``tinst_i`` input is tied to 0
|   ``enable_g_translation_i`` input is tied to 0
|   ``en_ld_st_g_translation_i`` input is tied to 0
|   ``flush_tlb_vvma_i`` input is tied to 0
|   ``flush_tlb_gvma_i`` input is tied to 0
|   ``v_i`` input is tied to 0
|   ``ld_st_v_i`` input is tied to 0
|   ``csr_hs_ld_st_inst_o`` output is tied to 0
|   ``vs_sum_i`` input is tied to 0
|   ``vmxr_i`` input is tied to 0
|   ``vsatp_ppn_i`` input is tied to 0
|   ``vs_asid_i`` input is tied to 0
|   ``hgatp_ppn_i`` input is tied to 0
|   ``vmid_i`` input is tied to 0
| As EnableAccelerator = 0,
|   ``stall_st_pending_i`` input is tied to 0
|   ``acc_valid_i`` input is tied to 0
| As RVA = False,
|   ``amo_valid_commit_i`` input is tied to 0
|   ``amo_req_o`` output is tied to 0
|   ``amo_resp_i`` input is tied to 0
| As RVF = 0,
|   ``fpu_ready_o`` output is tied to 0
|   ``fpu_valid_i`` input is tied to 0
|   ``fpu_fmt_i`` input is tied to 0
|   ``fpu_rm_i`` input is tied to 0
|   ``fpu_frm_i`` input is tied to 0
|   ``fpu_prec_i`` input is tied to 0
|   ``fpu_trans_id_o`` output is tied to 0
|   ``fpu_result_o`` output is tied to 0
|   ``fpu_valid_o`` output is tied to 0
|   ``fpu_exception_o`` output is tied to 0
| As RVS = False,
|   ``enable_translation_i`` input is tied to 0
|   ``en_ld_st_translation_i`` input is tied to 0
|   ``sum_i`` input is tied to 0
|   ``mxr_i`` input is tied to 0
|   ``satp_ppn_i`` input is tied to 0
|   ``asid_i`` input is tied to 0
| As MMUPresent = 0,
|   ``flush_tlb_i`` input is tied to 0
| As PRIV = MachineOnly,
|   ``priv_lvl_i`` input is tied to MachineMode
|   ``ld_st_priv_lvl_i`` input is tied to MAchineMode
| As PerfCounterEn = 0,
|   ``itlb_miss_o`` output is tied to 0
|   ``dtlb_miss_o`` output is tied to 0
| As IsRVFI = 0,
|   ``rvfi_lsu_ctrl_o`` output is tied to 0
|   ``rvfi_mem_paddr_o`` output is tied to 0

