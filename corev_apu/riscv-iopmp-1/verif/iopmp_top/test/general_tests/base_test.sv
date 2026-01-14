/*************************************************************************
   > File Name:   base_test.sv
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
`include "uvm_macros.svh"
import uvm_pkg::*;

class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    iopmp_env             env;               // Environment handle
    virtual axi_interface axi_vif;           // Virtual interface for AXI signals
    virtual ahb_interface ahb_vif;           // Virtual interface for AXI signals
    configurations        cnfg;              // Configurations
    ahb_base_seq          reg_seqnc;
    iopmp_reg regmodel;
    uvm_reg rg;
    axi_s_config cfg;
    //Parameters for test to make it work for different functionalities
    bit mdcfg_improper; //high this Parameter to initialize improper mdcfgs
    bit r_perm; //high this bit for read perm
    bit w_perm; //high this bit for write perm
    bit x_perm; //high this bit for instruction fetch perm

    bit [1:0] ad_mode; //Adressing Mode

    bit [1:0] t_type;  //transaction type 0= read, 1 = write, 2 = instruction fetch

    bit        intr_en;      //Error capture fields
    bit        err_sup;
    bit        msi_en;
    bit        stall_voi_en;
    bit [10:0] msi_data;
    
    randc bit [3:0] transac_size;
    
    randc bit [(AXI_DATA_WIDTH/2)-1:0] data_size; 
    ////////
    int i, j;

    `ifdef CFG_IOPMP_SRCMD_FMT_0
    srcmden_reg_seq       srcmden;
    srcmdr_reg_seq        srcmdr;
    srcmdw_reg_seq        srcmdw;
    srcmdenh_reg_seq      srcmdenh;
    srcmdrh_reg_seq       srcmdrh;
    srcmdwh_reg_seq       srcmdwh;

    `endif

    `ifdef CFG_IOPMP_MDCFG_FMT_0
    mdcfg_reg_seq         mdcfg;
    `endif

    entry_addr_reg_seq    entry_addr;
    entry_addrh_reg_seq   entry_addrh;
    entry_cfg_reg_seq     entry_cfg;

    logic [2:0] HSIZE;
    logic [2:0] HBURST;
    logic [1:0] HTRANS;
    logic [3:0] HPROT;
    logic       HMASTLOCK;

    randc bit [31:0] index;
    randc bit [31:0] md;
    randc bit [31:0] lwr_entry;  //lower associated entry 
    randc bit [31:0] upr_entry;  //upper associated entry

    bit [31:0] md_2c;             // MD 2s Compliment
    bit [31:0] md_anded;             // MD 2s Compliment anded with md
    int right_most_high_bit;      // Right most bit high bit of MD

    randc bit [31:0] indexh;
    randc bit [31:0] mdh;


    randc bit [31:0] addr;
    randc bit [17:0] addrh;
    randc burst_type burst;
    randc bit [8:0] napot_size;

    randc bit [bus_params_pkg::BUS_IDW-1:0] seq_id;

    `ifdef CFG_IOPMP_SRCMD_FMT_0
    constraint index_c {
      SRCMD_FMT == 0 -> index inside {[0:MD_NUM-1]};
    }

    constraint indexh_c {
      SRCMD_FMT == 0 -> indexh inside {[0:MD_NUM-1]};
    }
    constraint md_c {
      // && ((md & (md - 1)) == 0)
      (md[0] != 1 );
    }

    // constraint mdh_c {
    //  ( mdh & (mdh - 1)) == 0;
    // }
    `ifdef CFG_IOPMP_MDCFG_FMT_0
    constraint lwr_entry_c {
      lwr_entry < ENTRY_NUM-2;
    }
    constraint upr_entry_c {
      solve lwr_entry before upr_entry;
      ((upr_entry > lwr_entry) && (upr_entry < ENTRY_NUM-1));
    }
    `endif 

    `ifndef CFG_IOPMP_MDCFG_FMT_0
    constraint lwr_entry_cc {
      solve md before lwr_entry;
      (lwr_entry >= (1+(($clog2(md+1)-2) * (MD_ENTRY_NUM+1)))) && /////($clog2(md+1)-1)  if md = b'10 -> clog2(md+1) -> 2 but actual md will be 0 thats why minus with 2 and plus one to whole value is because in function for other format it is doing minus 1
      (lwr_entry < (1+((MD_ENTRY_NUM+1) * (($clog2(md+1)-2)+1))));/////plus 1 is done because minus 1 is done in entry function for other formats
      }
    `endif
    `endif

    `ifndef CFG_IOPMP_SRCMD_FMT_0 //////////SRCMD !=0
    constraint md_cc {
      (md >= 1 ) && ((md & (md - 1)) == 0);//Because md=rrid in this model
    }
    constraint index_ccc {
      solve md before index;
      index == ($clog2(md+1) - 1);
    }
    constraint indexh_ccc {
      solve mdh before indexh;
      indexh == ($clog2(mdh+1) - 1);
    }
    `ifdef CFG_IOPMP_MDCFG_FMT_0

    constraint lwr_entry_c {
      lwr_entry < ENTRY_NUM-2;
    }
    constraint upr_entry_c {
      solve lwr_entry before upr_entry;
      ((upr_entry > lwr_entry) && (upr_entry < ENTRY_NUM-1));
    }

    `endif
    `ifndef CFG_IOPMP_MDCFG_FMT_0
    // constraint lwr_entry_cc {
    //   solve index before lwr_entry;
    //   (lwr_entry >= (1+(index * (MD_ENTRY_NUM+1)))) && 
    //   (lwr_entry < (2+((index+1) * MD_ENTRY_NUM)));
    //   }
      constraint lwr_entry_cc {
      solve md before lwr_entry;
      (lwr_entry >= (1+(($clog2(md+1)-1) * (MD_ENTRY_NUM+1)))) && /////($clog2(md+1)-1)  if md = b'10 -> clog2(md+1) -> 2 but actual md will be 0 thats why minus with 2 and plus one to whole value is because in function for other format it is doing minus 1
      (lwr_entry <= (1+((MD_ENTRY_NUM+1) * (($clog2(md+1)-1)+1))));/////plus 1 is done because minus 1 is done in entry function for other formats
      }
    // constraint lwr_entry_cc {
    //     solve index before lwr_entry;
    //     lwr_entry inside { [(1 + (index*(MD_ENTRY_NUM+1))) : (1+((index+1)*MD_ENTRY_NUM))] };
    // }

    `endif  
    `endif
    constraint addr_c {
      if (ad_mode == 2'b11) {
        // Allowed NAPOT sizes: 8, 16, 32, 64, 128
        napot_size inside {8, 16, 32, 64, 128};

        // Address must be aligned to the chosen size
        (addr % napot_size) == 0;
      }
    }
    constraint transac_size_c {
      (ad_mode == 2'b00) -> transac_size inside { 1, 2, 4, 8 };
      (ad_mode == 2'b01) -> transac_size inside { 1, 2, 4, 8 };
      (ad_mode == 2'b10) -> transac_size == 4;
      (ad_mode == 2'b11) -> transac_size == 8;
      // transac_size == 4;
    }

    constraint data_size_c {
      solve addr before transac_size;
      solve transac_size before data_size;
      (ad_mode == 2'b10) -> data_size == 4;
      ((ad_mode == 2'b11) && (addr[0] == 0 )) -> data_size==transac_size;
      ((ad_mode == 2'b11) && (addr[1:0] == 2'b01 )) -> data_size==2*transac_size;
      ((ad_mode == 2'b11) && (addr[2:0] == 3'b011 )) -> data_size==4*transac_size;
      ((ad_mode == 2'b11) && (addr[3:0] == 4'b0111 )) -> data_size==8*transac_size;
      ((ad_mode == 2'b11) && (addr[4:0] == 5'b01111 )) -> data_size==16*transac_size;

      (ad_mode == 2'b01 || ad_mode == 2'b00) -> ((data_size inside {transac_size,2*transac_size,3*transac_size,4*transac_size,5*transac_size,6*transac_size,
      7*transac_size,8*transac_size,9*transac_size,10*transac_size,11*transac_size,12*transac_size,13*transac_size,14*transac_size,
      15*transac_size,16*transac_size})&&(data_size<4096));
      // (ad_mode == 2'b01) -> data_size == 4;
    }

    constraint burst_C{
      burst inside {INCR, FIXED};
    }

    //-----------------------------------------------------------------------------
    // Function: build_phase
    //-----------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "BUILD PHASE STARTED", UVM_LOW);
        $readmemh("./../tb/BOOT_IMG0",cfg.mem_0);
        $readmemh("./../tb/BOOT_IMG1",cfg.mem_1);
        uvm_config_db#(axi_s_config)::set(null, "*", "cfg", cfg);
        if (!uvm_config_db#(virtual axi_interface)::get(null, "*", "axi_vif", axi_vif))
            `uvm_error(get_name(), "Failed to connect axi_vif interface")
        if (!uvm_config_db#(virtual ahb_interface#(.ADDR_WIDTH(`AHB_ADDR_WIDTH),.DATA_WIDTH(`AHB_DATA_WIDTH)))::get(null, "*", "ahb_vif", ahb_vif))
            `uvm_error(get_name(), "Failed to connect ahb_vif interface")
        // Create environment
        env = iopmp_env::type_id::create("env", this);
        regmodel = iopmp_reg::type_id::create("regmodel", this);
        uvm_config_db#(iopmp_reg)::get(null, "*", "regmodel", regmodel);
        reg_seqnc = ahb_base_seq::type_id::create("reg_seqnc", this);
        `ifdef CFG_IOPMP_SRCMD_FMT_0
          srcmden    = srcmden_reg_seq::type_id::create("srcmden");
          srcmdr     = srcmdr_reg_seq::type_id::create("srcmdr");
          srcmdw     = srcmdw_reg_seq::type_id::create("srcmdr");
          srcmdenh    = srcmdenh_reg_seq::type_id::create("srcmdenh");
          srcmdrh     = srcmdrh_reg_seq::type_id::create("srcmdrh");
          srcmdwh     = srcmdwh_reg_seq::type_id::create("srcmdwh");

        `endif
        `ifdef CFG_IOPMP_MDCFG_FMT_0
        mdcfg      = mdcfg_reg_seq::type_id::create("mdcfg");
        `endif

        entry_addr = entry_addr_reg_seq::type_id::create("entry_addr");
        entry_addrh = entry_addrh_reg_seq::type_id::create("entry_addrh");
        entry_cfg  = entry_cfg_reg_seq::type_id::create("entry_cfg");
          // reg_seqnc.regmodel = regmodel;
        
    endfunction : build_phase

    //-----------------------------------------------------------------------------
    // Function: end_of_elaboration_phase
    //-----------------------------------------------------------------------------

    function new(string name = "base_test", uvm_component parent = null);
       super.new(name, parent);
     endfunction


    task main_phase(uvm_phase phase);
      `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");
      /*
      -------------------
      */
      phase.drop_objection(this, "MAIN - drop_objection");
      `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase

    function void connect_phase(uvm_phase phase);
		/*------------------*/
    endfunction : connect_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info(get_name(), "------------------------- Topology Report -------------------------", UVM_LOW);
        uvm_top.print_topology();
    endfunction: end_of_elaboration_phase

    task randomi();
    `ifndef CFG_IOPMP_MDCFG_FMT_0
      this.upr_entry.rand_mode(0);
    `endif

      if (!this.randomize()) begin
      `uvm_info(get_name(), "Randomization failed!", UVM_LOW);
      end
      else begin
        `uvm_info(get_name(), $sformatf("Randomization Succeeded \n index = %h\n  md = %h\n lwr_entry = %h\n upr_entry = %h", index, md, lwr_entry, upr_entry), UVM_LOW);
      end

    endtask

  `ifdef CFG_IOPMP_SRCMD_FMT_0
    task srcmd_en();
          srcmden.b_data = md;
          srcmden.index = index;
          if(SE_EN==1)begin
            srcmden.index = 0;
          end
          srcmden.start(env.reg_env.ahb_agnt.ahb_sqr);
        `uvm_info(get_name(), $sformatf("srcmden____b_Data=%h,   index = %h", srcmden.b_data, srcmden.index), UVM_LOW);
    endtask

    task srcmd_r();
          srcmdr.b_data = md;
          srcmdr.index = index;
          if(SE_EN==1)begin
            srcmdr.index = 0;
          end
          srcmdr.start(env.reg_env.ahb_agnt.ahb_sqr);
        `uvm_info(get_name(), $sformatf("srcmdr____b_Data=%h,   index = %h", srcmdr.b_data, srcmdr.index), UVM_LOW);

    endtask

    task srcmd_w();
          srcmdw.b_data = md;
          srcmdw.index = index;
          if(SE_EN==1)begin
            srcmdw.index = 0;
          end
          srcmdw.start(env.reg_env.ahb_agnt.ahb_sqr);
        `uvm_info(get_name(), $sformatf("srcmdw____b_Data=%h,   index = %h", srcmdw.b_data, srcmdw.index), UVM_LOW);
    endtask

    task srcmd_enh();
          srcmdenh.b_data = mdh;
          srcmdenh.index = indexh;
          srcmdenh.start(env.reg_env.ahb_agnt.ahb_sqr);
        `uvm_info(get_name(), $sformatf("srcmdenh____b_Data=%h,   index = %h", srcmdenh.b_data, srcmdenh.index), UVM_LOW);
    endtask

    task srcmd_rh();
          srcmdrh.b_data = mdh;
          srcmdrh.index = indexh;
          srcmdrh.start(env.reg_env.ahb_agnt.ahb_sqr);
        `uvm_info(get_name(), $sformatf("srcmdrh____b_Data=%h,   index = %h", srcmdrh.b_data, srcmdrh.index), UVM_LOW);

    endtask

    task srcmd_wh();
          srcmdwh.b_data = mdh;
          srcmdwh.index = indexh;
          srcmdwh.start(env.reg_env.ahb_agnt.ahb_sqr);
        `uvm_info(get_name(), $sformatf("srcmdwh____b_Data=%h,   index = %h", srcmdwh.b_data, srcmdwh.index), UVM_LOW);

    endtask
  `endif
`ifdef CFG_IOPMP_MDCFG_FMT_0
    task md_cfg(input int lower = lwr_entry, int upper = upr_entry, int domain = ($clog2(md+1)-1)); //if lower srcmd bits are initialized
    $display("md____:%h",md);
    j = lower;
    if(SRCMD_FMT==0)begin
      i = domain-1;
      $display("i____:%h",i);
      for(; i>=0; i--)begin
          if(md[i+1] == 1)begin
            if(j>=0)begin
              mdcfg.index = i;
              mdcfg.b_data = j; 
              mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
              `uvm_info(get_name(), $sformatf("mdcfg____b_Data=%h,   index = %h", mdcfg.b_data, mdcfg.index), UVM_LOW);
              j--;
            end
          end
        end
    end
    else begin
        i = domain;
        $display("i___1:%h",i);
        for(; i>=0; i--)begin
          if(md[i] == 1)begin
            if(j>=0)begin
              mdcfg.index = i;
              mdcfg.b_data = j; 
              mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
              `uvm_info(get_name(), $sformatf("mdcfg____b_Data=%h,   index = %h", mdcfg.b_data, mdcfg.index), UVM_LOW);
              j--;
            end
          end
        end
    end 
    endtask   

    task mdh_cfg(input int lower = lwr_entry, int upper = upr_entry, int domain = $clog2(mdh+1)-1); // if upper srcmd bits are initialized
        mdcfg.index  = domain;
        mdcfg.b_data = lower; 
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
        `uvm_info(get_name(), $sformatf("mdcfg____b_Data=%h,   index = %h", mdcfg.b_data, mdcfg.index), UVM_LOW);
        for(int i = domain-1; i>=0; i--)begin
          if(md[i] == 1)begin
            if(j>=0)begin
              mdcfg.index = i;
              mdcfg.b_data = j; 
              mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
              `uvm_info(get_name(), $sformatf("mdcfg____b_Data=%h,   index = %h", mdcfg.b_data, mdcfg.index), UVM_LOW);
              j--;
            end
          end
        end
    endtask 

    task imp_md_cfg(input int lower = lwr_entry, int upper = upr_entry, int domain = ($clog2(md+1)-1)); //if lower srcmd bits are initialized
    $display("md____:%h",md);
    j = 1;
    if(SRCMD_FMT==0)begin
      i = domain-1;
      mdcfg.index = i;
      mdcfg.b_data = lower; 
      mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
      `uvm_info(get_name(), $sformatf("mdcfg____b_Data=%h,   index = %h", mdcfg.b_data, mdcfg.index), UVM_LOW);
      md_2c = ~md+1;
      md_anded = md_2c & md;
      right_most_high_bit = $clog2(md_anded+1)-1;
      $display("MD_____:%b",md);
      $display("MD_anded_____:%b",md_anded);
      $display("Right_____:%d",right_most_high_bit);

      // mdcfg.index = right_most_high_bit;
      // mdcfg.b_data = lower; 
      // mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
      // `uvm_info(get_name(), $sformatf("mdcfg____b_Data=%h,   index = %h", mdcfg.b_data, mdcfg.index), UVM_LOW);

      i--;
      $display("i____:%h",i);
      for(; i>=0; i--)begin
          if((md[i+1] != 1)&&(i > right_most_high_bit))begin
            if(j<lower)begin
              mdcfg.index = i;
              mdcfg.b_data = j; 
              mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
              `uvm_info(get_name(), $sformatf("mdcfg____b_Data_imp=%h,   index = %h", mdcfg.b_data, mdcfg.index), UVM_LOW);
              j++;
            end
          end
          ////If want to associate all entries lower that lwr_entry uncomment
          /* else if(i == right_most_high_bit)begin
              mdcfg.index = i;
              mdcfg.b_data = j; 
              mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
              `uvm_info(get_name(), $sformatf("mdcfg____b_Data_imp1=%h,   index = %h", mdcfg.b_data, mdcfg.index), UVM_LOW);
              j++;
          end*/
        end
    end
    else begin
        i = domain;
        mdcfg.index = i;
        mdcfg.b_data = lower; 
        mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
        $display("i___1:%h",i);

        md_2c = ~md+1;
        md_anded = md_2c & md;
        right_most_high_bit = $clog2(md_anded+1)-1;
        $display("MD_____:%b",md);
        $display("MD_anded_____:%b",md_anded);
        $display("Right_____:%d",right_most_high_bit);
        i--;
        // for(; i>=0; i--)begin
        //   if(md[i] == 1)begin
        //     if(j>=0)begin
        //       mdcfg.index = i;
        //       mdcfg.b_data = j; 
        //       mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
        //       `uvm_info(get_name(), $sformatf("mdcfg____b_Data=%h,   index = %h", mdcfg.b_data, mdcfg.index), UVM_LOW);
        //       j--;
        //     end
        //   end
        // end
        for(; i>=0; i--)begin
          if(md[i] != 1)begin
            if(j<lower)begin
              mdcfg.index = i;
              mdcfg.b_data = j; 
              mdcfg.start(env.reg_env.ahb_agnt.ahb_sqr);
              `uvm_info(get_name(), $sformatf("mdcfg____b_Data_imp=%h,   index = %h", mdcfg.b_data, mdcfg.index), UVM_LOW);
              j++;
            end
          end
        end
    end 
    endtask 
`endif

    task ent_addr(input int e_index = lwr_entry);
      if(e_index > 0)begin // zero is not possible corner case.
         entry_addr.b_data = addr[31:0];
         entry_addr.index = e_index-1;
         entry_addr.start(env.reg_env.ahb_agnt.ahb_sqr);
        `uvm_info(get_name(), $sformatf("entry_Addr____b_Data=%h,   index = %h", entry_addr.b_data, entry_addr.index), UVM_LOW);

         entry_addrh.b_data = addrh[17:0];
         entry_addrh.index = e_index-1;
         entry_addrh.start(env.reg_env.ahb_agnt.ahb_sqr);
        `uvm_info(get_name(), $sformatf("entry_Addrh____b_Data=%h,   index = %h", entry_addrh.b_data, entry_addrh.index), UVM_LOW);
        end
    endtask

    task ent_cfg(input int e_index = lwr_entry, bit [2:0] perm, bit [1:0] addr_mode, bit [5:0] suppress);
      if(e_index > 0)begin
        entry_cfg.b_data[2:0]  = perm;                         // rwx permission
        entry_cfg.b_data[4:3]  = addr_mode;                    // address mode NA/NAPOT/TOR/OFF
        entry_cfg.b_data[10:5] = suppress;                     // Interrupt and Error Suppression
        entry_cfg.index = e_index-1;
        entry_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);
        `uvm_info(get_name(), $sformatf("ent_cfg____b_Data perm=%h, addr_mode=%h, suppress=%h,  index = %h", entry_cfg.b_data[2:0], entry_cfg.b_data[4:3], entry_cfg.b_data[10:5], entry_cfg.index), UVM_LOW);
      end
    endtask



endclass