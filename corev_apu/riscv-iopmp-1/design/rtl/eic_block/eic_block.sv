///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 2-February-2025
/// Description: The Error and Interrupt Control module manages error
/// detection and interrupt generation based on the status of AXI
/// transactions and error record. It logs error information to the register
/// file, triggers WSI or MSI interrupts based on configuration.
///////////////////////////////////////////////////////////////////////////

module eic_block
  import execution_pipeline_pkg::error_info_t;
  import iopmp_axi_pkg::transaction_t;
  import rfm_pkg::rfm_eic_t;
  import rfm_pkg::eic_rfm_t;
  import iopmp_axi_pkg::slv_aw_channel_t;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic            clk,                     // Clock
  input  logic            rst_n,                   // Active low reset

  // Rule Analzyer Pipeline ==> Error and Interrupt Control
  input  logic            rap_eic_valid,           // Indicates rap_eic_err_info and rap_eic_trans has valid content
  input  error_info_t     rap_eic_error_info,      // Holds error information such as error type, interrupt suppression and error entry index
  input  transaction_t    rap_eic_trans,           // Error Transaction

  // Register File Manager <==> Error and Interrupt Control
  input  rfm_eic_t        rfm_eic,                 // Register data required in EIC to determine whether to generate interrupt, log error in error registers or record subsequest violations.
  output eic_rfm_t        eic_rfm,                 // Write enables and Data to write on error registers from EIC in case error has occured.
  output logic            eic_rfm_valid,           // Indicates that a subsequent violation has occured and set the window index pointed by eic_rfm_err_rrid.
  output logic [5:0]      eic_rfm_err_rrid,        // Indicates RRID for subsequent violations to set the corresponding index in window.

  // Error and Interrupt Control ==> Slave Request Manager
  output logic            eic_msi_valid,           // MSI Write Request valid
  output slv_aw_channel_t eic_msi_trans,           // MSI Write Data

  // Master Response Manager ==> Error and Interrupt Control
  input  logic            mrspm_eic_valid,         // MSI Write Response valid
  input  logic            mrspm_eic_trans,         // MSI Write Response

  output logic            wsi                      // WSI interrupt
);

  // FSM State for Wired Signal Interrupt (WSI)
  typedef enum bit {
    WSI_IDLE = 1'b0,
    GEN_WSI  = 1'b1
  } wsi_state_e;

  //###############################
  // Internal Signals Declarations
  //###############################

  wsi_state_e                wsi_state_q, wsi_state_n;    // Current and next state of WSI
  logic                      generate_intrpt;             // Indicates if interrupt can be generated or not
  logic                      err_rec_en;                  // Indicates if write on error register is valid or not
  logic [AXI_ADDR_WIDTH-1:0] msi_address;                 // Address of an MSI transaction

  // For an errored transaction (rap_eic_valid is high), interrupt will be generated when the interrupt suppression bit (bit 0) in the
  // rap_eic_error_info is low, ERR_INFO.v and ERR_INFO.msi_werr are low and Interrupt generation is enabled ERR_CFG.ie is asserted
  assign generate_intrpt = (!(rfm_eic.err_info_v || rfm_eic.err_info_msi_werr || rap_eic_error_info.err_info[0])) && rfm_eic.err_cfg_ie && rap_eic_valid;

  // On receiving an errored transaction (rap_eic_valid is high), the error is logged in error register if ERR_INFO.v and
  // ERR_INFO.msi_werr indicates no sign of a previous error (these signals must be low)
  assign err_rec_en = rap_eic_valid && (!(rfm_eic.err_info_v || rfm_eic.err_info_msi_werr));

  //****************************************************************************************************
  // Multi-Fault Record (MFR) Extension
  //****************************************************************************************************

  // If Multi-Fault Record (MFR) is enabled, the subsequent violation is logged in the error record window when either ERR_INFO.v
  // or ERR_INFO.msi_werr is high, inndicating the record of a previous error and error register has valid content
  if (CFG.MFR_EN) begin : gen_mfr_logic

    // On detecting a subsequent violation, a valid signal is sent to Register File Manager to indicate the eic_rfm_err_rrid signal has a valid content
    assign eic_rfm_valid    = rap_eic_valid && (rfm_eic.err_info_v || rfm_eic.err_info_msi_werr);

    assign eic_rfm_err_rrid = rap_eic_trans.rrid[5:0];    // Record the rrid for subsequent violation
  end
  else begin : drive_mfr_signals_zero
    assign eic_rfm_valid    = 1'b0;
    assign eic_rfm_err_rrid = '0;
  end

  //****************************************************************************************************
  // ERROR Registers HW Write Data Signals
  //****************************************************************************************************
  assign eic_rfm.err_info.v.hwdata     = 1'b1;      // Set err_info.v on error detection to indicate that error capture register holds valid data
  assign eic_rfm.err_info.etype.hwdata = rap_eic_error_info.err_info[4:1];    // Record the error type

  // Record the error transaction access type (read/write/instruction-fetch)
  assign eic_rfm.err_info.ttype.hwdata = {(rap_eic_trans.w || rap_eic_trans.x),(rap_eic_trans.r || rap_eic_trans.x)};

  assign eic_rfm.err_reqaddr.hwdata    = rap_eic_trans.addr[33:2];    // Record lower 32 bits error transaction address in err_reqaddr
  assign eic_rfm.err_reqaddrh.hwdata   = (AXI_ADDR_WIDTH == 52) ? rap_eic_trans.addr[51:34] : '0;   // Record upper 18 bits error transaction address in err_reqaddrh
  assign eic_rfm.err_reqid.rrid.hwdata = {{10{1'b0}},rap_eic_trans.rrid[5:0]};  // RRID of the errored transaction
  assign eic_rfm.err_reqid.eid.hwdata  = {{(16-$clog2(CFG.ENTRY_NUM)){1'b0}},rap_eic_error_info.err_entry_index};   // Record the error entry index

  //****************************************************************************************************
  // ERROR Registers HW Write Enable Signals
  //****************************************************************************************************
  assign eic_rfm.err_info.v.hwen     = err_rec_en;
  assign eic_rfm.err_info.etype.hwen = err_rec_en;
  assign eic_rfm.err_info.ttype.hwen = err_rec_en;
  assign eic_rfm.err_reqaddr.hwen    = err_rec_en;
  assign eic_rfm.err_reqaddrh.hwen   = (AXI_ADDR_WIDTH == 52) && err_rec_en;
  assign eic_rfm.err_reqid.rrid.hwen = err_rec_en;
  assign eic_rfm.err_reqid.eid.hwen  = err_rec_en;

  //****************************************************************************************************
  // Generate Message Signal Interrupt (MSI)
  //****************************************************************************************************

  // If Messsage Signal Interrupt (MSI) feature is enabled, then interrupt can be generated via MSI
  if (CFG.MSI_EN) begin : gen_msi

    // If IOPMP supports ADDRH_EN feature, the higher register ERR_MSIADDRH is implemented and MSI transaction address
    // is created from both lower (ERR_MSIADDR) and higher (ERR_MSIADDRH) registers
    if (CFG.ADDRH_EN) begin : gen_52bit_msi_trans_addr
      assign msi_address = {rfm_eic.err_msiaddrh,rfm_eic.err_msiaddr};
    end

    // If IOPMP does not support ADDRH_EN feature, the high register ERR_MSIADDRH is not implemented and MSI transaction address
    // is created only from lower register ERR_MSIADDR
    else begin : gen_32bit_msi_trans_addr
      assign msi_address = {rfm_eic.err_msiaddr,2'b00};
    end

    // Send the transaction to Slave Request Manager to log the MSI details
    assign eic_msi_trans = '{
      aw_id     : 6'h20,    // 1 at bit 5 indicates the transaction is an MSI
      aw_addr   : msi_address,
      aw_len    : '0,
      aw_size   : 3'b001,   // As MSIDATA is 11 bits wide so maximum 2 bytes transfer is valid
      aw_burst  : '0,
      aw_lock   : '0,
      aw_cache  : '0,
      aw_prot   : '0,
      aw_qos    : '0,
      aw_region : '0,
      aw_user   : '0
    };

    // MSI Interrupt is generated if generate_intrpt is high and ERR_CFG.msi_en is asserted
    assign eic_msi_valid = generate_intrpt && rfm_eic.err_cfg_msi_en;

    // When the MSI Interrupt is generated, the result of the write operation must be recorded is ERR_INFO.msi_werr
    assign eic_rfm.err_info.msi_werr.hwdata = mrspm_eic_trans;    // MSI write operation status
    assign eic_rfm.err_info.msi_werr.hwen   = mrspm_eic_valid;    // HW write enable signal for ERR_INFO.msi_werr
  end
  else begin : drive_msi_signals_zero
    assign eic_msi_valid                    = 1'b0;
    assign eic_msi_trans                    = '0;
    assign eic_rfm.err_info.msi_werr.hwdata = 1'b0;
    assign eic_rfm.err_info.msi_werr.hwen   = 1'b0;
  end

  //****************************************************************************************************
  // Generate Wired Signal Interrupt (WSI)
  //****************************************************************************************************
  always_comb begin : wsi_fsm_comb

    // Default next state assignment
    wsi_state_n = wsi_state_q;

    case (wsi_state_q)

      WSI_IDLE: begin

        // Wired Signal Interrupt default value
        wsi = 1'b0;

        // Wired Signal Interrupt is generated if generate_intrpt is high and ERR_CFG.msi_en is low
        // When a WSI is generated, the state changed to GEN_WSI and set wsi signal high
        if (generate_intrpt && (!rfm_eic.err_cfg_msi_en)) begin
          wsi_state_n = GEN_WSI;
          wsi         = 1'b1;
        end
      end

      // Stay in GEN_MSI state until SW clears the ERR_IFNO.v. When SW clears the ERR_INFO.v, the
      // state is changed to WSI_IDLE ans wsi signal is deasserted
      GEN_WSI: begin
        wsi = rfm_eic.err_info_v;
        if (!rfm_eic.err_info_v)
          wsi_state_n = WSI_IDLE;
      end
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin : wsi_fsm_flop
    if (!rst_n) begin
      wsi_state_q <= WSI_IDLE;      // Reset State
    end
    else begin
      wsi_state_q <= wsi_state_n;   // Next State
    end
  end

endmodule