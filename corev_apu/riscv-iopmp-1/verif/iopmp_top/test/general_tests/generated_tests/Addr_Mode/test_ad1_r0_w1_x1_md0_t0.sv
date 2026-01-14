/*************************************************************************
   > File Name:   test_ad1_r0_w1_x1_md0_t0.sv
   > Description: 
   Configurable and randomized test case for all IOPMP Test cases.

   > Author:      Malik Faayez Muhammad
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/
class test_ad1_r0_w1_x1_md0_t0 extends base_test;
  `uvm_component_utils(test_ad1_r0_w1_x1_md0_t0)
    hwcfg0_reg_seq        hwcfg0;
    errcfg_reg_seq        err_cfg;

    axi_req_seq           ar_seq;
    axi_req_seq_w         aw_seq;
    axi_req_seq_w_data    aw_seq_data;
    axi_s_sanity_seq      s_seq;


  function new(string name = "test_ad1_r0_w1_x1_md0_t0", uvm_component parent = null);
     super.new(name, parent);
      hwcfg0      = hwcfg0_reg_seq::type_id::create("hwcfg0");
      err_cfg     = errcfg_reg_seq::type_id::create("err_cfg");
      ar_seq      = axi_req_seq::type_id::create("ar_seq");
      aw_seq      = axi_req_seq_w::type_id::create("aw_seq");
      aw_seq_data = axi_req_seq_w_data::type_id::create("aw_seq_data");
      s_seq       = axi_s_sanity_seq::type_id::create("s_seq");
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
    mdcfg_improper = 0;       //high this Parameter to initialize improper mdcfgs
    r_perm         = 0;          //high this bit for read perm
    w_perm         = 1;          //high this bit for write perm
    x_perm         = 1;          //high this bit for instruction fetch perm
    ad_mode        = 1;         //OFF=0, TOR=1, NA4=2, NAPOT=3
    t_type         = 0;              //transaction type 0= read, 1 = write, 2 = instruction fetch
    intr_en        = 1;         //Error capture field
    err_sup        = 0;         //Error capture field
    msi_en         = 0;          //Error capture field
    stall_voi_en   = 0;    //Error capture field    
    msi_data       = 0;        //Error capture field 
    
    $display("md=%h, r_perm=%h, w_perm=%h, x_perm=%h, ad_mode=%h, t_type=%h", mdcfg_improper, r_perm, w_perm, x_perm, ad_mode, t_type);
    // transac_size  mas 128 because of spec 
    // data_size     max 4096 bytes and multiple of transac size
    randomi();

    `ifdef CFG_IOPMP_SRCMD_FMT_0
      $display("dis0000");
      srcmd_en();
      if(SPS_EN==1)begin
        if(x_perm|r_perm) srcmd_r();
        if(w_perm) srcmd_w();
      end
        `ifdef CFG_IOPMP_MDCFG_FMT_0
            if(mdcfg_improper == 0)begin
              md_cfg();
            end
            else begin
              imp_md_cfg();
            end
            $display("dis1111");
        `endif
    `endif
    //else
    `ifndef CFG_IOPMP_SRCMD_FMT_0
        $display("dis2222");
        `ifdef CFG_IOPMP_MDCFG_FMT_0
            if(mdcfg_improper==0)begin
              md_cfg();
            end
            else begin
              imp_md_cfg();
            end
            $display("dis3333");
        `endif
    `endif


      ent_addr();       //Entry_Addr
      ent_cfg(lwr_entry, {x_perm,w_perm,r_perm}, ad_mode, 6'b000000);

      err_cfg.b_data     = {msi_data, 3'b000, stall_voi_en, msi_en, err_sup, intr_en, 1'b0};                    // interrupt error capture
      err_cfg.start(env.reg_env.ahb_agnt.ahb_sqr);


      hwcfg0.b_data = 32'h80000000;                   //Setting IOPMP Enable 1
      `ifdef CFG_IOPMP_MDCFG_FMT_2
        hwcfg0.b_data[23:17] = MD_ENTRY_NUM;
      `endif
      $display("hwcfg0____ %h", hwcfg0.b_data);
      hwcfg0.start(env.reg_env.ahb_agnt.ahb_sqr);

      if(t_type==0)begin
        #50;
        ar_seq.rrid                        = index;
        if(ad_mode==2'b01)begin 
          $display("jklmn1");
          ar_seq.seq_addr = (({addrh[17:0],addr}<<2)-data_size);
          $display("AR TRANS addr=%h, data=%h, transac_size=%h", {addrh[17:0],addr}<<2,data_size,transac_size);
        end
        else begin
          $display("jklmn2");
          ar_seq.seq_addr               = {addrh[17:0],addr}<<2;
        end
        ar_seq.seq_id                      = seq_id;
        ar_seq.burst_t                     = burst;
        ar_seq.seq_prot                    = 0;
        ar_seq.seq_size                    = transac_size;
        ar_seq.data_size                   = data_size;
        ar_seq.length                      = 0;    //pass burst length manually
        ar_seq.has_length                  = 0;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction
        $display("AR TRANS %h", ar_seq.seq_addr);
        $display("Test:::Read:::Transaction");
      end
      else if(t_type==1)begin
        #50;
        //AW Channel
        aw_seq.rrid       = index;
        if(ad_mode==2'b01)begin 
          aw_seq.seq_addr   = (({addrh[17:0],addr}<<2)-data_size);
          $display("AR TRANS addr=%h, data=%h, transac_size=%h", {addrh[17:0],addr}<<2,data_size,transac_size);
        end
        else begin
        aw_seq.seq_addr   = {addrh[17:0],addr}<<2;
        end
        aw_seq.seq_id     = seq_id;
        aw_seq.burst_t    = burst;
        aw_seq.seq_size   = 4;
        aw_seq.data_size  = 4;     //Assign Data size to be written
        aw_seq.length     = 0;    //pass burst length manually
        aw_seq.has_length = 0;    //pass flag to sequence  (0 to not)
        //W data channel
        aw_seq_data.seq_addr   = {addrh[17:0],addr}<<2;;
        aw_seq_data.seq_size   = transac_size;
        aw_seq_data.data_size  = data_size;    //Assign Data size to be written
        aw_seq_data.length     = 0;    //pass burst length manually
        aw_seq_data.has_length = 0;    //pass flag to sequence (0 to not)
        // $display("AW TRANS %h", aw_seq.rrid);

        fork
          aw_seq.start(env.axi_env.wr_addr_agnt.wr_addr_sqr);              //write access test
          aw_seq_data.start(env.axi_env.wr_data_agnt.wr_data_sqr);
          #300;
        join_any
        $display("Test:::Write:::Transaction");
      end
      if(t_type==2)begin
        #50;
        ar_seq.rrid                 = index;
        if(ad_mode==2'b01)begin 
          ar_seq.seq_addr = (({addrh[17:0],addr}<<2)-data_size);
          $display("AR TRANS addr=%h, data=%h, transac_size=%h", {addrh[17:0],addr}<<2,data_size,transac_size);
        end
        else begin
          ar_seq.seq_addr               = {addrh[17:0],addr}<<2;
        end
        ar_seq.seq_id               = seq_id;
        ar_seq.burst_t              = burst;
        ar_seq.seq_prot             = 'b100;
        ar_seq.seq_size             = transac_size;
        ar_seq.data_size            = data_size;
        ar_seq.length               = 0;    //pass burst length manually
        ar_seq.has_length           = 0;    //pass flag to sequence
        ar_seq.start(env.axi_env.rd_addr_agnt.rd_addr_sqr); // read transaction
        $display("AR TRANS %h", ar_seq.seq_id);
        $display("Test:::Instr_Fetch:::Transaction");
      end
      
      fork
        s_seq.start(env.axi_s_env.agent.sequencer);
      #300;
      join_any
      #100;
      phase.drop_objection(this, "MAIN - drop_objection");
    `uvm_info(get_name(), "MAIN PHASE ENDED", UVM_LOW);
  endtask : main_phase
endclass