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


class entrylck_reg_seq extends ahb_base_seq ;
    `uvm_object_utils(entrylck_reg_seq)

        // bit [31:0] index;

        // uvm_reg rg;
        bit read;
    
    function new(string name = "entrylck_reg_seq");
        super.new(name);
    endfunction

    task body;
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);


        if(read == 0)
        begin
            regmodel.entrylck.write(status,b_data); //Address 0x004c
            regmodel.entrylck.read(status,r_data); //Address 0x004c
        end
        else if(read == 1)
        begin
            regmodel.entrylck.read(status,r_data); //Address 0x004c
        end

    endtask

endclass
