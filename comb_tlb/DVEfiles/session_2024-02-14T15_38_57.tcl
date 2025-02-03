# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Wed Feb 14 15:38:57 2024
# Designs open: 1
#   Sim: /home/user1/docker/OpenHW/cva6_work/MMU_verif/comb_tlb/simv
# Toplevel windows open: 1
# 	TopLevel.2
#   Wave.1: 35 signals
#   Group count = 11
#   Group i_dtlb signal count = 40
#   Group comb_tlb_vif signal count = 14
#   Group i_dtlb_1 signal count = 6
#   Group i_itlb signal count = 12
#   Group i_shared_tlb signal count = 17
#   Group tlb_vif signal count = 9
#   Group shared_tlb_vif signal count = 11
# End_DVE_Session_Save_Info

# DVE version: L-2016.06_Full64
# DVE build date: May 24 2016 21:01:02


#<Session mode="Full" path="/home/user1/docker/OpenHW/cva6_work/MMU_verif/comb_tlb/DVEfiles/session.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{0 60} {1365 767}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 395} {child_wave_right 965} {child_wave_colname 195} {child_wave_colvalue 196} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) none
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) none
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.2}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{-ucligui }}
gui_set_env SIMSETUP::SIMEXE {/home/user1/docker/OpenHW/cva6_work/MMU_verif/comb_tlb/simv}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {/home/user1/docker/OpenHW/cva6_work/MMU_verif/comb_tlb/simv}] } {
gui_sim_run Ucli -exe simv -args {-ucligui } -dir /home/user1/docker/OpenHW/cva6_work/MMU_verif/comb_tlb -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 1ns
gui_set_time_units 1ns
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {top.shared_tlb_vif}
gui_load_child_values {top.tlb_vif}
gui_load_child_values {top.i_dtlb}
gui_load_child_values {top.i_itlb}
gui_load_child_values {top.i_shared_tlb}
gui_load_child_values {top.comb_tlb_vif}


set _session_group_649 i_dtlb
gui_sg_create "$_session_group_649"
set i_dtlb "$_session_group_649"

gui_sg_addsignal -group "$_session_group_649" { {top.i_dtlb.unnamed$$_4} {top.i_dtlb.unnamed$$_6} {top.i_dtlb.p_assertions.unnamed$$_0} {top.i_dtlb.p_assertions.unnamed$$_1} top.i_dtlb.content_q top.i_dtlb.flush_i top.i_dtlb.new_index top.i_dtlb.idx_base top.i_dtlb.lu_asid_i top.i_dtlb.vpn0 top.i_dtlb.vpn1 top.i_dtlb.tags_n top.i_dtlb.lu_is_4M_o top.i_dtlb.vaddr_vpn1_match top.i_dtlb.tags_q top.i_dtlb.rst_ni top.i_dtlb.lu_content_o top.i_dtlb.ASID_WIDTH top.i_dtlb.lu_hit top.i_dtlb.lu_vaddr_i top.i_dtlb.lu_access_i top.i_dtlb.replace_en top.i_dtlb.update_i top.i_dtlb.vaddr_to_be_flushed_is0 top.i_dtlb.shift top.i_dtlb.CVA6Cfg top.i_dtlb.plru_tree_n top.i_dtlb.asid_to_be_flushed_is0 top.i_dtlb.lu_hit_o top.i_dtlb.asid_to_be_flushed_i top.i_dtlb.plru_tree_q top.i_dtlb.en top.i_dtlb.TLB_ENTRIES top.i_dtlb.vaddr_vpn0_match {top.i_dtlb.$unit} top.i_dtlb.content_n top.i_dtlb.clk_i top.i_dtlb.vaddr_to_be_flushed_i }
gui_set_radix -radix {decimal} -signals {Sim:top.i_dtlb.ASID_WIDTH}
gui_set_radix -radix {unsigned} -signals {Sim:top.i_dtlb.ASID_WIDTH}
gui_set_radix -radix {decimal} -signals {Sim:top.i_dtlb.TLB_ENTRIES}
gui_set_radix -radix {unsigned} -signals {Sim:top.i_dtlb.TLB_ENTRIES}

set _session_group_650 $_session_group_649|
append _session_group_650 i_shared_tlb
gui_sg_create "$_session_group_650"
set i_dtlb|i_shared_tlb "$_session_group_650"

gui_sg_addsignal -group "$_session_group_650" { top.i_shared_tlb.tag_we top.i_shared_tlb.all_ways_valid top.i_shared_tlb.tlb_update_asid_q top.i_shared_tlb.pte_wr_data top.i_shared_tlb.itlb_hit_i top.i_shared_tlb.itlb_miss_o top.i_shared_tlb.shared_tlb_access_d top.i_shared_tlb.shared_tlb_update_i top.i_shared_tlb.pte_rd_addr top.i_shared_tlb.vpn1_d top.i_shared_tlb.repl_way top.i_shared_tlb.pte_addr top.i_shared_tlb.shared_tlb_access_o top.i_shared_tlb.vpn0_d top.i_shared_tlb.shared_tlb_access_q top.i_shared_tlb.pte top.i_shared_tlb.vpn1_q top.i_shared_tlb.shared_tlb_vaddr_d top.i_shared_tlb.tag_wr_data top.i_shared_tlb.vpn0_q top.i_shared_tlb.shared_tlb_hit_d top.i_shared_tlb.asid_i top.i_shared_tlb.shared_tlb_vaddr_o top.i_shared_tlb.shared_tag_valid_d top.i_shared_tlb.shared_tlb_vaddr_q top.i_shared_tlb.tag_rd_addr top.i_shared_tlb.shared_tlb_hit_o top.i_shared_tlb.dtlb_vpn_q top.i_shared_tlb.shared_tag_valid_q top.i_shared_tlb.dtlb_vaddr_i top.i_shared_tlb.update_lfsr top.i_shared_tlb.pte_wr_addr top.i_shared_tlb.inv_way top.i_shared_tlb.tag_rd_en top.i_shared_tlb.tag_addr top.i_shared_tlb.dtlb_hit_i top.i_shared_tlb.pte_rd_en top.i_shared_tlb.itlb_req_d top.i_shared_tlb.dtlb_access_i top.i_shared_tlb.dtlb_update_o top.i_shared_tlb.enable_translation_i top.i_shared_tlb.itlb_req_o top.i_shared_tlb.itlb_req_q top.i_shared_tlb.rst_ni top.i_shared_tlb.shared_tag_valid top.i_shared_tlb.pte_we top.i_shared_tlb.tag_wr_addr top.i_shared_tlb.dtlb_miss_o top.i_shared_tlb.itlb_access_i top.i_shared_tlb.itlb_update_o top.i_shared_tlb.CVA6Cfg top.i_shared_tlb.way_valid top.i_shared_tlb.pte_rd_data top.i_shared_tlb.repl_way_oh_d top.i_shared_tlb.ASID_WIDTH top.i_shared_tlb.SHARED_TLB_DEPTH top.i_shared_tlb.clk_i top.i_shared_tlb.pte_req top.i_shared_tlb.shared_tag_wr top.i_shared_tlb.tag_req top.i_shared_tlb.en_ld_st_translation_i top.i_shared_tlb.tag_wr_en top.i_shared_tlb.tag_rd_data top.i_shared_tlb.itlb_vpn_q {top.i_shared_tlb.$unit} top.i_shared_tlb.dtlb_req_d top.i_shared_tlb.pte_wr_en top.i_shared_tlb.SHARED_TLB_WAYS top.i_shared_tlb.itlb_vaddr_i top.i_shared_tlb.rnd_way top.i_shared_tlb.shared_tag_rd top.i_shared_tlb.flush_i top.i_shared_tlb.tlb_update_asid_d top.i_shared_tlb.dtlb_req_q }
gui_set_radix -radix {decimal} -signals {Sim:top.i_shared_tlb.ASID_WIDTH}
gui_set_radix -radix {twosComplement} -signals {Sim:top.i_shared_tlb.ASID_WIDTH}
gui_set_radix -radix {decimal} -signals {Sim:top.i_shared_tlb.SHARED_TLB_DEPTH}
gui_set_radix -radix {twosComplement} -signals {Sim:top.i_shared_tlb.SHARED_TLB_DEPTH}
gui_set_radix -radix {decimal} -signals {Sim:top.i_shared_tlb.SHARED_TLB_WAYS}
gui_set_radix -radix {twosComplement} -signals {Sim:top.i_shared_tlb.SHARED_TLB_WAYS}

set _session_group_651 $_session_group_649|
append _session_group_651 i_itlb
gui_sg_create "$_session_group_651"
set i_dtlb|i_itlb "$_session_group_651"

gui_sg_addsignal -group "$_session_group_651" { {top.i_itlb.unnamed$$_4} {top.i_itlb.unnamed$$_6} {top.i_itlb.p_assertions.unnamed$$_0} {top.i_itlb.p_assertions.unnamed$$_1} top.i_itlb.content_q top.i_itlb.flush_i top.i_itlb.new_index top.i_itlb.idx_base top.i_itlb.lu_asid_i top.i_itlb.vpn0 top.i_itlb.vpn1 top.i_itlb.tags_n top.i_itlb.lu_is_4M_o top.i_itlb.vaddr_vpn1_match top.i_itlb.tags_q top.i_itlb.rst_ni top.i_itlb.lu_content_o top.i_itlb.ASID_WIDTH top.i_itlb.lu_hit top.i_itlb.lu_vaddr_i top.i_itlb.lu_access_i top.i_itlb.replace_en top.i_itlb.update_i top.i_itlb.vaddr_to_be_flushed_is0 top.i_itlb.shift top.i_itlb.CVA6Cfg top.i_itlb.plru_tree_n top.i_itlb.asid_to_be_flushed_is0 top.i_itlb.lu_hit_o top.i_itlb.asid_to_be_flushed_i top.i_itlb.plru_tree_q top.i_itlb.en top.i_itlb.TLB_ENTRIES top.i_itlb.vaddr_vpn0_match {top.i_itlb.$unit} top.i_itlb.content_n top.i_itlb.clk_i top.i_itlb.vaddr_to_be_flushed_i }
gui_set_radix -radix {decimal} -signals {Sim:top.i_itlb.ASID_WIDTH}
gui_set_radix -radix {unsigned} -signals {Sim:top.i_itlb.ASID_WIDTH}
gui_set_radix -radix {decimal} -signals {Sim:top.i_itlb.TLB_ENTRIES}
gui_set_radix -radix {unsigned} -signals {Sim:top.i_itlb.TLB_ENTRIES}

gui_sg_move "$_session_group_651" -after "$_session_group_649" -pos 33 

set _session_group_652 comb_tlb_vif
gui_sg_create "$_session_group_652"
set comb_tlb_vif "$_session_group_652"

gui_sg_addsignal -group "$_session_group_652" { top.comb_tlb_vif.dtlb_vaddr_i top.comb_tlb_vif.itlb_update_io top.comb_tlb_vif.dtlb_update_io top.comb_tlb_vif.rst_ni top.comb_tlb_vif.asid_i top.comb_tlb_vif.itlb_lu_hit_o top.comb_tlb_vif.dtlb_lu_hit_o top.comb_tlb_vif.itlb_vaddr_i top.comb_tlb_vif.itlb_lu_access_i top.comb_tlb_vif.flush_tlb_i top.comb_tlb_vif.dtlb_lu_access_i {top.comb_tlb_vif.$unit} top.comb_tlb_vif.clk_i }

set _session_group_653 $_session_group_652|
append _session_group_653 shared_tlb_vif
gui_sg_create "$_session_group_653"
set comb_tlb_vif|shared_tlb_vif "$_session_group_653"

gui_sg_addsignal -group "$_session_group_653" { top.shared_tlb_vif.shared_tlb_update_i top.shared_tlb_vif.enable_translation_i top.shared_tlb_vif.itlb_miss_o top.shared_tlb_vif.shared_tlb_hit_o top.shared_tlb_vif.shared_tlb_access_o top.shared_tlb_vif.shared_tlb_vaddr_o top.shared_tlb_vif.en_ld_st_translation_i top.shared_tlb_vif.itlb_req_o top.shared_tlb_vif.dtlb_miss_o {top.shared_tlb_vif.$unit} top.shared_tlb_vif.clk_i }

set _session_group_654 i_dtlb_1
gui_sg_create "$_session_group_654"
set i_dtlb_1 "$_session_group_654"

gui_sg_addsignal -group "$_session_group_654" { top.i_dtlb.lu_access_i top.i_dtlb.lu_vaddr_i top.i_dtlb.update_i top.i_dtlb.lu_is_4M_o top.i_dtlb.lu_content_o top.i_dtlb.lu_hit_o }

set _session_group_655 i_itlb
gui_sg_create "$_session_group_655"
set i_itlb "$_session_group_655"

gui_sg_addsignal -group "$_session_group_655" { top.i_itlb.lu_asid_i top.i_itlb.lu_vaddr_i top.i_itlb.update_i top.i_itlb.clk_i top.i_itlb.rst_ni top.i_itlb.flush_i top.i_itlb.lu_access_i top.i_itlb.lu_content_o top.i_itlb.lu_hit_o top.i_itlb.asid_to_be_flushed_i top.i_itlb.vaddr_to_be_flushed_i top.i_itlb.lu_is_4M_o }

set _session_group_656 i_shared_tlb
gui_sg_create "$_session_group_656"
set i_shared_tlb "$_session_group_656"

gui_sg_addsignal -group "$_session_group_656" { top.i_shared_tlb.itlb_access_i top.i_shared_tlb.itlb_req_o top.i_shared_tlb.en_ld_st_translation_i top.i_shared_tlb.dtlb_vaddr_i top.i_shared_tlb.dtlb_access_i top.i_shared_tlb.dtlb_hit_i top.i_shared_tlb.dtlb_miss_o top.i_shared_tlb.dtlb_update_o top.i_shared_tlb.enable_translation_i top.i_shared_tlb.shared_tlb_access_o top.i_shared_tlb.shared_tlb_update_i top.i_shared_tlb.shared_tlb_hit_o top.i_shared_tlb.shared_tlb_vaddr_o top.i_shared_tlb.itlb_vaddr_i top.i_shared_tlb.itlb_hit_i top.i_shared_tlb.itlb_miss_o top.i_shared_tlb.itlb_update_o }

set _session_group_657 tlb_vif
gui_sg_create "$_session_group_657"
set tlb_vif "$_session_group_657"

gui_sg_addsignal -group "$_session_group_657" { top.tlb_vif.lu_is_4M_dtlb_o top.tlb_vif.lu_is_4M_itlb_o top.tlb_vif.lu_content_dtlb_o top.tlb_vif.asid_to_be_flushed_i {top.tlb_vif.$unit} top.tlb_vif.lu_content_itlb_o top.tlb_vif.clk_i top.tlb_vif.vaddr_to_be_flushed_i }

set _session_group_658 $_session_group_657|
append _session_group_658 comb_tlb_vif
gui_sg_create "$_session_group_658"
set tlb_vif|comb_tlb_vif "$_session_group_658"

gui_sg_addsignal -group "$_session_group_658" { top.comb_tlb_vif.dtlb_vaddr_i top.comb_tlb_vif.itlb_update_io top.comb_tlb_vif.dtlb_update_io top.comb_tlb_vif.rst_ni top.comb_tlb_vif.asid_i top.comb_tlb_vif.itlb_lu_hit_o top.comb_tlb_vif.dtlb_lu_hit_o top.comb_tlb_vif.itlb_vaddr_i top.comb_tlb_vif.itlb_lu_access_i top.comb_tlb_vif.flush_tlb_i top.comb_tlb_vif.dtlb_lu_access_i {top.comb_tlb_vif.$unit} top.comb_tlb_vif.clk_i }

set _session_group_659 shared_tlb_vif
gui_sg_create "$_session_group_659"
set shared_tlb_vif "$_session_group_659"

gui_sg_addsignal -group "$_session_group_659" { top.shared_tlb_vif.shared_tlb_update_i top.shared_tlb_vif.enable_translation_i top.shared_tlb_vif.itlb_miss_o top.shared_tlb_vif.shared_tlb_hit_o top.shared_tlb_vif.shared_tlb_access_o top.shared_tlb_vif.shared_tlb_vaddr_o top.shared_tlb_vif.en_ld_st_translation_i top.shared_tlb_vif.itlb_req_o top.shared_tlb_vif.dtlb_miss_o {top.shared_tlb_vif.$unit} top.shared_tlb_vif.clk_i }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 1030



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 0 1410
gui_list_add_group -id ${Wave.1} -after {New Group} {i_shared_tlb}
gui_list_add_group -id ${Wave.1} -after {New Group} {i_itlb}
gui_list_add_group -id ${Wave.1} -after {New Group} {i_dtlb_1}
gui_list_select -id ${Wave.1} {top.i_shared_tlb.itlb_vaddr_i }
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group i_itlb  -item top.i_itlb.lu_content_o -position below

gui_marker_move -id ${Wave.1} {C1} 1030
gui_view_scroll -id ${Wave.1} -vertical -set 306
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

