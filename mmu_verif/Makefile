#Directories
TEST_NAME   	:= ""
SEQ		    	:= seq
PTW				:= ptw
Shared_TLB		:= shared_tlb
TLB 			:= tlb
Else			:= else
RTL				:= mmu_sv32
TB_TOP			:= tb_top.sv

VCS = vcs -sverilog -timescale=1ns/1ns 	\
	-ntb_opts uvm-1.2 					\
  	-lca -debug_access+all 				\
	-cm line+cond+tgl+branch+assert		\
	-cm_dir simv.vdb					\

SIMV = ./simv -gui & $(TEST3)

TEST1	:= +UVM_TESTNAME=hits_test                                 
TEST2   := +UVM_TESTNAME=all_miss_test
TEST3   := +UVM_TESTNAME=ptw_flush_test      
TEST4   := +UVM_TESTNAME=sh_tlb_flush_test                        
TEST5   := +UVM_TESTNAME=all_flush_test                        
TEST6   := +UVM_TESTNAME=tlb_flush_test                         
TEST7   := +UVM_TESTNAME=priority_test                        
TEST8   := +UVM_TESTNAME=dis_trans_test        
TEST9   := +UVM_TESTNAME=tlb_update_test  
TEST10  := +UVM_TESTNAME=sh_tlb_upd_test 
TEST11  := +UVM_TESTNAME=ptw_fsm_test 
TEST12  := +UVM_TESTNAME=rand_test
TEST13  := +UVM_TESTNAME=sh_tlb_full_test

build:
ifndef VCS
	$(error "vcs command not found")
endif
	$(VCS)\
	$(TEST1)\ $(TEST2)\ $(TEST3)\ $(TEST4)\ $(TEST5)\ $(TEST6)\ $(TEST7)\ $(TEST8)\ $(TEST9)\ $(TEST10)\ $(TEST11)\ $(TEST12)\ $(TEST13)\
		+incdir+$(RTL) \
		$(TB_TOP) \
	    +incdir+$(SEQ)\
		+incdir+$(TLB)\
		+incdir+$(Shared_TLB) \
		+incdir+$(PTW) \
 		
run:
	$(SIMV)

all_tests: 
	./simv $(TEST1) && \
	./simv $(TEST2) && \
	./simv $(TEST3) && \
	./simv $(TEST4) && \
	./simv $(TEST5) && \
	./simv $(TEST6) && \
	./simv $(TEST7) && \
	./simv $(TEST8) && \
	./simv $(TEST9) && \
	./simv $(TEST10) && \
	./simv $(TEST11) && \
	./simv $(TEST12) && \
	./simv $(TEST13)

coverage: 
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST1) && \
	cp -r simv.vdb test1.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST2) && \
	cp -r simv.vdb test2.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST3) && \
	cp -r simv.vdb test3.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST4) && \
	cp -r simv.vdb test4.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST5) && \
	cp -r simv.vdb test5.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST6) && \
	cp -r simv.vdb test6.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST7) && \
	cp -r simv.vdb test7.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST8) && \
	cp -r simv.vdb test8.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST9) && \
	cp -r simv.vdb test9.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST10) && \
	cp -r simv.vdb test10.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST11) && \
	cp -r simv.vdb test11.vdb && \
	./simv -cm line+cond+fsm+tgl+assert+path $(TEST12) && \
	cp -r simv.vdb test12.vdb && \
	./simv  -cm line+cond+fsm+tgl+assert+path $(TEST13) && \
	cp -r simv.vdb test13.vdb 

report:
	urg -dir test*.vdb

clean:
	rm -rf coverage.vdb csrc DVEfiles inter.vpd simv simv.daidir ucli.key vc_hdrs.h vcs.log .inter.vpd.uvm test*.vdb urgReport simv.vdb
