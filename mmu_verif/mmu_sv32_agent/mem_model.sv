class mem_model extends uvm_object; 

  logic [riscv::PLEN-1:0] addrrd;
  logic [riscv::PLEN-1:0] addrwr;

  dcache_req_o_t tlb_mem [bit [33:0]];

  function new(string name = "mem_model");
    super.new(name);
  endfunction

  function dcache_req_o_t read( logic [riscv::PLEN-1:0] addrrd);
    dcache_req_o_t data;
      data = tlb_mem[addrrd];
    return data;
  endfunction

  function void write(logic [riscv::PLEN-1:0] addrwr, dcache_req_o_t data);
    tlb_mem[addrwr] = data;
  endfunction

endclass
