class coverage extends uvm_object;
  
     `uvm_object_utils(coverage)

    virtual mmu_if mmu_vif;


    covergroup mmu_cover;

        iptw_hit: coverpoint { mmu_vif.icache_areq_i.fetch_req, mmu_vif.icache_areq_o.fetch_valid, mmu_vif.itlb_miss_o, mmu_vif.req_port_i[66:65], mmu_vif.icache_areq_o.fetch_exception.valid} {
            option.at_least = 6;
            wildcard bins ptw_hit = (6'b101110 => 6'b101??0 [*3] => 6'b110??0);
        }

        ish_tlb_hit : coverpoint  { mmu_vif.icache_areq_i.fetch_req, mmu_vif.icache_areq_o.fetch_valid, mmu_vif.itlb_miss_o, mmu_vif.req_port_i[66:65], mmu_vif.icache_areq_o.fetch_exception.valid} {
            option.at_least = 9;
            wildcard bins sh_tlb_hit = (6'b101000 => 6'b110000);
         }

        itlb_hit : coverpoint  { mmu_vif.icache_areq_i.fetch_req, mmu_vif.icache_areq_o.fetch_valid, mmu_vif.itlb_miss_o, mmu_vif.req_port_i[66:65], mmu_vif.icache_areq_o.fetch_exception.valid} {
            option.at_least = 46;
            wildcard bins tlb_hit = {6'b110000};
         }

        miss: coverpoint { mmu_vif.icache_areq_i.fetch_req, mmu_vif.itlb_miss_o, mmu_vif.req_port_i[66:65], mmu_vif.icache_areq_o.fetch_exception.valid} {
            wildcard bins all_miss = (5'b11110 => 5'b11??0 => 5'b11??1);
        }

        prioirty: coverpoint {mmu_vif.icache_areq_i.fetch_req, mmu_vif.itlb_miss_o, mmu_vif.icache_areq_o.fetch_valid, mmu_vif.lsu_req_i, mmu_vif.dtlb_miss_o, mmu_vif.lsu_valid_o,  mmu_vif.lsu_exception_o.valid} {
            option.at_least = 11;
            bins i_d_tlb = {7'b1001010};
        }

        itlb_access: coverpoint {mmu_vif.icache_areq_i.fetch_req, mmu_vif.itlb_miss_o, mmu_vif.icache_areq_o.fetch_valid, mmu_vif.lsu_req_i, mmu_vif.dtlb_miss_o, mmu_vif.lsu_valid_o, mmu_vif.icache_areq_o.fetch_exception.valid} {
            option.at_least = 41;
            wildcard bins itlb_only = {7'b1010?00};
        }
         
    endgroup

    covergroup mmu_fsm;

        permission_bits: coverpoint { mmu_vif.req_port_i[39:32]} {
            bins wrv = {8'b01011101};
            bins xwrv = {8'b01010001};
            bins superpage = {8'b01011001};
            bins a_not_set = {8'b00011001};

        }

        dtlb_access: coverpoint {mmu_vif.icache_areq_i.fetch_req, mmu_vif.itlb_miss_o, mmu_vif.icache_areq_o.fetch_valid, mmu_vif.lsu_req_i, mmu_vif.dtlb_miss_o, mmu_vif.lsu_valid_o, mmu_vif.lsu_exception_o.valid} {
            wildcard bins dtlb_only = {7'b0?01010};
        }

        ppn0 : coverpoint  { mmu_vif.req_port_i[51:42]} {
             bins all_zero = {10'd0};
             bins not_zero = {10'b0000000011};
        }

        iwalk : coverpoint  { mmu_vif.icache_areq_i.fetch_req, mmu_vif.enable_translation_i, mmu_vif.icache_areq_o.fetch_exception.valid , mmu_vif.itlb_miss_o } {
            bins i_error = {4'b1111};
            bins i_valid_upd = {4'b1100};
         }

        lsu_walk: coverpoint { mmu_vif.lsu_req_i,  mmu_vif.en_ld_st_translation_i, mmu_vif.lsu_exception_o.valid , mmu_vif.dtlb_miss_o } {
            bins d_error = {4'b1111 };
            bins d_valid_upd = {4'b1100};
        }

        lsu_is_store: coverpoint { mmu_vif.lsu_is_store_i } {
            bins store_req = {1'b1 };
            bins load_req  = {1'b0};
        }

        mxr_bit: coverpoint { mmu_vif.mxr_i } {
            bins set = {1'b1 };
            bins not_set  = {1'b0};
        }

        sum_bit: coverpoint { mmu_vif.sum_i } {
            bins set = {1'b1 };
            bins not_set  = {1'b0};
        }

        priv_lvl: coverpoint { mmu_vif.ld_st_priv_lvl_i } {
            bins s_mode = {2'b01};
            bins u_mode = {2'b00};
        }

        ptw_fsm_1: cross permission_bits, iwalk, ppn0 {
            option.cross_auto_bin_max = 0;
            bins mode1= binsof(permission_bits.wrv) && binsof (iwalk.i_error);
            bins mode3= binsof(permission_bits.superpage) && binsof (iwalk.i_error) && binsof(ppn0.not_zero);
            bins mode4= binsof(permission_bits.superpage) && binsof (iwalk.i_valid_upd) && binsof(ppn0.all_zero);
            bins mode5= binsof(permission_bits.a_not_set) && binsof (iwalk.i_error) && binsof(ppn0.all_zero);
        }

        ptw_fsm_2: cross permission_bits, lsu_walk, lsu_is_store, mxr_bit, sum_bit, priv_lvl {
            option.cross_auto_bin_max = 0;
            bins mode6= binsof(permission_bits.a_not_set) && binsof (lsu_walk.d_error) && binsof(lsu_is_store.store_req);
            bins mode7= binsof(permission_bits.a_not_set) && binsof (lsu_walk.d_error) && binsof(lsu_is_store.load_req) ;
            bins mode8= binsof(permission_bits.superpage) && binsof (lsu_walk.d_error) && binsof(lsu_is_store.load_req) && binsof(mxr_bit.not_set);
            bins mode9= binsof(permission_bits.superpage) && binsof (lsu_walk.d_valid_upd) && binsof(lsu_is_store.load_req) && binsof(mxr_bit.set) && binsof(sum_bit.not_set) && binsof(priv_lvl.u_mode);
            bins mode10= binsof(permission_bits.superpage) && binsof (lsu_walk.d_error) && binsof(lsu_is_store.load_req) && binsof(mxr_bit.set) && binsof(sum_bit.not_set) && binsof(priv_lvl.s_mode);
            bins mode11= binsof(permission_bits.superpage) && binsof (lsu_walk.d_valid_upd) && binsof(lsu_is_store.load_req) && binsof(mxr_bit.set) && binsof(sum_bit.set) && binsof(priv_lvl.s_mode);
        }

    endgroup

    covergroup mmu_signals;

        flush: coverpoint {mmu_vif.flush_i } {
            bins set = {1'b1};
            bins not_set = {1'b0};
            
        }
        enable_translation: coverpoint {mmu_vif.enable_translation_i } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        en_ld_st_translation: coverpoint {mmu_vif.en_ld_st_translation_i } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        
        icache_fetch_req : coverpoint {mmu_vif.icache_areq_i.fetch_req } {
            bins Fetch_req = {1'b1};
            bins no_fect_req = {1'b0} ;
        }
        icache_vaddr : coverpoint {mmu_vif.icache_areq_i.fetch_vaddr } {
            bins max = {32'hFFFFFFFF};
            bins min = {32'h00000000};
            bins vpn1 = {[32'h00001000:32'h003FF000]};
            bins vpn2 = {[32'h004FF000:32'hFFFFF000]};
        }
        icache_i: cross icache_fetch_req, icache_vaddr ;

        misaligned_ex_cause: coverpoint {mmu_vif.misaligned_ex_i.cause } {
            bins max = {32'hFFFFFFFF};
            bins min = {32'h00000000};
            bins range = {[32'h00000001:32'hFFFFFFFE]};       
        }
        misaligned_ex_tval: coverpoint {mmu_vif.misaligned_ex_i.tval } {
            bins max = {32'hFFFFFFFF};
            bins min = {32'h00000000};
            bins range = {[32'h00000001:32'hFFFFFFFE]};        
        }
        misaligned_ex_valid: coverpoint {mmu_vif.misaligned_ex_i.valid } {
            bins set = {1'b1};
            bins not_set = {1'b0};       
        }
        misaligned_ex: cross misaligned_ex_cause, misaligned_ex_tval, misaligned_ex_valid;

        lsu_req: coverpoint {mmu_vif.lsu_req_i } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        lsu_vaddr: coverpoint {mmu_vif.lsu_vaddr_i } {
            bins max = {32'hFFFFFFFF};
            bins min = {32'h00000000};
            bins vpn1 = {[32'h00001000:32'h003FF000]};
            bins vpn2 = {[32'h004FF000:32'hFFFFF000]};
        }
        lsu_i: cross lsu_req, lsu_vaddr;

        lsu_is_store: coverpoint {mmu_vif.lsu_is_store_i } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        priv_lvl: coverpoint {mmu_vif.priv_lvl_i } {
            bins m_mode = {2'b11};
            bins u_mode = {2'b00};
            bins s_mode = {2'b01};
        }
        ld_st_priv_lvl: coverpoint {mmu_vif.ld_st_priv_lvl_i } {
            bins m_mode = {2'b11};
            bins u_mode = {2'b00};
            bins s_mode = {2'b01};
        }
        sum: coverpoint {mmu_vif.sum_i } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        mxr: coverpoint {mmu_vif.mxr_i } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        satp_ppn: coverpoint {mmu_vif.satp_ppn_i } {
            bins min = {22'h000000};
            bins range = {[22'h000001:22'h2FFFFF]};
            bins max = {22'h3FFFFF};
        }
        asid: coverpoint {mmu_vif.asid_i } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }

        asid_to_be_flushed: coverpoint {mmu_vif.asid_to_be_flushed_i } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        vaddr_to_be_flushed: coverpoint {mmu_vif.vaddr_to_be_flushed_i } {
            bins max = {32'hFFFFFFFF};
            bins min = {32'h00000000};
            bins vpn1 = {[32'h00001000:32'h003FF000]};
            bins vpn2 = {[32'h004FF000:32'hFFFFF000]};
        }
        flush_tlb: coverpoint {mmu_vif.flush_tlb_i } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        flush_addr: cross flush_tlb, asid_to_be_flushed, vaddr_to_be_flushed;

        req_grant: coverpoint {mmu_vif.req_port_i[66:65] } {
            bins granted = {2'b11};
            bins not_granted = {2'b00};       
        }
        req_port_rdata_permission: coverpoint {mmu_vif.req_port_i[39:32] } {
            wildcard bins permission = {[8'h00:8'hFF]};
        }
        req_port_rdata_ppn0: coverpoint {mmu_vif.req_port_i[51:42] } {
            wildcard bins ppn0 = {[10'h000:32'h3FF]};   
        }
        req_port_rdata_ppn1: coverpoint {mmu_vif.req_port_i[63:52] } {  
            wildcard bins ppn1 = {[12'h000:12'hFFF]}; 
        }
        req_port_i: cross req_grant, req_port_rdata_permission,  req_port_rdata_ppn0, req_port_rdata_ppn1;

        icache_valid: coverpoint {mmu_vif.icache_areq_o.fetch_valid} {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        icache_paddr: coverpoint {mmu_vif.icache_areq_o.fetch_paddr} {
            bins match_execute_region = {[34'h0:34'h1000], [34'h10000:34'h20000], [34'h080000000:34'h0C0000000]};
            bins bad_region = default;
        }
        icache_o: cross icache_valid, icache_paddr;

        icache_exception_cause: coverpoint {mmu_vif.icache_areq_o.fetch_exception.cause } {
            bins page_fault = {32'd12};
            bins no_cause = {32'd0};
            bins access_fault = {32'd1};
        }
        icache_exception_tval: coverpoint {mmu_vif.icache_areq_o.fetch_exception.tval } {
            bins max = {32'hFFFFFFFF};
            bins min = {32'h00000000};
            bins range = {[32'h00000001:32'hFFFFFFFE]};        
        }
        icache_exception_valid: coverpoint {mmu_vif.icache_areq_o.fetch_exception.valid } {
            bins set = {1'b1};
            bins not_set = {1'b0};       
        }
        icache_ex: cross icache_exception_cause, icache_exception_tval, icache_exception_valid;

        lsu_dtlb_hit: coverpoint {mmu_vif.lsu_dtlb_hit_o } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        lsu_dtlb_ppn: coverpoint {mmu_vif.lsu_dtlb_ppn_o } {
            bins min = {22'h000000};
            bins range = {[22'h000001:22'h2FFFFF]};
            bins max = {22'h3FFFFF};
        }
        lsu_valid: coverpoint {mmu_vif.lsu_valid_o } {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        lsu_paddr: coverpoint {mmu_vif.lsu_paddr_o } {
            bins max = {34'h3FFFFFFFF};
            bins min = {34'h000000000};
            bins range = {[34'h000000001:34'h2FFFFFFFF]};
        }
        lsu_o: cross lsu_valid, lsu_paddr;

        lsu_exception_cause: coverpoint {mmu_vif.lsu_exception_o.cause } {
            bins max = {32'hFFFFFFFF};
            bins min = {32'h00000000};
            bins range = {[32'h00000001:32'hFFFFFFFE]}; 
        }
        lsu_exception_tval: coverpoint {mmu_vif.lsu_exception_o.tval } {
            bins max = {32'hFFFFFFFF};
            bins min = {32'h00000000};
            bins range = {[32'h00000001:32'hFFFFFFFE]};        
        }
        lsu_exception_valid: coverpoint {mmu_vif.lsu_exception_o.valid } {
            bins set = {1'b1};
            bins not_set = {1'b0};       
        }
        lsu_ex: cross lsu_exception_cause, lsu_exception_tval, lsu_exception_valid;

        itlb_miss: coverpoint {mmu_vif.itlb_miss_o } {
            bins miss = {1'b1};
            bins hit = {1'b0};
        }
        dtlb_miss: coverpoint {mmu_vif.dtlb_miss_o } {
            bins miss = {1'b1};
            bins hit = {1'b0};
        }

        req_port_index: coverpoint {mmu_vif.req_port_o.address_index} {
            bins max = {12'hFFF};
            bins min = {12'h000};
            bins range = {[12'h001:12'hFFE]}; 
        }
        req_port_tag: coverpoint {mmu_vif.req_port_o.address_tag} {
            bins min = {22'h000000};
            bins range = {[22'h000001:22'h2FFFFF]};
            bins max = {22'h3FFFFF};
        }
        req_port_valid: coverpoint {mmu_vif.req_port_o.tag_valid} {
            bins set = {1'b1};
            bins not_set = {1'b0}; 
        }
        req_port_o: cross  req_port_index,  req_port_tag, req_port_valid;

    endgroup

    function new(string name = "coverage");
        super.new(name);
        mmu_cover = new();
        mmu_fsm = new();
        mmu_signals = new();

    endfunction: new

    task sample_1();
        mmu_vif.clk_pos(1);
        mmu_cover.sample();
        mmu_signals.sample();
    endtask

    task sample_fsm();
        mmu_vif.clk_pos(1);
        mmu_fsm.sample();
        mmu_signals.sample();
    endtask

    task sample_sig();
        mmu_vif.clk_pos(1);
        mmu_signals.sample();
    endtask

endclass