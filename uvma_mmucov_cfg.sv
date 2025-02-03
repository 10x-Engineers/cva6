class uvma_mmucov_cfg_c extends uvm_object;

  rand bit                     enabled;
  rand uvm_active_passive_enum is_active;

  rand bit                     cov_model_enabled;

  // Core configuration object to filter extensions, csrs, modes, supported
  uvma_core_cntrl_cfg_c        core_cfg;

  `uvm_object_utils_begin(uvma_mmucov_cfg_c);
    `uvm_field_int(enabled, UVM_DEFAULT);
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT);
    `uvm_field_int(cov_model_enabled, UVM_DEFAULT);
  `uvm_object_utils_end;

  extern function new(string name = "uvma_mmucov_cfg");

endclass : uvma_mmucov_cfg_c

function uvma_mmucov_cfg_c::new(string name = "uvma_mmucov_cfg");

  super.new(name);

endfunction : new