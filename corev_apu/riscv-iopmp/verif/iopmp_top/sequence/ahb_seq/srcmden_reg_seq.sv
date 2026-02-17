/*************************************************************************
   > File Name:   ahb_base_seq.sv
   > Description: AHB_Sequence to configure Registers.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/


class srcmden_reg_seq extends ahb_base_seq;
    `uvm_object_utils(srcmden_reg_seq)
        // iopmp_reg regmodel;
        // uvm_status_e   status;
        bit [31:0] index;
        uvm_reg_addr_t addr;
        // bit [31:0] b_data;
        uvm_reg rg;
        bit read;
    
    function new(string name = "srcmden_reg_seq");
        super.new(name);
    endfunction

    task body;
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);
        addr= BASE_ADDR+'h1000 + (index*32);
        `uvm_info(get_type_name(),$sformatf("Register_addr_ %h", addr),UVM_MEDIUM);
        rg = regmodel.default_map.get_reg_by_offset(addr, 0);
        `uvm_info(get_type_name(),$sformatf("SEQ_RAL_REG_ENV:::: %s", rg.get_full_name()),UVM_LOW);
        if(read == 0)
        begin
            if (rg != null) begin
                // Register found at the specified offset
                // ... Use reg_h to read or write the register ...
                rg.write(status,b_data);
                rg.read(status,r_data);
            end else begin
                // Register not found at the specified offset
                `uvm_error(get_type_name(),$sformatf("Register not found at offset: %h", addr));
            end
        end
        else if(read == 1)
        begin
            if (rg != null) begin
                // Register found at the specified offset
                // ... Use reg_h to read or write the register ...
                rg.read(status,r_data);
            end else begin
                // Register not found at the specified offset
                `uvm_error(get_type_name(),$sformatf("Register not found at offset: %h", addr));
            end
        end


    endtask

endclass
