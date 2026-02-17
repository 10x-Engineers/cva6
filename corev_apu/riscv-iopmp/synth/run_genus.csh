#!/bin/csh
set prompt = "%"
echo "Script is running!"
echo "Arguments: $argv"

if ($#argv < 2) then
    echo "Usage: run_genus.csh <config_folder> <synth_arg>"
    exit 1
endif

set CONFIG = $1
set SYNTH_ARG = $2

# echo "===> Sourcing cshrc"
# Source cshrc located two directories above run_genus.csh
source ../../cshrc

# echo "===> Moving into config folder: $CONFIG"
cd $CONFIG

# echo "PATH is: $PATH"
# echo "which genus: `which genus`"
# echo "Running genus with argument: $SYNTH_ARG"

# echo "===> Starting genus..."
genus -f scripts/script.tcl -execute "set argv $SYNTH_ARG"

# echo "===> Done. Starting new csh shell..."
# exec csh
