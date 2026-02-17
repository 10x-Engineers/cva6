// /*************************************************************************
//    File Name:   top_adapter.sv
//    Description: Adapter to convert date from reg to bus and bus to reg.
//    Author:      Malik Faayez Muhammad
//    Modified:    Malik Faayez Muhammad
//    Mail:        faayez.muhammad@10xengineers.ai
//    ---------------------------------------------------------------
//    Copyright   (c)2025 10xEngineers
//    ---------------------------------------------------------------
// ************************************************************************/

// class top_adapter extends uvm_reg_adapter;
//   `uvm_object_utils(top_adapter);

//       //---------------------------------------
//       // Constructor
//       //---------------------------------------
//       function new (string name = "top_adapter");
//         super.new (name);
//         this.provides_responses = 1; // Tell reg model: wait for responses
//       endfunction

//       //---------------------------------------
//       // reg2bus method
//       //---------------------------------------
//       function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
//       ahb_seq_item tr;

//       tr = ahb_seq_item::type_id::create("tr");

//       //write/read channel

//       tr.ACCESS_o   = (rw.kind == UVM_WRITE) ? 1'b1 : 1'b0;
//       tr.HADDR_o     = rw.addr;
//       tr.HWDATA_o    = rw.data;

//       return tr;
//     endfunction

//     function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
//       ahb_seq_item tr;

//       assert($cast(tr, bus_item)) // assert that bus_item is a transaction
//       else `uvm_fatal("", "A bad thing has just happened in top_adapter")
//       $display("BUS2REG::::%h",tr.HRDATA_i);
//       rw.kind = (tr.ACCESS_o == 1'b1) ? UVM_WRITE : UVM_READ; // update kind in register transaction based on bus transaction type
//       rw.data = tr.HRDATA_i; // update data in register
//       rw.addr = tr.HADDR_o; // update address in register
//       rw.status = UVM_IS_OK; // update status
//     endfunction

//   endclass

class top_adapter extends uvm_reg_adapter;
  `uvm_object_utils(top_adapter);

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new (string name = "top_adapter");
    super.new(name);
    this.provides_responses = 1; // Tell reg model: wait for responses
  endfunction

  //---------------------------------------
  // reg2bus : RAL -> Bus
  //---------------------------------------
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    ahb_seq_item tr;

    tr = ahb_seq_item::type_id::create("tr");

    tr.ACCESS_o  = (rw.kind == UVM_WRITE) ? 1'b1 : 1'b0;
    tr.HADDR_o   = rw.addr;
    tr.HWDATA_o  = rw.data;

    `uvm_info("TOP_ADAPTER",
              $sformatf("reg2bus: kind=%s addr=0x%0h data=0x%0h",
                        (rw.kind==UVM_WRITE)?"WRITE":"READ",
                        rw.addr, rw.data),
              UVM_HIGH)

    return tr;
  endfunction

  //---------------------------------------
  // bus2reg : Bus -> RAL
  //---------------------------------------
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    ahb_seq_item tr;

    if (!$cast(tr, bus_item)) begin
      `uvm_fatal("TOP_ADAPTER", "bus2reg: cast failed, got wrong type of transaction")
    end

    // update reg bus op
    rw.kind   = (tr.ACCESS_o == 1'b1) ? UVM_WRITE : UVM_READ;
    rw.addr   = tr.HADDR_o;
    rw.data   = tr.HRDATA_i;
    rw.status = UVM_IS_OK;

    `uvm_info("TOP_ADAPTER",
              $sformatf("bus2reg: kind=%s addr=0x%0h data=0x%0h HRDATA_i=0x%0h",
                        (rw.kind==UVM_WRITE)?"WRITE":"READ",
                        rw.addr, rw.data, tr.HRDATA_i),
              UVM_HIGH)
  endfunction

endclass
