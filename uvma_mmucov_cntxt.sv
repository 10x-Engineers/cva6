class uvma_mmucov_cntxt_c extends uvm_object;

  `uvm_object_utils(uvma_mmucov_cntxt_c)

  extern function new(string name = "uvma_mmucov_cntxt");

endclass : uvma_mmucov_cntxt_c


function uvma_mmucov_cntxt_c::new(string name = "uvma_mmucov_cntxt");

  super.new(name);

endfunction : new