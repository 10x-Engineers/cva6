class axi_s_write_data_seq extends axi_s_seq;
    `uvm_object_utils(axi_s_write_data_seq)

    axi_s_seq_item req;
    axi_s_seq_item aw_req;
    int trans_count;
    logic [63:0] w_addr;
    axi_s_config cfg;

    function new(string name = "axi_s_write_data_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Starting write_data_seq", UVM_MEDIUM)
            gen_axi_address_queue(aw_req.AWADDR, aw_req.AWBURST, aw_req.AWLEN, aw_req.AWSIZE);
            trans_count = addr_queue.size();
            repeat(trans_count) begin
            req = axi_s_seq_item::type_id::create("req");
                // Slave request
                start_item(req);
                finish_item(req);
                w_addr = addr_queue.pop_front();
                {cfg.mem_1[w_addr>>3],cfg.mem_0[w_addr>>3]} = (req.WDATA & {{8{req.WSTRB[7]}}, {8{req.WSTRB[6]}}, {8{req.WSTRB[5]}}, {8{req.WSTRB[4]}}, {8{req.WSTRB[3]}}, {8{req.WSTRB[2]}}, {8{req.WSTRB[1]}}, {8{req.WSTRB[0]}}});
                $display("%0h %0h %0h %0h", w_addr, req.WDATA, req.WSTRB, {cfg.mem_1[w_addr>>3],cfg.mem_0[w_addr>>3]});
            end
        `uvm_info(get_type_name(), "write_data_seq completed", UVM_MEDIUM)
    endtask

endclass
