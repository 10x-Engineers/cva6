/*************************************************************************
   > File Name:   configurations.sv
   > Description: This file implements the AXI to AHB testbench, which 
                  initializes the environment and sequences to verify the
                  AXI to AHB bridge functionality.
   > Author:      Ahmed Raza
   > Modified:    Ahmed Raza
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2024 10xEngineers
   ---------------------------------------------------------------
**********************************************************************/
`include "uvm_macros.svh"
import uvm_pkg::*;

class configurations extends uvm_object;

   `uvm_object_utils(configurations)

   // Constructor
   function new(string name = "configurations");
      super.new(name);
   endfunction: new

   // Data Members
   uvm_active_passive_enum active = UVM_ACTIVE;
   integer Iterations;

endclass: configurations
