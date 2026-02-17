class axi_s_config extends uvm_object;
    `uvm_object_utils(axi_s_config)

    rand bit enable_monitor;
    rand bit enable_coverage;
    rand int unsigned slave_id;

    typedef bit [31:0] uint32_t;
    static bit [31:0] mem_0 [uint32_t];
    static bit [31:0] mem_1 [uint32_t];

    function new(string name = "axi_s_config");
        super.new(name);
    endfunction

    function void do_print(uvm_printer printer);
        super.do_print(printer);
        printer.print_field("enable_monitor", enable_monitor, 1, UVM_BIN);
        printer.print_field("enable_coverage", enable_coverage, 1, UVM_BIN);
        printer.print_field("slave_id", slave_id, 32, UVM_DEC);
    endfunction

endclass
