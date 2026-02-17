class axi_s_sanity_seq extends uvm_sequence #(axi_s_seq_item);
    `uvm_object_utils(axi_s_sanity_seq)

    `uvm_declare_p_sequencer(axi_s_sequencer)

    axi_s_write_address_seq aw_seq;
    axi_s_write_data_seq    w_seq;
    axi_s_write_response_seq b_seq;
    axi_s_read_address_seq  ar_seq;
    axi_s_read_data_seq     r_seq;
    axi_s_seq_item ready_seq;
    axi_s_seq_item read_queue[$];
    axi_s_seq_item write_data_queue[$];
    axi_s_seq_item write_response_queue[$];
    int Burst;
    int ID;
    int User;
    response_type  BRESP;
    bit resp;
    // bit [bus_params_pkg::BUS_IDW:0]  ID[$];
    // bit [bus_params_pkg::BUS_U_SLAVE-1:0]  USER[$];

    function new(string name = "axi_s_sanity_seq");
        super.new(name);
        aw_seq = axi_s_write_address_seq::type_id::create("aw_seq");
        w_seq  = axi_s_write_data_seq::type_id::create("w_seq");
        b_seq  = axi_s_write_response_seq::type_id::create("b_seq");
        ar_seq = axi_s_read_address_seq::type_id::create("ar_seq");
        r_seq  = axi_s_read_data_seq::type_id::create("r_seq");
        ready_seq = axi_s_seq_item::type_id::create("ready_seq");
    endfunction



    task body();
        `uvm_info(get_type_name(), "Starting axi_sanity_seq", UVM_MEDIUM)
        `uvm_do_on(ready_seq,p_sequencer.aw_sequencer);
        fork
            forever begin
                aw_seq.start(p_sequencer.aw_sequencer);
                write_data_queue.push_back(aw_seq.req);
                Burst = aw_seq.req.AWBURST;
                ID = aw_seq.req.AWID;
                // ID.push_back(aw_seq.req.AWID);
                User = aw_seq.req.AWUSER;
                // USER.push_back(aw_seq.req.AWUSER);
                $display("Sanity::::AW:: ID=%h  User=%h Addr=%h", ID, User, aw_seq.req.AWADDR);
            end
            forever begin
                wait (p_sequencer.vif.WVALID);
                wait(write_data_queue.size()>0);
                w_seq.aw_req = write_data_queue.pop_front();
                w_seq.start(p_sequencer.w_sequencer);
                write_response_queue.push_back(w_seq.req);
                // @(posedge p_sequencer.vif.ACLK);
                $display("Sanity::::Data::");
                $display("Sanity::::W:: dATA=%h ", w_seq.req.WDATA);
            end
            forever begin
                // wait(write_response_queue.size() && ID.size())
                wait(write_response_queue.size() && (Burst>=0))
                $display("Sanity-QUE-SIZE:::%h",write_response_queue.size());
                // $display("Sanity-ID-SIZE:::%h",ID.size());
                // $display("Sanity-USER-SIZE:::%h",USER.size());
                b_seq.req = write_response_queue.pop_front();
                $display("Sanity::::B:: ID=%h  User=%h", ID, User);
                b_seq.req.BID = ID;
                // b_seq.req.BID = ID.pop_front();
                b_seq.req.BUSER = User;
                // b_seq.req.BUSER = USER.pop_front();
                if(resp == 1)begin
                    b_seq.resp_a = 1;
                end

                b_seq.start(p_sequencer.b_sequencer);
                Burst--;
            end
            forever begin
                ar_seq.start(p_sequencer.ar_sequencer);
                read_queue.push_back(ar_seq.req);
            end
            forever begin
                wait(read_queue.size())
                r_seq.req = read_queue.pop_front();
                r_seq.start(p_sequencer.r_sequencer);

            end
        join
    endtask


endclass
