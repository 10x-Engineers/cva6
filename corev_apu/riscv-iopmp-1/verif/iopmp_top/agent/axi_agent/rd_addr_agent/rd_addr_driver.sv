/*************************************************************************
   > File Name:   rd_addr_driver.sv
   > Description: This class implements a read address driver for an AXI protocol
                  interface. It drives address and control signals based on received 
                  sequence items and manages the AXI handshake.
   > Author:      Ahmed Raza
   > Modified:    Malik Faayez Muhammad
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/


`ifndef RD_ADDR_DRIVER
`define RD_ADDR_DRIVER

class rd_addr_driver extends uvm_driver #(axi_seq_item);

  `uvm_component_utils(rd_addr_driver)
  virtual axi_interface axi_vif;         // Virtual interface for AXI signals

  // Constructor
  function new(string name = "rd_addr_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //-----------------------------------------------------------------------------
  // Build Phase
  //-----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), "Build phase completed", UVM_LOW)
  endfunction

  //-----------------------------------------------------------------------------
  // Connect Phase
  //-----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual axi_interface#(.ID_WIDTH(`AXI_ID_WIDTH),.ADDR_WIDTH(`AXI_ADDR_WIDTH),.R_USER_WIDTH(`R_USER_WIDTH),.W_USER_WIDTH(`W_USER_WIDTH),.DATA_WIDTH(`AXI_DATA_WIDTH)))::get(null, "*", "axi_vif", axi_vif))
      `uvm_error(get_name(), "Failed to connect axi_vif interface")
  endfunction
 
  //-----------------------------------------------------------------------------
  // Reset Phase
  //-----------------------------------------------------------------------------
  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    axi_vif.reset_axi();  // Reset the Axi signals to defualt
   `uvm_info(get_name(), "Reset phase: Signals reset to default", UVM_LOW)
    phase.drop_objection(this);
  endtask : reset_phase
 
  //-----------------------------------------------------------------------------
  // Post Reset Phase
  //-----------------------------------------------------------------------------
  task post_reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    axi_vif.post_reset_axi();   // Wait for reset conditions to over
    `uvm_info(get_name(),$sformatf("Reset Condition Over"), UVM_LOW)
    phase.drop_objection(this);
  endtask : post_reset_phase

  //-----------------------------------------------------------------------------
  // Main Phase
  //-----------------------------------------------------------------------------
  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "Main Phase Started", UVM_LOW)
    forever begin
      drive_read_addr();
    end
    `uvm_info(get_name(), $sformatf("Main Phase Ended"), UVM_LOW)
  endtask

  //-----------------------------------------------------------------------------
  // Task drive_read_addr
  //-----------------------------------------------------------------------------
  task drive_read_addr();

    // Retrieve the next sequence item
    seq_item_port.get_next_item(req);
      `uvm_info(get_name(), "Driving read address transaction", UVM_LOW)
       // Drive AXI read address and control signals
       axi_vif.ARBURST <= req.burst;
       axi_vif.ARADDR  <= req.addr;
       axi_vif.ARID    <= req.id;
       axi_vif.ARUSER  <= req.r_user;
       axi_vif.ARSIZE  <= req.awsize_val;
       axi_vif.ARVALID <= req.ar_valid;
       axi_vif.ARLEN   <= req.burst_length;;
       axi_vif.ARPROT  <= req.prot;
       axi_vif.ARREGION  <= req.region;
       axi_vif.ARQOS  <= req.qos;
       wait(axi_vif.ARREADY);
       

    `uvm_info(get_type_name(), $sformatf("DRIV LENGTH:%X\n",req.burst_length), UVM_LOW)
    `uvm_info(get_name(), "Read address transaction completed", UVM_LOW)
    req.print();
    seq_item_port.item_done(); 
    @(posedge axi_vif.ACLK);
    req.print();
  endtask
endclass

`endif

