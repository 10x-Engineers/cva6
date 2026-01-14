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


class mdhlck_reg_seq extends ahb_base_seq ;
    `uvm_object_utils(mdhlck_reg_seq)

        // bit [31:0] index;

        // uvm_reg rg;
        bit read;
    
    function new(string name = "mdhlck_reg_seq");
        super.new(name);
    endfunction

    task body;
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);


        if(read == 0)
        begin
            regmodel.mdlckh.write(status,b_data); //Address 0x0044
            regmodel.mdlckh.read(status,r_data); //Address 0x0044
        end
        else if(read == 1)
        begin
            regmodel.mdlckh.read(status,r_data); //Address 0x0044
        end
 
    endtask

endclass
