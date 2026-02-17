
ver =
cov =
cov_def =

SRC := $(PWD)/../../design/rtl
VLIB := $(PWD)/vlib
SRC_gen := $(PWD)/design/rtl
VLIB_gen := $(PWD)/vlib
DPI_DIR := $(PWD)/../iopmp_ref_model/src
DPI_DIR_VERIF := $(PWD)/../iopmp_ref_model/verif

Regression         ?= Regression
Regres_fmt         ?= fmt_${fmt}
XRUN               ?= xrun
XRUN_WORK_DIR      ?= xrun_work
XRUN_RESULTS_DIR   ?= xrun_results
XRUN_UVMHOME_ARG   ?= CDNS-1.2-ML
XRUN_COMPL_LOG     ?= xrun_compl.log
XRUN_COMPL_LOG_GEN ?= comp_${Regression}_${fmt}
XRUN_RUN_LOG_GEN   ?= sim_${Regression}_${fmt}
XRUN_RUN_LOG       ?= $(test).log
# Tools
VERILATOR ?= verilator
#CVA6_HOME	   ?= $(realpath -s $(root-dir))
top_level	   ?= iopmp
max_cycles	   ?= 100000
test	  	   ?=
srcmd_fmt	   ?=
mdcfg_fmt      ?=
fmt   		   ?= 0
gen_test	   ?= read_perm_read_transac_test
md_imp		   ?=
r_perm		   ?=
w_perm		   ?=
x_perm		   ?=
ad_mode		   ?=
t_type		   ?=
mdcfg_improper_a			?=
r_perm_a					?=
w_perm_a					?=
x_perm_a					?=
ad_mode_a					?=
t_type_a					?=
repeat						?=
cfg_intr_en					?= 1
cfg_err_sup					?= 0
cfg_msi_en					?= 0
cfg_stall_voi_en			?= 0
cfg_msi_data				?= 0

# For direct
md_improper    ?= md_improper
md_proper   ?= md_proper

# Number of times to repeat each simulation
repeat_count=3
# Parameter sweeps
mdcfg_improper_list= 0
r_perm_list= 0 1
w_perm_list= 0 1
x_perm_list= 0 1
ad_mode_list= 0 1 2 3
t_type_list= 0 1 2

FLIST ?= flist_rtl.f
VERILATOR_FLAGS := --sv --lint-only -Wall -Wno-fatal
TOP ?= iopmp
LINT_RPT ?= lint.rpt

# Path to template file
TEMPLATE=${PWD}/test/general_tests/read_perm_read_transac_test.sv

# Output directory
OUTDIR=/work/faayez-iopmp/riscv-iopmp/verif/iopmp_top/test/general_tests/generated_tests/Addr_Mode

# Make sure output dir exists

ifeq ($(fmt),0)
	srcmd_fmt =	+define+CFG_IOPMP_SRCMD_FMT_0
	mdcfg_fmt =	+define+CFG_IOPMP_MDCFG_FMT_0
endif

ifeq ($(fmt),1)
	srcmd_fmt =	+define+CFG_IOPMP_SRCMD_FMT_0
	mdcfg_fmt =	+define+CFG_IOPMP_MDCFG_FMT_1
endif

ifeq ($(fmt),2)
	srcmd_fmt =	+define+CFG_IOPMP_SRCMD_FMT_0
	mdcfg_fmt =	+define+CFG_IOPMP_MDCFG_FMT_2
endif

ifeq ($(fmt),3)
	srcmd_fmt =	+define+CFG_IOPMP_SRCMD_FMT_1
	mdcfg_fmt =	+define+CFG_IOPMP_MDCFG_FMT_0
endif

ifeq ($(fmt),4)
	srcmd_fmt =	+define+CFG_IOPMP_SRCMD_FMT_1
	mdcfg_fmt =	+define+CFG_IOPMP_MDCFG_FMT_1
endif

ifeq ($(fmt),5)
	srcmd_fmt =	+define+CFG_IOPMP_SRCMD_FMT_1
	mdcfg_fmt =	+define+CFG_IOPMP_MDCFG_FMT_2
endif

ifeq ($(fmt),6)
	srcmd_fmt =	+define+CFG_IOPMP_SRCMD_FMT_2
	mdcfg_fmt =	+define+CFG_IOPMP_MDCFG_FMT_0
endif

ifeq ($(fmt),7)
	srcmd_fmt =	+define+CFG_IOPMP_SRCMD_FMT_2
	mdcfg_fmt =	+define+CFG_IOPMP_MDCFG_FMT_1
endif

ifeq ($(fmt),8)
	srcmd_fmt =	+define+CFG_IOPMP_SRCMD_FMT_2
	mdcfg_fmt =	+define+CFG_IOPMP_MDCFG_FMT_2
endif


ifeq ($(mdcfg_improper_a),1)
	md_imp =	+define+CFG_MDCFG_IMP
endif

ifeq ($(r_perm_a),1)
	r_perm =	+define+CFG_R_PERM
endif

ifeq ($(w_perm_a),1)
	w_perm =	+define+CFG_W_PERM
endif

ifeq ($(x_perm_a),1)
	x_perm =	+define+CFG_X_PERM
endif

ifeq ($(ad_mode_a),0)
	ad_mode =	+define+CFG_AD_MODE_OFF
endif

ifeq ($(ad_mode_a),1)
	ad_mode =	+define+CFG_AD_MODE_TOR
endif

ifeq ($(ad_mode_a),2)
	ad_mode =	+define+CFG_AD_MODE_NA
endif

ifeq ($(ad_mode_a),3)
	ad_mode =	+define+CFG_AD_MODE_NAPOT
endif

ifeq ($(t_type_a),0)
	t_type =	+define+CFG_TN_0
endif

ifeq ($(t_type_a),1)
	t_type =	+define+CFG_TN_1
endif

ifeq ($(t_type_a),2)
	t_type =	+define+CFG_TN_2
endif
ifeq ($(cfg_intr_en),1)
	t_type =	+define+CFG_INTR_EN
endif
ifeq ($(cfg_err_sup),1)
	t_type =	+define+CFG_ERR_SUP
endif
ifeq ($(cfg_msi_en),1)
	t_type =	+define+CFG_MSI_EN
endif
ifeq ($(cfg_stall_voi_en),1)
	t_type =	+define+CFG_STALL_VOI_EN
endif
ifeq ($(cfg_msi_data),1)
	t_type =	+define+CFG_MSI_DATA
endif



DPI_SOURCES :=  $(DPI_DIR)/iopmp_reg.c \
				$(DPI_DIR)/iopmp_interrupt.c \
            	$(DPI_DIR)/iopmp_rule_analyzer.c \
            	$(DPI_DIR)/iopmp_validate.c \
            	$(DPI_DIR)/iopmp_error_capture.c \
				$(DPI_DIR_VERIF)/test_utils.c

XRUN_COMP_FLAGS  ?= -64bit -disable_sem2009 -access +rwc 			\
			-sv -v93 -uvm -uvmhome $(XRUN_UVMHOME_ARG) \
			-smartorder -sv -g -timescale 1ns/1ps -dpi -snsvdpi #-top worklib.$(top_level)			\
			+define+-xceligen on=1903 -timescale 1ns/1ps	\

ifeq ($(gui),1)
	GUI := -gui -input $(PWD)/probes.tcl
endif

XRUN_RUN_FLAGS := -R -64bit -disable_sem2009 -access +rwc \
		$(GUI) \
		-timescale 1ns/1ps		\
		-xceligen on=1903	\

XRUN_DISABLED_WARNINGS := BIGWIX 	\
			ZROMCW 		\
			STRINT 		\
			ENUMERR 	\
			SPDUSD		\
			RNDXCELON

XRUN_DISABLED_WARNINGS 	:= $(patsubst %, -nowarn %, $(XRUN_DISABLED_WARNINGS))

XRUN_COMP = $(XRUN_COMP_FLAGS)		\
	$(XRUN_DISABLED_WARNINGS) 	\
	-f $(VLIB)/flist_rtl.f 	    \
	-f $(VLIB)/flist_tb.f \
	-sysv $(DPI_SOURCES) \

XRUN_COMP_GEN = $(XRUN_COMP_FLAGS)		\
	$(XRUN_DISABLED_WARNINGS) 	\
	-f $(VLIB_gen)/flist_rtl.f 	    \
	-f $(VLIB_gen)/flist_tb.f \
	-sysv $(DPI_SOURCES) \

#	$(filter %.sv, $(XRUN_TB))	\

XRUN_RUN = $(XRUN_RUN_FLAGS) 		\
	$(XRUN_DISABLED_WARNINGS)	\

xrun_clean:
	@echo "[XRUN] clean up"
	rm -rf $(XRUN_RESULTS_DIR)
	rm -rf $(dpi-library)

xrun_clean_gen:
	@echo "[XRUN] clean up"
	rm -rf $(Regression)
	rm -rf $(dpi-library)

xrun_comp:
	@echo "[XRUN] Building Model"
	@echo $(SRC)
	mkdir -p $(XRUN_RESULTS_DIR)
	cd $(XRUN_RESULTS_DIR) && $(XRUN)   \
		+permissive		    \
		${srcmd_fmt}				\
		${mdcfg_fmt}				\
		$(XRUN_COMP)                \
		-l $(XRUN_COMPL_LOG)        \
		+permissive-off		    \
		-elaborate				\
		-coverage all -covoverwrite \

xrun_sim:
	@echo "[XRUN] Simulating selected binary"
	cd $(XRUN_RESULTS_DIR) && mkdir $(test) && $(XRUN)	\
		+permissive			\
		$(XRUN_RUN)			\
		+MAX_CYCLES=$(max_cycles)	\
		+UVM_TESTNAME=$(test)	\
		-l ./$(test)/$(XRUN_RUN_LOG)		\
		+permissive-off			\
		++$(elf_file); \
		mv cov_work $(test); \

xrun_comp_gen:
	cd $(Regression) && $(XRUN) \
								+permissive \
								${srcmd_fmt} \
								${mdcfg_fmt} \
								${ad_mode} \
								${r_perm} \
								${w_perm} \
								${x_perm} \
								${md_imp} \
								${t_type} \
								$(XRUN_COMP_GEN) \
								-l ./$(Regres_fmt)/$(md_proper)/$(XRUN_COMPL_LOG_GEN)_$(ad_mode_a)_$(r_perm_a)_$(w_perm_a)_$(x_perm_a)_$(t_type_a)_$(mdcfg_improper_a).log \
								+permissive-off \
								-elaborate \
								-coverage all -covoverwrite; \
								cd ./../; \

xrun_sim_gen:
	mkdir -p ./$(Regression)/$(Regres_fmt)/$(md_proper)/$(XRUN_RUN_LOG_GEN)_$(ad_mode_a)_$(r_perm_a)_$(w_perm_a)_$(x_perm_a)_$(t_type_a)_$(mdcfg_improper_a)/$(gen_test)_$(repeat); \
	cd $(Regression) && $(XRUN) \
								+permissive \
								$(XRUN_RUN) \
								+MAX_CYCLES=$(max_cycles)	\
								+UVM_TESTNAME=$(gen_test) \
								-l ./$(Regres_fmt)/$(md_proper)/$(XRUN_RUN_LOG_GEN)_$(ad_mode_a)_$(r_perm_a)_$(w_perm_a)_$(x_perm_a)_$(t_type_a)_$(mdcfg_improper_a)/$(gen_test)_$(repeat).log \
								+permissive-off \
								++$(elf_file) && mv cov_work ./$(Regres_fmt)/$(md_proper)/$(XRUN_RUN_LOG_GEN)_$(ad_mode_a)_$(r_perm_a)_$(w_perm_a)_$(x_perm_a)_$(t_type_a)_$(mdcfg_improper_a)/$(gen_test)_$(repeat); \
								cd ./../; \

iopmp_test_clean:
	rm -rf ${OUTDIR}
