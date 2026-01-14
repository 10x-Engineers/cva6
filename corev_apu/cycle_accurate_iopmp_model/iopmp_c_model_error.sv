///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Gull Ahmed <gull.ahmed@10xengineers.ai>
/// Date Created: 2-Jan-2025
/// Description:
///////////////////////////////////////////////////////////////////////////

module iopmp_c_model
  import config_iopmp_pkg::MAX_BURST_LEN;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import config_iopmp_pkg::AHB_LITE_ADDR_WIDTH;
  import config_iopmp_pkg::MAX_TRANS;
#(
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                           clk,
  input  logic                           rst_n,

  // Address Write Channel
  input  logic                           iAwValid,
  input  iopmp_axi_pkg::aw_channel_t     iAwChannel,
  output logic                           eAwReady,

  // Address Read Channel
  input  logic                           iArValid,
  input  iopmp_axi_pkg::ar_channel_t     iArChannel,
  output logic                           eArReady,

  // Write Channel
  input  logic                           iWrValid,
  input  iopmp_axi_pkg::w_channel_t      iWrChannel,
  output logic                           eWrReady,

  // Write Response Channel
  input  logic                           iBReady,
  output logic                           eBValid,
  output iopmp_axi_pkg::b_channel_t      eBChannel,

  // Read Response Channel
  input  logic                           iRReady,
  output logic                           eRValid,
  output iopmp_axi_pkg::r_channel_t      eRChannel,

  // Slave Address Write Channel
  input  logic                           iAwReady,
  output logic                           eAwValid,
  output iopmp_axi_pkg::slv_aw_channel_t eAwChannel,

  // Slave Address Read Channel
  input  logic                           iArReady,
  output logic                           eArValid,
  output iopmp_axi_pkg::ar_channel_t     eArChannel,

  // Slave Write Channel
  input  logic                           iWrReady,
  output logic                           eWrValid,
  output iopmp_axi_pkg::w_channel_t      eWrChannel,

  // Slave Read Response Channel
  input  logic                           iRValid,
  input  iopmp_axi_pkg::r_channel_t      iRChannel,
  output logic                           eRReady,

  // Slave Write Response Channel
  input  logic                           iBValid,
  input  iopmp_axi_pkg::slv_b_channel_t  iBChannel,
  output logic                           eBReady,

  // Ahb Request/Response Channel
  input  ahb_lite_pkg::ahb_req_i_t       ahb_req,
  output ahb_lite_pkg::ahb_resp_t        ahb_resp,

  // WSI - Wire-signaled-interrupt
  output logic                           wsi
);

localparam ENTRIES_PER_CYCLE   = 8;
localparam IOPMP_ENTRY_NUM     = 128;
localparam ENTRY_SEARCH_CYCLES = IOPMP_ENTRY_NUM/ENTRIES_PER_CYCLE;

localparam IOPMP_MD_NUM           = 63;
localparam IOPMP_MD_NUM_PER_CYCLE = 21;
localparam MD_CYCLE               = IOPMP_MD_NUM/IOPMP_MD_NUM_PER_CYCLE;

localparam EXE_PIPE_CYCLE = MD_CYCLE + ENTRY_SEARCH_CYCLES;

// localparam CYCLE_TILL_EXE_PIPE = 2;

