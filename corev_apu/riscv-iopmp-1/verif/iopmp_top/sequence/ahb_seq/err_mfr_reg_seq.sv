/*************************************************************************
   > File Name:   err_mfr_reg_seq.sv
   > Description: AHB_Sequence to configure Registers.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/


class err_mfr_reg_seq extends ahb_base_seq;
    `uvm_object_utils(err_mfr_reg_seq)

        uvm_reg rg;
        bit read;
    
    function new(string name = "err_mfr_reg_seq");
        super.new(name);
    endfunction

    task body;
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);

        if(read == 0)
        begin
            regmodel.err_mfr.write(status,b_data); //Address 0x0078
            regmodel.err_mfr.read(status,r_data); //Address 0x0078
        end
        if(read == 1)
        begin
            regmodel.err_mfr.read(status,r_data); //Address 0x0078
        end
     
    endtask

endclass
