class sequence_h extends uvm_sequence #(seq_item);

    `uvm_object_utils(sequence_h)

    mem_model  mem;

    seq_item sq;
    seq_item fifo_item;
    
    function new(string name = "sequence_h");
        super.new(name);
        mem = new();
    endfunction 

     `uvm_declare_p_sequencer(sequencer)

    task pseq();

        p_sequencer.fifo_ap.get(fifo_item); 
        sq.req_port_o = fifo_item.req_port_o;

    endtask

endclass

class ptw_hit_seq extends sequence_h;

    `uvm_object_utils(ptw_hit_seq)
        
    function new(string name = "ptw_hit_seq");
        super.new(name);
    endfunction 

    virtual task body();
        
        mem.write(34'h20000000C, 67'h72800005B22332233);
        mem.write(34'h2000000AC, 67'h72AC0005B22332233);
        mem.write(34'h200000ABC, 67'h72AB0005B22332233);
        mem.write(34'h200000DBC, 67'h72DB0005B22332233);
        mem.write(34'h20000CCCC, 67'h728C0005B22332233);
        mem.write(34'h20000AAAC, 67'h72AC0005B22332233);
        mem.write(34'h2000DDBAC, 67'h72AB0005B22332233);
        mem.write(34'h2000BDBDC, 67'h72DB0005B22332233);
        mem.write(34'h200CDDC0C, 67'h72AD0005B22332233);
        mem.write(34'h200CBDA0C, 67'h72DC0005B22332233);

        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.priv_lvl_i==2'd0;sq.satp_ppn_i ==22'h200000;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.priv_lvl_i==2'd0;sq.satp_ppn_i ==22'h200000;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.priv_lvl_i==2'd0;sq.satp_ppn_i ==22'h200000;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.priv_lvl_i==2'd0;sq.satp_ppn_i ==22'h200000;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.priv_lvl_i==2'd0;sq.satp_ppn_i ==22'h200000;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.priv_lvl_i==2'd0;sq.satp_ppn_i ==22'h200000;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.priv_lvl_i==2'd0;sq.satp_ppn_i ==22'h200000;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.priv_lvl_i==2'd0;sq.satp_ppn_i ==22'h200000;})
        pseq();

    endtask : body

endclass

class all_miss_seq extends sequence_h;

    `uvm_object_utils(all_miss_seq)
        
    function new(string name = "all_miss_seq");
        super.new(name);
    endfunction 

    virtual task body();

        dcache_req_o_t data;


        
        mem.write(34'h20000000C, 67'h72800005B22332233);
        mem.write(34'h2000000AC, 67'h72800801B22332233);

        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})


        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq();     
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;})
        pseq();
        



    endtask : body

endclass


class ptw_flush_seq extends sequence_h;

    `uvm_object_utils(ptw_flush_seq)
        
    function new(string name = "ptw_flush_seq");
        super.new(name);
    endfunction 

    virtual task body();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 1;sq.flush_tlb_i==0;})
        pseq();  

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();
        #20;
    endtask : body

endclass

class sh_tlb_flush_seq extends sequence_h;

    `uvm_object_utils(sh_tlb_flush_seq)
        
    function new(string name = "sh_tlb_flush_seq");
        super.new(name);
    endfunction 

    virtual task body();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i==1;asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'hDBfbb000;})
        pseq();  

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();
        #40;

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();
        #40;
    endtask : body

endclass

class all_flush_seq extends sequence_h;

    `uvm_object_utils(all_flush_seq)
        
    function new(string name = "all_flush_seq");
        super.new(name);
    endfunction 

    virtual task body();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 1;sq.flush_tlb_i==1;asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'h00000000;})
        pseq();  

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;})
        pseq();
        #60;

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;})
        pseq();
        #60;

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;})
        pseq();
        #60;

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;})
        pseq();
        #60;
    endtask : body

endclass

class tlb_flush_seq extends sequence_h;

    `uvm_object_utils(tlb_flush_seq)
        
    function new(string name = "tlb_flush_seq");
        super.new(name);
    endfunction 

    virtual task body();

        mem.write(34'h20000000C, 67'h72800005B22332233);
        mem.write(34'h2000000AC, 67'h72AC0007B22332233);
        mem.write(34'h200000ABC, 67'h72AB0005B22332233);
        mem.write(34'h200000DBC, 67'h72DB0005B22332233);


        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})


        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==1;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==1;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;})
        pseq();


        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i==1;asid_to_be_flushed_i==1;vaddr_to_be_flushed_i==32'h00000000;})
        pseq();  

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000; sq.priv_lvl_i==2'b00;})
        pseq();

        
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==1;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==1;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();


        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i==1;asid_to_be_flushed_i==1;vaddr_to_be_flushed_i==32'hABfbb000;})
        pseq();  

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'b00;})
        pseq();
        #60;

    endtask : body

