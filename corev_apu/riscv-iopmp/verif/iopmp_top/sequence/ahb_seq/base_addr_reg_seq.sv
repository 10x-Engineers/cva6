/*************************************************************************
   > File Name:   base_addr_reg_seq.sv
   > Description: AHB_Sequence to read base_Addr Registers as this register is read only.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/


class base_addr_reg_seq extends ahb_base_seq;
    `uvm_object_utils(base_addr_reg_seq)

        uvm_reg rg;
        bit read;
    
    function new(string name = "base_addr_reg_seq");
        super.new(name);
    endfunction

    task body;
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);

        if(read == 1)
        begin
            regmodel.base_addr.read(status,r_data); //Address 0x0018
        end
        else if(read == 0)
        begin
            `uvm_info(get_name(), "BASE_ADDR is read only register", UVM_LOW)
        end
     
    endtask

endclass
