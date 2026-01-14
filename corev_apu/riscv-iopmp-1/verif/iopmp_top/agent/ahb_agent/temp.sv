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
//     `uvm_info(get_name(), "BUILD PHASE @ Driver", UVM_LOW)
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

//     `uvm_info(get_name(), "Reset phase: Signals reset to default", UVM_LOW)
//     phase.drop_objection(this);
//   endtask : reset_phase

//   //-----------------------------------------------------------------------------
//   // Post Reset Phase
//   //-----------------------------------------------------------------------------
//   task post_reset_phase(uvm_phase phase);
//     phase.raise_objection(this);

//     ahb_vif.post_reset_ahb(); // Wait for reset conditions to over

//     `uvm_info(get_name(),$sformatf("Reset Condition Over"), UVM_LOW)
//     phase.drop_objection(this);
//   endtask : post_reset_phase

//   //-----------------------------------------------------------------------------
//   // Main Phase
//   //-----------------------------------------------------------------------------
//   task main_phase(uvm_phase phase);
//     `uvm_info(get_name(), "Main Phase Started", UVM_LOW)
//     forever begin
//       drive();
//     end
//     `uvm_info(get_name(), "Main Phase Ended", UVM_LOW)
//   endtask : main_phase

//   //-----------------------------------------------------------------------------
//   // Task: drive
//   //-----------------------------------------------------------------------------
//   task drive();

//     seq_item_port.get_next_item(req);
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

//     @(posedge ahb_vif.HCLK);
//     `AHB_DRIV_IF.HWDATA <= req.HWDATA_o;             // write data bus value

//    // Wait for the transfer to complete (HREADY high again)
//     wait(ahb_vif.HREADY == 1);
//     @(posedge ahb_vif.HCLK);

//     `uvm_info(get_name(), "AHB Driver info", UVM_LOW)
//     req.print();
//     seq_item_port.item_done();

//     // Reset all signals to 0 after the transfer is complete
//     `AHB_DRIV_IF.HWRITE <= 0;
//     `AHB_DRIV_IF.HSIZE  <= 0;
//     `AHB_DRIV_IF.HBURST <= 0;
//     `AHB_DRIV_IF.HTRANS <= 0;

//   endtask : drive

// endclass : ahb_driver

// `endif

`ifndef AHB_DRIVER
`define AHB_DRIVER

`include "ahb_seq_item.sv" // ensure sequence item is visible

`define AHB_DRIV_IF ahb_vif.driver_cb

