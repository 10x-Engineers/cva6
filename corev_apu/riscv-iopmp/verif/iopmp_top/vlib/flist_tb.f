
// This file includes all the files being used in the project
//Author: Muhammad Hassan

// UVM Macros and Package
//$UVM_HOME/src/uvm_pkg.sv
//+incdir+$UVM_HOME/src
$(PWD)/../vlib/bus_params_pkg.sv
//$(PWD)/../vlib/config_iopmp_pkg.sv

$(PWD)/../vlib/tb_pkg.sv
$(PWD)/../vlib/reg32_uvm_pkg.sv

$(PWD)/../interface/axi_interface.sv
$(PWD)/../interface/axi_s_interface.sv
$(PWD)/../interface/ahb_interface.sv

+incdir+$(PWD)/../agent/
+incdir+$(PWD)/../agent/ahb_agent/
+incdir+$(PWD)/../agent/axi_agent/
+incdir+$(PWD)/../agent/axi_s_agent/
+incdir+$(PWD)/../agent/axi_agent/rd_addr_agent/
+incdir+$(PWD)/../agent/axi_agent/rd_data_agent/
+incdir+$(PWD)/../agent/axi_agent/wr_addr_agent/
+incdir+$(PWD)/../agent/axi_agent/wr_data_agent/
+incdir+$(PWD)/../agent/axi_agent/wr_rsp_agent/
+incdir+$(PWD)/../config/
+incdir+$(PWD)/../coverage/
+incdir+$(PWD)/../env/
+incdir+${PWD}/../interface/
+incdir+${PWD}/../../iopmp_top/
+incdir+${PWD}/../test/
+incdir+$(PWD)/../sequence/
+incdir+$(PWD)/../sequence/ahb_seq
+incdir+$(PWD)/../sequence/axi_s_seq
+incdir+$(PWD)/../tb/

//**************Ref-Model*************//
+incdir+${PWD}/../../iopmp_ref_model/
+incdir+${PWD}/../../iopmp_ref_model/include/
+incdir+${PWD}/../../iopmp_ref_model/src/

+incdir+$(PWD)/../vlib/

//**********VERIFICATION-TOP**********//

$(PWD)/../tb/iopmp_tb_top.sv

