/*************************************************************************
   > File Name:   full_model_r_perm_read_illegal_ahb_address_cases.sv
   > Description: Send read address for Full MOdel with NA4 Addressing mode with r permission in entry_cfg. Set address to illegal 1C.
   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class ill_addr;
  randc [31:0] illegal_addr;
  randc [31:0] illegal_addr1;
  randc [31:0] illegal_addr2;

  constraint ill{ illegal_addr inside  {32'h20, 32'h24, 32'h28};}

  constraint ill1{ illegal_addr1 inside  {32'h40, 32'h44};}

  constraint ill2{ 
    illegal_addr2 inside  {[32'h50:32'h5C]};
    illegal_addr2 % 4 ==0;
    }
endclass

class full_model_r_perm_read_illegal_ahb_address_cases extends full_model_base_test;
  `uvm_component_utils(full_model_r_perm_read_illegal_ahb_address_cases)
    ahb_general_seq        ahb_seq;

    ill_addr rand_addr;

  function new(string name = "full_model_r_perm_read_illegal_ahb_address_cases", uvm_component parent = null);
     super.new(name, parent);
      ahb_seq     = ahb_general_seq::type_id::create("ahb_seq");
      rand_addr   = new();
  endfunction
   

  task main_phase(uvm_phase phase);
    `uvm_info(get_name(), "MAIN PHASE STARTED", UVM_LOW);
      phase.raise_objection(this, "MAIN - raise_objection");

      env.reg_env.ahb_agnt.ahb_drv.HSIZE     = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HBURST    = 0;
      env.reg_env.ahb_agnt.ahb_drv.HTRANS    = 'd2;
      env.reg_env.ahb_agnt.ahb_drv.HPROT     = 'd3;
      env.reg_env.ahb_agnt.ahb_drv.HMASTLOCK = 0;
      env.reg_env.ahb_agnt.ahb_drv.HSEL = 1;

      rand_addr.randomize();


      //rfm_cover_illegal_offset_1C+
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'h1c+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_srcmd_illegal+
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'h101c+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_sps_illegal -> need to change config -> sps_en = 0 
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'h1008+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_mdcfg_illegal -> need to change config -> fmt != 0 
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'h0800+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_misalign_addr: Address Misaligned by seting either bit 1 or 0 +
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'h0801+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_entry_array_illegal
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'hC+BASE_ADDR+ENTRY_OFFSET;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_base_region_illegal1+
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = rand_addr.illegal_addr+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_illegal_offset_3C+
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'h3C+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      // rfm_cover_mdlck_mdlckh_illegal -> need to change config -> fmt != 0 
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = rand_addr.illegal_addr1+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);
      
      // rfm_cover_mdcfglck_illegal -> need to change config -> fmt != 0 
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'h48+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      //rfm_cover_base_region_illegal2+
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = rand_addr.illegal_addr2+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      // rfm_cover_mfr_disable -> need to change config -> MFR_EN = 0 
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'h74+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      // rfm_cover_msi_disable -> need to change config -> MSI_EN = 0 
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'h78+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      // rfm_cover_addrh_disable -> need to change config -> ADDRH_EN = 0 
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = 32'h7C+BASE_ADDR;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      // rfm_cover_section_illegal: Set value with any upper 16 bit high other than Base addr and entry offset
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = BASE_ADDR+ENTRY_OFFSET+32'h10000;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      // rfm_cover_mdcfg_srcmd_illegal: Set value higher than largest possible mdcfg value and lower than smallest possible srcmd value
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = BASE_ADDR+32'h0904;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      // rfm_cover_base_mdcfg_illegal: Set value higher than base registers address and lower than smallest possible mdcfg address value.
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = BASE_ADDR+32'h07FC;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      // rfm_cover_offset_out_of_srcmd: Must be in section 1 but addr must be higher than largest possible value of srcmd registers.
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = BASE_ADDR+32'h1818;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);

      // rfm_cover_offset_out_of_entry_array: Must be in section 2 but addr must be higher than largest possible value of entry addr registers.
      ahb_seq.transac.ACCESS_o = read;                        
      ahb_seq.transac.HADDR_o = BASE_ADDR+ENTRY_OFFSET+32'h8A4;               
      ahb_seq.start(env.reg_env.ahb_agnt.ahb_sqr);


      #100;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass