CONFIGS := config1 config2 config3 config4 config5

.PHONY: run_synthesis

run_synthesis:
	@echo "Enter a short description of your design changes:"; \
	read DESCRIPTION; \
	echo ""; \
	echo "Enter synthesis argument (choose one): IOPMP, RAP, TTU, RFM, MATCH_ENTRY, MRM, SRM, EIC"; \
	read SYNTH_ARG; \
	VALID_ARGS="IOPMP RAP TTU RFM MATCH_ENTRY MRM SRM EIC"; \
	if ! echo $$VALID_ARGS | grep -wq $$SYNTH_ARG; then \
		echo "? Error: Invalid synthesis argument '$$SYNTH_ARG'"; \
		echo "Please run 'make run_synthesis' again and choose a valid argument."; \
		exit 1; \
	fi; \
	PROJECT_DIR=$$(cd .. && pwd); \
	SYNTH_DIR=$$(pwd); \
	TIMESTAMP=$$(date +"%Y-%m-%d_%H-%M-%S"); \
	OUTPUT_DIR="$$SYNTH_DIR/synthesis_reports_$$TIMESTAMP"; \
	mkdir -p "$$OUTPUT_DIR"; \
	{ \
		echo "[$$(date +"%Y-%m-%d %H:%M:%S")] $$DESCRIPTION"; \
		echo ""; \
		echo "Synthesis argument used: $$SYNTH_ARG"; \
	} >> "$$OUTPUT_DIR/design_changes_record.txt"; \
	echo "? Launching synthesis in new terminals with argument '$$SYNTH_ARG'..."; \
	for CONFIG in $(CONFIGS); do \
		gnome-terminal --title="$$CONFIG" -- bash -c "cd '$$SYNTH_DIR'; csh -i -c './run_genus.csh $$CONFIG $$SYNTH_ARG'; exec bash"; \
	done; \
	echo ""; \
	read -p "? Press ENTER when all synthesis runs have completed..." DUMMY; \
	echo "? Collecting reports from config folders..."; \
	for CONFIG in $(CONFIGS); do \
		SRC_DIR="$$SYNTH_DIR/$$CONFIG"; \
		DEST_DIR="$$OUTPUT_DIR/$$CONFIG"; \
		mkdir -p "$$DEST_DIR"; \
		if [ -d "$$SRC_DIR/$$SYNTH_ARG"_outputs ]; then \
			cp -r "$$SRC_DIR/$$SYNTH_ARG"_outputs "$$DEST_DIR/"; \
		else \
			echo "??  Warning: $$SRC_DIR/$$SYNTH_ARG"_outputs "not found"; \
		fi; \
		if [ -d "$$SRC_DIR/$$SYNTH_ARG"_reports ]; then \
			cp -r "$$SRC_DIR/$$SYNTH_ARG"_reports "$$DEST_DIR/"; \
		else \
			echo "??  Warning: $$SRC_DIR/$$SYNTH_ARG"_reports "not found"; \
		fi; \
		if [ -f "$$SRC_DIR/genus.log" ]; then \
			cp "$$SRC_DIR/genus.log" "$$DEST_DIR/"; \
		else \
			echo "??  Warning: $$SRC_DIR/genus.log not found"; \
		fi; \
	done; \
	echo ""; \
	read -p "? Do you want to clean synthesis-generated files from config folders? (y/n): " CONFIRM_CLEAN; \
	if [ "$$CONFIRM_CLEAN" = "y" ] || [ "$$CONFIRM_CLEAN" = "Y" ]; then \
	  echo "? Cleaning synthesis-generated files from config folders..."; \
	  for CONFIG in $(CONFIGS); do \
	    echo "Cleaning $$CONFIG..."; \
	    find "$$SYNTH_DIR/$$CONFIG"/* \
	      ! -path "$$SYNTH_DIR/$$CONFIG/scripts" \
	      ! -path "$$SYNTH_DIR/$$CONFIG/scripts/*" \
	      ! -name "Makefile" \
	      ! -name "config_iopmp_pkg.sv" \
	      -exec rm -rf {} +; \
	  done; \
	  \
	  echo "? Deleting *.tstamp files from config folders..."; \
	  for CONFIG in $(CONFIGS); do \
	    find "$$SYNTH_DIR/$$CONFIG" -type f -name "*.tstamp" -exec rm -f {} +; \
	  done; \
	  \
		echo "? Removing .st_launch* and .pbs_localhost.* folders..."; \
		for CONFIG in $(CONFIGS); do \
			find "$$SYNTH_DIR/$$CONFIG" -maxdepth 1 -type d -name ".st_launch*" -exec rm -rf {} +; \
			find "$$SYNTH_DIR/$$CONFIG" -maxdepth 1 -type d -name ".pbs_localhost.*" -exec rm -rf {} +; \
		done; \
		\
		echo "? Cleanup completed."; \
	else \
	  echo "? Skipping cleanup."; \
	fi; \
	echo ""; \
	echo "? All reports collected in: $$OUTPUT_DIR"; \
	echo "? Design change recorded in: $$OUTPUT_DIR/design_changes_record.txt"

