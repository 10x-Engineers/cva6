///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 27-June-2025
/// Description: This module handles AHB-Lite register accesses for IOPMP.
/// It performs address decoding, manages read/write requests with error
/// handling, and provides register configuration data to the Table Traversal
/// Unit (TTU), Rule Analyzer Pipeline (RAP), and Error & Interrupt Control
/// (EIC) units. It also generates per-RRID stall signals for AXI Master
/// Request Manager.
///////////////////////////////////////////////////////////////////////////

module register_file_manager
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import config_iopmp_pkg::AHB_LITE_ADDR_WIDTH;
  import rfm_pkg::rfm_ttu_t;
  import rfm_pkg::rfm_rap_t;
  import rfm_pkg::rfm_eic_t;
  import rfm_pkg::eic_rfm_t;
  import rfm_pkg::change_state_e;
  import ahb_lite_pkg::ahb_req_t;
  import ahb_lite_pkg::ahb_resp_t;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                    clk,                  // Clock Rising Edge
  input  logic                    rst_n,                // Reset Active Low

  // Regmap ==> Table Traversal Unit
  output rfm_ttu_t                rfm_ttu,              // Registers data required in TTU for Table Lookup

  // Regmap ==> Rule Analyzer Pipeline
  output rfm_rap_t                rfm_rap,              // Registers data required in RAP for address and permission matches

  // Regmap <==> Error and Interrupt Control
  output rfm_eic_t                rfm_eic,              // Register data required in EIC to determine whether to generate interrupt, log error in error registers or record subsequest violations
  input  eic_rfm_t                eic_rfm,              // Write enables and Data to write on error registers from EIC in case error has occured
  input  logic                    eic_rfm_valid,        // Indicates that a subsequent violation has occured and set the window index pointed by eic_rfm_err_rrid
  input  logic [5:0]              eic_rfm_err_rrid,     // Indicates RRID for subsequent violations to set the corresponding index in window

  // Regmap ==> AXI Master Request Manager
  output change_state_e           change_state,         // Indicates the Master Request Manager about the IOPMP state transition
  output logic [CFG.RRID_NUM-1:0] rrid_stall,           // Stall signal required in AXI Master Request Manager to determine whether to stall the transaction for specific RRID or not

  // Regmap ==> Slave Request manager
  output logic [10:0]             msi_data,             // The data to trigger MSI

  // RFM <==> AHB-LITE Interface
  input  ahb_req_t                ahb_req,              // Request from AHB-LITE Interface
  output ahb_resp_t               ahb_resp              // Response to AHB-LITE Interface
);

  // FSM States for response generation
  typedef enum bit {
    AHB_REQ    = 1'b0,         // 0 : Indicates that RFM is either waiting for valid request or processing the appropriate response of a valid request based in address decode
    RESP_ERROR = 1'b1          // 1 : Indicates that the incoming request address is illegal or misaligned. In that case, error is reported to AHB-LITE Interface
  } response_state_e;

  //###############################
  // Internal Signals Declarations
  //###############################
  ahb_req_t                       ahb_req_q;                              // AHB Request flop signal
  ahb_resp_t                      ahb_resp_n, ahb_resp_q;                 // AHB Response flop signal
  response_state_e                response_state_n, response_state_q;     // Response FSM State signals
  logic [AHB_LITE_DATA_WIDTH-1:0] ahb_hrdata;                             // Register to hold data of iopmp registers in case of read request
  logic [AHB_LITE_ADDR_WIDTH-1:0] req_addr_n, req_addr_q;                 // Register to hold the address till hreadyout is low
  logic                           valid_req;                              // Indicates that the request is valid based on interface signals
  logic                           is_addr_legal;                          // Indicates address is legal or illegal
  logic                           base_reg_legal;                         // Indicates whether incoming address belongs to a legal register in BASE region section 1
  logic                           info_legal;                             // Indicates whether incoming address belongs to a legal INFO register
  logic                           prog_prot_legal;                        // Indicates whether incoming address belongs to a legal PROGRAMMING PROTECTION register
  logic                           config_prot_legal;                      // Indicates whether incoming address belongs to a legal CONFIGURATION PROTECTION register
  logic                           err_rpt_legal;                          // Indicates whether incoming address belongs to a legal ERROR REPORTING register
  logic                           mdcfg_legal;                            // Indicates whether incoming address belongs to MDCFG region section 1
  logic                           srcmd_legal;                            // Indicates whether incoming address belongs to a legal register in SRCMD region section 1
  logic                           entry_array_legal;                      // Indicates whether incoming address belongs to a legal register in ENTRY ARRAY region section 2
  logic                           hreadyout_internal;                     // Internal signal to drive hreadyout low at the interface

  // Flop the incoming request for further processing
  always_ff @(posedge clk or negedge rst_n) begin : req_flop
    if(!rst_n) begin
      ahb_req_q <= '0;            // Default Assignment on reset
    end
    else begin
      ahb_req_q <= ahb_req;       // Register the incoming request from AHB-LITE Interface
    end
  end

  // Determine whether request is valid based on AHB-LITE interface signals
  assign valid_req = ahb_req_q.hsel && ahb_req_q.hready && (ahb_req_q.htrans == 2'b10);

  //****************************************************************************************************
  // AHB Response State Machine
  // The state machine drives the response of the AHB-LITE request based on address decode results
  // For a valid request with the a legal address, there is 1 wait state in case of read request and
  // 2 wait states for a write request. For an illegal or misaligned address, the 2 cycles of error
  // reponse is generated according to AHB-LITE spec
  //****************************************************************************************************
  always_comb begin

    // Default Assignment
    ahb_resp_n         = ahb_resp;
    response_state_n   = response_state_q;
    hreadyout_internal = 1'b1;
    req_addr_n         = req_addr_q;

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
            ahb_resp_n.hreadyout = 1'b0;
          end

          // For valid request if is_addr_legal is high and request is a read then send the register read data in response
          else begin
            ahb_resp_n.hrdata = ahb_hrdata;
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

  //****************************************************************************************************
  // IOPMP Address Check and Regmap Module
  //****************************************************************************************************
  address_check #(
    .CFG(CFG)
  ) address_check
  (
    // AHB-LITE Interface ==> Address Check
    .req_addr          (req_addr_n),              // Incoming request address from AHB-LITE Interface
    .valid_req         (valid_req),               // Indicates whether the incoming request is valid or not

    // Address Check ==> Regmap
    .is_addr_legal     (is_addr_legal),           // Indicates address is legal or illegal
    .base_reg_legal    (base_reg_legal),          // Indicates whether incoming address belongs to a legal register in BASE region section 1
    .info_legal        (info_legal),              // Indicates whether incoming address belongs to a legal INFO register
    .prog_prot_legal   (prog_prot_legal),         // Indicates whether incoming address belongs to a legal PROGRAMMING PROTECTION register
    .config_prot_legal (config_prot_legal),       // Indicates whether incoming address belongs to a legal CONFIGURATION PROTECTION register
    .err_rpt_legal     (err_rpt_legal),           // Indicates whether incoming address belongs to a legal ERROR REPORTING register
    .mdcfg_legal       (mdcfg_legal),             // Indicates whether incoming address belongs to MDCFG region section 1
    .srcmd_legal       (srcmd_legal),             // Indicates whether incoming address belongs to a legal register in SRCMD region section 1
    .entry_array_legal (entry_array_legal)        // Indicates whether incoming address belongs to a legal register in ENTRY ARRAY region section 2
  );

  regmap #(
    .CFG(CFG)
  ) regmap
  (
    .clk               (clk),                       // Clock Rising Edge
    .rst_n             (rst_n),                     // Reset Active Low

    // Address Check ==> Regmap
    .is_addr_legal     (is_addr_legal),             // Indicates address is legal or illegal
    .base_reg_legal    (base_reg_legal),            // Indicates whether incoming address belongs to a legal register in BASE region section 1
    .info_legal        (info_legal),                // Indicates whether incoming address belongs to a legal INFO register
    .prog_prot_legal   (prog_prot_legal),           // Indicates whether incoming address belongs to a legal PROGRAMMING PROTECTION register
    .config_prot_legal (config_prot_legal),         // Indicates whether incoming address belongs to a legal CONFIGURATION PROTECTION register
    .err_rpt_legal     (err_rpt_legal),             // Indicates whether incoming address belongs to a legal ERROR REPORTING register
    .mdcfg_legal       (mdcfg_legal),               // Indicates whether incoming address belongs to MDCFG region section 1
    .srcmd_legal       (srcmd_legal),               // Indicates whether incoming address belongs to a legal register in SRCMD region section 1
    .entry_array_legal (entry_array_legal),         // Indicates whether incoming address belongs to a legal register in ENTRY ARRAY region section 2

    // AHB-LITE Interface ==> Regmap
    .req_offset_addr   (req_addr_n[10:2]),          // Incoming request offset address bit[10:2]
    .req_access_type   (ahb_req_q.hwrite),          // Indicates whether the incoming request wants a write access (logic high) or read access (logic low)
    .req_wdata         (ahb_req_q.hwdata),          // Write data for write request

    // Regmap <==> Error and Interrupt Control
    .eic_rfm           (eic_rfm),                   // Write enables and Data to write on error registers from EIC in case error has occured
    .eic_rfm_valid     (eic_rfm_valid),             // Indicates that a subsequent violation has occured and set the window index pointed by eic_rfm_err_rrid
    .eic_rfm_err_rrid  (eic_rfm_err_rrid),          // Indicates RRID for subsequent violations to set the corresponding index in window
    .rfm_eic           (rfm_eic),                   // Register data required in EIC to determine whether to generate interrupt, log error in error registers or record subsequest violations

    // Regmap ==> Table Traversal Unit
    .rfm_ttu           (rfm_ttu),                   // Registers data required in TTU for Table Lookup

    // Regmap ==> Rule Analyzer Pipeline
    .rfm_rap           (rfm_rap),                   // Registers data required in RAP for address and permission matches

    // Regmap ==> AXI Master Request Manager
    .change_state      (change_state),              // Indicates the AXI Master Request Manager about the state transition
    .rrid_stall        (rrid_stall),                // Stall signal required in AXI Master Request Manager to determine whether to stall the transaction for specific RRID or not

    // Regmap ==> AXI Slave Request Manager
    .msi_data          (msi_data),                  // The data to trigger MSI

    // Regmap ==> Response Generation
    .ahb_hrdata        (ahb_hrdata)                 // Register data on read read request
  );

endmodule