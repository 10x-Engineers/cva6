# DVE Simulation Rebuild/Restart Options
# Saved on Tue Feb 6 16:43:54 2024
set SIMSETUP::REBUILDOPTION 1
set SIMSETUP::REBUILDCMD {vcs -lca -debug_access+all -sverilog -timescale=1ns/1ns -ntb_opts uvm-1.2 +incdir+/home/user101/docker/OpenHW/MMU_verif/mmu_sv32/ ./tb_top.sv}
set SIMSETUP::REBUILDDIR {}
set SIMSETUP::RESTOREBP 1
set SIMSETUP::RESTOREDUMP 1
set SIMSETUP::RESTOREFORCE 1
set SIMSETUP::RESTORESPECMAN 0