localparam PIPE_STAGES = EXE_PIPE_CYCLE;

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
import "DPI-C" function void iopmp_validate_access(input iopmp_trans_req req, output iopmp_trans_rsp rsp, output bit [7:0] out);
import "DPI-C" context function void write_register(input longint unsigned offset, input int unsigned data, input byte num_bytes);
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
import "DPI-C" context function int unsigned read_register(input longint unsigned offset, input byte num_bytes);

  iopmp_trans_req     sv_trans_req;
  iopmp_trans_rsp     sv_trans_rsp;
  bit [7:0] out[10];

  typedef struct {
    logic             valid;
    iopmp_trans_req   data;
  } pipe_entry_t;

  pipe_entry_t rd_pipe [PIPE_STAGES];

  // FIFO class: default type = int, default depth = 32
  class fifo_queue #(type T = int, int MAX_DEPTH = 32);
    // Internal queue
    T queue[$];

    // Push method
    function void push(T data);
      if (queue.size() < MAX_DEPTH) begin
        queue.push_back(data);
      end else begin
        $display("FIFO full, cannot push %0p", data);
      end
    endfunction

    // Pop method
    function bit pop(output T data);
      if (queue.size() > 0) begin
        data = queue.pop_front();
        return 1; // success
      end else begin
        $display("[%0t] FIFO empty, returning default value", $time);
        data = '0;
        return 0;  // empty
      end
    endfunction

    function bit peek(output T data);
      if (queue.size() > 0) begin
        data = queue[0];   // front element — the one pop() will remove
        return 1;
      end
      data = '0;
      return 0;
    endfunction

    // Check size
    function int size();
      return queue.size();
    endfunction

    task automatic discard_n(input int n);
      if (n <= 0) return;

      if (queue.size() <= n)
        queue.delete();
      else
        queue = queue[n:$];   // keep entries starting at index n
    endtask

    // Helper methods
    function bit is_empty(); return (queue.size() == 0); endfunction
    function bit is_full();  return (queue.size() >= MAX_DEPTH); endfunction
  endclass

  // ------------------------------------------------------------------
  //  SIMPLE ROUND-ROBIN ARBITER FOR READ/WRITE REQUESTS
  // ------------------------------------------------------------------
  typedef enum {REQ_NONE, REQ_READ, REQ_WRITE} req_t;

  logic        read_req, write_req;
  req_t        granted_req;
  logic        rr_pointer;      // 0=read priority, 1=write priority

  // Detect requests
  assign read_req  = !rd_trans_req.is_empty();
  assign write_req = !wr_trans_req.is_empty();   // write request considered valid only when both arrive

  always_comb begin
    granted_req = REQ_NONE;

    case ({write_req, read_req})
      2'b00: granted_req = REQ_NONE;

      2'b01: granted_req = REQ_READ;       // only read present
      2'b10: granted_req = REQ_WRITE;      // only write present

      2'b11: begin                         // both present -> round robin
        if (rr_pointer == 1'b0)
          granted_req = REQ_READ;
        else
          granted_req = REQ_WRITE;
      end
    endcase
  end

  // Update pointer after a grant
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      rr_pointer <= 0;
    else if (granted_req != REQ_NONE)
      rr_pointer <= ~rr_pointer;
  end


  fifo_queue #(iopmp_axi_pkg::ar_channel_t, 32) read_trans_queue;
  // fifo_queue #(aw_channel_t, MAX_TRANS) write_trans_queue;
  // fifo_queue #(w_channel_t, MAX_TRANS) write_data_queue;
  // fifo_queue #(iopmp_trans_req, MAX_TRANS) rd_trans_req, wr_trans_req;
  // fifo_queue #(int,MAX_TRANS) read_trans_pass, read_trans_fail, wr_trans_pass, wr_trans_fail;
  // fifo_queue #(r_channel_t,16) store_rd_rsp;
  // fifo_queue #(b_channel_t,16) store_wr_rsp;

  bit dummy, dummy1;
  iopmp_trans_req rd_trans, wr_trans;
  logic w_data_ip, w_data_ip_n;

  initial begin : create_fifo_obj
    read_trans_queue  = new();
    // write_trans_queue = new();
    // write_data_queue  = new();
    // read_trans_pass   = new();
    // store_rd_rsp      = new();
    // store_wr_rsp      = new();
    // read_trans_fail   = new();
    // wr_trans_pass     = new();
    // wr_trans_fail     = new();
    // rd_trans_req      = new();
    // wr_trans_req      = new();
  end

  // iopmp_axi_pkg::ar_channel_t read_trans_queue;
  iopmp_axi_pkg::aw_channel_t write_trans_queue;
  iopmp_axi_pkg::w_channel_t write_data_queue;
  iopmp_trans_req rd_trans_req, wr_trans_req;
  logic read_trans_pass, read_trans_fail, wr_trans_pass, wr_trans_fail;
  iopmp_axi_pkg::r_channel_t store_rd_rsp;
  iopmp_axi_pkg::b_channel_t store_wr_rsp;

  iopmp_axi_pkg::ar_channel_t ar_rd_rsp;
  iopmp_axi_pkg::aw_channel_t aw_rd_rsp;
  logic [15:0] rd_beat_cntr, rd_beat_cntr_n;
  logic [31:0] error_info;

  // ------------------------------------------------------------------
  //  PROCESS 1: Collect incoming AR + AW transactions
  // ------------------------------------------------------------------
  initial forever begin
    @(posedge clk);
    eArReady = 1'b0;
    eAwReady = 1'b0;
    eWrReady = 1'b0;
    wsi      = '0;
    if (!rst_n) continue;

    error_info = read_register('h64, 'h4);
    wsi = error_info[0];

    eArReady = 1'b1;
    eAwReady = 1'b1;
    eWrReady = 1'b1;

    if (iArValid & eArReady) begin
      rd_trans.is_amo = iArChannel.ar_lock;
      rd_trans.perm   = iArChannel.ar_prot[2] ? 'h3 : 'h1;
      rd_trans.size   = iArChannel.ar_size;
      rd_trans.length = iArChannel.ar_len;
      rd_trans.addr   = iArChannel.ar_addr;
      rd_trans.rrid   = iArChannel.ar_user;

      rd_trans_req.push(rd_trans);
      read_trans_queue.push(iArChannel);
    end

    if (iAwValid & eAwReady) begin
      wr_trans.is_amo = iAwChannel.aw_lock;
      wr_trans.perm   = 'h2;
      wr_trans.size   = iAwChannel.aw_size;
      wr_trans.length = iAwChannel.aw_len;
      wr_trans.addr   = iAwChannel.aw_addr;
      wr_trans.rrid   = iAwChannel.aw_user;

      wr_trans_req.push(wr_trans);
      write_trans_queue.push(iAwChannel);
    end

    if (iWrValid & eWrReady) begin
      write_data_queue.push(iWrChannel);
    end

    write_register('h8,read_register('h8,'h4) | 'h80000000,'h4);    // Enable IOPMP

    if (rd_pipe[PIPE_STAGES-1].valid) begin
      sv_trans_req = rd_pipe[PIPE_STAGES-1].data;

      // Call C reference model
      iopmp_validate_access(sv_trans_req, sv_trans_rsp, out);

      if (sv_trans_req.perm == 'h2) begin
        if (sv_trans_rsp.status == 0)
          wr_trans_pass.push(1);
        else
          wr_trans_fail.push(1);
      end else begin
        if (sv_trans_rsp.status == 0)
          read_trans_pass.push(1);
        else
          read_trans_fail.push(1);
      end
    end
  end

  // ------------------------------------------------------------------
  //  PROCESS 2: Drive eAr channel to Slave (PASS case)
  // ------------------------------------------------------------------
  initial forever begin
    @(posedge clk);
    eArValid = 1'b0;
    if (!rst_n) continue;

    if (!read_trans_pass.is_empty()) begin
      repeat (1) @(posedge clk);

      eArValid = 1'b1;
      if (eArValid & iArReady) begin
        read_trans_queue.pop(eArChannel);
        read_trans_pass.pop(dummy);
      end
    end
  end

  // ------------------------------------------------------------------
  //  PROCESS 3: Drive eAw channel to Slave (PASS case)
  // ------------------------------------------------------------------
  initial forever begin
    @(posedge clk);
    eAwValid = 1'b0;
    eWrValid = '0;
    if (!rst_n) continue;

    if ((!wr_trans_pass.is_empty()) & !w_data_ip) begin
      repeat (1) @(posedge clk);

      eAwValid = 1'b1;
      if (eAwValid & iAwReady) begin
        write_trans_queue.pop(eAwChannel);
        wr_trans_pass.pop(dummy1);
      end
    end

    w_data_ip_n = (eAwValid & iAwReady) ? 1'b1 : w_data_ip;

    if ((eAwValid & iAwReady) || w_data_ip) begin
      eWrValid = 1'b1;
      if (eWrValid & iWrReady) begin
        write_data_queue.pop(eWrChannel);
        w_data_ip_n = eWrChannel.w_last ? 1'b0 : w_data_ip;
      end
    end
  end

  // ------------------------------------------------------------------
  //  PROCESS 4: Respond back RRESP
  // ------------------------------------------------------------------
  initial forever begin
    @(posedge clk);
    eRReady = '0;
    eRValid = '0;
    rd_beat_cntr_n = rd_beat_cntr;
    if (!rst_n) continue;

    eRReady = 1'b1;
    if (iRValid & eRReady) begin
      store_rd_rsp.push(iRChannel);
    end

    if (!store_rd_rsp.is_empty()) begin
      eRValid = 1'b1;
      if (eRValid & iRReady) begin
        store_rd_rsp.pop(eRChannel);
      end
    end

    if (!read_trans_fail.is_empty()) begin
      eRValid = 1'b1;
      if (eRValid & iRReady) begin
        read_trans_queue.peek(ar_rd_rsp);
        eRChannel.r_id   = ar_rd_rsp.ar_id;
        eRChannel.r_data = '0;
        eRChannel.r_resp = 'h1;
        eRChannel.r_last = 'h1;
        eRChannel.r_user = ar_rd_rsp.ar_user;

        if ((ar_rd_rsp.ar_len == '0) || (rd_beat_cntr == ar_rd_rsp.ar_len)) begin
          read_trans_queue.pop(ar_rd_rsp);
          read_trans_fail.pop(dummy);
        end
        else begin
          rd_beat_cntr_n = rd_beat_cntr + 1;
        end
      end
    end
  end

  // ------------------------------------------------------------------
  //  PROCESS 5: Respond back BRESP
  // ------------------------------------------------------------------
  initial forever begin
    @(posedge clk);
    eBReady = '0;
    eBValid = '0;
    if (!rst_n) continue;

    eBReady = 1'b1;
    if (iBValid & eBReady) begin
      store_wr_rsp.push(iBChannel);
    end

    if (!store_wr_rsp.is_empty()) begin
      eBValid = 1'b1;
      if (eBValid & iBReady) begin
        store_wr_rsp.pop(eBChannel);
      end
    end

    if (!wr_trans_fail.is_empty()) begin
      eBValid = 1'b1;
      if (eBValid & iBReady) begin
        write_trans_queue.pop(aw_rd_rsp);
        eBChannel.b_id   = aw_rd_rsp.aw_id;
        eBChannel.b_resp = 'h1;
        eBChannel.b_user = aw_rd_rsp.aw_user;
        if (aw_rd_rsp.aw_len == '0)
          write_data_queue.pop();
        else
          write_data_queue.discard_n(aw_rd_rsp.aw_len);

        wr_trans_fail.pop(dummy1);
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin : beat_rd_beat_cntr
    if (!rst_n) begin
      rd_beat_cntr <= '0;
      w_data_ip <= '0;
    end else begin
      rd_beat_cntr <= rd_beat_cntr_n;
      w_data_ip    <= w_data_ip_n;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i=0; i<PIPE_STAGES; i++) begin
        rd_pipe[i].valid <= 1'b0;
        rd_pipe[i].data  <= '0;
      end
    end else begin
      // shift stages downward
      for (int i = PIPE_STAGES-1; i > 0; i--) begin
        rd_pipe[i] <= rd_pipe[i-1];
      end

      // stage 0 gets new request if available
      if (granted_req == REQ_READ) begin
        rd_pipe[0].valid <= 1'b1;
        rd_trans_req.pop(rd_pipe[0].data);
      end else if (granted_req == REQ_WRITE) begin
        rd_pipe[0].valid <= 1'b1;
        wr_trans_req.pop(rd_pipe[0].data);
      end else begin
        rd_pipe[0].valid <= 1'b0;
        rd_pipe[0].data  <= '0;
      end
    end
  end

  // FSM States for response generation
  typedef enum bit {
    AHB_REQ    = 1'b0,         // 0 : Indicates that RFM is either waiting for valid request or processing the appropriate response of a valid request based in address decode
    RESP_ERROR = 1'b1          // 1 : Indicates that the incoming request address is illegal or misaligned. In that case, error is reported to AHB-LITE Interface
  } response_state_e;

  ahb_lite_pkg::ahb_req_t         ahb_request;
  ahb_lite_pkg::ahb_req_t         ahb_req_q;                              // AHB Request flop signal
  logic                           hreadyout_internal;
  ahb_lite_pkg::ahb_resp_t        ahb_resp_n, ahb_resp_q;                 // AHB Response flop signal
  logic                           valid_req;
  logic                           is_addr_legal;
  response_state_e                response_state_n, response_state_q;     // Response FSM State signals
  logic [AHB_LITE_DATA_WIDTH-1:0] ahb_hrdata;                             // Register to hold data of iopmp registers in case of read request
  logic [AHB_LITE_ADDR_WIDTH-1:0] req_addr_n, req_addr_q, req_addr;                 // Register to hold the address till hreadyout is low

  // Local parameters for base address of section 1 and 2
  // Base Address of each section must be 64K byte aligned
  localparam logic [15:0] BASE_ADDR_OF_SECT_1    = CFG.BASE_ADDR[31:16];
  localparam logic [15:0] BASE_ADDR_OF_SECT_2    = CFG.BASE_ADDR[31:16] + CFG.ENTRY_OFFSET[31:16];

  localparam              REG_SIZE               = 4;             // Register size in IOPMP is 4 byte
  localparam logic [15:0] MAX_BASE_REG_OFFSET    = 16'h007C;      // This parameter indicates the maximum value of offset address that lies in BASE region
  localparam logic [15:0] MDCFG_START_OFFSET     = 16'h0800;      // This parameter indicates the start offset address of MDCFG region
  localparam logic [15:0] SRCMD_START_OFFSET     = 16'h1000;      // This parameter indicates the start offset address of SRCMD region
  localparam logic [15:0] MAX_MDCFG_OFFSET       = (MDCFG_START_OFFSET + ({10'd0,CFG.MD_NUM} << 2)) - REG_SIZE;     // Indicates the maximum offset address that can belong to region 3 (MDCFG)
  localparam logic [15:0] MAX_SRCMD_FMT_0_OFFSET = (SRCMD_START_OFFSET + (CFG.RRID_NUM << 5)) - REG_SIZE;   // Indicates the maximum offset address that can belong to region 5 (SRCMD) when SRCMD Format is 0
  localparam logic [15:0] MAX_SRCMD_FMT_2_OFFSET = (SRCMD_START_OFFSET + ({10'd0,CFG.MD_NUM} << 5)) - REG_SIZE;     // Indicates the maximum offset address that can belong to region 5 (SRCMD) when SRCMD Format is 2
  localparam logic [15:0] MAX_ENTRY_ARRAY_OFFSET = (CFG.ENTRY_NUM << 4) - REG_SIZE;   // Indicates the maximum offset address that can belong to section 2 (ENTRY ARRAY)

  assign req_addr = req_addr_n;

   // Driving ahb request with hready drive internally
  assign ahb_request = '{
    haddr     : ahb_req.haddr,
    hwrite    : ahb_req.hwrite,
    hsize     : ahb_req.hsize,
    hburst    : ahb_req.hburst,
    hprot     : ahb_req.hprot,
    htrans    : ahb_req.htrans,
    hmastlock : ahb_req.hmastlock,
    hwdata    : ahb_req.hwdata,
    hready    : ahb_resp.hreadyout,
    hsel      : ahb_req.hsel
  };

  // ------------------------------------------------------------------
  //  Program IOPMP MMRs
  // ------------------------------------------------------------------

  `define VALID_ADDR_CHECK(req_addr, valid_req, is_addr_legal)                   \
  begin                                                                            \
    logic [15:0] req_offset_addr = req_addr[15:0];                                 \
    logic [15:0] req_base_addr   = req_addr[31:16];                                \
                                                                                  \
    logic addr_aligned             = (req_addr[1:0] == 2'b00);                     \
    logic is_section_1             = (req_base_addr == BASE_ADDR_OF_SECT_1);       \
    logic is_section_2             = (req_base_addr == BASE_ADDR_OF_SECT_2);       \
    logic is_base_register         = (req_offset_addr <= MAX_BASE_REG_OFFSET);     \
                                                                                  \
    logic info_reg1_legal          = is_base_register && (req_offset_addr[6:4] == 3'b000); \
    logic info_reg2_legal          = is_base_register &&                          \
                                    (req_offset_addr[6:4] == 3'b001) &&           \
                                    (!(&req_offset_addr[3:2]));                   \
    logic info_legal               = is_section_1 && (info_reg1_legal || info_reg2_legal);  \
                                                                                  \
    logic prog_prot_legal          = is_section_1 && is_base_register &&           \
                                    (req_offset_addr[6:4] == 3'b011) &&           \
                                    (!(&req_offset_addr[3:2]));                   \
                                                                                  \
    logic config_prot_maybe_legal  = is_base_register && (req_offset_addr[6:4] == 3'b100); \
    logic config_prot_illegal1     = CFG.SRCMD_FMT_1 && (!req_offset_addr[3]);     \
    logic config_prot_illegal2     = (CFG.MDCFG_FMT_1 || CFG.MDCFG_FMT_2) &&       \
                                    (req_offset_addr[3] && (!req_offset_addr[2])); \
    logic config_prot_legal        = is_section_1 && config_prot_maybe_legal &&    \
                                    (!(config_prot_illegal1 || config_prot_illegal2)); \
                                                                                  \
    logic err_rpt1_maybe_legal     = is_base_register && (req_offset_addr[6:4] == 3'b110) \
                                    && CFG.ERROR_CAPTURE_EN;                      \
    logic err_rpt1_illegal1        = (!CFG.ADDRH_EN) && (&req_offset_addr[3:2]);   \
    logic err_rpt1_legal           = err_rpt1_maybe_legal && (!err_rpt1_illegal1); \
                                                                                  \
    logic err_rpt2_maybe_legal     = is_base_register && (req_offset_addr[6:4] == 3'b111) \
                                    && CFG.ERROR_CAPTURE_EN;                      \
    logic err_rpt2_illegal1        = (!CFG.MFR_EN) && ((!req_offset_addr[3]) && req_offset_addr[2]); \
    logic err_rpt2_illegal2        = (!CFG.MSI_EN) && (req_offset_addr[3]);        \
    logic err_rpt2_illegal3        = (CFG.MSI_EN) && (!CFG.ADDRH_EN) && (&req_offset_addr[3:2]); \
    logic err_rpt2_legal           = err_rpt2_maybe_legal &&                       \
                                    (!(err_rpt2_illegal1 || err_rpt2_illegal2 || err_rpt2_illegal3)); \
                                                                                  \
    logic err_rpt_legal            = is_section_1 && (err_rpt1_legal || err_rpt2_legal); \
                                                                                  \
    logic base_reg_legal           = info_legal || prog_prot_legal ||              \
                                    config_prot_legal || err_rpt_legal;           \
                                                                                  \
    logic mdcfg_legal              = CFG.MDCFG_FMT_0 && is_section_1 &&            \
                                    (req_offset_addr >= MDCFG_START_OFFSET) &&    \
                                    (req_offset_addr <= MAX_MDCFG_OFFSET);        \
                                                                                  \
    logic is_srcmd_register        = (CFG.SRCMD_FMT_0 &&                           \
                                    (req_offset_addr >= SRCMD_START_OFFSET) &&    \
                                    (req_offset_addr <= MAX_SRCMD_FMT_0_OFFSET)) || \
                                    (CFG.SRCMD_FMT_2 &&                           \
                                    (req_offset_addr >= SRCMD_START_OFFSET) &&    \
                                    (req_offset_addr <= MAX_SRCMD_FMT_2_OFFSET)); \
                                                                                  \
    logic srcmd_illegal1           = (&req_offset_addr[4:3]);                      \
    logic srcmd_illegal2           = CFG.SRCMD_FMT_0 && (!CFG.SPS_EN) && (|req_offset_addr[4:3]); \
    logic srcmd_illegal3           = CFG.SRCMD_FMT_2 && (|req_offset_addr[4:3]);   \
    logic srcmd_legal              = is_section_1 && is_srcmd_register &&          \
                                    (!(srcmd_illegal1 || srcmd_illegal2 || srcmd_illegal3)); \
                                                                                  \
    logic is_entry_array           = (req_offset_addr <= MAX_ENTRY_ARRAY_OFFSET);  \
    logic entry_array_illegal1     = (&req_offset_addr[3:2]);                      \
    logic entry_array_illegal2     = (!CFG.ADDRH_EN) && ((!req_offset_addr[3]) && req_offset_addr[2]); \
    logic entry_array_legal        = is_section_2 && is_entry_array &&             \
                                    (!(entry_array_illegal1 || entry_array_illegal2)); \
                                                                                  \
    logic is_addr_legal_section_1  = base_reg_legal || mdcfg_legal || srcmd_legal; \
                                                                                  \
    is_addr_legal = (is_addr_legal_section_1 || entry_array_legal) &&              \
                    addr_aligned && valid_req;                                     \
  end

  assign valid_req = ahb_req_q.hsel && ahb_req_q.hready && (ahb_req_q.htrans == 2'b10);

  always_comb begin
    // Default Assignment
    ahb_resp_n         = ahb_resp;
    response_state_n   = response_state_q;
    hreadyout_internal = 1'b1;
    req_addr_n         = req_addr_q;
    `VALID_ADDR_CHECK(req_addr_n, valid_req, is_addr_legal)

    case (response_state_q)

      AHB_REQ: begin
        hreadyout_internal   = !valid_req;    // Drive the hreadyout low internally when request is valid
        ahb_resp_n.hreadyout = 1'b1;
        ahb_resp_n.hresp     = 1'b0;
        ahb_resp_n.hrdata    = '0;

        // For a valid request, drive appropriate AHB response based on address check is legal or not
        if (valid_req) begin

          req_addr_n = ahb_req_q.haddr;   // Store the incoming address

          // If is_addr_legal is low, it indicates that the incoming request address is either illegal or misaligned
          // In this case, drive hreadyout low and hresp high to register the first cycle of an error response
          if (!is_addr_legal) begin
            response_state_n     = RESP_ERROR;
            ahb_resp_n.hreadyout = 1'b0;
            ahb_resp_n.hresp     = 1'b1;
          end

          // For valid request if is_addr_legal is high, it means the incoming request address is valid
          // In this case, insert a wait state to allow time for the register write operation to complete
          else if (ahb_req_q.hwrite) begin
            write_register(ahb_req_q.haddr - CFG.BASE_ADDR, ahb_request.hwdata, 'h4);
            $display("\n\nWrite Sucessful at address: %x and data: %x \n\n", ahb_req_q.haddr, read_register(ahb_req_q.haddr - CFG.BASE_ADDR,'h4));
            ahb_resp_n.hreadyout = 1'b0;
          end

          // For valid request if is_addr_legal is high and request is a read then send the register read data in response
          else begin
            ahb_resp_n.hrdata = read_register(ahb_req_q.haddr - CFG.BASE_ADDR,'h4);
            $display("\n\nRead Sucessful at address: %x and data: %x \n\n", ahb_req_q.haddr, ahb_resp_n.hrdata);
          end
        end
      end

      RESP_ERROR: begin

        // If the state is RESP_ERROR, it indicates that the first cycle of an error request has already been reported
        // In this case, drive the second cycle of the error response and then transition to the AHB_REQ state to accept the next request
        response_state_n     = AHB_REQ;
        ahb_resp_n.hreadyout = 1'b1;
        ahb_resp_n.hresp     = 1'b1;
        ahb_resp_n.hrdata    = '0;
      end
    endcase
  end

  // Response and Next state flop
  always_ff @(posedge clk or negedge rst_n) begin : resp_flop
    if(!rst_n) begin
      ahb_resp_q       <= '{
                            hrdata    : '0,
                            hresp     : 1'b0,
                            hreadyout : 1'b1
                          };                      // Default Assignment on reset
      response_state_q <= AHB_REQ;                // Default Assignment on reset
      req_addr_q       <= '0;                     // Default Assignment on reset
    end
    else begin
      ahb_resp_q       <= ahb_resp_n;             // Register the response to AHB-LITE Interface
      response_state_q <= response_state_n;       // Transition to next state
      req_addr_q       <= req_addr_n;             // Flop the incoming address till hreadyout low
    end
  end

  // Response to AHB-LITE Interface
  assign ahb_resp = '{
    hreadyout : ahb_resp_q.hreadyout && hreadyout_internal,     // Drive the hreadyout low combinationally when request is valid
    hresp     : ahb_resp_q.hresp,       // Response status 0: OKAY, 1: ERROR
    hrdata    : ahb_resp_q.hrdata       // Register data on read request
  };

  always_ff @(posedge clk or negedge rst_n) begin : req_flop
    if(!rst_n) begin
      ahb_req_q <= '0;            // Default Assignment on reset
    end
    else begin
      ahb_req_q <= ahb_request;       // Register the incoming request from AHB-LITE Interface
    end
  end


endmodule
