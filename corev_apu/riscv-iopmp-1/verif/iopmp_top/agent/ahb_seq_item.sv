/*************************************************************************
   > File Name:   ahb_seq_item.sv
   > Description: Defines the AHB sequence item class with randomized fields 
                  and UVM field macros for AXI-to-AHB bridge verification.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef AHB_SEQ_ITEM
`define AHB_SEQ_ITEM

//-----------------------------------------------------------------------------
// Enumerations for access type and response type
//-----------------------------------------------------------------------------
typedef enum {read, write} access_type;                  // Read/Write operations
typedef enum bit {okay, error} resp_type;          // Response type
import bus_params_pkg::*;
//-----------------------------------------------------------------------------
// AHB Sequence Item Class
//-----------------------------------------------------------------------------
class ahb_seq_item extends uvm_sequence_item;

    //-------------------------------------------------------------------------
    // Variables
    //-------------------------------------------------------------------------
    resp_type RESP_i;                                 // Response input
    rand access_type ACCESS_o;                        // Access type (read/write)

    rand bit [bus_params_pkg::BUS_AW-1:0] HADDR_o;    // Address bus
    rand bit [bus_params_pkg::BUS_DW-1:0] HWDATA_o;   // Write data bus
    bit [bus_params_pkg::BUS_DW-1:0] HRDATA_i;        // Read data bus
    rand bit [2:0] HSIZE_o;                           // Transfer size
    rand bit [2:0] HBURST_o;                          // Burst type
    rand bit [1:0] HTRANS_o;                          // Transfer type
    rand bit [3:0] HPROT_o;                          // Transfer type
    rand bit       HMASTLOCK_o;                          // Transfer type
    rand bit HSEL_o;                                     // Ready signal to master
    bit HREADY_i;                                     // Ready signal to master
    constraint mast_lock { HMASTLOCK_o == 0; }
    // constraint prot { HPROT_o == 0; }
    constraint hsel { HSEL_o == 1; }
    
    //-------------------------------------------------------------------------
    // Field Registration Macros
    //-------------------------------------------------------------------------
    `uvm_object_utils_begin(ahb_seq_item)
        `uvm_field_enum(resp_type, RESP_i, UVM_DEFAULT)      // Response field
        `uvm_field_enum(access_type, ACCESS_o, UVM_DEFAULT)  // Access type field
        `uvm_field_int(HADDR_o, UVM_DEFAULT)                 // Address field
        `uvm_field_int(HWDATA_o, UVM_DEFAULT)                // Write data field
        `uvm_field_int(HRDATA_i, UVM_DEFAULT)                // Read data field
        `uvm_field_int(HSIZE_o, UVM_DEFAULT)                 // Transfer size field
        `uvm_field_int(HBURST_o, UVM_DEFAULT)                // Burst type field
        `uvm_field_int(HTRANS_o, UVM_DEFAULT)                // Transfer type field
        `uvm_field_int(HPROT_o, UVM_DEFAULT)                // Transfer type field
        `uvm_field_int(HMASTLOCK_o, UVM_DEFAULT)                // Transfer type field
        `uvm_field_int(HREADY_i, UVM_DEFAULT)                // Ready signal field
    `uvm_object_utils_end

    //-------------------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------------------
    function new(string name = "ahb_seq_item");
        super.new(name);
    endfunction

endclass

`endif