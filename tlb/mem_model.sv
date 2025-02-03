class mem_model extends uvm_object;

  `uvm_object_utils(mem_model);

  function new(string name = "mem_model");
    super.new(name);
  endfunction

  bit [1:0] tlb_mem [63];

  function void write(input bit rep, bit [62:0] content);
      if (rep == 0) begin
        tlb_mem[0] = content;
      end
     else if (rep == 1)
        tlb_mem[1] = content;

  endfunction

  function bit [32:0] read(input bit [31:0] vaddr, bit asid);

    bit [32:0] rd_data; //MSB indicates whether data was hit/found in the tlb or not
    bit asid_check;
     if ((tlb_mem[0][62]) && (tlb_mem[0][60:51] == vaddr[31:22]) && ((tlb_mem[0][50:41] == vaddr[21:12]) || (tlb_mem[0][61]))) begin
        for (int i=0; i<9; i++) begin
            if(tlb_mem[0][32+i]== asid) 
              asid_check = 1;
            else begin
              asid_check = 0;
              break;
            end
        end
        if(asid_check || tlb_mem[0][5]) begin
          rd_data[31:0] = tlb_mem[0][31:0];
          rd_data[32] = 1;
        end
        else 
          rd_data = 33'd0;
      end
      else if ((tlb_mem[1][62]) && (tlb_mem[1][60:51] == vaddr[31:22]) && ((tlb_mem[1][50:41] == vaddr[21:12]) || (tlb_mem[1][61]))) begin
        for (int i=0; i<9; i++) begin
            if(tlb_mem[1][32+i]== asid) 
              asid_check = 1;
            else begin
              asid_check = 0;
              break;
            end
        end
        if(asid_check || tlb_mem[1][5]) begin
          rd_data[31:0] = tlb_mem[1][31:0];
          rd_data[32] = 1;
        end
        else 
          rd_data = 33'd0;
      end
      else
        rd_data = 33'd0;
    return rd_data;
    
  endfunction


endclass