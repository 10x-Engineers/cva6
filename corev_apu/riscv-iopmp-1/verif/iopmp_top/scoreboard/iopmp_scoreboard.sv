/*************************************************************************
   > File Name:   iopmp_scoreboard.sv
   > Description: Scoreboard implementation for AXI to AHB protocol bridge.
   > Author:      Malik Faayez Muhammad, Muhammad Hassan
   > Modified:    Malik Faayez Muhammad
   > Mail:        faayez.muhammad@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2025 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef IOPMP_SCOREBOARD
`define IOPMP_SCOREBOARD



`uvm_analysis_imp_decl(_axi_wr_addr)
`uvm_analysis_imp_decl(_axi_rd_addr)
`uvm_analysis_imp_decl(_axi_wr_data)
`uvm_analysis_imp_decl(_axi_rd_data)
`uvm_analysis_imp_decl(_axi_wr_rsp)
`uvm_analysis_imp_decl(_ahb_data)
`uvm_analysis_imp_decl(_ahb_addr)

`uvm_analysis_imp_decl(_axi_s_aw)
`uvm_analysis_imp_decl(_axi_s_w)
`uvm_analysis_imp_decl(_axi_s_b)
`uvm_analysis_imp_decl(_axi_s_ar)
`uvm_analysis_imp_decl(_axi_s_r)


typedef struct packed {
    bit        is_amo;   // Indicates the AMO Access
    bit [31:0] perm;      // Type of permission requested  //0,1,2
    bit [31:0] size;      // Size of each access in the transaction
    bit [31:0] length;    // Length of the transaction
    bit [63:0] addr;      // Target address for the transaction
    bit [15:0] rrid;      // Requester ID
} iopmp_trans_req;

typedef enum {
    IOPMP_SUCCESS = 0,  // Transaction successful
    IOPMP_ERROR   = 1   // Transaction encountered an error
} status_e;

// Structure for IOPMP transaction responses
typedef struct packed {
    bit [31:0] status;        // Transaction status (success or error)  //0,1
    bit [7:0]  rrid_stalled;  // Requester ID stall status
    bit [7:0]  user;          // User mode indicator
    bit [31:0] rrid;          // Requester ID
} iopmp_trans_rsp;




import "DPI-C" context function int reset_iopmp();
import "DPI-C" context function void iopmp_validate_access(input iopmp_trans_req, output iopmp_trans_rsp, output bit [7:0] out[]);
import "DPI-C" context function void write_register(input longint unsigned offset, input bit [31:0] data, input bit [7:0] num_bytes);
import "DPI-C" context function int create_memory( input int mem_gb);
import "DPI-C" context function int read_memory(input longint unsigned addr, input int size, output longint unsigned data);
import "DPI-C" context function int write_memory(output longint unsigned data, input longint unsigned addr, input int size);
import "DPI-C" context function void configure_err_info(input int data, input int num_bytes);
import "DPI-C" context function void configure_mdlck(input int data, input int num_bytes);
import "DPI-C" context function void configure_mdcfglck(input int data, input int num_bytes);
import "DPI-C" context function void configure_mdlckh(input int data, input int num_bytes);
import "DPI-C" context function void configure_entrylck(input int data, input int num_bytes);
import "DPI-C" context function void configure_mdstall(input int data, input int num_bytes);
import "DPI-C" context function void configure_mdstallh(input int data, input int num_bytes);
import "DPI-C" context function void configure_rridscp(input int data, input int num_bytes);
import "DPI-C" context function void configure_srcmd_n(input int srcmd_reg, input int srcmd_idx, input int data, input int num_bytes);
import "DPI-C" context function void configure_mdcfg_n(input int md_idx, input int data, input int num_bytes);
import "DPI-C" context function void configure_entry_n(input int entry_reg, input longint entry_idx, input int data, input int num_bytes);
import "DPI-C" context function void set_hwcfg0_enable();
import "DPI-C" context function int read_register(input longint unsigned offset, input bit [7:0] num_bytes);

`define SRCMD_EN     'h0
`define SRCMD_ENH    'h4
`define SRCMD_R      'h8
`define SRCMD_RH     'hC
`define SRCMD_W      'h10
`define SRCMD_WH     'h14
`define SRCMD_PERM   'h00
`define SRCMD_PERMH  'h04

`define ENTRY_ADDR      'h00
`define ENTRY_ADDRH     'h04
`define ENTRY_CFG       'h08
`define ENTRY_USER_CFG  'h0C

// Permissions
`define R 'h01
`define W 'h02
`define X 'h04

// Address Mode
`define OFF   'h00
`define TOR   'h08
`define NA4   'h10
`define NAPOT 'h18

// Interrupt Suppression
`define SIRE 'h20
`define SIWE 'h40
`define SIXE 'h80

// Error Suppression
`define SERE 'h100
`define SEWE 'h200
`define SEXE 'h400




class iopmp_scoreboard extends uvm_component;

    // Registering the scoreboard component with UVM factory
    `uvm_component_utils(iopmp_scoreboard)

    // TLM analysis FIFOs for data transfer
    uvm_analysis_imp_axi_wr_addr #(axi_seq_item, iopmp_scoreboard) axi_wr_addr_imp;
    uvm_analysis_imp_axi_rd_addr #(axi_seq_item, iopmp_scoreboard) axi_rd_addr_imp;
    uvm_analysis_imp_axi_wr_data #(axi_seq_item, iopmp_scoreboard) axi_wr_data_imp;
    uvm_analysis_imp_axi_rd_data #(axi_seq_item, iopmp_scoreboard) axi_rd_data_imp;
    uvm_analysis_imp_axi_wr_rsp #(axi_seq_item, iopmp_scoreboard) axi_wr_rsp_imp;
    uvm_analysis_imp_ahb_data #(ahb_seq_item, iopmp_scoreboard) ahb_data_imp;
    // uvm_analysis_imp_ahb_addr #(ahb_seq_item, iopmp_scoreboard) ahb_addr_imp;

    //axi slave analysis ports
    uvm_analysis_imp_axi_s_aw#(axi_s_seq_item, iopmp_scoreboard) axi_s_aw_imp;
    uvm_analysis_imp_axi_s_w#(axi_s_seq_item, iopmp_scoreboard) axi_s_w_imp;
    uvm_analysis_imp_axi_s_b#(axi_s_seq_item, iopmp_scoreboard) axi_s_b_imp;
    uvm_analysis_imp_axi_s_ar#(axi_s_seq_item, iopmp_scoreboard) axi_s_ar_imp;
    uvm_analysis_imp_axi_s_r#(axi_s_seq_item, iopmp_scoreboard) axi_s_r_imp;

    axi_seq_item axi_wr_addr_q[$];
    axi_seq_item axi_wr_data_q[$];
    axi_seq_item axi_wr_rsp_q[$];
    axi_seq_item axi_rd_addr_q[$];
    axi_seq_item axi_rd_data_q[$];
    ahb_seq_item ahb_data_q[$];
    ahb_seq_item ahb_data_q_read[$];
    // ahb_seq_item ahb_addr_q[$];
    // logic [31:0] axi_addr_queue[$];
    // logic [31:0] temp_addr;


    // Transaction items for comparison
    axi_seq_item axi_wr_addr_item_sc;
    axi_seq_item axi_wr_data_item_sc;
    axi_seq_item axi_rd_addr_item_sc;
    axi_seq_item axi_rd_data_item_sc;
    axi_seq_item axi_wr_rsp_item_sc;
    ahb_seq_item ahb_data_item_sc;
    ahb_seq_item ahb_read_item;

    //Slave Axi Items
    axi_s_seq_item axi_s_aw_item;
    axi_s_seq_item axi_s_w_item;
    axi_s_seq_item axi_s_b_item;
    axi_s_seq_item axi_s_ar_item;
    axi_s_seq_item axi_s_r_item;

    bit [31:0] tmp;
    iopmp_trans_req     trans_req;
    iopmp_trans_rsp     trans_rsp;
    bit [7:0] out[10];

    // Variables
    longint unsigned addr;
    int size;
    int unsigned data;
    int unsigned data1;
    int status;

    bit [15:0] rrid;

    int srcmd_reg;
    int srcmd_en_index;
    int srcmd_en_data;
    int srcmd_enh_index;
    int srcmd_enh_data;
    int srcmd_r_index;
    int srcmd_r_data;
    int srcmd_rh_index;
    int srcmd_rh_data;
    int srcmd_w_index;
    int srcmd_w_data;
    int srcmd_wh_index;
    int srcmd_wh_data;
    int mdcfg_lock_f;
    int mdcfg_index;
    int mdcfg_data;
    int entry_ar_reg;
    int entry_addr_index;
    int entry_addr_data;
    int entry_addrh_index;
    int entry_addrh_data;
    int entry_cfg_index;
    int entry_cfg_data;
    int mdstall_data;
    int mdstallh_data;
    int rridscp_data;
    int mdlck_data;
    int mdlckh_data;
    int mdcfglck_data;
    int entrylck_data;
    int info_data;


    /*************************************************************************
     * Constructor: Initialize the scoreboard component.
     *************************************************************************/
    function new(string name = "iopmp_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        axi_wr_addr_item_sc        = axi_seq_item::type_id::create("axi_wr_addr_item_sc");
        axi_wr_data_item_sc        = axi_seq_item::type_id::create("axi_wr_data_item_sc");
        axi_rd_addr_item_sc        = axi_seq_item::type_id::create("axi_rd_addr_item_sc");
        axi_rd_data_item_sc        = axi_seq_item::type_id::create("axi_rd_data_item_sc");
        axi_wr_rsp_item_sc         = axi_seq_item::type_id::create("axi_wr_rsp_item_sc");
        ahb_data_item_sc           = ahb_seq_item::type_id::create("ahb_data_item_sc");
        ahb_read_item              = ahb_seq_item::type_id::create("ahb_read_item");
    endfunction

    /*************************************************************************
     * Build Phase: Create and initialize FIFOs.
     *************************************************************************/
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_wr_addr_imp = new("axi_wr_addr_imp", this);
        axi_rd_addr_imp = new("axi_rd_addr_imp", this);
        axi_wr_data_imp = new("axi_wr_data_imp", this);
        axi_rd_data_imp = new("axi_rd_data_imp", this);
        axi_wr_rsp_imp  = new("axi_wr_rsp_imp", this);
        ahb_data_imp    = new("ahb_data_imp", this);

        axi_s_aw_imp    = new("axi_s_aw_imp", this);
        axi_s_w_imp     = new("axi_s_w_imp", this);
        axi_s_b_imp     = new("axi_s_b_imp", this);
        axi_s_ar_imp    = new("axi_s_ar_imp", this);
        axi_s_r_imp     = new("axi_s_r_imp", this);
    endfunction

    virtual function void write_axi_s_aw(axi_s_seq_item item_s);
        `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_aw Analysis Imp Port"),UVM_LOW)
        axi_s_aw_item = item_s;
    endfunction

    virtual function void write_axi_s_w(axi_s_seq_item item_s);
        `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_w Analysis Imp Port"),UVM_LOW)
        axi_s_w_item = item_s;
    endfunction

    virtual function void write_axi_s_b(axi_s_seq_item item_s);
        `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_b Analysis Imp Port"),UVM_LOW)
        axi_s_b_item = item_s;
    endfunction

    virtual function void write_axi_s_ar(axi_s_seq_item item_s);
        `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_ar Analysis Imp Port"),UVM_LOW)
        axi_s_ar_item = item_s;
    endfunction

    virtual function void write_axi_s_r(axi_s_seq_item item_s);
        `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_r Analysis Imp Port"),UVM_LOW)
        axi_s_r_item = item_s;
    endfunction

    virtual function void write_axi_wr_addr(axi_seq_item axi_wr_addr_item);
        `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_wr_addr Analysis Imp Port"),UVM_LOW)
        axi_wr_addr_q.push_back(axi_wr_addr_item);
    endfunction

    virtual function void write_axi_rd_addr(axi_seq_item axi_rd_addr_item);
        `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_rd_addr Analysis Imp Port"),UVM_LOW)
        axi_rd_addr_q.push_back(axi_rd_addr_item);
    endfunction

    virtual function void write_axi_wr_data(axi_seq_item axi_wr_data_item);
        `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_wr_data Analysis Imp Port"),UVM_LOW)
        axi_wr_data_q.push_back(axi_wr_data_item);
    endfunction

    virtual function void write_axi_rd_data(axi_seq_item axi_rd_data_item);
        `uvm_info(get_type_name(),$sformatf("AXI_READ::::axi_rd_data_item.data=%d",axi_rd_data_item.id),UVM_LOW)
        `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_rd_data Analysis Imp Port"),UVM_LOW)
        axi_rd_data_q.push_back(axi_rd_data_item);
        // `uvm_info(get_type_name(),$sformatf("AXI_READ::::axi_rd_data_item.data=%d",axi_rd_data_q[0]),UVM_LOW)
    endfunction

    virtual function void write_axi_wr_rsp(axi_seq_item axi_wr_rsp_item);
        `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_wr_rsp Analysis Imp Port"),UVM_LOW)
        axi_wr_rsp_q.push_back(axi_wr_rsp_item);
    endfunction

    virtual function void write_ahb_data(ahb_seq_item ahb_data_item);
        `uvm_info(get_type_name(),$sformatf("Received trans On write_ahb_data Analysis Imp Port"),UVM_LOW)
        if(ahb_data_item.HRDATA_i==0)ahb_data_q.push_back(ahb_data_item);
        // if(ahb_data_item.HWDATA_o==0)ahb_data_q_read.push_back(ahb_data_item);
        $display("Scoreboard:::::HADDR_o=%x", ahb_data_item.HADDR_o);
        $display("Scoreboard:::::HWDATA_o=%x", ahb_data_item.HWDATA_o);
        $display("Scoreboard:::::HRDATA_i=%x", ahb_data_item.HRDATA_i);
        $display("Scoreboard:::::HSIZE_o=%x", ahb_data_item.HSIZE_o);
        $display("Scoreboard:::::HBURST_o=%x", ahb_data_item.HBURST_o);
        $display("Scoreboard:::::HTRANS_o=%x", ahb_data_item.HTRANS_o);
        $display("Scoreboard:::::HPROT_o=%x", ahb_data_item.HPROT_o);
        $display("Scoreboard:::::HMASTLOCK_o=%x", ahb_data_item.HMASTLOCK_o);
        $display("Scoreboard:::::HREADY_i=%x", ahb_data_item.HREADY_i);

        if(ahb_data_q.size()) 
        begin
            ahb_data_item_sc = ahb_data_q.pop_front();
            if((ahb_data_item_sc.RESP_i==0) && (ahb_data_item_sc.HRDATA_i == 0) ) begin
                if ((ahb_data_item_sc.HADDR_o-BASE_ADDR) >= ENTRY_OFFSET && (ahb_data_item_sc.HADDR_o-BASE_ADDR) < (ENTRY_OFFSET+8'h80*8'h10))
                begin
                   entry_ar_reg = (((ahb_data_item_sc.HADDR_o-BASE_ADDR) - ENTRY_OFFSET)%16)/4;
                    case(entry_ar_reg)
                        0:begin
                            `uvm_info(get_type_name (), $sformatf ("In scoreboard ENTRY_ADDR_DATA WRITE"), UVM_NONE);
                            entry_addr_index = ((ahb_data_item_sc.HADDR_o-BASE_ADDR)-ENTRY_OFFSET)/16;
                            `uvm_info(get_type_name (), $sformatf ("addr1 %x, size: %x ", (ahb_data_item_sc.HADDR_o-BASE_ADDR), ahb_data_item_sc.HSIZE_o), UVM_NONE);
                            if(ahb_data_item_sc.HSIZE_o == 3)  begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                            else begin
                                entry_addr_data = ahb_data_item_sc.HWDATA_o;
                            end
                            configure_entry_n(`ENTRY_ADDR,entry_addr_index, entry_addr_data, 4);
                        end
                        1:begin
                            `uvm_info(get_type_name (), $sformatf ("In scoreboard ENTRY_ADDRH_DATA WRITE"), UVM_NONE);
                            entry_addrh_index = ((ahb_data_item_sc.HADDR_o-BASE_ADDR)-ENTRY_OFFSET-4'h4)/16;
                            `uvm_info(get_type_name (), $sformatf ("addr1 %x, size: %x ", ahb_data_item_sc.HADDR_o-BASE_ADDR, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                            if(ahb_data_item_sc.HSIZE_o == 3)  begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                            else begin
                                entry_addrh_data = ahb_data_item_sc.HWDATA_o;
                            end
                            configure_entry_n(`ENTRY_ADDRH,entry_addrh_index, entry_addrh_data, 4);
                            // $display("Index , %d",entry_addrh_index);
                            // $display("Data , %d",entry_addrh_data);
                        end
                        2:begin
                            `uvm_info(get_type_name (), $sformatf ("In scoreboard ENTRY_CFG_DATA WRITE"), UVM_NONE);
                            entry_cfg_index = ((ahb_data_item_sc.HADDR_o-BASE_ADDR)-ENTRY_OFFSET-4'h8)/16;
                            `uvm_info(get_type_name (), $sformatf ("Entry_CFG_INDEX %x",entry_cfg_index), UVM_NONE);
                            `uvm_info(get_type_name (), $sformatf ("addr3 %x, size: %x ", ahb_data_item_sc.HADDR_o, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                            if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                            else begin
                                entry_cfg_data = ahb_data_item_sc.HWDATA_o[31:0];
                            end
                            configure_entry_n(`ENTRY_CFG, entry_cfg_index, entry_cfg_data, 4);
                            $display("Entry_CFG Index in scoreboard , %h",entry_cfg_index);
                            $display("Entry_CFG Data in scoreboard , %h",entry_cfg_data);
                            $display("Entry_CFG Port Data in scoreboard , %h",ahb_data_item_sc.HWDATA_o);
                        end
                    endcase
                end
                if((ahb_data_item_sc.HADDR_o-BASE_ADDR) >= 16'h0800 && (ahb_data_item_sc.HADDR_o-BASE_ADDR) < 16'h1000)
                begin
                    if ((ahb_data_item_sc.HADDR_o-BASE_ADDR) >= 16'h0800 && (ahb_data_item_sc.HADDR_o-BASE_ADDR) <= (16'h0800+8'h3F*4'h4))
                    begin
                        `uvm_info(get_type_name (), $sformatf ("In scoreboard MDCFG_DATA WRITE"), UVM_NONE);
                        mdcfg_index = ((ahb_data_item_sc.HADDR_o-BASE_ADDR)-16'h0800)/4;
                        `uvm_info(get_type_name (), $sformatf ("addr4 %x, size: %x ", ahb_data_item_sc.HADDR_o-BASE_ADDR, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                        if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                            mdcfg_data = ahb_data_item_sc.HWDATA_o[63:32];
                            `uvm_info(get_type_name (), $sformatf ("HELLO1"), UVM_NONE);
                        end
                        else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                        else begin
                            mdcfg_data = ahb_data_item_sc.HWDATA_o[31:0];
                            `uvm_info(get_type_name (), $sformatf ("HELLO2"), UVM_NONE);
                        end
                        `uvm_info(get_type_name (), $sformatf ("MDCFG_INDEX  , %h",mdcfg_index), UVM_NONE);
                        `uvm_info(get_type_name (), $sformatf ("MDCFG_DATA  , %h",mdcfg_data), UVM_NONE);
                        configure_mdcfg_n(mdcfg_index, mdcfg_data, 4);
                    end
                end

                if((ahb_data_item_sc.HADDR_o-BASE_ADDR) == 16'h0008)
                begin
                        info_data = ahb_data_item_sc.HSIZE_o;
                        `uvm_info(get_type_name (), $sformatf ("In scoreboard Info WRITE"), UVM_NONE);
                        `uvm_info(get_type_name (), $sformatf ("addr4 %x, size: %x ", ahb_data_item_sc.HADDR_o-BASE_ADDR, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                        `uvm_info(get_type_name (), $sformatf ("Info_DATA  , %h",info_data), UVM_NONE);
                        if(ahb_data_item_sc.HWDATA_o[31]) set_hwcfg0_enable();
                end

                if((ahb_data_item_sc.HADDR_o-BASE_ADDR) == 16'h0030)
                begin
                        `uvm_info(get_type_name (), $sformatf ("In scoreboard MDSTALL WRITE"), UVM_NONE);
                        `uvm_info(get_type_name (), $sformatf ("addr4 %x, size: %x ", ahb_data_item_sc.HADDR_o-BASE_ADDR, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                        if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                            mdstall_data = ahb_data_item_sc.HWDATA_o[63:32];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO1"), UVM_NONE);
                        end
                        else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                        else begin
                            mdstall_data = ahb_data_item_sc.HWDATA_o[31:0];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO2"), UVM_NONE);
                        end
                        `uvm_info(get_type_name (), $sformatf ("MDSTALL_DATA  , %h",mdstall_data), UVM_NONE);
                        configure_mdstall( mdstall_data , 4);
                end

                if((ahb_data_item_sc.HADDR_o-BASE_ADDR) == 16'h0034)
                begin
                        `uvm_info(get_type_name (), $sformatf ("In scoreboard MDSTALLH WRITE"), UVM_NONE);
                        `uvm_info(get_type_name (), $sformatf ("addr4 %x, size: %x ", ahb_data_item_sc.HADDR_o-BASE_ADDR, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                        if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                            mdstallh_data = ahb_data_item_sc.HWDATA_o[63:32];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO1"), UVM_NONE);
                        end
                        else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                        else begin
                            mdstallh_data = ahb_data_item_sc.HWDATA_o[31:0];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO2"), UVM_NONE);
                        end
                        `uvm_info(get_type_name (), $sformatf ("MDSTALLH_DATA  , %h",mdstallh_data), UVM_NONE);
                        configure_mdstallh( mdstallh_data , 4);
                end

                if((ahb_data_item_sc.HADDR_o-BASE_ADDR) == 16'h0038)
                begin
                        `uvm_info(get_type_name (), $sformatf ("In scoreboard RRIDSCP WRITE"), UVM_NONE);
                        `uvm_info(get_type_name (), $sformatf ("addr4 %x, size: %x ", ahb_data_item_sc.HADDR_o-BASE_ADDR, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                        if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                            rridscp_data = ahb_data_item_sc.HWDATA_o[63:32];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO1"), UVM_NONE);
                        end
                        else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                        else begin
                            rridscp_data = ahb_data_item_sc.HWDATA_o[31:0];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO2"), UVM_NONE);
                        end
                        `uvm_info(get_type_name (), $sformatf ("RRIDSCP_DATA  , %h",rridscp_data), UVM_NONE);
                        configure_rridscp(rridscp_data , 4);
                end

                //////
                if((ahb_data_item_sc.HADDR_o-BASE_ADDR) == 16'h0040)
                begin
                        `uvm_info(get_type_name (), $sformatf ("In scoreboard MDLCK WRITE"), UVM_NONE);
                        `uvm_info(get_type_name (), $sformatf ("addr4 %x, size: %x ", ahb_data_item_sc.HADDR_o-BASE_ADDR, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                        if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                            mdlck_data = ahb_data_item_sc.HWDATA_o[63:32];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO1"), UVM_NONE);
                        end
                        else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                        else begin
                            mdlck_data = ahb_data_item_sc.HWDATA_o[31:0];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO2"), UVM_NONE);
                        end
                        `uvm_info(get_type_name (), $sformatf ("MDLCK_DATA  , %h",mdlck_data), UVM_NONE);
                        configure_mdlck(mdlck_data , 4);
                end

                if((ahb_data_item_sc.HADDR_o-BASE_ADDR) == 16'h0044)
                begin
                        `uvm_info(get_type_name (), $sformatf ("In scoreboard MDLCKH WRITE"), UVM_NONE);
                        `uvm_info(get_type_name (), $sformatf ("addr4 %x, size: %x ", ahb_data_item_sc.HADDR_o-BASE_ADDR, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                        if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                            mdlckh_data = ahb_data_item_sc.HWDATA_o[63:32];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO1"), UVM_NONE);
                        end
                        else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                        else begin
                            mdlckh_data = ahb_data_item_sc.HWDATA_o[31:0];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO2"), UVM_NONE);
                        end
                        `uvm_info(get_type_name (), $sformatf ("MDLCKH_DATA  , %h",mdlckh_data), UVM_NONE);
                        configure_mdlckh( mdlckh_data , 4);
                end

                if((ahb_data_item_sc.HADDR_o-BASE_ADDR) == 16'h0048)
                begin
                        `uvm_info(get_type_name (), $sformatf ("In scoreboard MDCFGLCK WRITE"), UVM_NONE);
                        `uvm_info(get_type_name (), $sformatf ("addr4 %x, size: %x ", ahb_data_item_sc.HADDR_o-BASE_ADDR, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                        if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                            mdcfglck_data = ahb_data_item_sc.HWDATA_o[63:32];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO1"), UVM_NONE);
                        end
                        else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                        else begin
                            mdcfglck_data = ahb_data_item_sc.HWDATA_o[31:0];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO2"), UVM_NONE);
                        end
                        `uvm_info(get_type_name (), $sformatf ("MDCFGLCK_DATA  , %h",mdcfglck_data), UVM_NONE);
                        configure_mdcfglck( mdcfglck_data , 4);
                end
                if((ahb_data_item_sc.HADDR_o-BASE_ADDR) == 16'h004C)
                begin
                        `uvm_info(get_type_name (), $sformatf ("In scoreboard ENTRYLCK WRITE"), UVM_NONE);
                        `uvm_info(get_type_name (), $sformatf ("addr4 %x, size: %x ", ahb_data_item_sc.HADDR_o-BASE_ADDR, ahb_data_item_sc.HSIZE_o), UVM_NONE);
                        if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                            entrylck_data = ahb_data_item_sc.HWDATA_o[63:32];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO1"), UVM_NONE);
                        end
                        else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                        else begin
                            entrylck_data = ahb_data_item_sc.HWDATA_o[31:0];
                            // `uvm_info(get_type_name (), $sformatf ("HELLO2"), UVM_NONE);
                        end
                        `uvm_info(get_type_name (), $sformatf ("ENTRYLCK_DATA  , %h",entrylck_data), UVM_NONE);
                        configure_entrylck(entrylck_data , 4);
                end

                /////

                if((ahb_data_item_sc.HADDR_o-BASE_ADDR) >= 16'h1000 && (ahb_data_item_sc.HADDR_o-BASE_ADDR) <= ENTRY_OFFSET)
                begin
                    srcmd_reg=((ahb_data_item_sc.HADDR_o-BASE_ADDR)-16'h1000)%32/4;
                    `uvm_info(get_type_name (), $sformatf ("srcmd reg , %d",srcmd_reg), UVM_NONE);
                    `uvm_info(get_type_name (), $sformatf ("ADDR, %h",ahb_data_item_sc.HADDR_o-BASE_ADDR), UVM_NONE);
                    `uvm_info(get_type_name (), $sformatf ("data  , %h",ahb_data_item_sc.HWDATA_o), UVM_NONE);
                    case(srcmd_reg)
                        0:begin
                            `uvm_info(get_type_name (), $sformatf ("In scoreboard SRCMD_EN WRITE"), UVM_NONE);
                            srcmd_en_index = ((ahb_data_item_sc.HADDR_o-BASE_ADDR)-16'h1000)/32;
                            if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                                srcmd_en_data = ahb_data_item_sc.HWDATA_o[63:32];
                            end
                            else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                            else begin
                                srcmd_en_data = ahb_data_item_sc.HWDATA_o;
                            end
                            `uvm_info(get_type_name (), $sformatf ("Index , %d",srcmd_en_index), UVM_NONE);
                            `uvm_info(get_type_name (), $sformatf ("Data  , %d",srcmd_en_data), UVM_NONE);
                            configure_srcmd_n(`SRCMD_EN, srcmd_en_index, srcmd_en_data, 4);
                        end
                        1:begin
                            `uvm_info(get_type_name (), $sformatf ("In scoreboard SRCMD_ENH WRITE"), UVM_NONE);
                            srcmd_enh_index = ((ahb_data_item_sc.HADDR_o-BASE_ADDR)-16'h1004)/32;
                            if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                                srcmd_enh_data = ahb_data_item_sc.HWDATA_o[63:32];
                            end
                            else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                            else begin
                                srcmd_enh_data = ahb_data_item_sc.HWDATA_o;
                            end
                            configure_srcmd_n(`SRCMD_ENH, srcmd_enh_index, srcmd_enh_data, 4);

                        end
                        2:begin
                            `uvm_info(get_type_name (), $sformatf ("In scoreboard SRCMD_R WRITE"), UVM_NONE);
                            srcmd_r_index = ((ahb_data_item_sc.HADDR_o-BASE_ADDR)-16'h1008)/32;

                            if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                                srcmd_r_data = ahb_data_item_sc.HWDATA_o[63:32];
                            end
                            else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                            else begin
                                srcmd_r_data = ahb_data_item_sc.HWDATA_o;
                            end
                            `uvm_info(get_type_name (), $sformatf ("Index , %d",srcmd_r_index), UVM_NONE);
                            `uvm_info(get_type_name (), $sformatf ("Data  , %d",srcmd_r_data), UVM_NONE);
                            configure_srcmd_n(`SRCMD_R, srcmd_r_index, srcmd_r_data, 4);
                        end
                        3:begin
                            `uvm_info(get_type_name (), $sformatf ("In scoreboard SRCMD_RH WRITE"), UVM_NONE);
                            srcmd_rh_index = ((ahb_data_item_sc.HADDR_o-BASE_ADDR)-16'h100C)/32;
                            if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                                srcmd_rh_data = ahb_data_item_sc.HWDATA_o[63:32];
                            end
                            else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                            else begin
                                srcmd_rh_data = ahb_data_item_sc.HWDATA_o;
                            end
                            configure_srcmd_n(`SRCMD_RH, srcmd_rh_index, srcmd_rh_data, 4);
                        end
                        4:begin
                            `uvm_info(get_type_name (), $sformatf ("In scoreboard SRCMD_W WRITE"), UVM_NONE);
                            srcmd_w_index = ((ahb_data_item_sc.HADDR_o-BASE_ADDR)-16'h1010)/32;
                            if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                                srcmd_w_data = ahb_data_item_sc.HWDATA_o[63:32];
                            end
                            else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                            else begin
                                srcmd_w_data = ahb_data_item_sc.HWDATA_o;
                            end
                            `uvm_info(get_type_name (), $sformatf ("Index , %d",srcmd_w_index), UVM_NONE);
                            `uvm_info(get_type_name (), $sformatf ("Data  , %d",srcmd_w_data), UVM_NONE);
                            configure_srcmd_n(`SRCMD_W, srcmd_w_index, srcmd_w_data, 4);
                        end
                        5:begin
                            `uvm_info(get_type_name (), $sformatf ("In scoreboard SRCMD_WH WRITE"), UVM_NONE);
                            srcmd_wh_index = ((ahb_data_item_sc.HADDR_o-BASE_ADDR)-16'h1014)/32;
                            if((ahb_data_item_sc.HADDR_o[2] ==1) && (ahb_data_item_sc.HSIZE_o == 2) && bus_params_pkg::BUS_DW ==64 ) begin
                                srcmd_wh_data = ahb_data_item_sc.HWDATA_o[63:32];
                            end
                            else if(ahb_data_item_sc.HSIZE_o == 3) begin
                                `uvm_fatal (get_type_name (), $sformatf ("8 HSIZE is not Possible"))
                            end
                            else begin
                                srcmd_wh_data = ahb_data_item_sc.HWDATA_o;
                            end
                            configure_srcmd_n(`SRCMD_WH, srcmd_wh_index, srcmd_wh_data, 4);
                        end
                    endcase
                end
            end
        // configure_srcmd_n(`SRCMD_EN, srcmd_en_index, srcmd_en_data, 4);
        // configure_srcmd_n(`SRCMD_R, srcmd_r_index, srcmd_r_data, 4);
        // configure_srcmd_n(`SRCMD_W, srcmd_w_index, srcmd_w_data, 4);
        // configure_mdcfg_n(mdcfg_index, mdcfg_data, 4);
        // configure_entry_n(`ENTRY_ADDR,entry_addr_index, entry_addr_data, 4);
        // configure_entry_n(`ENTRY_ADDRH,entry_addrh_index, entry_addrh_data, 4);
        // configure_entry_n(`ENTRY_CFG, entry_cfg_index, entry_cfg_data, 4);
        // write_register(16'h0030, mdstall_data , 4);
        // write_register(16'h0034, mdstallh_data, 4);
        // write_register(16'h0038, rridscp_data , 4);
        // write_register(16'h0040, mdlck_data , 4);
        // write_register(16'h0044, mdlckh_data , 4);
        // write_register(16'h0048, mdcfglck_data , 4);
        // write_register(16'h004c, entrylck_data , 4);
        end
    endfunction

    task reset_phase(uvm_phase phase);
        `uvm_info("RESET", "Starting Reset Phase...", UVM_MEDIUM)
        reset_iopmp();
        `uvm_info("RESET", "Reset Phase...Completed", UVM_MEDIUM)
    endtask

    virtual task  run_phase(uvm_phase phase);
        super.run_phase(phase);

        // `uvm_info(get_type_name (), $sformatf ("SRCMDEN , %d",srcmd_en_data), UVM_NONE);
        // configure_srcmd_n(`SRCMD_EN, srcmd_en_index, srcmd_en_data, 4);
        // `uvm_info(get_type_name (), $sformatf ("SRCMDR , %d",srcmd_r_data), UVM_NONE);
        // configure_srcmd_n(`SRCMD_R, srcmd_r_index, srcmd_r_data, 4);
        // configure_srcmd_n(`SRCMD_W, srcmd_w_index, srcmd_w_data, 4);
        // configure_mdcfg_n(mdcfg_index, mdcfg_data, 4);
        // configure_entry_n(`ENTRY_ADDR,entry_addr_index, entry_addr_data, 4);
        // configure_entry_n(`ENTRY_ADDRH,entry_addrh_index, entry_addrh_data, 4);
        // configure_entry_n(`ENTRY_CFG, entry_cfg_index, entry_cfg_data, 4);
        // write_register(16'h0030, mdstall_data , 4);
        // write_register(16'h0034, mdstallh_data, 4);
        // write_register(16'h0038, rridscp_data , 4);
        // write_register(16'h0040, mdlck_data , 4);
        // write_register(16'h0044, mdlckh_data , 4);
        // write_register(16'h0048, mdcfglck_data , 4);
        // write_register(16'h004c, entrylck_data , 4);
        //TODO:
        // Error
        fork
        // begin
        //     ahb_read_item = ahb_data_q_read.pop_front();

        //     if((ahb_read_item.RESP_i==0) && (ahb_read_item.HWDATA_i == 0))
        //     begin
        //         if(ahb_read_item.HADDR_o==)
        //     end
        // end
        begin
            forever
            begin
                wait((axi_wr_addr_q.size()>0)||(axi_rd_addr_q.size()>0));
                `uvm_info(get_type_name(),$sformatf("AXI_READ::POP::axi_rd_addr_item.addr=%d",axi_rd_addr_q[0]),UVM_LOW)
                if(axi_wr_addr_q.size())begin
                    // `uvm_info(get_type_name(),$sformatf("AXI_READ::POP::axi_rd_addr_item.addr=%d",axi_wr_addr_q[0]),UVM_LOW)
                    axi_wr_addr_item_sc = axi_wr_addr_q.pop_front();
                    `uvm_info(get_type_name(),$sformatf("AXI_WRITE::POP::axi_wr_addr_item.addr=%d",axi_wr_addr_item_sc.addr),UVM_LOW)
                    trans_req.rrid  = axi_wr_addr_item_sc.w_user;
                    trans_req.addr  = axi_wr_addr_item_sc.addr;
                    trans_req.length= axi_wr_addr_item_sc.burst_length;
                    trans_req.size  = axi_wr_addr_item_sc.size;
                    trans_req.perm  = 2;
                end
                else if(axi_rd_addr_q.size())begin
                    axi_rd_addr_item_sc = axi_rd_addr_q.pop_front();
                    `uvm_info(get_type_name(),$sformatf("AXI_READ::POP::axi_rd_addr_item.addr=%d",axi_rd_addr_item_sc.addr),UVM_LOW)
                    trans_req.rrid  = axi_rd_addr_item_sc.r_user[5:0];
                    trans_req.addr  = axi_rd_addr_item_sc.addr;
                    trans_req.length= axi_rd_addr_item_sc.burst_length;
                    trans_req.size  = axi_rd_addr_item_sc.size;
                    if(axi_rd_addr_item_sc.prot[2] == 0)begin
                        trans_req.perm  = 1;
                    end
                    else begin
                        trans_req.perm  = 3;
                    end
                end
                // $display("score burst %d", axi_rd_addr_item_sc.burst_length);
                // $display("score size %d", axi_rd_addr_item_sc.size);
                $display("1In Scoreboard req rrid: %d", trans_req.rrid);
                $display("1In Scoreboard req addr: %d", trans_req.addr);
                $display("1In Scoreboard req burst_length: %d", trans_req.length);
                $display("1In Scoreboard req size: %d", trans_req.size);
                $display("1In Scoreboard req prot: %d", axi_rd_addr_item_sc.prot[2]);

                addr = 'h8000;
                size = 4;
                data = 'hABCD1234;

                create_memory(2);

                // Call write_memory
                status = write_memory(data, addr, size);
                $display("Write Status: %d", status);
                // Clear data array
                data = "";
                $display("1In Scoreboard req addr: %d", trans_req.addr);
                $display("1In Scoreboard req length: %d", trans_req.length);
                $display("1In Scoreboard req size: %d", trans_req.size);
                $display("1In Scoreboard req rrid: %d", trans_req.rrid);


                iopmp_validate_access(trans_req, trans_rsp, out);
                // $display("1In Scoreboard status: %d", trans_rsp.status);
                // Call read_memory
                status = read_memory(addr, size, data1);
                // $display("Read Status: %d", status);
                // $display("Read Successful. Data: %x", data1);
                wait((axi_wr_rsp_q.size()>0)||(axi_rd_data_q.size()>0));
                if (axi_wr_rsp_q.size()) begin
                   axi_wr_rsp_item_sc = axi_wr_rsp_q.pop_front();
                   $display("IN Scoreboard write response popping data from queue");
                     axi_wr_rsp_item_sc.print();
                        if(axi_wr_rsp_item_sc.b_valid)begin
                            $display("In Scoreboard wr rsp item response %0d",axi_wr_rsp_item_sc.response);
                            if((axi_wr_rsp_item_sc.response[1]==trans_rsp.status)||(axi_wr_rsp_item_sc.response[1]==0 && trans_rsp.rrid_stalled))begin
                                $write("%c[1;32m",27);
                                `uvm_info(get_name(), "TEST PASSED YYYYYYYYYYYYYYYYYYYYYYY", UVM_LOW)
                                $write("%c[0m",27);
                            end
                            else begin
                                $write("%c[1;31m",27);
                                `uvm_error(get_name(), "TEST FAILED NNNNNNNNNNNNNNNNNNNN")
                                $write("%c[0m",27);
                            end
                            // $display("Scoreboard status: %0d", trans_rsp.status);
                            // $display("Design status: %0d", axi_wr_rsp_item_sc.response);
                            `uvm_info(get_type_name(), $sformatf ("Scoreboard status: %0d", trans_rsp.status), UVM_NONE);
                            `uvm_info(get_type_name(), $sformatf ("Design status: %0d", axi_wr_rsp_item_sc.response), UVM_NONE);

                        end
                end

                `uvm_info(get_type_name(), $sformatf ("AXI DATA ITEM  IN SCBoard"), UVM_NONE);
                // `uvm_info(get_type_name(),$sformatf("Received trans On write_axi_aw Analysis Imp Port"),UVM_LOW)
                if (axi_rd_data_q.size()) begin
                   axi_rd_data_item_sc = axi_rd_data_q.pop_front();
                   $display("IN Scoreboard read response popping data from queue");
                     axi_rd_data_item_sc.print();
                        if(axi_rd_data_item_sc.r_valid)begin
                            if((axi_rd_data_item_sc.response[1]==trans_rsp.status)||(axi_wr_rsp_item_sc.response[1]==0 && trans_rsp.rrid_stalled))begin
                                $write("%c[1;32m",27);
                                `uvm_info(get_name(), "\nTEST PASSED YYYYYYYYYYYYYYYYYYYYYYY", UVM_LOW)
                                $write("%c[0m",27);
                            end
                            else begin
                                $write("%c[1;31m",27);
                                `uvm_error(get_name(), "\nTEST FAILED NNNNNNNNNNNNNNNNNNNNNNN")
                                $write("%c[0m",27);
                                configure_err_info(32'h0000, 4);
                            end
                            `uvm_info(get_type_name(), $sformatf ("Scoreboard status: %0d", trans_rsp.status), UVM_NONE);
                            `uvm_info(get_type_name(), $sformatf ("Design status: %0d", axi_rd_data_item_sc.response), UVM_NONE);
                        end
                end
            end
        end
        join_none
    endtask


// SRCMD_REG_INDEX(offset)   ((((offset) - SRCMD_TABLE_BASE_OFFSET) % SRCMD_REG_STRIDE) / MIN_REG_WIDTH)
    // task main_phase(uvm_phase phase);


    // endtask




endclass

`endif