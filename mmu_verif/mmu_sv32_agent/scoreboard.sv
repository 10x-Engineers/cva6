class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard);
  `uvm_analysis_imp_decl(_sh_mon2scb)
  `uvm_analysis_imp_decl(_tlb_mon2scb)
  `uvm_analysis_imp_decl(_ptw_mon2scb)

  uvm_analysis_imp_tlb_mon2scb#(seq_item,scoreboard) tlb_ms;
  uvm_analysis_imp_sh_mon2scb#(seq_item,scoreboard) sh_ms;
  uvm_analysis_imp_ptw_mon2scb#(seq_item,scoreboard) ptw_ms;

   seq_item   queue_sh[$];
   seq_item   queue_tlb[$];
   seq_item   queue_ptw[$];

   integer match=0;
   integer mismatch =0;

   virtual mmu_if mmu_vif;
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual mmu_if):: get(this,"*","mmu_vif",mmu_vif))begin
        `uvm_fatal ("DRIVER","driver:Failed to get mmu_vif")
    end
    sh_ms = new("sh_ms", this);
    tlb_ms = new("tlb_ms", this);
    ptw_ms = new("ptw_ms", this);

  endfunction

  virtual function void write_ptw_mon2scb (seq_item ptw_t);    
    queue_ptw.push_back(ptw_t);
  endfunction

  virtual function void write_sh_mon2scb (seq_item sh_t);    
    queue_sh.push_back(sh_t);
   
  endfunction

  virtual function void write_tlb_mon2scb (seq_item tlb_t);
    queue_tlb.push_back(tlb_t); 
    if(mmu_vif.rst_ni && !mmu_vif.flush_i && !mmu_vif.flush_tlb_i) begin
      comp();
    end
    
  endfunction

  function void comp();

    seq_item   sh_u;
    seq_item   tlb_u;
    seq_item   ptw_u;

    logic [riscv::PLEN-1:0] lsu_y;
    logic [riscv::PLEN-1:0] if_y;

    logic page_lvl; //1==4MegaPage, else LVL2 page
    logic v,r,w,x; //(pte.v, pte.r, pte.x and pte.w)


    if(queue_sh.size()>0 && queue_tlb.size()>0  ) begin
      

      if (mmu_vif.lsu_req_i && queue_ptw.size()<=0)
        return;
        sh_u = queue_sh.pop_back();
        tlb_u = queue_tlb.pop_back();
        ptw_u = queue_ptw.pop_back();

        v = mmu_vif.req_port_i.data_rdata[0];
        r = mmu_vif.req_port_i.data_rdata[1];
        w = mmu_vif.req_port_i.data_rdata[2];
        x = mmu_vif.req_port_i.data_rdata[3];

        page_lvl = ~(~(!v | (!r & w)) && ~(r | x));

        if(page_lvl) begin
            lsu_y = {mmu_vif.req_port_i.data_rdata[31:20], mmu_vif.lsu_vaddr_i[21:0]};
            if_y =  {mmu_vif.req_port_i.data_rdata[31:20], mmu_vif.icache_areq_i.fetch_vaddr[21:0]};
        end
        else begin
            lsu_y = {mmu_vif.req_port_i.data_rdata[31:10], mmu_vif.lsu_vaddr_i[11:0]};
            if_y  = {mmu_vif.req_port_i.data_rdata[31:10], mmu_vif.icache_areq_i.fetch_vaddr[11:0]};
        end


        if(mmu_vif.lsu_req_i) begin
            if(~sh_u.dtlb_miss_o && ptw_u.lsu_valid_o && !ptw_u.lsu_exception_o.valid) begin
              if(mmu_vif.en_ld_st_translation_i) begin
                if(tlb_u.lsu_paddr_o == lsu_y ) begin
                    `uvm_info("$p", "Comparison passed", UVM_NONE)
                    match++;
                end
                else begin
                    `uvm_info("$f", "Comparison failed", UVM_NONE)
                    mismatch++;
                end
              end
              else begin
                if(tlb_u.lsu_paddr_o == {2'b0, mmu_vif.lsu_vaddr_i} ) begin
                    `uvm_info("$p", "Comparison passed", UVM_NONE)
                    match++;
                end
                else begin
                    `uvm_info("$f", "Comparison failed", UVM_NONE)
                    mismatch++;
                end
              end
            end
          end
        else if (mmu_vif.icache_areq_i.fetch_req) begin
            if(~sh_u.itlb_miss_o && tlb_u.icache_areq_o.fetch_valid && !tlb_u.icache_areq_o.fetch_exception.valid) begin
              if(mmu_vif.enable_translation_i) begin
                if(tlb_u.icache_areq_o.fetch_paddr == if_y ) begin
                    `uvm_info("$p", "Comparison passed", UVM_NONE)
                    match++;
                end
                else begin
                    `uvm_info("$f", "Comparison failed", UVM_NONE)
                    mismatch++;
                end
              end
                else begin
                if(tlb_u.icache_areq_o.fetch_paddr == {2'b0, mmu_vif.icache_areq_i.fetch_vaddr} ) begin
                    `uvm_info("$p", "Comparison passed", UVM_NONE)
                    match++;
                end
                else begin
                    `uvm_info("$f", "Comparison failed", UVM_NONE)
                    mismatch++;
                end
              end
            end
          end
      end
   
  endfunction
    

  function void report_phase(uvm_phase phase);
    $display("\n");
    $display("\n");
    $display("\n");
    $display("\n");
    $display("**************************");
    $display("**************************");
    $display("**************************");
    $display("**************************");

    $display("No. of matches and mismatches are: \n matches: %0d \n mismatches: %0d ", match, mismatch);
    
    $display("**************************");
    $display("**************************");
    $display("**************************");
    $display("**************************");
    $display("\n");
    $display("\n");
    $display("\n");
    $display("\n");
  endfunction
  
endclass