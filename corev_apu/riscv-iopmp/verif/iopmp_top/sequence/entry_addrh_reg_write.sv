

class entry_addrh_reg_write extends uvm_sequence #(ahb_seq_item);
    `uvm_object_utils(entry_addrh_reg_write)
  
    // Sequence item handle and Memory Handle
    ahb_seq_item req;
    bit[6:0] index;
    bit [31:0] wdata;
    //------------------------------------------------------------------------------
    // Constructor: new
    // Default constructor with an optional name parameter.
    //------------------------------------------------------------------------------
    function new(string name = "entry_addrh_reg_write");
      super.new(name);
    endfunction
  
    //------------------------------------------------------------------------------
    // Task: body
    // Slave Sequence Method Implemented
    //------------------------------------------------------------------------------
    task body();
      req = ahb_seq_item::type_id::create("req");
   
      `uvm_do_with (req, {req.HBURST_o==0 && req.HTRANS_o ==3'd2;req.ACCESS_o==write;req.HADDR_o==`ENTRY_OFFSET+4+(index*16);req.HSIZE_o==3'd2;req.HWDATA_o == wdata;})

    endtask
  endclass : entry_addrh_reg_write