endclass

class priority_seq extends sequence_h;

    `uvm_object_utils(priority_seq)
        
    function new(string name = "priority_seq");
        super.new(name);
    endfunction 

    virtual task body();

        mem.write(34'h20000000C, 67'h72800005B22332233);
        mem.write(34'h2000000AC, 67'h72AC0007B22332233);


        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})


        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==1;sq.lsu_vaddr_i == 32'h00fff000; sq.icache_areq_i == 33'h100fff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==1;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 1;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==1;sq.lsu_vaddr_i == 32'h00fff000;sq.icache_areq_i == 33'h100fff000;sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0;sq.asid_i ==1;sq.lsu_req_i == 1; sq.ld_st_priv_lvl_i==2'd0; sq.satp_ppn_i ==22'h200000;sq.sum_i ==0; sq.mxr_i ==0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==1;sq.lsu_vaddr_i == 32'h00fff000;sq.icache_areq_i == 33'h100fff000;sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0;sq.asid_i ==1;sq.lsu_req_i == 1;sq.ld_st_priv_lvl_i==2'd0; sq.satp_ppn_i ==22'h200000;sq.sum_i ==0; sq.mxr_i ==0;})
        pseq();
        #40;

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==1;sq.lsu_vaddr_i == 32'h0Afff000;sq.icache_areq_i == 33'h10Afff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==1;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 1;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==1;sq.lsu_vaddr_i == 32'h0Afff000;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==1;sq.lsu_req_i == 1;sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0;sq.satp_ppn_i ==22'h200000;sq.ld_st_priv_lvl_i==2'd0;sq.sum_i ==0; sq.mxr_i ==0; })
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==1;sq.lsu_is_store_i==0;sq.lsu_vaddr_i == 32'h0Afff000;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==1;sq.misaligned_ex_i == 65'd0;sq.lsu_req_i == 1;sq.lsu_is_store_i==0;sq.satp_ppn_i ==22'h200000;sq.ld_st_priv_lvl_i==2'd0;sq.sum_i ==0; sq.mxr_i ==0; })
        pseq();
        #60;


      

    endtask : body

endclass

class dis_trans_seq extends sequence_h;

    `uvm_object_utils(dis_trans_seq)
        
    function new(string name = "dis_trans_seq");
        super.new(name);
    endfunction 

    virtual task body();

        mem.write(34'h20000000C, 67'h72800005B22332233);
        mem.write(34'h2000000AC, 67'h72AC0007B22332233);


        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==0;sq.lsu_vaddr_i == 32'h00008000;sq.icache_areq_i == 33'h100010001;sq.asid_i ==1;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;})
        pseq();
        
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==0;sq.lsu_vaddr_i == 32'h0001FFFF;sq.icache_areq_i == 33'h10001FFFF;sq.asid_i ==1;sq.lsu_req_i == 1;sq.satp_ppn_i ==22'h200000;})
        pseq();
        #40;


      

    endtask : body

endclass

