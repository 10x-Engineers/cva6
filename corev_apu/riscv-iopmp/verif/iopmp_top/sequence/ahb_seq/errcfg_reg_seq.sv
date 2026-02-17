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


class errcfg_reg_seq extends ahb_base_seq ;
    `uvm_object_utils(errcfg_reg_seq)

    bit read;

    function new(string name = "errcfg_reg_seq");
        super.new(name);
    endfunction

    task body;
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);


        if(read == 0)
        begin
            regmodel.err_cfg.write(status,b_data); //Address 0x0060
            regmodel.err_cfg.read(status,r_data); //Address 0x0060
        end
        else if(read == 1)
        begin
            regmodel.err_cfg.read(status,r_data); //Address 0x0060
        end
 
    endtask

endclass
