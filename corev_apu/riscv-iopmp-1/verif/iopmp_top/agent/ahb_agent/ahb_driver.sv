//     /*************************************************************************
//    > File Name:   ahb_driver.sv
//    > Description: This file implements the AHB driver class, which extends
//                   the UVM driver to handle AHB transactions based on sequence items.
//    > Author:      Ahmed Raza
//    > Modified:    Ahmed Raza
//    > Mail:        ahmed.raza@10xengineers.ai
//    ---------------------------------------------------------------
//    Copyright   (c)2024 10xEngineers
//    ---------------------------------------------------------------
// ************************************************************************/

// `ifndef AHB_DRIVER
// `define AHB_DRIVER

// `define AHB_DRIV_IF ahb_vif.driver_cb

// class ahb_driver extends uvm_driver #(ahb_seq_item);

//   `uvm_component_utils(ahb_driver)

//   logic [2:0] HSIZE;
//   logic [2:0] HBURST;
//   logic [1:0] HTRANS;
//   logic [3:0] HPROT;
//   logic       HMASTLOCK;
//   logic       HSEL;

//   ahb_seq_item req;
//   // ahb_seq_item rsp;

//   virtual ahb_interface ahb_vif;        // Virtual interface for AHB protocol
//   virtual axi_interface axi_vif;        // Virtual interface for AXI protocol


//   // Constructor
//   function new(string name = "ahb_driver", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction : new

