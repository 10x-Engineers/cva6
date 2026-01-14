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
  import config_cycle_acc_pkg::*;
  import axi_c_pkg::*;
  import ahb_lite_c_pkg::*;
  import c_model_pkg::*;
  import fifo_pkg::*;
(
  input  logic        clk,
  input  logic        rst_n,

  // Address Write Channel
  input  logic        iAwValid,
  input  aw_channel_t iAwChannel,
  output logic        eAwReady,

  // Address Read Channel
  input  logic        iArValid,
  input  ar_channel_t iArChannel,
  output logic        eArReady,

  // Write Channel
  input  logic        iWrValid,
  input  w_channel_t  iWrChannel,
  output logic        eWrReady,

  // Write Response Channel
  input  logic        iBReady,
  output logic        eBValid,
  output b_channel_t  eBChannel,

  // Read Response Channel
  input  logic        iRReady,
  output logic        eRValid,
  output r_channel_t  eRChannel,

  // Slave Address Write Channel
  input  logic        iAwReady,
  output logic        eAwValid,
  output aw_channel_t eAwChannel,

  // Slave Address Read Channel
  input  logic        iArReady,
  output logic        eArValid,
  output ar_channel_t eArChannel,

  // Slave Write Channel
  input  logic        iWrReady,
  output logic        eWrValid,
  output w_channel_t  eWrChannel,

  // Slave Read Response Channel
  input  logic        iRValid,
  input  r_channel_t  iRChannel,
  output logic        eRReady,

  // Slave Write Response Channel
  input  logic        iBValid,
  input  b_channel_t  iBChannel,
  output logic        eBReady,

  // Ahb Request/Response Channel
  input  ahb_req_i_t  ahb_req,
  output ahb_resp_t   ahb_resp,

  // WSI - Wire-signaled-interrupt
  output logic        wsi
);

  // Internal Signal Declaration
  localparam ENTRIES_PER_CYCLE   = 8;
  localparam IOPMP_ENTRY_NUM     = 128;     // TODO: Replace this hard-coded number
  localparam ENTRY_SEARCH_CYCLES = IOPMP_ENTRY_NUM/ENTRIES_PER_CYCLE;

  localparam IOPMP_MD_NUM           = 63;
  localparam IOPMP_MD_NUM_PER_CYCLE = 21;
  localparam MD_CYCLE               = IOPMP_MD_NUM/IOPMP_MD_NUM_PER_CYCLE;

  localparam PIPE_STAGES = MD_CYCLE + ENTRY_SEARCH_CYCLES;

  iopmp_trans_req     sv_trans_req;
  iopmp_trans_rsp     sv_trans_rsp;
  bit [7:0] out[10];

  pipe_entry_t rd_pipe [PIPE_STAGES];

  // fifo_queue #(ar_channel_t, MAX_TRANS) read_trans_queue;
  // fifo_queue #(aw_channel_t, MAX_TRANS) write_trans_queue;
  // fifo_queue #(w_channel_t, MAX_TRANS) write_data_queue;
  // fifo_queue #(iopmp_trans_req, MAX_TRANS) rd_trans_req, wr_trans_req;
  // fifo_queue #(int,MAX_TRANS) read_trans_pass, read_trans_fail, wr_trans_pass, wr_trans_fail;
  // fifo_queue #(r_channel_t,16) store_rd_rsp;
  // fifo_queue #(b_channel_t,16) store_wr_rsp;

  fifo_t read_trans_queue;
  fifo_t write_trans_queue;
  fifo_t write_data_queue;
  fifo_t rd_trans_req, wr_trans_req;
  fifo_t read_trans_pass, read_trans_fail, wr_trans_pass, wr_trans_fail;
  fifo_t store_rd_rsp;
  fifo_t store_wr_rsp;

  int dummy, dummy1;
  w_channel_t dummy2;
  iopmp_trans_req rd_trans, wr_trans;
  logic w_data_ip, w_data_ip_n;

  initial begin : create_fifo_obj
    init(read_trans_queue , 32);
    init(write_trans_queue, 32);
    init(write_data_queue , 32);
    init(read_trans_pass  , 32);
    init(store_rd_rsp     , 16);
    init(store_wr_rsp     , 16);
    init(read_trans_fail  , 32);
    init(wr_trans_pass    , 32);
    init(wr_trans_fail    , 32);
    init(rd_trans_req     , 32);
    init(wr_trans_req     , 32);
  end

  ar_channel_t ar_rd_rsp;
  aw_channel_t aw_rd_rsp;
  logic [15:0] rd_beat_cntr, rd_beat_cntr_n;
  logic [31:0] error_info;
  logic [31:0] error_cfg;

  // import "DPI-C" context function int reset_iopmp();
  import "DPI-C" context function void iopmp_validate_access(input iopmp_trans_req req, output iopmp_trans_rsp rsp, output bit [7:0] out[]);
  import "DPI-C" context function void write_register(input longint unsigned offset, input int unsigned data, input byte num_bytes);
  import "DPI-C" context function int unsigned read_register(input longint unsigned offset, input byte num_bytes);

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
    error_cfg  = read_register('h60, 'h4);
    // WSI only when interrupt is enabled
    wsi = error_cfg[1] & error_info[0];

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

      // rd_trans_req.push(rd_trans);
      push(rd_trans_req, rd_trans);
      push(read_trans_queue, iArChannel);
      // read_trans_queue.push(iArChannel);
    end

    if (iAwValid & eAwReady) begin
      wr_trans.is_amo = iAwChannel.aw_lock;
      wr_trans.perm   = 'h2;
      wr_trans.size   = iAwChannel.aw_size;
      wr_trans.length = iAwChannel.aw_len;
      wr_trans.addr   = iAwChannel.aw_addr;
      wr_trans.rrid   = iAwChannel.aw_user;

      push(wr_trans_req, wr_trans);
      push(write_trans_queue, iAwChannel);
    end

    if (iWrValid & eWrReady) begin
      push(write_data_queue, iWrChannel);
    end

    // write_register('h8,read_register('h8,'h4) | 'h80000000,'h4);    // Enable IOPMP

    if (rd_pipe[PIPE_STAGES-1].valid) begin
      sv_trans_req = rd_pipe[PIPE_STAGES-1].data;

      // Call C reference model
      iopmp_validate_access(sv_trans_req, sv_trans_rsp, out);

      if (sv_trans_req.perm == 'h2) begin
        if (sv_trans_rsp.status == 0)
          push(wr_trans_pass, 1);
        else
          push(wr_trans_fail, 1);
      end else begin
        if (sv_trans_rsp.status == 0)
          push(read_trans_pass, 1);
        else
          push(read_trans_fail, 1);
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

    if (!is_empty(read_trans_pass)) begin
      repeat (1) @(posedge clk);

      eArValid = 1'b1;
      if (eArValid & iArReady) begin
        push(read_trans_queue, eArChannel);
        push(read_trans_pass, dummy);
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

    if (!is_empty(wr_trans_pass) & !w_data_ip) begin
      repeat (1) @(posedge clk);

      eAwValid = 1'b1;
      if (eAwValid & iAwReady) begin
        push(write_trans_queue, eAwChannel);
        push(wr_trans_pass, dummy1);
      end
    end

    w_data_ip_n = (eAwValid & iAwReady) ? 1'b1 : w_data_ip;

    if ((eAwValid & iAwReady) || w_data_ip) begin
      eWrValid = 1'b1;
      if (eWrValid & iWrReady) begin
        push(write_data_queue, eWrChannel);
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
      push(store_rd_rsp, iRChannel);
    end

    if (!is_empty(store_rd_rsp)) begin
      eRValid = 1'b1;
      if (eRValid & iRReady) begin
        push(store_rd_rsp, eRChannel);
      end
    end

    if (!is_empty(read_trans_fail)) begin
      eRValid = 1'b1;
      if (eRValid & iRReady) begin
        peek(read_trans_queue, ar_rd_rsp);
        eRChannel.r_id   = ar_rd_rsp.ar_id;
        eRChannel.r_data = '0;
        eRChannel.r_resp = 'h1;
        eRChannel.r_last = 'h1;
        eRChannel.r_user = ar_rd_rsp.ar_user;

        if ((ar_rd_rsp.ar_len == '0) || (rd_beat_cntr == ar_rd_rsp.ar_len)) begin
          push(read_trans_queue, ar_rd_rsp);
          push(read_trans_fail, dummy);
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
      push(store_wr_rsp, iBChannel);
    end

    if (!is_empty(store_wr_rsp)) begin
      eBValid = 1'b1;
      if (eBValid & iBReady) begin
        push(store_wr_rsp, eBChannel);
      end
    end

    if (!is_empty(wr_trans_fail)) begin
      eBValid = 1'b1;
      if (eBValid & iBReady) begin
        push(write_trans_queue, aw_rd_rsp);
        eBChannel.b_id   = aw_rd_rsp.aw_id;
        eBChannel.b_resp = 'h1;
        eBChannel.b_user = aw_rd_rsp.aw_user;
        if (aw_rd_rsp.aw_len == '0)
          push(write_data_queue, dummy2);
        else
          discard_n(write_data_queue, aw_rd_rsp.aw_len);

        push(wr_trans_fail, dummy1);
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin : beat_rd_beat_cntr
    if (!rst_n) begin
      rd_beat_cntr <= '0;
      w_data_ip    <= '0;
    end else begin
      rd_beat_cntr <= rd_beat_cntr_n;
      w_data_ip    <= w_data_ip_n;
    end
  end

   // ------------------------------------------------------------------
  //  SIMPLE ROUND-ROBIN ARBITER FOR READ/WRITE REQUESTS
  // ------------------------------------------------------------------
  logic        read_req, write_req;
  req_t        granted_req;
  logic        rr_pointer;      // 0=read priority, 1=write priority

  always_comb begin
  // Detect requests
   read_req  = !is_empty(rd_trans_req);
   write_req = !is_empty(wr_trans_req);   // write request considered valid only when both arrive
  end

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
        push(rd_trans_req, rd_pipe[0].data);
      end else if (granted_req == REQ_WRITE) begin
        rd_pipe[0].valid <= 1'b1;
        push(wr_trans_req, rd_pipe[0].data);
      end else begin
        rd_pipe[0].valid <= 1'b0;
        rd_pipe[0].data  <= '0;
      end
    end
  end

  ahb_req_t        ahb_request;
  ahb_req_t        ahb_req_q;
  logic            hreadyout_internal;
  ahb_resp_t       ahb_resp_n, ahb_resp_q;
  logic            valid_req;
  logic            is_addr_legal;
  response_state_e response_state_n, response_state_q;
  logic [AHB_LITE_DATA_WIDTH-1:0] ahb_hrdata;
  logic [AHB_LITE_ADDR_WIDTH-1:0] req_addr_n, req_addr_q, req_addr;

  //TODO: Read these values from the register
  localparam logic [15:0] MAX_MDCFG_OFFSET       = (MDCFG_START_OFFSET + ({10'd0,MD_NUM} << 2)) - REG_SIZE;     // Indicates the maximum offset address that can belong to region 3 (MDCFG)
  localparam logic [15:0] MAX_SRCMD_FMT_0_OFFSET = (SRCMD_START_OFFSET + (RRID_NUM << 5)) - REG_SIZE;   // Indicates the maximum offset address that can belong to region 5 (SRCMD) when SRCMD Format is 0
  localparam logic [15:0] MAX_SRCMD_FMT_2_OFFSET = (SRCMD_START_OFFSET + ({10'd0,MD_NUM} << 5)) - REG_SIZE;     // Indicates the maximum offset address that can belong to region 5 (SRCMD) when SRCMD Format is 2
  localparam logic [15:0] MAX_ENTRY_ARRAY_OFFSET = (ENTRY_NUM << 4) - REG_SIZE;   // Indicates the maximum offset address that can belong to section 2 (ENTRY ARRAY)

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
            write_register(ahb_req_q.haddr - BASE_ADDR, ahb_request.hwdata, 'h4);
            ahb_resp_n.hreadyout = 1'b0;
          end

          // For valid request if is_addr_legal is high and request is a read then send the register read data in response
          else begin
            ahb_resp_n.hrdata = read_register(ahb_req_q.haddr - BASE_ADDR,'h4);
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
