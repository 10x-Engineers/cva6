class reg_wr_rd_seq extends ahb_base_seq;
    `uvm_object_utils(reg_wr_rd_seq)

    uvm_status_e   status;
    int num_req = 4;
    uvm_reg iopmp_registers[$];
    //command line arguments
    int write_all_0s = 0;
    int write_all_1s = 100;
    int write_all_random =0;
    int num_reg = 2;
    function new(string name = "reg_wr_rd_seq");
        super.new(name);
    endfunction

    task body();
        if((!uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel)))
            `uvm_error(get_name(), "Failed to regmodel")
        `uvm_info(get_name(), "i am in reg_wr_rd_seq", UVM_LOW)
        regmodel.get_registers(iopmp_registers);
        for  ( int i=0 ; i < 1 ; i++)begin
            if(i ==0 )begin
                write_all_0s = 0;
                write_all_1s = 100;
                write_all_random =0;
            end
            else if(i ==1 )begin
                write_all_0s = 100;
                write_all_1s = 0;
                write_all_random =0;
            end
            else if(i ==2 )begin
                write_all_0s = 0;
                write_all_1s = 0;
                write_all_random =100;
            end
            check_reset(iopmp_registers);
            register_write_read(iopmp_registers);
        end
    endtask

    virtual task check_reset (uvm_reg reg_q[$]);
        uvm_reg reg_h;
        uvm_status_e sts;
        int reg_q_size;
        bit [config_iopmp_pkg::AHB_LITE_DATA_WIDTH -1 :0] actual_reset_val, exp_reset_val;

        //total number of registers in design
        reg_q_size = reg_q.size();
        //TODO(Faaayez, P3) print total registers with verbosity UVM_HIGH

        for(int j=0; j<reg_q_size; j++) begin
          reg_h = reg_q.pop_back();
          `uvm_info("check_reset", $sformatf("Register is : %s", reg_h.get_name()), UVM_NONE)
          if(reg_h.has_reset()) begin
            //get expected reset value from UVM RAL
            exp_reset_val = reg_h.get_reset();
            `uvm_info("check_reset", $sformatf("reg: %s has reset value: %016x as per RDL", reg_h.get_name(), exp_reset_val), UVM_LOW)

            //read the RTL reset value
            reg_h.read(sts, actual_reset_val, UVM_FRONTDOOR);
            //TODO(Faayez, P3) update bus2reg method with correct logic of status.
            // 0 means read transaction
            // 1 write transaction
            check_uvm_status(reg_h,sts,actual_reset_val,0);
            compare_value(reg_h,actual_reset_val,exp_reset_val);
          end
          else begin
            `uvm_info("check_reset", $sformatf("reg: %s has not reset value", reg_h.get_name()), UVM_LOW)
          end
        end
      endtask

      virtual task register_write_read(uvm_reg reg_q[$]);

        uvm_reg reg_h;
        uvm_status_e sts;
        int reg_q_size;
        string reg_name;
        bit [config_iopmp_pkg::AHB_LITE_DATA_WIDTH -1 :0] write_value, read_value, expected_value;
        bit [config_iopmp_pkg::AHB_LITE_DATA_WIDTH -1 :0] hwcfg1_data;

        //total number of registers in design
        reg_q_size = reg_q.size();
        //TODO(Faaayez, P3) print total registers with verbosity UVM_HIGH

        for(int j=0; j<reg_q_size; j++) begin
            reg_h = reg_q.pop_back();
            `uvm_info("register_write_read", $sformatf("Register is : %s", reg_h.get_name()), UVM_NONE)
            //get write_value
            write_value = get_write_value();

            //write value on regiser
            reg_h.write(sts,write_value);

            //check if uvm status is OK
            check_uvm_status(reg_h,sts,write_value,1);

            // get_expected value
            reg_name = reg_h.get_name();

            //fetch data for expected value of rridscp
            if (reg_name.substr(0,5) == "hwcfg1") begin
                hwcfg1_data = reg_h.get();
            end
            if (reg_name.substr(0,4) == "mdcfg") begin
                expected_value = reg_h.get();
                if (expected_value >= 128)begin
                    expected_value = 128;
                end
            end else if (reg_name.substr(0,5) == "hwcfg2") begin
                expected_value = reg_h.get();
                if (expected_value >= 48)begin
                    expected_value = 48;
                end
            end else if (reg_name.substr(0,5) == "hwcfg0") begin
                    expected_value = reg_h.get();
                    if (expected_value[1:0] == 2'b00)begin
                        expected_value[23:17] = '0;
                    end
                    else begin
                        expected_value[23:17] = 8'h7;
                    end
            end else if (reg_name.substr(0,7) == "entrylck") begin
                    expected_value = reg_h.get();
                    if (expected_value[16:1] >= 128)begin
                        expected_value[16:1] = 128;
                    end
            end else if (reg_name.substr(0,6) == "err_mfr") begin
                    expected_value = reg_h.get();
                    if (expected_value[27:16] >= 3)begin
                        expected_value[27:16] = 3;
                    end
            end else if (reg_name.substr(0,6) == "rridscp") begin
                expected_value = reg_h.get();
                if (expected_value[15:0] >= hwcfg1_data[15:0])begin
                    expected_value[15:0] = hwcfg1_data[15:0];
                end
                expected_value[31:30] = '0;
            end else begin
                expected_value = reg_h.get();
            end
            //read actual RTL value
            reg_h.read(sts,read_value,UVM_FRONTDOOR);
            check_uvm_status(reg_h,sts,read_value,0);

            //compare if the values matches or not
            compare_value(reg_h,read_value, expected_value);
            `uvm_info("Compare done", $sformatf("Register is : %s", reg_h.get_name()), UVM_NONE)
        end
      endtask

      virtual function check_uvm_status(input uvm_reg reg_h,
                                    input uvm_status_e sts,
                                    input bit [config_iopmp_pkg::AHB_LITE_DATA_WIDTH -1 :0] rw_value,
                                    input bit rw);
        if (rw) begin // WRITE transaction
            if (sts != UVM_IS_OK) begin
                `uvm_error("check_uvm_status",
                  $sformatf("Read txn for register '%s' UVM status: %s write value: %016x",
                            reg_h.get_name(), sts.name(), rw_value))
            end
            else begin
                `uvm_info("check_uvm_status",
                  $sformatf("Read txn for register '%s' UVM status: %s write value: %016x",
                            reg_h.get_name(), sts.name(), rw_value), UVM_LOW)
            end
        end
        else begin // READ transaction
            if (sts != UVM_IS_OK) begin
                `uvm_error("check_uvm_status",
                  $sformatf("Write txn for register '%s' UVM status: %s read value: %016x",
                            reg_h.get_name(), sts.name(), rw_value))
            end
            else begin
                `uvm_info("check_uvm_status",
                  $sformatf("Write txn for register '%s' UVM status: %s read value: %016x",
                            reg_h.get_name(), sts.name(), rw_value), UVM_LOW)
            end
        end

    endfunction

    virtual function compare_value(uvm_reg reg_h,
                                   bit [config_iopmp_pkg::AHB_LITE_DATA_WIDTH:0] actual_val,
                                   bit [config_iopmp_pkg::AHB_LITE_DATA_WIDTH:0] expected_val);

      if (actual_val !== expected_val) begin
          `uvm_error("compare_value", $sformatf("register : %s  VALUE MISMATCH Expected: %016x Actual          : %016x", reg_h.get_name(), expected_val, actual_val));
      end else begin
          `uvm_info("compare_value", $sformatf("register  : %s  VALUE MATCH    Expected: %016x Actual          : %016x", reg_h.get_name(), expected_val, actual_val), UVM_LOW);
      end
    endfunction

    virtual function [config_iopmp_pkg::AHB_LITE_DATA_WIDTH -1 :0] get_write_value();
        randcase
            write_all_0s: begin
                get_write_value = '0;
            end
            write_all_1s: begin
                get_write_value = '1;
            end
            write_all_random: begin
                get_write_value = $urandom_range((2**config_iopmp_pkg::AHB_LITE_DATA_WIDTH)-1, 32'h0000_0000);
            end
        endcase
    endfunction
endclass