iopmp_test: xrun_clean_gen
	rm -rf ${OUTDIR}
	@mkdir -p $(OUTDIR)
	@mkdir -p $(Regression)/$(Regres_fmt)/$(md_proper)
	@mkdir -p $(Regression)/$(Regres_fmt)/$(md_improper)
	@echo "[INFO] Starting regression in $(Regression)/$(Regres_fmt)/$(md_proper)"
	@echo "[INFO] Starting regression in $(Regression)/$(Regres_fmt)/$(md_improper)"
	@for ad in $(ad_mode_list); do \
		for r in $(r_perm_list); do \
			for w in $(w_perm_list); do \
				for x in $(x_perm_list); do \
					for mdcfg in $(mdcfg_improper_list); do \
						for t in $(t_type_list); do \
							TEST_FILE_NAME=test_ad$${ad}_r$${r}_w$${w}_x$${x}_md$${mdcfg}_t$${t}; \
							OUTFILE=$(OUTDIR)/$${TEST_FILE_NAME}.sv; \
							SVHFILE=$(PWD)/SVHFILE.sv; \
							SIMFILE=$(PWD)/SIMFILE.sv; \
							sed \
								-e "s/CFG_R_PERM/$$r/g" \
								-e "s/CFG_W_PERM/$$w/g" \
								-e "s/CFG_X_PERM/$$x/g" \
								-e "s/CFG_AD_MODE/$$ad/g" \
								-e "s/CFG_TN/$$t/g" \
								-e "s/CFG_MDCFG_IMP/$$mdcfg/g" \
								-e "s/CFG_INTR_EN/${cfg_intr_en}/g" \
								-e "s/CFG_ERR_SUP/${cfg_err_sup}/g" \
								-e "s/CFG_MSI_EN/${cfg_msi_en}/g" \
								-e "s/CFG_STALL_VOI_EN/${cfg_stall_voi_en}/g" \
								-e "s/CFG_MSI_DATA/${cfg_msi_data}/g" \
								-e "s/TEST_NAME/$${TEST_FILE_NAME}/g" \
								$(TEMPLATE) > $$OUTFILE; \
							echo "\`include \"/generated_tests/Addr_Mode/$${TEST_FILE_NAME}.sv\"" >> $$SVHFILE; \
							echo "make xrun sim test=$$TEST_FILE_NAME" >> $$SIMFILE; \
						done; \
					done; \
				done; \
			done; \
		done; \
	done

sanity_test:
	make xrun_clean
	make xrun_comp fmt=0
	make format0_default

full_model:
	make xrun_clean
	make xrun_comp fmt=0
	make sanity_tests


rapid_k_model:
	make xrun_clean
	make xrun_comp fmt=1
	make sanity_tests

dynamic_k_model:
	make xrun_clean
	make xrun_comp fmt=2
	make sanity_tests

isolation_model:
	make xrun_clean
	make xrun_comp fmt=3
	make sanity_tests

compact_k_model:
	make xrun_clean
	make xrun_comp fmt=4
	make sanity_tests

unnamed_model_1:
	make xrun_clean
	make xrun_comp fmt=5
	make sanity_tests

unnamed_model_2:
	make xrun_clean
	make xrun_comp fmt=6
	make sanity_tests

unnamed_model_3:
	make xrun_clean
	make xrun_comp fmt=7
	make sanity_tests

unnamed_model_4:
	make xrun_clean
	make xrun_comp fmt=8
	make sanity_tests

include Makefile_tests

ifeq ($(ver),1)

all: run clean
.PHONY: all
RTL     := rtl
TB      := verif
COMP_OPT += +vcs+lic+wait
COMP_OPT += -debug_access+all +vpi -kdb -lca -fsdb -DVCS -LDFLAGS
COMP_OPT += -full64 -q
COMP_OPT += -timescale=1ns/1ns	+warn=none
COMP_OPT +=  -ntb_opts uvm-1.2 -sverilog
COMP_OPT += -l comp.log
COMP_OPT += +lint=TFIPC-L +vcs+vcdpluson

SIM_OPT += -l sim.log
SIM_OPT += +vcs+initreg+0

ifeq ($(cov),1)
	COMP_OPT += -cm line+cond+fsm+tgl+branch
	cov_def = +define+COV_EN
endif

run: compile sim
run_gen: compile_gen sim
compile:
	vcs ${COMP_OPT} ${cov_def} -f $(VLIB)/flist_rtl.f -f $(VLIB)/flist_tb.f
compile_gen:
	vcs ${COMP_OPT} ${cov_def} -f $(VLIB_gen)/flist_rtl.f -f $(VLIB_gen)/flist_tb.f