class tlb_update_seq extends sequence_h; //for tlb_enteries == 8

    `uvm_object_utils(tlb_update_seq)
        
    function new(string name = "tlb_update_seq");
        super.new(name);
    endfunction 

    virtual task body();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h20000C;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000C;sq.priv_lvl_i==2'd0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000C;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1AAfff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h20000A;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1AAfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000A;sq.priv_lvl_i==2'd0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1AAfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000A;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1BAfff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h2000DD;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1BAfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h2000DD;sq.priv_lvl_i==2'd0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1BAfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h2000DD;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1BDfff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h2000BD;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1BDfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h2000BD;sq.priv_lvl_i==2'd0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1BDfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h2000BD;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1C0fbb0f0; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200CDD;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1C0fbb0f0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200CDD;sq.priv_lvl_i==2'd0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1C0fbb0f0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200CDD;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1A0fbb0f0; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200CBD;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1A0fbb0f0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200CBD;sq.priv_lvl_i==2'd0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1A0fbb0f0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200CBD;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000C;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1AAfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000A;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1BAfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h2000DD;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1BDfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h2000BD;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1C0fbb0f0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200CDD;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1A0fbb0f0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200CBD;sq.priv_lvl_i==2'd0;})
        pseq();


    endtask : body

endclass

class sh_tlb_upd_seq extends sequence_h;

    `uvm_object_utils(sh_tlb_upd_seq)
        
    function new(string name = "sh_tlb_upd_seq");
        super.new(name);
    endfunction 

    virtual task body();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h20000C;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000C;sq.priv_lvl_i==2'd0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000C;sq.priv_lvl_i==2'd0;})
        pseq();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000C;sq.priv_lvl_i==2'd0;})
        pseq();
        #20;

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();
        #20;

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();
        #40;
    
    endtask : body

endclass

