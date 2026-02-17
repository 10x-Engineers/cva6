/*************************************************************************
   > File Name:   hwcfg0_reg_seq.sv
   > Description: AHB_Sequence to configure Registers.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/


class hwcfg0_reg_seq extends ahb_base_seq;
    `uvm_object_utils(hwcfg0_reg_seq)

        uvm_reg rg;
        bit read;
    
    function new(string name = "hwcfg0_reg_seq");
        super.new(name);
    endfunction

    task body;
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);

        if(read == 0)
        begin
            regmodel.hwcfg0.write(status,b_data); //Address 0x0008
            regmodel.hwcfg0.read(status,r_data); //Address 0x0008
        end
        else if(read == 1)
        begin
            regmodel.hwcfg0.read(status,r_data); //Address 0x0008
        end
     
    endtask

endclass
