//../../../design/rtl/register_file_manager/register_file_manager.sv
//../../../design/rtl/table_traversal_unit/table_traversal_unit.sv
//../../../design/rtl/iopmp.sv

+incdir+${PWD}/../../../design/include/

// Packages
$(PWD)/../vlib/config_iopmp_pkg.sv
${PWD}/../../../design/include/iopmp_axi_pkg.sv
${PWD}/../../../design/include/rfm_pkg.sv
${PWD}/../../../design/include/ahb_lite_pkg.sv
${PWD}/../../../design/include/execution_pipeline_pkg.sv

// Common
${PWD}/../../../design/common/cf_math_pkg.sv
${PWD}/../../../design/common/iopmp_fifo.sv
${PWD}/../../../design/common/iopmp_lzc.sv
${PWD}/../../../design/common/lzc_1.sv
${PWD}/../../../design/common/mem_1r1w.sv
${PWD}/../../../design/common/vld_array.sv
${PWD}/../../../design/common/tag_gen.sv
${PWD}/../../../design/common/arb_rr.v
${PWD}/../../../design/common/rr_arbiter.sv

// Register File Manager
${PWD}/../../../design/rtl/register_file_manager/address_check.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/regfield.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/regfield_arb.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/base_registers/info_regs.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/base_registers/prog_prot_regs.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/base_registers/config_prot_regs.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/base_registers/err_rpt_regs.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/base_registers/error_record_windows.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/base_registers/base_regs.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/mdcfg_regs.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/srcmd_fmt_0_regs.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/srcmd_fmt_2_regs.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/entry_array_regs.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/read_register.sv
${PWD}/../../../design/rtl/register_file_manager/rfm_regmap/regmap.sv
${PWD}/../../../design/rtl/register_file_manager/register_file_manager.sv

// Master and Slave Interface
${PWD}/../../../design/rtl/master_request_manager/master_request_manager.sv
${PWD}/../../../design/rtl/slave_request_manager/axi_write_chnl_controller.sv
${PWD}/../../../design/rtl/slave_request_manager/slave_request_manager.sv
${PWD}/../../../design/rtl/master_response_manager/master_response_manager.sv

// Table Traversal Unit
${PWD}/../../../design/rtl/table_traversal_unit/ttu_checks.sv
${PWD}/../../../design/rtl/table_traversal_unit/srcmd_table_traversal.sv
${PWD}/../../../design/rtl/table_traversal_unit/mdcfg_fmt_2.sv
${PWD}/../../../design/rtl/table_traversal_unit/mds_traversal_fmt_2.sv
${PWD}/../../../design/rtl/table_traversal_unit/mdcfg_fmt_1.sv
${PWD}/../../../design/rtl/table_traversal_unit/mds_traversal_fmt_1.sv
${PWD}/../../../design/rtl/table_traversal_unit/mdcfg_fmt_0.sv
${PWD}/../../../design/rtl/table_traversal_unit/mdcfg_table_traversal.sv
${PWD}/../../../design/rtl/table_traversal_unit/table_traversal_unit.sv

// Rule ANalyzer Pipeline
${PWD}/../../../design/rtl/rule_analyzer_pipeline/rule_analyzer_pipeline.sv
${PWD}/../../../design/rtl/rule_analyzer_pipeline/response_generator.sv
${PWD}/../../../design/rtl/rule_analyzer_pipeline/encoder.sv
${PWD}/../../../design/rtl/rule_analyzer_pipeline/match_8_entry.sv
${PWD}/../../../design/rtl/rule_analyzer_pipeline/match_entry.sv

// Error Control Block
${PWD}/../../../design/rtl/eic_block/eic_block.sv

${PWD}/../../../design/rtl/iopmp.sv

//**********Coverage Model**********//

$(PWD)/../coverage/interface_functional_cov.sv