sim:
	./simv $(SIM_OPT) +UVM_TESTNAME=my_test +UVM_VERBOSITY=UVM_LOW
endif

clean:
	rm -rf *.vdb csrc *.daidir *.h novas.* *.log *.simv *.fsdb waves.* *.dump verdiLog simvs obj_dir *.vpd $(LINT_RPT)

report:
	@echo "Generating final UVM test report..."
	@pass=0; fail=0; \
	for f in $(PWD)/xrun_results/*/*.log; do \
		test_name=$$(basename $$f .log); \
		scoreboard_status=$$(grep -oE "Scoreboard status: (0|1)" $$f | awk -F':' '{ print $$0}'); \
		design_status=$$(grep -oE "Design status: (0|1|2)" $$f | awk -F':' '{print $$0}'); \
		uvm_error=$$(grep -w "UVM_ERROR" $$f | tail -1 | awk -F':' '{gsub(/ /, "", $$2); print $$2}'); \
		uvm_fatal=$$(grep -w "UVM_FATAL" $$f | tail -1 | awk -F':' '{gsub(/ /, "", $$2); print $$2}'); \
		if [ "$$uvm_error" = "" ]; then uvm_error=0; fi; \
		if [ "$$uvm_fatal" = "" ]; then uvm_fatal=0; fi; \
		if [ "$$uvm_error" = "0" ] && [ "$$uvm_fatal" = "0" ]; then \
			echo "✅ $$test_name: PASS								($$scoreboard_status & $$design_status)"; \
			pass=$$((pass+1)); \
		else \
			echo "❌ $$test_name: FAIL (UVM_ERROR=$$uvm_error, UVM_FATAL=$$uvm_fatal)				($$scoreboard_status & $$design_status)"; \
			fail=$$((fail+1)); \
		fi; \
	done; \
	total=$$((pass+fail)); \
	echo "-----------------------------------------"; \
	echo "Summary: $$pass / $$total tests passed."; \
	if [ "$$fail" -eq 0 ]; then echo "? All tests passed!"; else echo "??  $$fail test(s) failed."; fi

report_gen:
	@echo "Generating final UVM test report for Random-Constraints Test cases..."
	@pass=0; fail=0; \
	for f in $(PWD)/Regression/*/*/*/*.log; do \
		test_name=$$(basename $$f .log); \
		scoreboard_status=$$(grep -oE "Scoreboard status: (0|1)" $$f | awk -F':' '{ print $$0}'); \
		design_status=$$(grep -oE "Design status: (0|1|2)" $$f | awk -F':' '{print $$0}'); \
		uvm_error=$$(grep -w "UVM_ERROR" $$f | tail -1 | awk -F':' '{gsub(/ /, "", $$2); print $$2}'); \
		uvm_fatal=$$(grep -w "UVM_FATAL" $$f | tail -1 | awk -F':' '{gsub(/ /, "", $$2); print $$2}'); \
		if [ "$$uvm_error" = "" ]; then uvm_error=0; fi; \
		if [ "$$uvm_fatal" = "" ]; then uvm_fatal=0; fi; \
		if [ "$$uvm_error" = "0" ] && [ "$$uvm_fatal" = "0" ]; then \
			echo "✅ $$test_name: PASS								($$scoreboard_status & $$design_status)"; \
			pass=$$((pass+1)); \
		else \
			echo "❌ $$test_name: FAIL (UVM_ERROR=$$uvm_error, UVM_FATAL=$$uvm_fatal)				($$scoreboard_status & $$design_status)"; \
			fail=$$((fail+1)); \
		fi; \
	done; \
	total=$$((pass+fail)); \
	echo "-----------------------------------------"; \
	echo "Summary: $$pass / $$total tests passed."; \
	if [ "$$fail" -eq 0 ]; then echo "? All tests passed!"; else echo "??  $$fail test(s) failed."; fi

lint:
	@echo "[INFO] Running Verilator lint check..."
	$(VERILATOR) $(VERILATOR_FLAGS) $(srcmd_fmt) $(mdcfg_fmt) -f $(FLIST) --top-module $(TOP) > $(LINT_RPT) 2>&1
	@echo "[INFO] Lint report saved to $(LINT_RPT)"
