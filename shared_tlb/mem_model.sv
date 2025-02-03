class mem_model extends uvm_object;

  `uvm_object_utils(mem_model);

  function new(string name = "mem_model");
    super.new(name);
  endfunction

  bit [63:0] sh_tlb_mem [63];
 // bit rep;

  function void write(input bit rep, bit [63:0] content);
      if (rep == 0) begin
        sh_tlb_mem[0] = content;
      end
     else if (rep == 1)
        sh_tlb_mem[1] = content;
      
      //have to be extend for all mem locations

  endfunction

  function bit [32:0] read(input bit [31:0] vaddr);
    bit [32:0] rd_data; //MSB indicates whether data was hit/found in the tlb or not
    bit [5:0] set_bit;
    set_bit = vaddr[17:12];
    for (int i=0; i<64; i++) begin
      if(sh_tlb_mem [i][46:41] == set_bit) begin
          if(sh_tlb_mem [i][60:41] == vaddr[31:12]) begin
            rd_data[31:0] = sh_tlb_mem [i][31:0];
            rd_data[32] = 1;
          end
      end 
    end
    return rd_data;
  endfunction


endclass