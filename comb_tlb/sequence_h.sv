class sequence_h extends uvm_sequence #(seq_item);

    `uvm_object_utils(sequence_h)

    seq_item sq;
    
    function new(string name = "sequence_h");
            super.new(name);
    endfunction 

     virtual task body();


        `uvm_do_with (sq, {sq.rst_ni == 1;sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 0;sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 0;sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 0;sq.flush_tlb_i==0;})

        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.flush_tlb_i==0;sq.asid_i==0;sq.shared_tlb_update_i == 63'h0000000000000000;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.dtlb_lu_access_i==0; sq.itlb_lu_access_i == 1; sq.itlb_vaddr_i == 32'h00000000; sq.asid_i==0;sq.shared_tlb_update_i == 63'h000000000000003F;sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.asid_i==0;sq.flush_tlb_i==0;sq.shared_tlb_update_i == 63'h0000000000000000;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.asid_i==0;sq.flush_tlb_i==0;sq.shared_tlb_update_i == 63'h0000000000000000;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F800000;sq.asid_i==1;sq.flush_tlb_i==0;sq.shared_tlb_update_i == 63'h0000000000000000;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.dtlb_lu_access_i==0; sq.itlb_lu_access_i == 1; sq.itlb_vaddr_i == 32'h7F800000;sq.asid_i==1; sq.shared_tlb_update_i == 63'h6FF001FF0000006F;sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F800000;sq.asid_i==1;sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F800000;sq.asid_i==1;sq.flush_tlb_i==0;})

        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.dtlb_lu_access_i ==0; sq.itlb_lu_access_i == 1;sq.itlb_vaddr_i == 32'h00000000;sq.asid_i==0; sq.flush_tlb_i==0;sq.shared_tlb_update_i == 63'h0000000000000000;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.asid_i==0;sq.shared_tlb_update_i == 63'h600000000000003D;sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.asid_i==0;sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.asid_i==0;sq.flush_tlb_i==0;})

        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F400000;sq.asid_i==1;sq.flush_tlb_i==0;sq.shared_tlb_update_i == 63'h0000000000000000;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.dtlb_lu_access_i==0; sq.itlb_lu_access_i == 1; sq.itlb_vaddr_i == 32'h7F400000;sq.asid_i==1;sq.shared_tlb_update_i == 63'h6FE801FF0000006F; sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F400000;sq.asid_i==1;sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F400000;sq.asid_i==1;sq.flush_tlb_i==0;})

        // `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F400000;sq.asid_i==0;sq.flush_tlb_i==0;sq.shared_tlb_update_i == 63'h0000000000000000;})
        // `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.dtlb_lu_access_i==0; sq.itlb_lu_access_i == 1; sq.itlb_vaddr_i == 32'h7F400000;sq.asid_i==0;sq.shared_tlb_update_i == 63'h6FE800000000006F; sq.flush_tlb_i==0;})
        // `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F400000;sq.asid_i==0;sq.flush_tlb_i==0;})
        // `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F400000;sq.asid_i==0;sq.flush_tlb_i==0;})

        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.dtlb_lu_access_i ==0; sq.itlb_lu_access_i == 1;sq.itlb_vaddr_i == 32'h7F800000;sq.asid_i==1; sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.dtlb_lu_access_i ==0; sq.itlb_lu_access_i == 1;sq.itlb_vaddr_i == 32'h00000000;sq.asid_i==0; sq.flush_tlb_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.dtlb_lu_access_i ==0; sq.itlb_lu_access_i == 1;sq.itlb_vaddr_i == 32'h7F400000;sq.asid_i==0; sq.flush_tlb_i==0;})

        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1; sq.dtlb_lu_access_i == 1; sq.dtlb_vaddr_i == 32'h000FF000;sq.flush_tlb_i==0;sq.asid_i==0;sq.shared_tlb_update_i == 63'h0000000000000000;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1; sq.dtlb_lu_access_i == 1; sq.dtlb_vaddr_i == 32'h000FF000; sq.shared_tlb_update_i == 63'h4001FE0000000F4F;sq.flush_tlb_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1; sq.dtlb_lu_access_i == 1; sq.dtlb_vaddr_i == 32'h000FF000;sq.flush_tlb_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1; sq.dtlb_lu_access_i == 1; sq.dtlb_vaddr_i == 32'h000FF000;sq.flush_tlb_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1; sq.dtlb_lu_access_i == 1; sq.dtlb_vaddr_i == 32'hF0000000;sq.flush_tlb_i==0;sq.asid_i==1;sq.shared_tlb_update_i == 63'h0000000000000000;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1; sq.dtlb_lu_access_i == 1; sq.dtlb_vaddr_i == 32'hF0000000; sq.shared_tlb_update_i == 63'h5E0001FF00000F5F;sq.flush_tlb_i==0;sq.asid_i==1;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1; sq.dtlb_lu_access_i == 1; sq.dtlb_vaddr_i == 32'hF0000000;sq.flush_tlb_i==0;sq.asid_i==1;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1; sq.dtlb_lu_access_i == 1; sq.dtlb_vaddr_i == 32'hF0000000;sq.flush_tlb_i==0;sq.asid_i==1;})

        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1;sq.dtlb_lu_access_i == 1;sq.flush_tlb_i==1;sq.asid_to_be_flushed_i == 1;sq.vaddr_to_be_flushed_i == 32'hF0000000;})

        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.flush_tlb_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F800000;sq.flush_tlb_i==0;sq.asid_i==1;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.enable_translation_i == 1; sq.itlb_lu_access_i == 1; sq.dtlb_lu_access_i ==0;sq.itlb_vaddr_i == 32'h7F400000;sq.flush_tlb_i==0;sq.asid_i==0;})

        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1; sq.dtlb_lu_access_i == 1; sq.dtlb_vaddr_i == 32'h000FF000;sq.flush_tlb_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni == 1;sq.en_ld_st_translation_i == 1; sq.dtlb_lu_access_i == 1; sq.dtlb_vaddr_i == 32'hF0000000;sq.flush_tlb_i==0;sq.asid_i==1;})
    

    endtask : body

endclass    

