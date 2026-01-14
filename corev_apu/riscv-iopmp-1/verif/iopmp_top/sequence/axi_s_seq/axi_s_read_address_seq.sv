class axi_s_read_address_seq extends axi_s_seq;
    `uvm_object_utils(axi_s_read_address_seq)

    axi_s_seq_item req;
    axi_s_seq_item rsp;

    function new(string name = "axi_s_read_address_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Starting read_address_seq", UVM_MEDIUM)
                req = axi_s_seq_item::type_id::create("req");
                // Slave request
                start_item(req);
                finish_item(req);
        `uvm_info(get_type_name(), "read_address_seq completed", UVM_MEDIUM)
    endtask

endclass
