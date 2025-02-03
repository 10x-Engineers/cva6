class sequence_h extends uvm_sequence #(seq_item);

    `uvm_object_utils(sequence_h)

    seq_item sq;
    
    function new(string name = "sequence_h");
            super.new(name);
    endfunction 

     virtual task body();
     
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i==0;sq.lu_access_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i==0;sq.lu_access_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i==0;sq.lu_access_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==0;sq.flush_i==0;sq.lu_access_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.flush_i==0;sq.lu_access_i == 0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h00000000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.update_i == 63'h000000000000005F;sq.flush_i==0;sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h00000000;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 1; sq.lu_vaddr_i == 32'h7F800000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.update_i == 63'h4FF001FF0000008F;sq.lu_asid_i == 1; sq.lu_vaddr_i == 32'h7F800000;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 1; sq.lu_vaddr_i == 32'h7F800000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h00000000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.update_i == 63'h400000000000005F;sq.flush_i==0;sq.lu_asid_i == 0;sq.lu_vaddr_i == 32'h00000000;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h00000000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 1; sq.lu_vaddr_i == 32'h7F800000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 1; sq.lu_vaddr_i == 32'h7F800000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h00000000;sq.flush_i==0;})

      
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h7F400000;sq.flush_i==0;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.update_i == 63'h6FE800000000001F;sq.flush_i==0;sq.lu_asid_i == 0;sq.lu_vaddr_i == 32'h7F400000;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h7F400000;sq.flush_i==0;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h00000000;sq.flush_i==0;sq.update_i == 63'h0000000000000000;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 1; sq.lu_vaddr_i == 32'h7F800000;sq.flush_i==0;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h00000000;sq.flush_i==0;sq.update_i == 63'h0000000000000000;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h00000000;sq.flush_i==0;sq.update_i == 63'h0000000000000000;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 1; sq.lu_vaddr_i == 32'h7F800000;sq.flush_i==0;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 1; sq.lu_vaddr_i == 32'h7F800000;sq.flush_i==0;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h7F400000;sq.flush_i==0;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h7F400000;sq.flush_i==0;})
         `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h7F400000;sq.flush_i==0;sq.update_i == 63'h0000000000000000;})


        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.asid_to_be_flushed_i == 1;sq.vaddr_to_be_flushed_i == 32'h7F800000;sq.flush_i==1;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h00000000;sq.flush_i==0;sq.update_i == 63'h0000000000000000;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h00000000;sq.flush_i==0;sq.update_i == 63'h0000000000000000;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 1; sq.lu_vaddr_i == 32'h7F800000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 1; sq.lu_vaddr_i == 32'h7F800000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h7F400000;sq.flush_i==0;})
        `uvm_do_with (sq, {sq.rst_ni==1;sq.lu_access_i == 1; sq.lu_asid_i == 0; sq.lu_vaddr_i == 32'h7F400000;sq.flush_i==0;})
  
    endtask : body

endclass    

