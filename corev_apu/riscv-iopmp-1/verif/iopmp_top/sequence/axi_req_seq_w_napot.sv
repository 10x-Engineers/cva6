
class axi_req_seq_w_napot extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_req_seq_w_napot) // Register with the UVM factory

    axi_seq_item req; // Sequence item for the Read transaction

    bit[4:0] id;
    bit[63:0] addr;
    bit[8:2] rrid;

    // Constructor
    function new(string name = "axi_req_seq_w_napot");
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
                 aw_valid == 1;
                 data.size == 16;
                 w_user[5:0] == rrid; //rrid;
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
          req.aw_valid = 0;
          send_request(req);
          wait_for_item_done();

        end
    endtask
endclass : axi_req_seq_w_napot