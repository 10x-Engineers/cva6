// Include directory
+incdir+../../../design/include/

// Packages
../../synth/config1/config_iopmp_pkg.sv
../../design/include/iopmp_axi_pkg.sv
../../design/include/ahb_lite_pkg.sv
../../design/include/rfm_pkg.sv
../../design/include/execution_pipeline_pkg.sv

// Common
../../design/common/cf_math_pkg.sv
../../design/common/iopmp_fifo.sv
../../design/common/iopmp_common_macros.svh
../../design/common/iopmp_lzc.sv
../../design/common/mem1r1w.sv
../../design/common/vld_array.sv
../../design/common/tag_gen.sv
../../design/common/arb_rr.v
../../design/common/rr_arbiter.sv

// Register File Manager
../../design/rtl/register_file_manager/address_check.sv
../../design/rtl/register_file_manager/rfm_regmap/regfield.sv
../../design/rtl/register_file_manager/rfm_regmap/regfield_arb.sv
../../design/rtl/register_file_manager/rfm_regmap/base_registers/info_regs.sv
../../design/rtl/register_file_manager/rfm_regmap/base_registers/prog_prot_regs.sv
../../design/rtl/register_file_manager/rfm_regmap/base_registers/config_prot_regs.sv
../../design/rtl/register_file_manager/rfm_regmap/base_registers/err_rpt_regs.sv
../../design/rtl/register_file_manager/rfm_regmap/base_registers/error_record_windows.sv
../../design/rtl/register_file_manager/rfm_regmap/base_registers/base_regs.sv
../../design/rtl/register_file_manager/rfm_regmap/mdcfg_regs.sv
../../design/rtl/register_file_manager/rfm_regmap/srcmd_fmt_0_regs.sv
../../design/rtl/register_file_manager/rfm_regmap/srcmd_fmt_2_regs.sv
../../design/rtl/register_file_manager/rfm_regmap/entry_array_regs.sv
../../design/rtl/register_file_manager/rfm_regmap/read_register.sv
../../design/rtl/register_file_manager/rfm_regmap/regmap.sv
../../design/rtl/register_file_manager/register_file_manager.sv

// Master and Slave Interface
../../design/rtl/master_request_manager/master_request_manager.sv
../../design/rtl/slave_request_manager/axi_write_chnl_controller.sv
../../design/rtl/slave_request_manager/slave_request_manager.sv
../../design/rtl/master_response_manager/master_response_manager.sv

// Table Traversal Unit
../../design/rtl/table_traversal_unit/ttu_checks.sv
../../design/rtl/table_traversal_unit/srcmd_table_traversal.sv
../../design/rtl/table_traversal_unit/mdcfg_fmt_2.sv
../../design/rtl/table_traversal_unit/mds_traversal_fmt_2.sv
../../design/rtl/table_traversal_unit/mdcfg_fmt_1.sv
../../design/rtl/table_traversal_unit/mds_traversal_fmt_1.sv
../../design/rtl/table_traversal_unit/mdcfg_fmt_0.sv
../../design/rtl/table_traversal_unit/mdcfg_table_traversal.sv
../../design/rtl/table_traversal_unit/table_traversal_unit.sv

// Rule ANalyzer Pipeline
../../design/rtl/rule_analyzer_pipeline/rule_analyzer_pipeline.sv
../../design/rtl/rule_analyzer_pipeline/response_generator.sv
../../design/rtl/rule_analyzer_pipeline/encoder.sv
../../design/rtl/rule_analyzer_pipeline/match_8_entry.sv
../../design/rtl/rule_analyzer_pipeline/match_entry.sv

// Error Control Block
../../design/rtl/eic_block/eic_block.sv

../../design/rtl/iopmp.sv
