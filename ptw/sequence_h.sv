class sequence_h extends uvm_sequence #(seq_item);

    `uvm_object_utils(sequence_h)

    seq_item sq;
    
    function new(string name = "sequence_h");
            super.new(name);
    endfunction 

     virtual task body();

        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i == 0;})

        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==1;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==1; sq.satp_ppn_i == 22'h200000;})
        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==0;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==1; sq.satp_ppn_i == 22'h200000;})
        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==1; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h30011001122332233;})

        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==1; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h70011001822332233;})
        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==1; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h70011001522332233;})

        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==1; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h70011001122332233;})
        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==1; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h70000001122332233;})

        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==1; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h70011001B22332233;})
        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==1; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h70000001B22332233;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==1; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h70000105B22332233;})

        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==0; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h70000001B22332233;sq.lsu_is_store_i ==1;})
        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==0; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h7000000FF22332233;sq.lsu_is_store_i ==1;})
        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==0; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h7000000BF22332233;sq.lsu_is_store_i ==1;sq.mxr_i==0;})
        // `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==0; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h7000000FD22332233;sq.lsu_is_store_i ==1;sq.mxr_i==0;})
        
        //  `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 0;sq.asid_i==0;sq.shared_tlb_access_i==1;sq.shared_tlb_hit_i==0;sq.shared_tlb_vaddr_i==32'h00fff000;sq.itlb_req_i==0; sq.satp_ppn_i == 22'h200000;sq.req_port_i == 67'h5000000FF22332233;sq.lsu_is_store_i ==1;})
        //  `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i == 1;})

    endtask : body

endclass    

