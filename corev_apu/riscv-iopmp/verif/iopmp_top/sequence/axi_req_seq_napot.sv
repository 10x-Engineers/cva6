
class axi_req_seq_napot extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_req_seq_napot) // Register with the UVM factory

    axi_seq_item req; // Sequence item for the Read transaction

    bit[4:0] id;
    bit[63:0] addr;
    bit[5:0] rrid;
    bit user_perm;

    // Constructor
    function new(string name = "axi_req_seq_napot");
      super.new(name);
    endfunction

    // Main sequence body
    task body();
      begin
            wait_for_grant();
            // Create and randomize sequence item
            req = axi_seq_item::type_id::create("basic_rd_addr_req");
            if (!req.randomize() with {
                    access == READ_TRAN;
                    burst == FIXED;
                    size == 8;
                   ar_valid == 1;
                   data.size == 16;
                   r_user[6:1] == rrid; //rrid;
                   r_user[0] == user_perm;
                }) begin
                `uvm_error(get_name(), "REQ Randomization Failed @axi_sequence")
            end
            // Assign transaction details
            req.id = id;
            req.addr = addr;

            // Send request and wait for completion
            send_request(req);
            wait_for_item_done();

            wait_for_grant();
            req.ar_valid = 0;
            send_request(req);
            wait_for_item_done();

        end
    endtask
endclass : axi_req_seq_napot
