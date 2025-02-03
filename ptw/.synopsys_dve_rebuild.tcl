# DVE Simulation Rebuild/Restart Options
# Saved on Wed Feb 28 15:27:43 2024
set SIMSETUP::REBUILDOPTION 1
set SIMSETUP::REBUILDCMD {vcs -lca -debug_access+all -sverilog -timescale=1ns/1ns -ntb_opts uvm-1.2 +incdir+/home/user1/docker/OpenHW/cva6_work/MMU_verif/ptw/mmu_sv32/ ./tb_top.sv
}
set SIMSETUP::REBUILDDIR {}
set SIMSETUP::RESTOREBP 1
set SIMSETUP::RESTOREDUMP 1
set SIMSETUP::RESTOREFORCE 1
set SIMSETUP::RESTORESPECMAN 0
