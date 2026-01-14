

class mdstall_reg_read extends uvm_sequence #(ahb_seq_item);
    `uvm_object_utils(mdstall_reg_read)
  
    // Sequence item handle and Memory Handle
    ahb_seq_item req;
    //------------------------------------------------------------------------------
    // Constructor: new
    // Default constructor with an optional name parameter.
    //------------------------------------------------------------------------------
    function new(string name = "mdstall_reg_read");
      super.new(name);
    endfunction
  
    //------------------------------------------------------------------------------
    // Task: body
    // Slave Sequence Method Implemented
    //------------------------------------------------------------------------------
    task body();
      req = ahb_seq_item::type_id::create("req");
   
      `uvm_do_with (req, {req.HBURST_o==0 && req.HTRANS_o ==3'd2;req.ACCESS_o==read;req.HADDR_o==16'h30;req.HSIZE_o==3'd2;})

    endtask
endclass : mdstall_reg_read