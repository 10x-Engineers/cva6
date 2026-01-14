class axi_s_seq extends uvm_sequence #(axi_s_seq_item);
    `uvm_object_utils(axi_s_seq)

    function new(string name = "axi_s_seq");
        super.new(name);
    endfunction


    logic [AXI_ADDR_WIDTH-1:0] addr_queue[$]; // Queue to store addresses

    function gen_axi_address_queue(
    input logic [AXI_ADDR_WIDTH-1:0] addr,       // Starting AXI address
    input logic [1:0]  burst,      // Burst type
    input logic [7:0]  length,     // Number of transfers (burst length)
    input logic [2:0]  size        // Transfer size (2^size bytes per transfer)
);
    
    int num_bytes;
    int wrap_boundary;
    longint wrap_addr=addr;
    
    num_bytes = 1 << size; // Convert size to number of bytes per transfer

    wrap_boundary = (addr/(num_bytes*(length+1))) * (num_bytes*(length+1));
    
    addr_queue.push_back(addr); // Push first address


    
    for (int i = 1; i <= length; i++) begin
        case (burst)
            2'b00: // Fixed burst
                addr_queue.push_back(addr); 
            
            2'b01: // Incrementing burst
                addr_queue.push_back(addr + i * num_bytes);
            
            2'b10: // Wrapping burst
            begin
                if (addr + i * num_bytes  == wrap_boundary + (num_bytes * (length+1))) begin
                    wrap_addr = wrap_boundary;   
                end
                else begin
                    wrap_addr = wrap_addr + num_bytes;   
                end
                    addr_queue.push_back(wrap_addr);
            end
        endcase
    end
endfunction

endclass
