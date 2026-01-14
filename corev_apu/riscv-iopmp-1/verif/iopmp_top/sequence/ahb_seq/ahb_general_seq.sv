

class ahb_general_seq extends uvm_sequence #(ahb_seq_item);
    `uvm_object_utils(ahb_general_seq)
  
    // Sequence item handle and Memory Handle
    ahb_seq_item req;
    ahb_seq_item transac;
    //------------------------------------------------------------------------------
    // Constructor: new
    // Default constructor with an optional name parameter.
    //------------------------------------------------------------------------------
    function new(string name = "ahb_general_seq");
      super.new(name);
      transac = ahb_seq_item::type_id::create("transac");
    endfunction
  
    //------------------------------------------------------------------------------
    // Task: body
    // Slave Sequence Method Implemented
    //------------------------------------------------------------------------------
    task body();
      req = ahb_seq_item::type_id::create("req");
   
      `uvm_do_with (req, {req.HBURST_o==0; req.HTRANS_o ==3'd2;req.ACCESS_o==transac.ACCESS_o; req.HWDATA_o == transac.HWDATA_o; req.HADDR_o == transac.HADDR_o;req.HSIZE_o==3'd2; req.HPROT_o == 'd3; req.HMASTLOCK_o == 0; req.HSEL_o == 1;})

    endtask
endclass : mdstall_reg_read