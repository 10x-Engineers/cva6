#Reading lib and hdl files
read_libs /work/Ahmar-10x/lib/tcbn12ffcllbwp16p90ssgnp0p9v125c_ccs.lib
set RAP "scripts/flist_Synthesis_RAP.f"
set MATCH_ENTRY "scripts/flist_Synthesis_MATCHENTRY.f"
set TTU "scripts/flist_Synthesis_TTU.f"
set RFM "scripts/flist_Synthesis_RFM.f"
set IOPMP "scripts/flist_Synthesis.f"
set MRM "scripts/flist_master_req_manager.f"
set SRM "scripts/flist_slave_req_manager.f"
set EIC "scripts/flist_eic.f"
set arg0 [lindex $argv 0]
if {$arg0 eq "RAP"} {
    set value $RAP
} elseif {$arg0 eq "MATCH_ENTRY"} {
    set value $MATCH_ENTRY
} elseif {$arg0 eq "TTU"} {
    set value $TTU
} elseif {$arg0 eq "RFM"} {
    set value $RFM
} elseif {$arg0 eq "IOPMP"} {
    set value $IOPMP
} elseif {$arg0 eq "MRM"} {
    set value $MRM
} elseif {$arg0 eq "SRM"} {
    set value $SRM
} elseif {$arg0 eq "EIC"} {
    set value $EIC
} else {
    puts "Error: '$arg0' does not match RAP,MATCH_ENTRY,TTU,RFM,MRM,EIC or IOPMP"
    exit 1
}
read_hdl -define "CFG_IOPMP_SRCMD_FMT_0 CFG_IOPMP_MDCFG_FMT_0" -sv -f $value
set PREFIX $arg0

#elaborate the design
elaborate

#Set top module
if {$arg0 eq "RAP"} {
    set_top_module rule_analyzer_pipeline
} elseif {$arg0 eq "MATCH_ENTRY"} {
    set_top_module match_entry
} elseif {$arg0 eq "TTU"} {
    set_top_module table_traversal_unit
} elseif {$arg0 eq "RFM"} {
    set_top_module register_file_manager
} elseif {$arg0 eq "IOPMP"} {
    set_top_module iopmp
} elseif {$arg0 eq "MRM"} {
    set_top_module master_req_mgr
} elseif {$arg0 eq "SRM"} {
    set_top_module slave_req_mgr
} elseif {$arg0 eq "EIC"} {
    set_top_module eic_block
} else {
    puts "Error: '$arg0' does not match RAP,MATCH_ENTRY,TTU,RFM,MRM,EIC or IOPMP"
    exit 1
}
#Reading constraint file
read_sdc ../constraints.sdc

#set_db tns_opto true
set_db information_level 3
#Setting top module
#check_timing_intent

#Setting synthesis efforts
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

#Synthesizing,mapping and optimizing the design
syn_generic
syn_map
syn_opt

#retime -min_delay -effort high
#Generating reports
report_sequential -deleted > ${PREFIX}_reports/seq_del.rpt
report_timing > ${PREFIX}_reports/timing.rpt
report_power > ${PREFIX}_reports/power.rpt
report_area -detail > ${PREFIX}_reports/area.rpt
report_qor > ${PREFIX}_reports/qor.rpt
report_logic_levels > ${PREFIX}_reports/logic_levels.rpt
report gates > ${PREFIX}_reports/gates.rpt
report_logic_levels_histogram -threshold 30 -details > ${PREFIX}_reports/high_level_paths.rpt

#Generating outputs
write_hdl > ${PREFIX}_outputs/netlist.v
write_sdc > ${PREFIX}_outputs/design_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > ${PREFIX}_outputs/delays.sdf
