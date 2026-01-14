class axi_s_read_data_seq extends axi_s_seq;
    `uvm_object_utils(axi_s_read_data_seq)

    int trans_count;
    logic [31:0] r_addr;
    axi_s_config cfg;

    axi_s_seq_item req;
    axi_s_seq_item rsp;

    function new(string name = "axi_s_read_data_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Starting read_data_seq", UVM_MEDIUM)
            rsp = axi_s_seq_item::type_id::create("rsp");
            gen_axi_address_queue(req.ARADDR, req.ARBURST, req.ARLEN, req.ARSIZE);
            trans_count = addr_queue.size();
            for (int i = 1; i <= trans_count; i++)
            begin
                r_addr = addr_queue.pop_front();
                start_item(rsp);
                if (i == trans_count) begin
                    rsp.RID = req.ARID;
                    rsp.RLAST = 1'b1;
                    rsp.RVALID = 1'b1;
                    rsp.RDATA = {cfg.mem_1[r_addr>>3], cfg.mem_0[r_addr>>3]};
                    rsp.RRESP = 2'b00;
                    rsp.RUSER = req.ARUSER;
                end
                else begin
                    rsp.RID = req.ARID;
                    rsp.RLAST = 1'b0;
                    rsp.RVALID = 1'b1;
                    rsp.RDATA = {cfg.mem_1[r_addr>>3], cfg.mem_0[r_addr>>3]};
                    rsp.RRESP = 2'b00;
                    rsp.RUSER = req.ARUSER;
                end
                finish_item(rsp);
            end
        `uvm_info(get_type_name(), "read_data_seq completed", UVM_MEDIUM)
    endtask


endclass