class ptw_fsm_seq extends sequence_h;

    `uvm_object_utils(ptw_fsm_seq)
        
    function new(string name = "ptw_fsm_seq");
        super.new(name);
    endfunction 

    virtual task body();

        dcache_req_o_t data;

        mem.write(34'h20000000C, 67'h72800005D22332233);
        mem.write(34'h2000000AC, 67'h72800805122332233);
        mem.write(34'h200000ABC, 67'h72AB00F5922332233);
        mem.write(34'h200000DBC, 67'h72DB0005922332233);
        mem.write(34'h20000CCCC, 67'h72DB0001922332233);
        mem.write(34'h20000AAAC, 67'h72AC0005922332233);
        mem.write(34'h20000AABC, 67'h72AC0005922332233);
        mem.write(34'h20000AACC, 67'h72AC0005922332233);

        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})

        // not valid or (not readable and writeable)
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();
         `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h100fff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;})
        pseq();

        //valid but not readable or executable 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq();     
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h10Afff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();
        #20;
        
        // misaligned superpage
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1ABfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();

        // superpage with instruction walk, valid update
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h200000;sq.priv_lvl_i==2'd0;})
        pseq();
        #40;

        // superpage with instruction walk, propagate error
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfff000; sq.misaligned_ex_i == 65'd0;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h20000C;sq.lsu_req_i == 0;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000C;sq.priv_lvl_i==2'd0;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == 33'h1CCfff000;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==22'h20000C;sq.priv_lvl_i==2'd0;})
        pseq();

        //store request
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0CCfff000; sq.misaligned_ex_i == 65'd0;sq.lsu_vaddr_i==32'hCCfff000;sq.lsu_is_store_i==1; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h20000C;sq.lsu_req_i == 1;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0CCfff000;sq.asid_i ==0;sq.lsu_req_i == 1;sq.lsu_vaddr_i==32'hCCfff000;sq.satp_ppn_i ==22'h20000C;sq.lsu_is_store_i==1;sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;})
        pseq();

        //load request with !pte.a, propagate error
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0CCfff000; sq.misaligned_ex_i == 65'd0;sq.lsu_vaddr_i==32'hCCfff000;sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h20000C;sq.lsu_req_i == 1;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0CCfff000;sq.asid_i ==0;sq.lsu_req_i == 1;sq.lsu_vaddr_i==32'hCCfff000;sq.satp_ppn_i ==22'h20000C;sq.sum_i ==0;sq.lsu_is_store_i==0;sq.mxr_i ==0; sq.ld_st_priv_lvl_i==2'd0;})
        pseq();

        //load request with !mxr, propagate error
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0DBfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_vaddr_i==32'hAAfbb000; sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h20000A;sq.lsu_req_i == 1;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 1;sq.lsu_vaddr_i==32'hAAfbb000; sq.mxr_i ==0;sq.lsu_is_store_i==0; sq.satp_ppn_i ==22'h20000A;sq.ld_st_priv_lvl_i==2'd0;sq.sum_i ==0;})
        pseq(); 
         
        // load request with valid update
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0DBfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_vaddr_i==32'hDBfbb000; sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==1;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h200000;sq.lsu_req_i == 1;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 1;sq.lsu_vaddr_i==32'hDBfbb000; sq.mxr_i ==1;sq.lsu_is_store_i==0; sq.sum_i ==0;sq.ld_st_priv_lvl_i==2'd0; sq.satp_ppn_i ==22'h200000;})
        pseq();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 1;sq.lsu_vaddr_i==32'hDBfbb000;sq.mxr_i ==1;sq.lsu_is_store_i==0;  sq.sum_i ==0; sq.ld_st_priv_lvl_i==2'd0; sq.satp_ppn_i ==22'h200000;})
        pseq();

        // u==1 with sum==0 in supervisor mode (exception)
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0ABfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_vaddr_i==32'hABfbb000; sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd1; sq.sum_i ==0; sq.mxr_i ==1;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h20000A;sq.lsu_req_i == 1;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0ABfbb000;sq.asid_i ==0;sq.lsu_req_i == 1;sq.lsu_vaddr_i==32'hABfbb000; sq.mxr_i ==1;sq.lsu_is_store_i==0; sq.sum_i ==0;sq.ld_st_priv_lvl_i==2'd1; sq.satp_ppn_i ==22'h20000A;})
        pseq();

        // u==1 with sum==1 in supervisor mode (valid update)
         `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0DBfbb000; sq.misaligned_ex_i == 65'd0;sq.lsu_vaddr_i==32'hACfbb000; sq.lsu_is_store_i==0; sq.priv_lvl_i==2'd0; sq.ld_st_priv_lvl_i==2'd1; sq.sum_i ==1; sq.mxr_i ==1;sq.asid_i ==0;sq.asid_to_be_flushed_i==0;vaddr_to_be_flushed_i==32'd0; sq.satp_ppn_i ==22'h20000A;sq.lsu_req_i == 1;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 1;sq.lsu_vaddr_i==32'hACfbb000; sq.mxr_i ==1;sq.lsu_is_store_i==0; sq.sum_i ==1;sq.ld_st_priv_lvl_i==2'd1; sq.satp_ppn_i ==22'h20000A;})
        pseq(); 
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==0;sq.en_ld_st_translation_i==1;sq.icache_areq_i == 33'h0DBfbb000;sq.asid_i ==0;sq.lsu_req_i == 1;sq.lsu_vaddr_i==32'hACfbb000; sq.mxr_i ==1;sq.lsu_is_store_i==0; sq.sum_i ==1;sq.ld_st_priv_lvl_i==2'd1; sq.satp_ppn_i ==22'h20000A;})
        pseq(); 
        #40;

    endtask : body

endclass

class rand_seq extends sequence_h;

    `uvm_object_utils(rand_seq)
        
    function new(string name = "rand_seq");
        super.new(name);
    endfunction 

        rand dcache_req_o_t data;
        rand bit [riscv::PLEN-1:0] address;

        logic [riscv::PPNW-1:0] satppn;
        randc logic [22-1:0] vaddr;
        logic [riscv::VLEN-1:0] lsu_vaddr;
        icache_arsp_t icache_areq;

    virtual task body();

        

        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})

        for(int i=0; i<100; i++) begin
            randomize(data);
            randomize(address);
            randomize(vaddr);
            address = {22'h3FFFFF, 10'h3FF, address[1:0]};
             data = {2'b11, data[64], 32'hFFF003FF, data[31:0]};
            mem.write(address,data);
            lsu_vaddr = {address[11:2], vaddr };
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == 33'h1FFFFFFFF; sq.lsu_vaddr_i == lsu_vaddr;sq.satp_ppn_i ==22'h3FFFFF;sq.lsu_req_i == 0; sq.enable_translation_i==1;})
            pseq(); 
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == 33'h1FFFFFFFF;sq.lsu_vaddr_i == lsu_vaddr; sq.satp_ppn_i ==22'h3FFFFF;sq.lsu_req_i == 0; sq.enable_translation_i==1;})
            pseq();
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == 33'h1FFFFFFFF;sq.lsu_vaddr_i == lsu_vaddr; sq.satp_ppn_i ==22'h3FFFFF;sq.lsu_req_i == 0; sq.enable_translation_i==1;})
            pseq();

        end

        for(int i=0; i<100; i++) begin
            randomize(data);
            randomize(address);
            randomize(vaddr);
            address = {address[33:12], 10'h3FF, address[1:0]};
            mem.write(address,data);
            satppn = address[33:12];
            lsu_vaddr = {address[11:2], vaddr };
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == 33'h1FFFFFFFF; sq.lsu_vaddr_i == lsu_vaddr;sq.satp_ppn_i ==satppn;})
            pseq(); 
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == 33'h1FFFFFFFF;sq.lsu_vaddr_i == lsu_vaddr; sq.satp_ppn_i ==satppn;})
            pseq();
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == 33'h1FFFFFFFF;sq.lsu_vaddr_i == lsu_vaddr; sq.satp_ppn_i ==satppn;})
            pseq();

        end

         for(int i=0; i<100; i++) begin
            randomize(data);
            randomize(address);
            randomize(vaddr);
            mem.write(address,data);
            satppn = address[33:12];
            lsu_vaddr = {address[11:2], vaddr };
            icache_areq = {1'b1, address[11:2], vaddr};
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq; sq.lsu_vaddr_i == lsu_vaddr;sq.satp_ppn_i ==satppn; sq.misaligned_ex_i == 65'h1FFFFFFFFFFFFFFFF;})
            pseq(); 
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq;sq.lsu_vaddr_i == lsu_vaddr; sq.satp_ppn_i ==satppn; sq.misaligned_ex_i == 65'h1FFFFFFFFFFFFFFFF;})
            pseq();
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq;sq.lsu_vaddr_i == lsu_vaddr; sq.satp_ppn_i ==satppn; sq.misaligned_ex_i == 65'h1FFFFFFFFFFFFFFFF;})
            pseq();

        end

        for(int i=0; i<100; i++) begin
            randomize(data);
            randomize(address);
            randomize(vaddr);
            address = {address[33:12], 10'h3FF, address[1:0]};
            mem.write(address,data);
            satppn = address[33:12];
            icache_areq = {1'b1, address[11:2], vaddr};
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq; sq.lsu_vaddr_i == 32'hFFFFFFFF;sq.satp_ppn_i ==satppn;})
            pseq(); 
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq;sq.lsu_vaddr_i == 32'hFFFFFFFF; sq.satp_ppn_i ==satppn;})
            pseq();
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq;sq.lsu_vaddr_i == 32'hFFFFFFFF; sq.satp_ppn_i ==satppn;})
            pseq();

        end

        for(int i=0; i<100; i++) begin
            randomize(data);
            randomize(address);
            randomize(vaddr);
            address = {22'h3FFFFF, address[11:0]};
            mem.write(address,data);
            lsu_vaddr = {address[11:2], vaddr };
            icache_areq = {1'b1, address[11:2], vaddr};
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq; sq.lsu_vaddr_i == lsu_vaddr;sq.satp_ppn_i ==22'h3FFFFF; })
            pseq(); 
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq;sq.lsu_vaddr_i == lsu_vaddr; sq.satp_ppn_i ==22'h3FFFFF; })
            pseq();
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq;sq.lsu_vaddr_i == lsu_vaddr; sq.satp_ppn_i ==22'h3FFFFF; })
            pseq();

        end

        for(int i=0; i<100; i++) begin
            randomize(data);
            randomize(address);
            randomize(vaddr);
            mem.write(address,data);
            satppn = address[33:12];
            lsu_vaddr = {address[11:2], vaddr };
            icache_areq = {1'b1, address[11:2], vaddr};
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq; sq.lsu_vaddr_i == lsu_vaddr;sq.satp_ppn_i ==satppn; vaddr_to_be_flushed_i == 32'hFFFFFFFF;})
            pseq(); 
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq;sq.lsu_vaddr_i == lsu_vaddr; sq.satp_ppn_i ==satppn; vaddr_to_be_flushed_i == 32'hFFFFFFFF;})
            pseq();
            `uvm_do_with (sq, {sq.rst_ni==1;sq.icache_areq_i == icache_areq;sq.lsu_vaddr_i == lsu_vaddr; sq.satp_ppn_i ==satppn; vaddr_to_be_flushed_i == 32'hFFFFFFFF;})
            pseq();

        end

    endtask : body

endclass

class sh_tlb_full_seq extends sequence_h;

    `uvm_object_utils(sh_tlb_full_seq)
        
    function new(string name = "sh_tlb_full_seq");
        super.new(name);
    endfunction 

    bit [5:0] set_num = 0;
    bit [9:0] vpn1 = 0;
    bit [9:0] vpn1_2 = 0;

    rand dcache_req_o_t data;
    rand bit [riscv::PLEN-1:0] address;
    rand bit [riscv::PLEN-1:0] address2;

    logic [riscv::PPNW-1:0] satppn;
    icache_arsp_t icache_areq;

    logic [riscv::PPNW-1:0] satppn2;
    icache_arsp_t icache_areq2;

    virtual task body();

        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;sq.flush_tlb_i == 0;})

         for( int i=0; i<32; i++) begin
            randomize(data);
            vpn1_2 = vpn1+1;
            address = {22'h200000, vpn1, 2'b00};
            address2 = {22'h200000, vpn1_2, 2'b00};
            data = {3'b111, 32'h2800005B, data[31:0]};
            mem.write(address,data);
            mem.write(address2, data);
            satppn = address[33:12];
            icache_areq = {1'b1, address[11:2], 4'b0000, set_num, 12'h000};
            satppn2 = address2[33:12];
            icache_areq2 = {1'b1, address2[11:2], 4'b0000, set_num, 12'h000};
           

            `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == icache_areq; sq.misaligned_ex_i == 65'd0;sq.priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.satp_ppn_i == satppn;sq.lsu_req_i == 0;})
            pseq(); 
            `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == icache_areq;sq.misaligned_ex_i == 65'd0;sq.priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==satppn;})
            pseq();
            `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == icache_areq;sq.misaligned_ex_i == 65'd0;sq.priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==satppn;})
            pseq();

            `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == icache_areq2; sq.misaligned_ex_i == 65'd0;sq.priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.satp_ppn_i == satppn2;sq.lsu_req_i == 0;})
            pseq(); 
            `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == icache_areq2;sq.misaligned_ex_i == 65'd0;sq.priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==satppn2;})
            pseq();
            `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == icache_areq2;sq.misaligned_ex_i == 65'd0;sq.priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==satppn2;})
            pseq();

            set_num = set_num+1;
            vpn1 = vpn1+2;

        end

        set_num = 0;
        vpn1 = 0;
        vpn1_2 = 0;

        for( int i=0; i<32; i++) begin

            vpn1_2 = vpn1+1;
            address = {22'h200000, vpn1, 2'b00};
            address2 = {22'h200000, vpn1_2, 2'b00};
            satppn = address[33:12];
            icache_areq = {1'b1, address[11:2], 4'b0000, set_num, 12'h000};
            satppn2 = address2[33:12];
            icache_areq2 = {1'b1, address2[11:2], 4'b0000, set_num, 12'h000};
            
            `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == icache_areq;sq.misaligned_ex_i == 65'd0;sq.priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.lsu_req_i == 0;sq.satp_ppn_i ==satppn;})
            pseq();
            #40;

            `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.flush_tlb_i == 0;sq.enable_translation_i ==1;sq.en_ld_st_translation_i==0;sq.icache_areq_i == icache_areq2; sq.misaligned_ex_i == 65'd0;sq.priv_lvl_i==2'd0; sq.sum_i ==0; sq.mxr_i ==0;sq.asid_i ==0;sq.satp_ppn_i == satppn2;sq.lsu_req_i == 0;})
            pseq(); 
            #40;

            set_num = set_num+1;
            vpn1 = vpn1+2;

        end
    
    endtask : body

endclass