//   //-----------------------------------------------------------------------------
//   // Build Phase
//   //-----------------------------------------------------------------------------
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     `uvm_info(get_name(), "BUILD PHASE @ Driver", UVM_HIGH)
//   endfunction : build_phase

//   //-----------------------------------------------------------------------------
//   // Connect Phase
//   //-----------------------------------------------------------------------------
//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     if (!uvm_config_db#(virtual ahb_interface#(.ADDR_WIDTH(`AHB_ADDR_WIDTH),.DATA_WIDTH(`AHB_DATA_WIDTH)))::get(this, "*", "ahb_vif", ahb_vif))
//       `uvm_error("Config Error", "Configuration Failed @ Connect Phase in AHB Driver")
//     if (!uvm_config_db#(virtual axi_interface#(.ID_WIDTH(`AXI_ID_WIDTH),.ADDR_WIDTH(`AXI_ADDR_WIDTH),.R_USER_WIDTH(`R_USER_WIDTH),.W_USER_WIDTH(`W_USER_WIDTH),.DATA_WIDTH(`AXI_DATA_WIDTH)))::get(this, "*", "axi_vif", axi_vif))
//       `uvm_error("Config Error", "Configuration Failed @ Connect Phase in axi Driver")
//   endfunction : connect_phase

//   //-----------------------------------------------------------------------------
//   // Reset Phase
//   //-----------------------------------------------------------------------------
//   task reset_phase(uvm_phase phase);
//     phase.raise_objection(this);

//     ahb_vif.reset_ahb();  // Reset AHB by setting the signals to default

//     `uvm_info(get_name(), "Reset phase: Signals reset to default", UVM_HIGH)
//     phase.drop_objection(this);
//   endtask : reset_phase

//   //-----------------------------------------------------------------------------
//   // Post Reset Phase
//   //-----------------------------------------------------------------------------
//   task post_reset_phase(uvm_phase phase);
//     phase.raise_objection(this);

//     ahb_vif.post_reset_ahb(); // Wait for reset conditions to over

//     `uvm_info(get_name(),$sformatf("Reset Condition Over"), UVM_HIGH)
//     phase.drop_objection(this);
//   endtask : post_reset_phase

//   //-----------------------------------------------------------------------------
//   // Main Phase
//   //-----------------------------------------------------------------------------
//   task main_phase(uvm_phase phase);
//     `uvm_info(get_name(), "Main Phase Started", UVM_HIGH)
//     forever begin
//       seq_item_port.get_next_item(req);
//       fork
//         drive();
//         begin
//           if(ahb_vif.HWRITE == 0)begin
//             #1;
//             if(ahb_vif.HTRANS==2) begin
//               #1;
//                     @(posedge ahb_vif.HCLK);
//                     @(ahb_vif.HREADY == 1)
//                     req.HRDATA_i = ahb_vif.HRDATA;
//                     req.RESP_i   = (ahb_vif.HRESP == 1) ? error : okay;
//                     `uvm_info(get_type_name (), $sformatf ("Drive_dAta_Read, %h",req.HRDATA_i), UVM_HIGH);

//             end
//           end
//         end
//       join
//       `uvm_info(get_name(), "AHB Driver info", UVM_HIGH)
//       req.print();
//       seq_item_port.item_done(req);


//       // Reset all signals to 0 after the transfer is complete
//       `AHB_DRIV_IF.HWRITE <= 0;
//       `AHB_DRIV_IF.HSIZE  <= 0;
//       `AHB_DRIV_IF.HBURST <= 0;
//       `AHB_DRIV_IF.HTRANS <= 0;

//     end
//     `uvm_info(get_name(), "Main Phase Ended", UVM_HIGH)
//   endtask : main_phase

//   //-----------------------------------------------------------------------------
//   // Task: drive
//   //-----------------------------------------------------------------------------
//   task drive();


//     // Assign input signals to the sequence item's fields based on AHB interface
//     wait(ahb_vif.HREADY==1);
//     `AHB_DRIV_IF.HWRITE <= req.ACCESS_o;             // read/write access
//     `AHB_DRIV_IF.HADDR  <= req.HADDR_o;              // address bus value
//     `AHB_DRIV_IF.HSIZE  <= HSIZE;              // transfer size
//     `AHB_DRIV_IF.HBURST <= HBURST;             // burst type
//     `AHB_DRIV_IF.HTRANS <= HTRANS;             // trans type
//     `AHB_DRIV_IF.HPROT <= HPROT;               // prot type
//     `AHB_DRIV_IF.HMASTLOCK <= HMASTLOCK;       // mast lock type
//     `AHB_DRIV_IF.HSEL   <= HSEL;
//     // `AHB_DRIV_IF.HREADY_i   <= 1;
//     req.HRDATA_i = ahb_vif.HRDATA;
//     @(posedge ahb_vif.HCLK);
//     `AHB_DRIV_IF.HWDATA <= req.HWDATA_o;             // write data bus value

//    // Wait for the transfer to complete (HREADY high again)
//     wait(ahb_vif.HREADY == 1);
//     @(posedge ahb_vif.HCLK);


//   endtask : drive

// endclass : ahb_driver

// `endif

// // task monitor();
// //             `uvm_info(get_name(), "Monitoring ahb transactions", UVM_HIGH)
// //             // Address Phase, monitor control signals
// //         if (ahb_vif.HTRANS!=0 && ahb_vif.HREADY) begin
// //             ahb_mon_item.HADDR_o  = ahb_vif.HADDR;
// //             ahb_mon_item.ACCESS_o = (ahb_vif.HWRITE == 1)? write : read;
// //             ahb_mon_item.HBURST_o = ahb_vif.HBURST;
// //             ahb_mon_item.HSIZE_o  = ahb_vif.HSIZE;
// //             $display("AHB_MON::::");


// //             // Data Phase
// //             if(ahb_mon_item.ACCESS_o==write)begin
// //                 @(posedge ahb_vif.HCLK);
// //                 #1;
// //                 ahb_mon_item.HWDATA_o = ahb_vif.HWDATA;
// //                 `uvm_info(get_type_name (), $sformatf ("MON_dAta , %d",ahb_mon_item.HWDATA_o), UVM_HIGH);
// //                 if (ahb_vif.HREADY) begin
// //                     $display("AHB_MON::::");
// //                     ahb_mon_item.HTRANS_o = ahb_vif.HTRANS;
// //                     ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? error : okay;

// //                     ahb_ap.write(ahb_mon_item);
// //                     ahb_mon_item.print();  // Print the monitored data
// //                 end
// //             end else begin
// //                 if (ahb_vif.HTRANS==2) begin
// //                     @(posedge ahb_vif.HCLK);
// //                     @(ahb_vif.HREADY == 1)
// //                     ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? error : okay;
// //                     ahb_mon_item.HTRANS_o = ahb_vif.HTRANS;
// //                     ahb_mon_item.HRDATA_i = ahb_vif.HRDATA;
// //                     `uvm_info(get_type_name (), $sformatf ("MON_dAta_Read, %d",ahb_mon_item.HRDATA_i), UVM_HIGH);
// //                     ahb_ap.write(ahb_mon_item);
// //                     ahb_mon_item.print();  // Print the monitored data
// //                 end
// //             end
// //             // `uvm_info(get_type_name (), $sformatf ("MON_trans , %d",ahb_mon_item.HTRANS_o), UVM_HIGH);
// //         end
// //     endtask

`ifndef AHB_DRIVER
`define AHB_DRIVER

`define AHB_DRIV_IF ahb_vif.driver_cb

class ahb_driver extends uvm_driver #(ahb_seq_item);

  `uvm_component_utils(ahb_driver)

  // Bus control/defaults (can be configured externally)
  logic [2:0] HSIZE;
  logic [2:0] HBURST;
  logic [1:0] HTRANS; // NONSEQ by default for single transfers
  logic [3:0] HPROT;
  logic       HMASTLOCK;
  logic       HSEL;

  // current request item
  ahb_seq_item req;

  // Virtual interfaces
  virtual ahb_interface ahb_vif;
  virtual axi_interface axi_vif;

  // Constructor
  function new(string name = "ahb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), "BUILD PHASE @ Driver", UVM_HIGH)
  endfunction : build_phase

  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual ahb_interface#(.ADDR_WIDTH(`AHB_ADDR_WIDTH),.DATA_WIDTH(`AHB_DATA_WIDTH)))::get(this, "*", "ahb_vif", ahb_vif)) begin
      `uvm_error("AHB_DRV_CFG", "Configuration Failed: ahb_vif not found in config_db")
    end
    if (!uvm_config_db#(virtual axi_interface#(.ID_WIDTH(`AXI_ID_WIDTH),.ADDR_WIDTH(`AXI_ADDR_WIDTH),.R_USER_WIDTH(`R_USER_WIDTH),.W_USER_WIDTH(`W_USER_WIDTH),.DATA_WIDTH(`AXI_DATA_WIDTH)))::get(this, "*", "axi_vif", axi_vif)) begin
      // AXI vif optional in some setups
      `uvm_info("AHB_DRV_CFG", "axi_vif not found in config_db (maybe not used)", UVM_HIGH)
    end
  endfunction : connect_phase

  // Reset Phase
  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    if (ahb_vif != null) begin
      ahb_vif.reset_ahb();
      `uvm_info(get_name(), "Reset phase: AHB signals reset to default via vif", UVM_HIGH)
    end else begin
      `uvm_info(get_name(), "Reset phase: ahb_vif null, cannot reset signals", UVM_HIGH)
    end
    phase.drop_objection(this);
  endtask : reset_phase

  // Post Reset Phase
  task post_reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    if (ahb_vif != null) begin
      ahb_vif.post_reset_ahb();
      `uvm_info(get_name(), "Post reset phase: wait complete", UVM_HIGH)
    end
    phase.drop_objection(this);
  endtask : post_reset_phase

  // Main Phase - get items, drive, sample response, return same item
  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "Main Phase Started", UVM_HIGH)
    forever begin
      // get the next seq item (this is the same object sequencer/adapter expect)
      seq_item_port.get_next_item(req);

      // Log receipt of item
      `uvm_info("AHB_DRV", $sformatf("Got seq item: ADDR=%h ACCESS=%0b WDATA=%h",
                 req.HADDR_o, req.ACCESS_o, req.HWDATA_o), UVM_HIGH);

      // Perform the address+data phases and sample HRDATA/RESP BEFORE item_done
      drive(req);

      // After drive() returns, req.HRDATA_i / req.RESP_i should be valid
      `uvm_info("AHB_DRV", $sformatf("Completed transfer: ADDR=%h ACCESS=%0b HRDATA=%h RESP=%0d",
                 req.HADDR_o, req.ACCESS_o, req.HRDATA_i, req.RESP_i), UVM_HIGH);
      // req.print();

      // Return same object to sequencer - adapter/predictor will now see response
      seq_item_port.item_done(req);
      `uvm_info("AHB_DRV", $sformatf("item_done called for ADDR=%h (HRDATA=%h)", req.HADDR_o, req.HRDATA_i), UVM_HIGH);

      // Optionally a small idle gap
      // @(posedge ahb_vif.HCLK);
    end
    `uvm_info(get_name(), "Main Phase Ended", UVM_HIGH)
  endtask : main_phase

  // Drive task: drives address phase, waits for HREADY, samples data/resp
  task drive(ref ahb_seq_item req_item);
    // Defensive null check
    if (ahb_vif == null) begin
      `uvm_fatal("AHB_DRV", "ahb_vif is null in driver drive()")
    end

    // Align to clock edge before driving address
    @(posedge ahb_vif.HCLK);

    // DRIVE ADDRESS PHASE
    `AHB_DRIV_IF.HADDR  <= req_item.HADDR_o;
    `AHB_DRIV_IF.HWRITE <= req_item.ACCESS_o;    // 1 = write, 0 = read
    `AHB_DRIV_IF.HSIZE  <= HSIZE;
    `AHB_DRIV_IF.HBURST <= HBURST;
    `AHB_DRIV_IF.HTRANS <= HTRANS;               // NONSEQ/SEQ as set by driver defaults
    `AHB_DRIV_IF.HPROT  <= HPROT;
    `AHB_DRIV_IF.HMASTLOCK <= HMASTLOCK;
    `AHB_DRIV_IF.HSEL   <= 1'b1;

    `uvm_info("AHB_DRV", $sformatf("Address phase driven: ADDR=%h ACCESS=%0b", req_item.HADDR_o, req_item.ACCESS_o), UVM_HIGH);

    // If it's a write, present HWDATA (can be earlier or on data phase depending on BFM)
    if (req_item.ACCESS_o == write) begin
      // present write data before data phase sampling
      `AHB_DRIV_IF.HWDATA <= req_item.HWDATA_o;
      `uvm_info("AHB_DRV", $sformatf("Write presented: WDATA=%h", req_item.HWDATA_o), UVM_HIGH);
    end

    // Wait at least one cycle then wait for HREADY indicating data phase valid
    @(posedge ahb_vif.HCLK);

    // Wait until slave asserts HREADY (data phase active)
    do begin
      @(posedge ahb_vif.HCLK);
      `uvm_info("AHB_DRV", $sformatf("Waiting for HREADY: HREADY=%0b HRDATA=%h", ahb_vif.HREADY, ahb_vif.HRDATA), UVM_HIGH);
    end while (ahb_vif.HREADY == 0);

    // DATA PHASE: sample response/data now that HREADY==1
    if (req_item.ACCESS_o == write) begin
      // For a write, sample any response (HRESP) if needed
      req_item.RESP_i = (ahb_vif.HRESP == 1) ? error : okay;
      `uvm_info("AHB_DRV", $sformatf("Write data-phase complete: ADDR=%h RESP=%0d", req_item.HADDR_o, req_item.RESP_i), UVM_HIGH);
    end else begin
      // For a read, sample HRDATA
      req_item.HRDATA_i = ahb_vif.HRDATA;
      req_item.RESP_i   = (ahb_vif.HRESP == 1) ? error : okay;
      `uvm_info("AHB_DRV", $sformatf("Read data-phase sampled: ADDR=%h HRDATA=%h RESP=%0d",
                 req_item.HADDR_o, req_item.HRDATA_i, req_item.RESP_i), UVM_HIGH);
    end

    // Deassert transfer signals (back to IDLE)
    @(posedge ahb_vif.HCLK);
    `AHB_DRIV_IF.HTRANS <= 2'b00;
    `AHB_DRIV_IF.HSEL   <= 1'b0;
    `AHB_DRIV_IF.HWRITE <= 1'b0;

    // Small settle cycle
    @(posedge ahb_vif.HCLK);
  endtask : drive

endclass : ahb_driver

`endif
