/*************************************************************************
   > File Name:   err_info_reg_seq.sv
   > Description: AHB_Sequence to configure Registers.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/


class err_info_reg_seq extends ahb_base_seq ;
    `uvm_object_utils(err_info_reg_seq)

    bit read;
        
    function new(string name = "err_info_reg_seq");
        super.new(name);
    endfunction

    task body;
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);


        if(read == 0)
        begin
            regmodel.err_info.write(status,b_data); //Address 0x0064
            #40ns;
            regmodel.err_info.read(status,r_data); //Address 0x0064
        end
        else if(read == 1)
        begin
            regmodel.err_info.read(status,r_data); //Address 0x0064
        end
 
    endtask

endclass
