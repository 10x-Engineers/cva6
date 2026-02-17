/*************************************************************************
   > File Name:   axi_req_seq_w_data.sv
   > Description: Sequence implementation for Master AXI4 VIP write data channel.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

class axi_req_seq_w_data extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_req_seq_w_data) // Register with the UVM factory
  
    axi_seq_item req; // Sequence item for the Read transaction

    bit[bus_params_pkg::BUS_IDW-1:0]    seq_id;
    bit[63:0]  seq_addr;
    bit[5:0]   rrid;
    bit[6:0] seq_size;
    // bit[2:0]   user_perm;
    bit[7:0]    length;
    bit        has_length;
    bit[11:0]  data_size;

    // Constructor
    function new(string name = "axi_req_seq_w_data");
      super.new(name);
    endfunction
  
    // Main sequence body
    task body();
      begin
            wait_for_grant();
            // Create and randomize sequence item
            req = axi_seq_item::type_id::create("basic_rd_addr_req");
            if(has_length == 1)begin
              req.has_burst_length = 1;
            end
            if (!req.randomize() with {
                   addr       == seq_addr;     //For Write Address info
                   access     == WRITE_TRAN;  //For Write Address info
                   size       == seq_size;           //For Write Address info
                   data.size  == data_size;           //For Write Address info
                   has_length == 1 -> burst_length == length;
                   w_valid    == 1;
                   w_user     == 0;
                }) begin
                `uvm_error(get_name(), "REQ Randomization Failed @axi_sequence")
            end
            // Assign transaction details
         
            //  foreach (req.write_strobe[i]) begin
            //       req.write_strobe[i] = 'b0; // Zero out each element of write_strobe
            //   end
            //  foreach (req.write_data[i]) begin
            //     req.write_data[i] = 'b0; // Zero out each element of write_data
            //  end

            // Send request and wait for completion
            send_request(req);
            wait_for_item_done();

            // wait_for_grant();
            // req.w_valid = 0;
            // send_request(req);
            // wait_for_item_done();
    
        end
    endtask
  endclass : axi_req_seq_w_data

