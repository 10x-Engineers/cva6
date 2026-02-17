# =====================================================
# JasperGold Lint Run Script
# To run the script type this command on shell: 
# jaspergold -batch -tcl run_lint.tcl
# =====================================================
# Read in RTL (SystemVerilog/Verilog)
analyze -sv -f flist_rtl.f

# Set top module
set design_top iopmp

# Elaborate design
elaborate

exit