/*************************************************************************
   > File Name:   axi_req_seq_w_data.sv
   > Description: Sequence implementation for Master AXI4 VIP read addr channel.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

class axi_req_seq extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_req_seq) // Register with the UVM factory

    axi_seq_item req; // Sequence item for the Read transaction

    burst_type                         burst_t;
    bit [bus_params_pkg::BUS_IDW-1:0]  seq_id;
    bit [63:0]                         seq_addr;
    bit [5:0]                          rrid;
    bit [6:0]                          seq_size;
    bit                                user_perm;
    bit [7:0]                          length;
    bit                                has_length;
    bit [11:0]                         data_size;
    bit [2:0]                          seq_prot;

    // Constructor
    function new(string name = "axi_req_seq");
      super.new(name);
    endfunction

    // Main sequence body
    task body();
      begin
            wait_for_grant();
            // Create and randomize sequence item
            req = axi_seq_item::type_id::create("basic_rd_addr_req");
            if(has_length == 1)
              req.has_burst_length = 1;
            if (!req.randomize() with {
                    id == seq_id;
                    addr == seq_addr;
                    access == READ_TRAN;
                    burst == INCR;
                    size == seq_size;
                    ar_valid == 1;
                    data.size == data_size;
                    r_user[5:0] == rrid; //rrid;
                    has_length == 1 -> burst_length == length;
                    prot == seq_prot;
                    region == 0;
                    qos == 0;
                }) begin
                `uvm_error(get_name(), "REQ Randomization Failed @axi_sequence")
            end
            // Assign transaction details
            // req.id = id;
            // req.addr = addr;

            // Send request and wait for completion
            send_request(req);
            wait_for_item_done();

            // wait_for_grant();
            // req.ar_valid = 0;
            // send_request(req);
            // wait_for_item_done();

        end
    endtask
  endclass : axi_req_seq
