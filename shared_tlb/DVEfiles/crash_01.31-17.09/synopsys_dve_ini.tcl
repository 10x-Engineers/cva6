gui_state_default_create -off -ini

# Globals
gui_set_state_value -category Globals -key recent_sessions -value {{gui_load_session -ignore_errors -file /home/user1/docker/OpenHW/MMU_verif/shared_tlb/DVEfiles//crash_01.31-17.09/dve_session01.31-17.09.tcl} {gui_load_session -ignore_errors -file /home/user1/docker/OpenHW/MMU_verif/shared_tlb/DVEfiles//crash_01.24-17.57/dve_session01.24-17.57.tcl}}

# Layout
gui_set_state_value -category Layout -key child_console_size_x -value 1365
gui_set_state_value -category Layout -key child_console_size_y -value 159
gui_set_state_value -category Layout -key child_data_size_x -value 154
gui_set_state_value -category Layout -key child_data_size_y -value 441
gui_set_state_value -category Layout -key child_driver_size_x -value 1069
gui_set_state_value -category Layout -key child_driver_size_y -value 179
gui_set_state_value -category Layout -key child_hier_col3 -value {-1}
gui_set_state_value -category Layout -key child_hier_colpd -value 0
gui_set_state_value -category Layout -key child_hier_size_x -value 154
gui_set_state_value -category Layout -key child_hier_size_y -value 441
gui_set_state_value -category Layout -key child_source_pos_x -value {-2}
gui_set_state_value -category Layout -key child_source_pos_y -value {-15}
gui_set_state_value -category Layout -key child_source_size_x -value 1060
gui_set_state_value -category Layout -key child_source_size_y -value 436
gui_set_state_value -category Layout -key child_wave_colname -value 195
gui_set_state_value -category Layout -key child_wave_colvalue -value 196
gui_set_state_value -category Layout -key child_wave_left -value 395
gui_set_state_value -category Layout -key child_wave_right -value 965
gui_set_state_value -category Layout -key main_pos_x -value 0
gui_set_state_value -category Layout -key main_pos_y -value 60
gui_set_state_value -category Layout -key main_size_x -value 1365
gui_set_state_value -category Layout -key main_size_y -value 767
gui_set_state_value -category Layout -key stand_wave_child_pos_x -value {-2}
gui_set_state_value -category Layout -key stand_wave_child_pos_y -value {-15}
gui_set_state_value -category Layout -key stand_wave_child_size_x -value 1370
gui_set_state_value -category Layout -key stand_wave_child_size_y -value 595
gui_set_state_value -category Layout -key stand_wave_top_pos_x -value 0
gui_set_state_value -category Layout -key stand_wave_top_pos_y -value 60
gui_set_state_value -category Layout -key stand_wave_top_size_x -value 1365
gui_set_state_value -category Layout -key stand_wave_top_size_y -value 767

# list_value_column

# Sim

# Assertion

# Stream

# Data

# TBGUI

# Driver

# Class

# Member

# ObjectBrowser

# UVM

# Local

# Backtrace

# FastSearch

# Exclusion

# SaveSession

# FindDialog
gui_create_state_key -category FindDialog -key m_pMatchCase -value_type bool -value false
gui_create_state_key -category FindDialog -key m_pMatchWord -value_type bool -value false
gui_create_state_key -category FindDialog -key m_pUseCombo -value_type string -value {}
gui_create_state_key -category FindDialog -key m_pWrapAround -value_type bool -value true

# Widget_History
gui_create_state_key -category Widget_History -key {dlgSimSetup|m_setupTab|tab pages|BuildTab|m_rebuildBtnGroup|m_customCmdCombo} -value_type string -value {{vcs -lca -debug_access+all -sverilog -timescale=1ns/1ns -ntb_opts uvm-1.2 +incdir+/home/user101/docker/OpenHW/MMU_verif/mmu_sv32/ ./tb_top.sv} {vcs -lca -debug_access+all -sverilog -timescale=1ns/1ns -ntb_opts uvm-1.2 +incdir+/home/user101/docker/OpenHW/MMU_verif/comb_tlb/mmu_sv32/ +incdir+/home/user101/docker/OpenHW/MMU_verif/comb_tlb/shared_tlb/ +incdir+/home/user101/docker/OpenHW/MMU_verif/comb_tlb/tlb/ ./tb_top.sv} {vcs -lca -debug_access+all -sverilog -timescale=1ns/1ns -ntb_opts uvm-1.2 +incdir+/home/user101/docker/OpenHW/MMU_verif/mmu_sv32/ ./tb_top.sv
}}
gui_create_state_key -category Widget_History -key {dlgSimSetup|m_setupTab|tab pages|SimTab|m_VPDCombo} -value_type string -value inter.vpd
gui_create_state_key -category Widget_History -key {dlgSimSetup|m_setupTab|tab pages|SimTab|m_argsCombo} -value_type string -value {{-ucligui }}
gui_create_state_key -category Widget_History -key {dlgSimSetup|m_setupTab|tab pages|SimTab|m_curDirCombo} -value_type string -value {/home/user1/docker/OpenHW/MMU_verif/shared_tlb /home/user1/docker/OpenHW/MMU_verif/tlb /home/user1/docker/OpenHW/MMU_verif/comb_tlb /home/user1/docker/OpenHW/MMU_verif/comb_tlb/shared_tlb /home/user1/docker/OpenHW/MMU_verif/ptw}
gui_create_state_key -category Widget_History -key {dlgSimSetup|m_setupTab|tab pages|SimTab|m_exeCombo} -value_type string -value {/home/user1/docker/OpenHW/MMU_verif/shared_tlb/simv ./simv /home/user1/docker/OpenHW/MMU_verif/tlb/simv /home/user1/docker/OpenHW/MMU_verif/comb_tlb/simv /home/user1/docker/OpenHW/MMU_verif/comb_tlb/shared_tlb/simv}


gui_state_default_create -off
