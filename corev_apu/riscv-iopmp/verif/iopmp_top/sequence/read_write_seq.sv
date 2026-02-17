

class read_write_seq extends uvm_sequence #(ahb_seq_item);
    `uvm_object_utils(read_write_seq)
  
    // Sequence item handle and Memory Handle
    ahb_seq_item req;
    // ahb_seq_item rsp;
  
    //------------------------------------------------------------------------------
    // Constructor: new
    // Default constructor with an optional name parameter.
    //------------------------------------------------------------------------------
    function new(string name = "read_write_seq");
      super.new(name);
    endfunction
  
    //------------------------------------------------------------------------------
    // Task: body
    // Slave Sequence Method Implemented
    //------------------------------------------------------------------------------
    task body();
      req = ahb_seq_item::type_id::create("req");
    //   rsp = ahb_seq_item::type_id::create("rsp");
  
    //   forever begin


        // start_item(req);  
        // finish_item(req);

        // `uvm_do_with(req.)



      
      `uvm_do_with (req, {req.HBURST_o==0 && req.HTRANS_o ==3'd2;req.ACCESS_o==read;req.HADDR_o==32'h2030;req.HSIZE_o==3'd2;})
      `uvm_do_with (req, {req.HBURST_o==0 && req.HTRANS_o ==3'd2;req.ACCESS_o==write;req.HADDR_o==32'h48;req.HWDATA_o==32'h2;req.HSIZE_o==3'd2;})
      `uvm_do_with (req, {req.HBURST_o==0 && req.HTRANS_o ==3'd2;req.ACCESS_o==write;req.HADDR_o==32'h080C;req.HWDATA_o==64'h1234deadbeef;req.HSIZE_o==3'd2;})
      `uvm_do_with (req, {req.HBURST_o==0 && req.HTRANS_o ==3'd2;req.ACCESS_o==write;req.HADDR_o==32'hC;req.HWDATA_o==32'hdeadbeef;req.HSIZE_o==3'd3;})
      `uvm_do_with (req, {req.HBURST_o==0 && req.HTRANS_o ==3'd2;req.ACCESS_o==read;req.HADDR_o==32'hC;req.HSIZE_o==3'd2;})
      `uvm_do_with (req, {req.HBURST_o==0 && req.HTRANS_o ==3'd2;req.ACCESS_o==read;req.HADDR_o==8;req.HSIZE_o==3'd2;})

        //   // Perform write or read operation based on DUT response
        //   if (req.ACCESS_o == write) begin
        //       `uvm_info("AHB Write Transaction", 
        //       $sformatf("Writing to address %0h: data %0h", req.HADDR_o, 
        //       req.HWDATA_o), UVM_LOW)
        //       req.RESP_i <= okay;
        //   end
        //   else begin
        //       `uvm_info("AHB Read Transaction",
        //       $sformatf("Reading from address %0h", req.HADDR_o), UVM_LOW)
  
        //       req.HRDATA_i = $urandom();
        //       `uvm_info("DATA_SEQ", $sformatf("Read from address %0h Data is:%0h ",
        //       req.HADDR_o, req.HRDATA_i), UVM_LOW)
        //   end
        //   req.HREADY_i <= 1'b1;
          
        // // Start new sequence to drive the values to the DUT
        // start_item(rsp);
        // rsp.copy(req);
        // rsp.print();
        // finish_item(rsp);
    //   end
       
    endtask
  endclass : read_write_seq