/*************************************************************************
   > File Name:   hwcfg1_reg_seq.sv
   > Description: AHB_Sequence to read hwcfg1 Registers as this register is read only.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/


class hwcfg1_reg_seq extends ahb_base_seq;
    `uvm_object_utils(hwcfg1_reg_seq)

        uvm_reg rg;
        bit read;
    
    function new(string name = "hwcfg1_reg_seq");
        super.new(name);
    endfunction

    task body;
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);

        if(read == 1)
        begin
            regmodel.hwcfg1.read(status,r_data); //Address 0x000C
        end
        else if(read == 0)
        begin
            `uvm_info(get_name(), "HWCFG1 is read only register", UVM_LOW)
        end
     
    endtask

endclass
