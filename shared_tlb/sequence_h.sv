class sequence_h extends uvm_sequence #(seq_item);

    `uvm_object_utils(sequence_h)

    seq_item sq;
    
    function new(string name = "sequence_h");
            super.new(name);
    endfunction 


     virtual task body();
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i==0;})

        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.dtlb_access_i==0;sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.itlb_vaddr_i == 32'h00000000; sq.shared_tlb_update_i == 63'h000000000000003F;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'h00088000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.dtlb_access_i ==0;sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.itlb_vaddr_i == 32'h00088000; sq.shared_tlb_update_i == 63'h600110000000008F;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'h00088000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.dtlb_access_i==0;sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.itlb_vaddr_i == 32'h00000000; sq.shared_tlb_update_i == 63'h600000000000003F;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'h00088000;sq.flush_i==0;sq.asid_i==0;})

        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'hF0000000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.dtlb_access_i==0;sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.itlb_vaddr_i == 32'hF0000000; sq.shared_tlb_update_i == 63'h7E0000000000005F;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'hF0000000;sq.flush_i==0;sq.asid_i==0;})
        
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'hE0000000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.dtlb_access_i==0;sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.itlb_vaddr_i == 32'hE0000000; sq.shared_tlb_update_i == 63'h7C0000000000001F;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'hE0000000;sq.flush_i==0;sq.asid_i==0;})

        `uvm_do_with (sq, {sq.rst_ni==1;sq.en_ld_st_translation_i == 1; sq.dtlb_hit_i==0; sq.dtlb_access_i == 1; sq.dtlb_vaddr_i == 32'h000FF000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.en_ld_st_translation_i == 1; sq.dtlb_hit_i==0; sq.dtlb_access_i == 1; sq.dtlb_vaddr_i == 32'h000FF000; sq.shared_tlb_update_i == 63'h6001FE0000000F3F;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.en_ld_st_translation_i == 1; sq.dtlb_hit_i==0; sq.dtlb_access_i == 1; sq.dtlb_vaddr_i == 32'h000FF000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.en_ld_st_translation_i == 1; sq.dtlb_hit_i==0; sq.dtlb_access_i == 1; sq.dtlb_vaddr_i == 32'h000D9000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.en_ld_st_translation_i == 1; sq.dtlb_hit_i==0; sq.dtlb_access_i == 1; sq.dtlb_vaddr_i == 32'h000D9000; sq.shared_tlb_update_i == 63'h6001B30000000F6F;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.en_ld_st_translation_i == 1; sq.dtlb_hit_i==0; sq.dtlb_access_i == 1; sq.dtlb_vaddr_i == 32'h000D9000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.flush_i==0;sq.asid_i==0;sq.shared_tlb_update_i == 63'h0001B30000000F6F;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'hF0000000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'hF0000000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'hE0000000;sq.flush_i==0;sq.asid_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'hE0000000;sq.flush_i==0;sq.asid_i==0;})


    
        `uvm_do_with (sq, {sq.en_ld_st_translation_i == 1;sq.dtlb_access_i == 1;sq.flush_i==1;})

        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'h00000000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.enable_translation_i == 1; sq.itlb_hit_i==0; sq.itlb_access_i == 1; sq.dtlb_access_i ==0;sq.itlb_vaddr_i == 32'h00088000;sq.flush_i==0;})

        `uvm_do_with (sq, {sq.en_ld_st_translation_i == 1; sq.dtlb_hit_i==0; sq.dtlb_access_i == 1; sq.dtlb_vaddr_i == 32'h000FF000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.en_ld_st_translation_i == 1; sq.dtlb_hit_i==0; sq.dtlb_access_i == 1; sq.dtlb_vaddr_i == 32'h000D9000;sq.flush_i==0;})

    endtask : body

endclass    