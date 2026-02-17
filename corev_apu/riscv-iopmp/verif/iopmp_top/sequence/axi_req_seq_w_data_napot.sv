
class axi_req_seq_w_data_napot extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_req_seq_w_data_napot) // Register with the UVM factory

    axi_seq_item req; // Sequence item for the Read transaction

    bit[4:0] id;
    bit[63:0] addr;
    bit[8:2] rrid;
    bit [2:0] user_perm;

    // Constructor
    function new(string name = "axi_req_seq_w_data_napot");
      super.new(name);
    endfunction

    // Main sequence body
    task body();
      begin
          wait_for_grant();
          // Create and randomize sequence item
          req = axi_seq_item::type_id::create("basic_rd_addr_req");
          if (!req.randomize() with {
                 burst_length==0;
                 addr==0;
                //  last == 0;
                //  w_valid == 1;
                 w_user == 0;
              }) begin
              `uvm_error(get_name(), "REQ Randomization Failed @axi_sequence")
          end

          // Assign transaction details
           foreach (req.write_strobe[i]) begin
                req.write_strobe[i] = 'b0; // Zero out each element of write_strobe
            end

           foreach (req.write_data[i]) begin
              req.write_data[i] = 'b0; // Zero out each element of write_data
           end

          // Send request and wait for completion
          send_request(req);
          wait_for_item_done();
          // wait_for_grant();
          // req.w_valid = 0;
          // send_request(req);
          // wait_for_item_done();

        end
    endtask
endclass : axi_req_seq_w_data_napot

