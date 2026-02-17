/*************************************************************************
   > File Name:   axi_seq_item.sv
   > Description: The AXI Sequence Item is a UVM class defining randomized AXI4 transactions with constraints 
                  to ensure protocol compliance and diverse test coverage.
   > Author:      Ahmed Raza
   > Modified:    Malik Faayez Muhammad
   > Mail:        ahmed.raza@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef AXI_SEQ_ITEM
`define AXI_SEQ_ITEM

// Enums for Readibility
typedef enum bit [1:0] {FIXED, INCR, WRAP} burst_type;
typedef enum bit [1:0] {OKAY, EXOKAY, SLVERR, DECERR} response_type;
typedef enum bit {READ_TRAN, WRITE_TRAN} operation_type;

// AXI Sequence Item Class
class axi_seq_item extends uvm_sequence_item;

  bit has_burst_length ;                                            // flag to notify I burst_length is assigned in a test case

  // Randomized variables
  rand bit    [bus_params_pkg::BUS_AW-1:0] addr;                     // Address        
  rand  bit [bus_params_pkg::BUS_IDW-1:0]  id;                       // Transaction ID
  rand   int                               size;                     // Data size
  rand   burst_type                        burst;                    // Burst type      
  rand   bit [7:0]                         data[];                   // Data array
  response_type                            response;                 // Response type   
  rand  operation_type                     access;                   // Operation type     
  rand   bit [7:0]                         burst_length;             // Burst length      
  bit   [bus_params_pkg::BUS_AW-1:0]       aligned_addr;             // Aligned address
  bit   [bus_params_pkg::BUS_DS-1:0]       awsize_val;               // AWSIZE value
  bit   [bus_params_pkg::BUS_DBW-1:0]      write_strobe[1023:0];     // Write strobe array
  bit   [bus_params_pkg::BUS_DW-1:0]       write_data[$];            // Write data array
  bit                                      last;                     // Check last entry
  rand bit [bus_params_pkg::BUS_U_R-1:0]   r_user;                   // For USER custom
  rand bit [bus_params_pkg::BUS_U_W-1:0]   w_user;                   // For USER custom
  rand bit [2:0]                           prot;                     // For Protection
  rand bit [3:0]                           region;                   // For Region
  rand bit [3:0]                           qos;                      // For QOS
  rand bit                                 bready;                   // Write Response 
  rand bit                                 aw_valid;                 // Write Address Valid 
  rand bit                                 w_valid;                  // Write Data Valid         
  rand bit                                 ar_valid;                 // Read Address Valid 
  bit                                      b_valid;                  // Write Response Valid 
  bit                                      r_valid;                  // Read Response Valid 
  rand bit                                 rready;                   // Read Response 




  // Constraints
  //TODO:commented for general test
  // constraint data_con { data.size inside {[1:1024]}; }
  constraint size_con { size inside {1, 2, 4, 8, 16}; }
  constraint wr_res_con { bready == 1; }
  constraint rd_res_con { rready == 1; }
  constraint wr_addr_valid_con { aw_valid == 1; }
  constraint wr_data_valid_con { w_valid == 1; }
  constraint rd_addr_valid_con { ar_valid == 1; }


  // UVM Macros for field registration
  `uvm_object_utils_begin(axi_seq_item)
    `uvm_field_int(addr, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(id, UVM_DEFAULT)
    `uvm_field_int(size, UVM_DEFAULT)
    `uvm_field_int(prot, UVM_DEFAULT)
    `uvm_field_int(region, UVM_DEFAULT)
    `uvm_field_int(qos, UVM_DEFAULT)
    `uvm_field_enum(burst_type, burst, UVM_DEFAULT)
    `uvm_field_enum(response_type, response, UVM_DEFAULT)
    `uvm_field_enum(operation_type, access, UVM_DEFAULT)
    `uvm_field_sarray_int(data, UVM_DEFAULT)
    `uvm_field_sarray_int(write_data, UVM_DEFAULT)
  `uvm_object_utils_end

  // Constructor
  function new(string name="axi_seq_item");
    super.new(name);
  endfunction

// Function to calculate AWSIZE based on size
function bit [2:0] awsize();
  case (this.size)
    1   : return 3'b000; 
    2   : return 3'b001; 
    4   : return 3'b010; 
    8   : return 3'b011; 
    16  : return 3'b100; 
    32  : return 3'b101; 
    64  : return 3'b110; 
    128 : return 3'b111; 
    default: return 3'bxxx; // Invalid size
  endcase
endfunction


// Function to find Length of the Burst from AxSize and Data size
function void burst_strobe_data_gen();

      // Local variables
    int aligned_address;         // Address aligned to the size of the data
    int remaining_data_size;    
    int temp_length;             
    bit [1:0] address_alignment;
    int i = 0;
    int aligned_add;
    int data_index = 0;

  
    address_alignment = this.addr[1:0]; // Extract lower 2 bits of the address for alignment
    // remaining_data_size = this.data.size - (this.size * (address_alignment % this.size));

    temp_length = ((this.data.size % this.size) == 0) ? 
                  (this.data.size / this.size) - 1: 
                  ((this.data.size / this.size));
    if(this.has_burst_length==0)begin
      this.burst_length = temp_length; // Final burst length includes the initial beat
      // $display("seq_item:: %x",this.burst_length);
    end
    aligned_add =this.addr & ~(this.size - 1);


    // If transaction is WRITE, then generate strobe and data
    if (this.access == WRITE_TRAN) begin
        int rem = this.addr % this.size;///////
        for (int j = this.addr % this.size; j < (this.size); j++) begin//////
          this.write_strobe[i][j] = 1;
        end
    
      for (int k = 1; k <= this.burst_length; k++) begin
          aligned_add = aligned_add + this.size;
          i = i + 1;
          if (k == (this.burst_length)) begin
            ///////
              for (int l = aligned_add % this.size; l < (((aligned_add % this.size) + ((this.data.size-(addr%this.size))%this.size) == 0) ? this.size : (remaining_data_size % this.size)); l++) begin
                  this.write_strobe[i][l] = 1;
              end
          end 
          else begin
              for (int l = aligned_add % this.size; l < (aligned_add % this.size) + this.size; l++) begin///////
                  this.write_strobe[i][l] = 1;
              end
          end
      end


      /*------------------------------------------------------------------------------
      Generate write data:
        This code generates the write_data for each burst beat by iterating 
        through all valid byte positions marked by write_strobe. It maps the corresponding bits 
        from the data array into the appropriate positions in write_data, incrementing the data_index 
        for each byte processed.
      ------------------------------------------------------------------------------*/

        for (int beat_index = 0; beat_index <= this.burst_length; beat_index++) begin
            for (int byte_index = 0; byte_index < this.size; byte_index++) begin//////
                if (this.write_strobe[beat_index][byte_index] == 1'b1) begin
                    for (int bit_index = 0; bit_index < 8; bit_index++) begin
                        this.write_data[beat_index][(byte_index * 8) + bit_index] = this.data[data_index][bit_index];
                    end
                    data_index++;
                end
            end
        end
      
    end
    endfunction

  // Post-randomization function to calculate AWSIZE, Burst Length, Strobe and WDATA
  function void post_randomize();
    this.awsize_val = awsize();    // Compute AWSIZE using the size value
    burst_strobe_data_gen();
  endfunction
  
endclass

`endif