class ahb_driver extends uvm_driver #(ahb_seq_item);

  `uvm_component_utils(ahb_driver)

  // Control signals are expected to be set by the test/environment (as you requested)
  logic [2:0] HSIZE;
  logic [2:0] HBURST;
  logic [1:0] HTRANS;
  logic [3:0] HPROT;
  logic       HMASTLOCK;
  logic       HSEL;

  // Local copies / state
  ahb_seq_item req;

  // Virtual interfaces
  virtual ahb_interface#(.ADDR_WIDTH(`AHB_ADDR_WIDTH), .DATA_WIDTH(`AHB_DATA_WIDTH)) ahb_vif;
  virtual axi_interface  axi_vif; // kept if you plan to bridge to AXI; unused here //why needed ?

  // Configurable timeout (clock cycles)
  int unsigned hready_timeout = 1000;

  // Constructor
  function new(string name = "ahb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), "BUILD PHASE @ Driver", UVM_LOW)
  endfunction : build_phase

  // Connect Phase - get virtual interface(s)
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (!uvm_config_db#(virtual ahb_interface#(.ADDR_WIDTH(`AHB_ADDR_WIDTH), .DATA_WIDTH(`AHB_DATA_WIDTH)))::get(this, "", "ahb_vif", ahb_vif)) begin
      `uvm_error("AHB_DRIVER", "uvm_config_db get failed for ahb_vif")
    end

    // AXI if present
    if (!uvm_config_db#(virtual axi_interface)::get(this, "", "axi_vif", axi_vif)) begin // ???????
      `uvm_info(get_name(), "No AXI VIF in config (ok if unused)", UVM_LOW)
    end
  endfunction : connect_phase

  // Reset Phase: reset driver-side view (calls into interface helper tasks if provided)
  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);

    if (ahb_vif != null) begin
      // If your interface has helper tasks, call them; otherwise deassert control signals
      `AHB_DRIV_IF.HADDR  <= '0;
      `AHB_DRIV_IF.HWRITE <= 1'b0;
      `AHB_DRIV_IF.HWDATA <= '0;
      `AHB_DRIV_IF.HTRANS <= 2'b00;
      `AHB_DRIV_IF.HSEL   <= 1'b0;
      `AHB_DRIV_IF.HSIZE  <= '0;
      `AHB_DRIV_IF.HBURST <= '0;
      `AHB_DRIV_IF.HPROT  <= '0;
      `AHB_DRIV_IF.HMASTLOCK <= 1'b0;
    end

    `uvm_info(get_name(), "Reset phase done", UVM_LOW)
    phase.drop_objection(this);
  endtask : reset_phase

  // Main Phase - keep driving until simulation stops; sequencer controls flow via get_next_item
  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "Main Phase Started", UVM_LOW)
    forever begin
      seq_item_port.get_next_item(req);
      fork
        drive();
        begin
          if(ahb_vif.HWRITE == 0)begin
            #1;
            if(ahb_vif.HTRANS==2) begin
              #1;
                    @(posedge ahb_vif.HCLK);
                    @(ahb_vif.HREADY == 1)
                    req.HRDATA_i = ahb_vif.HRDATA;
                    req.RESP_i   = (ahb_vif.HRESP == 1) ? ERROR : okay;
                    `uvm_info(get_type_name (), $sformatf ("Drive_dAta_Read, %h",req.HRDATA_i), UVM_NONE);

            end
          end
        end
      join
      `uvm_info(get_name(), "AHB Driver info", UVM_LOW)
      req.print();
      seq_item_port.item_done(req);


      // Reset all signals to 0 after the transfer is complete
      `AHB_DRIV_IF.HWRITE <= 0;
      `AHB_DRIV_IF.HSIZE  <= 0;
      `AHB_DRIV_IF.HBURST <= 0;
      `AHB_DRIV_IF.HTRANS <= 0;

    end
    `uvm_info(get_name(), "Main Phase Ended", UVM_LOW)
  endtask : main_phase

  // ---------- Public RAL-friendly API ----------
  // These tasks let a RAL adapter (or other code) perform synchronous bus accesses
  task automatic reg_write(logic [(`AHB_ADDR_WIDTH-1):0] addr,
                           logic [(`AHB_DATA_WIDTH-1):0] data,
                           input bit [2:0] size = 3'b010); // default word size if needed
    ahb_seq_item tmp;
    tmp = ahb_seq_item::type_id::create($sformatf("%s_reg_write_tmp", get_name()));
    tmp.ACCESS_o = write;
    tmp.HADDR_o  = addr;
    tmp.HWDATA_o = data;
    tmp.HSIZE_o  = size;
    // The test/env may have set HTRANS/HBURST/HPROT/HMASTLOCK/HSEL signals in driver already.
    // Use the bus_cycle helper to execute the cycle and return response.
    bus_cycle(tmp);
    if (tmp.RESP_i != OKAY) begin
      `uvm_warning(get_name(), $sformatf("reg_write to 0x%0h returned resp %00d", addr, tmp.RESP_i))
    end
  endtask : reg_write

  task automatic reg_read(logic [(`AHB_ADDR_WIDTH-1):0] addr,
                          output logic [(`AHB_DATA_WIDTH-1):0] data_out,
                          input bit [2:0] size = 3'b010);
    ahb_seq_item tmp;
    tmp = ahb_seq_item::type_id::create($sformatf("%s_reg_read_tmp", get_name()));
    tmp.ACCESS_o = read;
    tmp.HADDR_o  = addr;
    tmp.HSIZE_o  = size;

    bus_cycle(tmp);
    data_out = tmp.HRDATA_i;
    if (tmp.RESP_i != OKAY) begin
      `uvm_warning(get_name(), $sformatf("reg_read from 0x%0h returned resp %00d", addr, tmp.RESP_i))
    end
  endtask : reg_read

  // ---------- Core bus cycle helper ----------
  // Performs a full AHB transfer (single- or multi-beat) for the provided ahb_seq_item.
  // Updates the item with response/read-data.
  task automatic bus_cycle(inout ahb_seq_item item);
    int unsigned timeout_cnt;
    bit [(`AHB_ADDR_WIDTH-1):0] cur_addr;
    int beat;
    int beats_total;

    // Basic checks
    if (ahb_vif == null) begin
      `uvm_error(get_name(), "AHB VIF not set. Aborting bus_cycle.")
      return;
    end

    // Determine number of beats from HBURST (basic support: SINGLE, INCR/WRAP treated as single or as requested)
    // For now, support SINGLE and INCR-like single-beat; multi-beat behavior: if HBURST indicates multi-beat,
    // we assume HBURST == INCR4 or INCR8 etc. and step address by size each beat.
    // The test is responsible for setting HBURST in the driver (as you said). We'll honor HBURST but
    // default to single-beat if HBURST == 3'b000 (SINGLE).
    if (HBURST == 3'b000) begin
      beats_total = 1;
    end else begin
      // decode some common burst lengths for convenience (INCR4/INCR8/INCR16)
      case (HBURST)
        3'b001: beats_total = 2;   // example mapping if using special encodings in your env
        3'b010: beats_total = 4;   // treat as 4-beat
        3'b011: beats_total = 8;   // treat as 8-beat
        3'b100: beats_total = 16;  // treat as 16-beat
        default: beats_total = 1;  // conservative default
      endcase
    end

    // Starting address & beat loop
    cur_addr = item.HADDR_o;

    // --- Address Phase: present address/control on bus ---
    // Wait for a rising edge, then drive address-phase signals
    @(posedge ahb_vif.HCLK);
    `AHB_DRIV_IF.HADDR      <= cur_addr;
    `AHB_DRIV_IF.HWRITE     <= (item.ACCESS_o == write) ? 1'b1 : 1'b0;
    `AHB_DRIV_IF.HTRANS     <= HTRANS;     // from test/env
    `AHB_DRIV_IF.HSIZE      <= HSIZE;      // from test/env
    `AHB_DRIV_IF.HBURST     <= HBURST;     // from test/env
    `AHB_DRIV_IF.HPROT      <= HPROT;      // from test/env
    `AHB_DRIV_IF.HMASTLOCK  <= HMASTLOCK;  // from test/env
    `AHB_DRIV_IF.HSEL       <= HSEL;       // from test/env

    // Wait for address-phase HREADY (with timeout)
    timeout_cnt = 0;
    do begin
      @(posedge ahb_vif.HCLK);
      timeout_cnt++;
      if (timeout_cnt > hready_timeout) begin
        `uvm_error(get_name(), $sformatf("HREADY timeout in address phase for addr 0x%0h", item.HADDR_o));
        item.RESP_i = ERROR;
        return;
      end
    end while (!ahb_vif.HREADY);

    // Now perform data-phase(s)
    for (beat = 0; beat < beats_total; beat++) begin

      // If write: place HWDATA at start of data phase
      if (item.ACCESS_o == write) begin
        @(posedge ahb_vif.HCLK);
        `AHB_DRIV_IF.HWDATA <= item.HWDATA_o; // single-beat uses same data; multi-beat should update externally
      end else begin
        // For read, ensure no drive to HWDATA
        @(posedge ahb_vif.HCLK);
      end

      // Wait for data-phase HREADY (transfer completion)
      timeout_cnt = 0;
      do begin
        @(posedge ahb_vif.HCLK);
        timeout_cnt++;
        if (timeout_cnt > hready_timeout) begin
          `uvm_error(get_name(), $sformatf("HREADY timeout in data phase (beat %0d) for addr 0x%0h", beat, item.HADDR_o));
          item.RESP_i = ERROR;
          return;
        end
      end while (!ahb_vif.HREADY);

      // On completion of this beat sample response / data
      item.RESP_i  = ahb_vif.HRESP; // HRESP width must map to your resp_type enum (see seq_item)
      if (item.ACCESS_o == read) begin
        item.HRDATA_i = ahb_vif.HRDATA;
      end

      // Prepare for next beat: increment address by transfer size if HBURST indicates increment
      if (beat < beats_total-1) begin
        // increment address by (1 << HSIZE) bytes
        cur_addr = cur_addr + (1 << HSIZE);
        // drive next address on the next address-phase edge
        @(posedge ahb_vif.HCLK);
        `AHB_DRIV_IF.HADDR <= cur_addr;
        // HTRANS should be SEQ for subsequent beats if supported; we keep HTRANS as provided by test env
      end
    end // for beats

    // Deassert control signals on next clock to not hold bus
    @(posedge ahb_vif.HCLK);
    `AHB_DRIV_IF.HWRITE <= 1'b0;
    `AHB_DRIV_IF.HTRANS <= 2'b00;
    `AHB_DRIV_IF.HSEL   <= 1'b0;
    `AHB_DRIV_IF.HWDATA <= '0;

    // Ensure we normalize response enum if simulator uses different encoding:
    // Convert numeric HRESP to seq_item resp_type if needed:
    // (Assumes ahb_vif.HRESP is 2'b00 OKAY, 2'b01 ERROR, etc.)
    unique case (ahb_vif.HRESP)
      2'b00: item.RESP_i = OKAY;
      2'b01: item.RESP_i = ERROR;
      default: item.RESP_i = ERROR;
    endcase
  endtask : bus_cycle

  // ---------- Driver's main drive task (sequencer-driven) ----------
  task drive();
<<<<<<< Updated upstream


    // Assign input signals to the sequence item's fields based on AHB interface
    wait(ahb_vif.HREADY==1);
    `AHB_DRIV_IF.HWRITE <= req.ACCESS_o;             // read/write access
    `AHB_DRIV_IF.HADDR  <= req.HADDR_o;              // address bus value
    `AHB_DRIV_IF.HSIZE  <= HSIZE;              // transfer size
    `AHB_DRIV_IF.HBURST <= HBURST;             // burst type
    `AHB_DRIV_IF.HTRANS <= HTRANS;             // trans type
    `AHB_DRIV_IF.HPROT <= HPROT;               // prot type
    `AHB_DRIV_IF.HMASTLOCK <= HMASTLOCK;       // mast lock type
    `AHB_DRIV_IF.HSEL   <= HSEL;
    // `AHB_DRIV_IF.HREADY_i   <= 1;

    @(posedge ahb_vif.HCLK);
    `AHB_DRIV_IF.HWDATA <= req.HWDATA_o;             // write data bus value

   // Wait for the transfer to complete (HREADY high again)
    wait(ahb_vif.HREADY == 1);
    @(posedge ahb_vif.HCLK);


=======
    // get next item from sequencer
    seq_item_port.get_next_item(req);

    // Perform the bus cycle using the item (this will block until complete or timeout)
    bus_cycle(req);

    // Return response & mark item done
    // Put response so sequencer can read the updated item if it expects responses
    seq_item_port.put_response(req);
    seq_item_port.item_done(req);

    `uvm_info(get_name(), $sformatf("AHB Driver completed transaction: addr=0x%0h dir=%0d resp=%0d data=0x%0h",
                                   req.HADDR_o, req.ACCESS_o, req.RESP_i, req.HRDATA_i), UVM_LOW)
>>>>>>> Stashed changes
  endtask : drive

endclass : ahb_driver

`endif
<<<<<<< Updated upstream

// task monitor();
//             `uvm_info(get_name(), "Monitoring ahb transactions", UVM_LOW)
//             // Address Phase, monitor control signals
//         if (ahb_vif.HTRANS!=0 && ahb_vif.HREADY) begin
//             ahb_mon_item.HADDR_o  = ahb_vif.HADDR;
//             ahb_mon_item.ACCESS_o = (ahb_vif.HWRITE == 1)? write : read;
//             ahb_mon_item.HBURST_o = ahb_vif.HBURST;
//             ahb_mon_item.HSIZE_o  = ahb_vif.HSIZE;
//             $display("AHB_MON::::");


//             // Data Phase
//             if(ahb_mon_item.ACCESS_o==write)begin
//                 @(posedge ahb_vif.HCLK);
//                 #1;
//                 ahb_mon_item.HWDATA_o = ahb_vif.HWDATA;
//                 `uvm_info(get_type_name (), $sformatf ("MON_dAta , %d",ahb_mon_item.HWDATA_o), UVM_NONE);
//                 if (ahb_vif.HREADY) begin
//                     $display("AHB_MON::::");
//                     ahb_mon_item.HTRANS_o = ahb_vif.HTRANS;
//                     ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? ERROR : okay;

//                     ahb_ap.write(ahb_mon_item);
//                     ahb_mon_item.print();  // Print the monitored data
//                 end
//             end else begin
//                 if (ahb_vif.HTRANS==2) begin
//                     @(posedge ahb_vif.HCLK);
//                     @(ahb_vif.HREADY == 1)
//                     ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? ERROR : okay;
//                     ahb_mon_item.HTRANS_o = ahb_vif.HTRANS;
//                     ahb_mon_item.HRDATA_i = ahb_vif.HRDATA;
//                     `uvm_info(get_type_name (), $sformatf ("MON_dAta_Read, %d",ahb_mon_item.HRDATA_i), UVM_NONE);
//                     ahb_ap.write(ahb_mon_item);
//                     ahb_mon_item.print();  // Print the monitored data
//                 end
//             end
//             // `uvm_info(get_type_name (), $sformatf ("MON_trans , %d",ahb_mon_item.HTRANS_o), UVM_NONE);
//         end
//     endtask
=======
>>>>>>> Stashed changes


/*************************************************************************
   > File Name:   ahb_monitor.sv
   > Description: AHB protocol monitor for verifying write and read operations.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef AHB_MONITOR
`define AHB_MONITOR

`define MON_IF ahb_vif.monitor_cb

//-----------------------------------------------------------------------------
// Class: ahb_monitor
//-----------------------------------------------------------------------------
class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)

    virtual ahb_interface ahb_vif;
    ahb_seq_item ahb_mon_item;
    reg [31:0] h_addr_pre=0,h_addr_new=0;
    reg h_write_new=0,h_write_pre=0;
    reg [1:0] h_resp_new=0,h_resp_pre=0;
    reg [2:0] h_burst_pre, h_burst_new;
    reg [1:0] h_trans_pre, h_trans_new;
    reg [1:0] h_size_pre, h_size_new;

    // Analysis port
    uvm_analysis_port #(ahb_seq_item) ahb_ap;

    //-----------------------------------------------------------------------------
    // Function: new
    //-----------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //-----------------------------------------------------------------------------
    // Function: build_phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ahb_ap = new("ahb_ap", this);
        // ahb_ap_addr = new("ahb_ap_addr", this);
        ahb_mon_item = ahb_seq_item::type_id::create("ahb_mon_item", this);
    endfunction

    //-----------------------------------------------------------------------------
    // Function: connect_phase
    //-----------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (!uvm_config_db#(virtual ahb_interface#(.ADDR_WIDTH(`AHB_ADDR_WIDTH),.DATA_WIDTH(`AHB_DATA_WIDTH)))::get(this, "*", "ahb_vif", ahb_vif)) begin
            `uvm_fatal(get_name(), "Configuration failed for ahb_monitor")
        end
    endfunction

    //-----------------------------------------------------------------------------
    // Task: main_phase
    //-----------------------------------------------------------------------------
    task main_phase(uvm_phase phase);
    // @(posedge ahb_vif.HCLK);
        forever begin
            @(posedge ahb_vif.HCLK);
            monitor();
        end
    endtask

    //-----------------------------------------------------------------------------
    // Task: monitor
    //-----------------------------------------------------------------------------
    // task monitor();
    //         `uvm_info(get_name(), "Monitoring ahb transactions", UVM_LOW)
    //         // Address Phase, monitor control signals

    //         ahb_mon_item.HADDR_o  = ahb_vif.HADDR;
    //         ahb_mon_item.ACCESS_o = (ahb_vif.HWRITE == 1)? write : read;
    //         ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? ERROR : okay;
    //         ahb_mon_item.HBURST_o = ahb_vif.HBURST;
    //         ahb_mon_item.HTRANS_o = ahb_vif.HTRANS;
    //         ahb_mon_item.HSIZE_o  = ahb_vif.HSIZE;


    //         // Data Phase
    //         @(posedge ahb_vif.HCLK);
    //         if(ahb_mon_item.ACCESS_o==write)begin
    //             ahb_mon_item.HWDATA_o = ahb_vif.HWDATA;
    //             // $display("MON_DATA:::%h", ahb_mon_item.HWDATA_o );
    //             // $display("MON_ADDR:::%h", ahb_mon_item.HADDR_o );
    //             `uvm_info(get_type_name (), $sformatf ("MON_dAta , %d",ahb_mon_item.HWDATA_o), UVM_NONE);

    //         end else begin
    //             ahb_mon_item.HRDATA_i = ahb_vif.HRDATA;
    //         end
    //         // `uvm_info(get_type_name (), $sformatf ("MON_trans , %d",ahb_mon_item.HTRANS_o), UVM_NONE);
    //         if (ahb_vif.HREADY) begin
    //              $display("AHB_MON::::");
    //             ahb_ap.write(ahb_mon_item);
    //             ahb_mon_item.print();  // Print the monitored data
    //         end
    // endtask
    task monitor();
<<<<<<< Updated upstream
            `uvm_info(get_name(), "Monitoring ahb transactions", UVM_LOW)
            // Address Phase, monitor control signals
        if (ahb_vif.HTRANS!=0 && ahb_vif.HREADY) begin
            ahb_mon_item.HADDR_o  = ahb_vif.HADDR;
            ahb_mon_item.ACCESS_o = (ahb_vif.HWRITE == 1)? write : read;
            ahb_mon_item.HBURST_o = ahb_vif.HBURST;
            ahb_mon_item.HSIZE_o  = ahb_vif.HSIZE;
            ahb_mon_item.HRDATA_i = ahb_vif.HRDATA;
            ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? ERROR : okay;
            $display("AHB_MON::::");


            // Data Phase
            if(ahb_mon_item.ACCESS_o==write)begin
                @(posedge ahb_vif.HCLK);
                ahb_mon_item.HWDATA_o = ahb_vif.HWDATA;
                `uvm_info(get_type_name (), $sformatf ("MON_dAta , %h",ahb_mon_item.HWDATA_o), UVM_NONE);
                if (ahb_vif.HREADY) begin
                    $display("AHB_MON::::");
                    // ahb_mon_item.HTRANS_o = ahb_vif.HTRANS;
                    // ahb_mon_item.RESP_i   = (ahb_vif.HRESP == 1) ? ERROR : okay;
                end
            end else begin
                if (ahb_vif.HTRANS==2) begin
                    @(posedge ahb_vif.HCLK);
                    @(ahb_vif.HREADY == 1)
                    ahb_mon_item.HTRANS_o = ahb_vif.HTRANS;
                    `uvm_info(get_type_name (), $sformatf ("MON_dAta_Read, %h",ahb_mon_item.HRDATA_i), UVM_NONE);
                    // ahb_ap.write(ahb_mon_item);
                    // ahb_mon_item.print();  // Print the monitored data
                end
            end
            ahb_ap.write(ahb_mon_item);
            ahb_mon_item.print();  // Print the monitored data
            // `uvm_info(get_type_name (), $sformatf ("MON_trans , %d",ahb_mon_item.HTRANS_o), UVM_NONE);
=======
        forever begin
            // Wait for a valid transfer (Address Phase)
            @(posedge ahb_vif.HCLK);
            if (ahb_vif.HSEL && ahb_vif.HTRANS[1] && ahb_vif.HREADY) begin
                // Create new item for each transaction
                ahb_seq_item tr;
                tr = ahb_seq_item::type_id::create("tr", this);

                // Capture address phase info
                tr.HADDR_o   = ahb_vif.HADDR;
                tr.ACCESS_o  = (ahb_vif.HWRITE) ? write : read;
                tr.HBURST_o  = ahb_vif.HBURST;
                tr.HTRANS_o  = ahb_vif.HTRANS;
                tr.HSIZE_o   = ahb_vif.HSIZE;
                tr.HPROT_o   = ahb_vif.HPROT;
                tr.HMASTLOCK_o = ahb_vif.HMASTLOCK;

                // Move to data phase
                @(posedge ahb_vif.HCLK);

                // Capture data phase
                if (tr.ACCESS_o == write) begin
                    tr.HWDATA_o = ahb_vif.HWDATA;
                end else begin
                    tr.HRDATA_i = ahb_vif.HRDATA;
                end

                // Capture response (valid in data phase)
                tr.RESP_i   = (ahb_vif.HRESP == 1) ? ERROR : OKAY;
                tr.HREADY_i = ahb_vif.HREADY;

                // Publish transaction
                ahb_ap.write(tr);

                `uvm_info(get_type_name(),
                          $sformatf("Monitored AHB txn: ADDR=0x%h DATA=0x%h ACCESS=%s RESP=%0d",
                                    tr.HADDR_o,
                                    (tr.ACCESS_o == write) ? tr.HWDATA_o : tr.HRDATA_i,
                                    (tr.ACCESS_o == write) ? "WRITE" : "READ",
                                    tr.RESP_i),
                          UVM_MEDIUM)
            end
>>>>>>> Stashed changes
        end
    endtask

endclass

`endif

/*************************************************************************
   File Name:   top_adapter.sv
   Description: Adapter to convert date from reg to bus and bus to reg.
   Author:      Malik Faayez Muhammad
   Modified:    Malik Faayez Muhammad
   Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

class top_adapter extends uvm_reg_adapter;
    `uvm_object_utils(top_adapter);

        //---------------------------------------
        // Constructor
        //---------------------------------------
        function new (string name = "top_adapter");
          super.new (name);
          this.provides_responses = 1; // Tell reg model: wait for responses
        endfunction

        //---------------------------------------
        // reg2bus method
        //---------------------------------------
        function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        ahb_seq_item tr;
    <<<<<<< Updated upstream

        tr = ahb_seq_item::type_id::create("tr");

        //write/read channel

        tr.ACCESS_o   = (rw.kind == UVM_WRITE) ? 1'b1 : 1'b0;
        tr.HADDR_o     = rw.addr;
        tr.HWDATA_o    = rw.data;

    =======

        //uvm_reg_item item = get_item();

        tr = ahb_seq_item::type_id::create("tr");

        //write channel

        tr.ACCESS_o   = (rw.kind == UVM_WRITE) ? 1'b1 : 1'b0;

        // if(rw.kind == UVM_WRITE) tr.HADDR_o  = rw.addr;

        // if(tr.ACCESS_o == 1'b1) tr.HWDATA_o = rw.data;

        //READ CHANNEL
        // if(rw.kind == UVM_READ) tr.HADDR_o  = rw.addr;

        tr.HADDR_o     = rw.addr;
        tr.HWDATA_o    = rw.data;
        // tr.HSIZE_o     = HSIZE;
        // tr.HBURST_o    = HBURST;
        // tr.HTRANS_o    = HTRANS;
        // tr.HPROT_o     = HPROT;
        // tr.HMASTLOCK_o = HMASTLOCK;
        $display("I am in reg2bus write:: %h",tr.HWDATA_o);
        $display("I am in reg2bus read :: %h",tr.HRDATA_i);


    >>>>>>> Stashed changes
        return tr;
      endfunction

      // function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      //   ahb_seq_item tr;

      //   assert($cast(tr, bus_item)); // assert that bus_item is a transaction
      //   if(tr.HREADY_i)begin

      //     $display("I am in bus2reg");
      //     rw.kind = (tr.ACCESS_o == 1'b1) ? UVM_WRITE : UVM_READ; // update kind in register transaction based on bus transaction type
      //     rw.data =  (tr.ACCESS_o == 1'b1) ? tr.HWDATA_o : tr.HRDATA_i; // update data in register
      //     $display("I am in bus2reg write:: %h",tr.HWDATA_o);
      //     $display("I am in bus2reg read :: %h",tr.HRDATA_i);
      //     $display("I am in bus2reg rw.data :: %h",rw.data);
      //     rw.addr = tr.HADDR_o; // update address in register
      //     rw.status = UVM_IS_OK; // update status
      //   end
      // endfunction

      function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        ahb_seq_item tr;

    <<<<<<< Updated upstream
        assert($cast(tr, bus_item)) // assert that bus_item is a transaction
        else `uvm_fatal("", "A bad thing has just happened in top_adapter")
        $display("BUS2REG::::%h",tr.HRDATA_i);
        rw.kind = (tr.ACCESS_o == 1'b1) ? UVM_WRITE : UVM_READ; // update kind in register transaction based on bus transaction type
        rw.data = tr.HRDATA_i; // update data in register
        rw.addr = tr.HADDR_o; // update address in register
        rw.status = UVM_IS_OK; // update status
    =======
        if (!$cast(tr, bus_item)) begin
          `uvm_fatal("NOT_AHB", "Provided bus_item is not ahb_seq_item")
          return;
        end

        // Update rw.kind based on AHB write signal (or enum properly)
        if (tr.ACCESS_o == write) begin
          rw.kind = UVM_WRITE;
          rw.data = tr.HWDATA_o;
          $display("bus2reg: WRITE, HWDATA=%h", tr.HWDATA_o);
        end
        else begin
          rw.kind = UVM_READ;
          rw.data = tr.HRDATA_i;
          $display("bus2reg: READ, HRDATA=%h", tr.HRDATA_i);
        end

        rw.addr   = tr.HADDR_o;
        rw.status = UVM_IS_OK;

        $display("bus2reg: rw.data=%h", rw.data);
    >>>>>>> Stashed changes
      endfunction

    endclass
