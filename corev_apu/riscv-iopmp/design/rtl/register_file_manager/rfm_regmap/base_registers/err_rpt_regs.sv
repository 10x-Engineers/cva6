///////////////////////////////////////////////////////////////////////////
// Copyright 2025 10xEngineers, technologies. All Rights Reserved.
//
// No portions of this material may be reproduced in any form without
// the written permission of 10xEngineers, technologies.
// All information contained in this document is 10xEngineers, technologies.
// company confidential, proprietary and trade secret.
//
/// Author: Urwa Maryam <urwa.maryam@10xengineers.ai>
/// Date Created: 20-June-2025
/// Description:
///////////////////////////////////////////////////////////////////////////

module err_rpt_regs
  import config_iopmp_pkg::AHB_LITE_DATA_WIDTH;
  import config_iopmp_pkg::AXI_ADDR_WIDTH;
  import rfm_pkg::eic_rfm_t;
  import rfm_pkg::err_rpt_reg_t;
  import rfm_pkg::IOPMP_ERR_CFG;
  import rfm_pkg::IOPMP_ERR_INFO;
  import rfm_pkg::IOPMP_ERR_REQADDR;
  import rfm_pkg::IOPMP_ERR_REQADDRH;
  import rfm_pkg::IOPMP_ERR_REQID;
  import rfm_pkg::IOPMP_ERR_MFR;
  import rfm_pkg::IOPMP_ERR_MSIADDR;
  import rfm_pkg::IOPMP_ERR_MSIADDRH;
#(
  // IOPMP Configuration Struct
  parameter config_iopmp_pkg::iopmp_cfg_t CFG = config_iopmp_pkg::iopmp_cfg_default
) (
  input  logic                           clk,                       // Clock Rising Edge
  input  logic                           rst_n,                     // Reset Active Low

  // Address Check ==> ERROR REPORTING Registers
  input  logic                           err_rpt_legal,             // Indicates whether incoming address belongs to a legal ERROR REPORTING register

  // Base Registers ==> ERROR REPORTING Registers
  input  logic [2:0]                     err_rpt_reg_demux_sel,     // ERROR REPORTING register write path demux select signal
  input  logic                           err_rpt_reg_write_valid,   // ERROR REPORTING register Write valid signal
  input  logic [AHB_LITE_DATA_WIDTH-1:0] err_rpt_reg_swdata,        // Write data for ERROR REPORTING registers

  // Error and Interrupt Control ==> ERROR REPORTING Registers
  input  eic_rfm_t                       eic_rfm,                   // Write enables and Data to write on error registers from EIC in case error has occured

  // Error Record Window ==> ERROR REPORTING Registers
  input  logic                           err_info_svc_hwen,         // ERR_INFO.svc HW write enable signal
  input  logic                           err_info_svc_hwdata,       // ERR_INFO.svc HW write data signal
  input  logic                           err_mfr_svs_hwen,          // ERR_MFR.svs HW write enable signal
  input  logic                           err_mfr_svs_hwdata,        // ERR_MFR.svs HW write data signal
  input  logic [15:0]                    err_mfr_svw_hwdata,        // ERR_MFR.svw HW write enable signal
  input  logic                           err_mfr_svw_hwen,          // ERR_MFR.svw HW write data signal
  input  logic [11:0]                    err_mfr_svi_hwdata,        // ERR_MFR.svi HW write enable signal
  input  logic                           err_mfr_svi_hwen,          // ERR_MFR.svi HW write data signal

  // ERROR REPORTING Registers ==> Base Registers
  output err_rpt_reg_t                   err_rpt_reg                // IOPMP ERROR REPORTING Registers
);

  localparam MAX_SVI_VALUE = (((int'(CFG.RRID_NUM) + 15)/16) - 1);   // Indicates the maximum error window index based on RRIDs

  //###############################
  // Internal Signals Declarations
  //###############################

  // Registers/Fields SW write enable and write data signals
  logic        err_cfg_l_swdata;
  logic        err_cfg_l_swen;
  logic        err_cfg_ie_swdata;
  logic        err_cfg_ie_swen;
  logic        err_cfg_msi_en_swdata;
  logic        err_cfg_msi_en_swen;
  logic [10:0] err_cfg_msidata_swdata;
  logic        err_cfg_msidata_swen;
  logic        err_info_v_swdata;
  logic        err_info_v_swen;
  logic        err_info_msi_werr_swdata;
  logic        err_info_msi_werr_swen;
  logic [11:0] err_mfr_svi_swdata;
  logic        err_mfr_svi_swen;
  logic [31:0] err_msiaddr_swdata;
  logic        err_msiaddr_swen;
  logic [19:0] err_msiaddrh_swdata;
  logic        err_msiaddrh_swen;

  if (CFG.ERROR_CAPTURE_EN) begin : gen_error_regs_write_path

    //****************************************************************************************************
    // Registers/Fields SW Write Data Signals
    //****************************************************************************************************

    // ERR_CFG Register Fields SW Write Data Signals
    assign err_cfg_l_swdata       = err_rpt_reg_swdata[0];
    assign err_cfg_ie_swdata      = err_rpt_reg_swdata[1];
    assign err_cfg_msi_en_swdata  = err_rpt_reg_swdata[3];
    assign err_cfg_msidata_swdata = err_rpt_reg_swdata[18:8];

    // ERR_INFO Register Fields SW Write Data Signals
    assign err_info_v_swdata        = err_rpt_reg_swdata[0];
    assign err_info_msi_werr_swdata = err_rpt_reg_swdata[3];

    // ERR_MFR Register Fields SW Write Data Signals
    if (CFG.MFR_EN) begin : gen_err_mfr_swdata

      // err_mfr.svi tells the windows index to search for subsequent violations. The range of legal values is defined by hwcfg1.rrid/16
      assign err_mfr_svi_swdata = (err_rpt_reg_swdata[27:16] <= MAX_SVI_VALUE[11:0]) ?
                                  err_rpt_reg_swdata[27:16] :   // Write new data
                                  MAX_SVI_VALUE[11:0];                // Configure to maximum supported value
    end
    else begin : drive_mfr_svi_swdata_zero
      assign err_mfr_svi_swdata = '0;
    end

    // ERR_MSIADDR Register SW Write Data Signals
    assign err_msiaddr_swdata = err_rpt_reg_swdata;

    // ERR_MSIADDRH Register SW Write Data Signals
    assign err_msiaddrh_swdata = err_rpt_reg_swdata[19:0];

    //****************************************************************************************************
    // DEMUX for Registers/Fields SW Write Enable Signals
    //****************************************************************************************************
    always_comb begin

      // The signal err_rpt_legal act as an enable signal to ERROR REPORTING registers demux
      // When high it indicates demux is enabled and determine the ERROR REPORTING register/fields to write based on err_rpt_reg_demux_sel signal
      if (err_rpt_legal) begin

        // Drive all SW write enable signals of ERROR REPORTING registers/fields low before matching any case
        // The case statement only handles the SW write enable signal for the particular register/fields it matches
        err_cfg_l_swen         = 1'b0;
        err_cfg_ie_swen        = 1'b0;
        err_cfg_msi_en_swen    = 1'b0;
        err_cfg_msidata_swen   = 1'b0;
        err_info_v_swen        = 1'b0;
        err_info_msi_werr_swen = 1'b0;
        err_mfr_svi_swen       = 1'b0;
        err_msiaddr_swen       = 1'b0;
        err_msiaddrh_swen      = 1'b0;

        // Determine the ERROR REPORTING register/fields to write based on err_rpt_reg_demux_sel signal
        case (err_rpt_reg_demux_sel)

          IOPMP_ERR_CFG: begin

            // Drive ERR_CFG register fields sw write enables
            err_cfg_l_swen       = err_rpt_reg_write_valid;
            err_cfg_ie_swen      = err_rpt_reg_write_valid && !err_rpt_reg.err_cfg.l;
            err_cfg_msi_en_swen  = CFG.MSI_EN && err_cfg_ie_swen;
            err_cfg_msidata_swen = CFG.MSI_EN && err_cfg_ie_swen;
          end

          IOPMP_ERR_INFO: begin

            // Drive ERR_INFO register fields sw write enables
            err_info_v_swen        = err_rpt_reg_write_valid;
            err_info_msi_werr_swen = CFG.MSI_EN && err_info_v_swen;
          end

          IOPMP_ERR_MFR: begin

            // Drive ERR_MFR register fields sw write enables
            err_mfr_svi_swen = CFG.MFR_EN && err_rpt_reg_write_valid;
          end

          IOPMP_ERR_MSIADDR: begin

            // Drive ERR_MSIADDR register sw write enables
            err_msiaddr_swen = CFG.MSI_EN && err_rpt_reg_write_valid && (!err_rpt_reg.err_cfg.l);  // Lock bit in ERR_CFG register locks the ERR_MSIADDR/ERR_MSIADDRH
          end

          IOPMP_ERR_MSIADDRH: begin

            // Drive ERR_MSIADDRH register sw write enables
            err_msiaddrh_swen = CFG.MSI_EN && CFG.ADDRH_EN && err_rpt_reg_write_valid && (!err_rpt_reg.err_cfg.l);  // Lock bit in ERR_CFG register locks the ERR_MSIADDR/ERR_MSIADDRH
          end
          default: ;
        endcase
      end

      // Drive all SW enable signals of ERROR REPORTING registers/fields low as err_rpt_legal is low
      else begin
        err_cfg_l_swen         = 1'b0;
        err_cfg_ie_swen        = 1'b0;
        err_cfg_msi_en_swen    = 1'b0;
        err_cfg_msidata_swen   = 1'b0;
        err_info_v_swen        = 1'b0;
        err_info_msi_werr_swen = 1'b0;
        err_mfr_svi_swen       = 1'b0;
        err_msiaddr_swen       = 1'b0;
        err_msiaddrh_swen      = 1'b0;
      end
    end
  end

  //****************************************************************************************************
  // ERROR REPORTING REGISTERS
  //****************************************************************************************************

  if (CFG.ERROR_CAPTURE_EN) begin : gen_error_capture_regs

    // ########### ERR_CFG ###########
    regfield #(
      .DW      (1),
      .SWACCESS("W1SS"),
      .RESVAL  (1'b0)
    ) u_err_cfg_l
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (err_cfg_l_swen),
      .swdata  (err_cfg_l_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (err_rpt_reg.err_cfg.l)
    );

    regfield #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'b0)
    ) u_err_cfg_ie
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (err_cfg_ie_swen),
      .swdata  (err_cfg_ie_swdata),

      .hwen    (1'b0),
      .hwdata  ('0),

      .hwrdata (err_rpt_reg.err_cfg.ie)
    );

    assign err_rpt_reg.err_cfg.rs = 1'b0;

    if (CFG.MSI_EN) begin : gen_msi_regs
      regfield #(
        .DW      (1),
        .SWACCESS("RW"),
        .RESVAL  (1'b1)
      ) u_err_cfg_msi_en
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (err_cfg_msi_en_swen),
        .swdata  (err_cfg_msi_en_swdata),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (err_rpt_reg.err_cfg.msi_en)
      );

      regfield #(
        .DW      (11),
        .SWACCESS("RW"),
        .RESVAL  ('0)
      ) u_err_cfg_msidata
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (err_cfg_msidata_swen),
        .swdata  (err_cfg_msidata_swdata),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (err_rpt_reg.err_cfg.msidata)
      );

      // ########### ERR_MSIADDR ###########
      regfield #(
        .DW      (32),
        .SWACCESS("RW"),
        .RESVAL  ('0)
      ) u_err_msiaddr
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (err_msiaddr_swen),
        .swdata  (err_msiaddr_swdata),

        .hwen    (1'b0),
        .hwdata  ('0),

        .hwrdata (err_rpt_reg.err_msiaddr.msiaddr)
      );

      if (CFG.ADDRH_EN) begin : gen_err_msiaddrh_reg

        // ########### ERR_MSIADDRH ###########
        regfield #(
          .DW      (20),
          .SWACCESS("RW"),
          .RESVAL  ('0)
        ) u_err_msiaddrh
        (
          .clk     (clk),
          .rst_n   (rst_n),

          .swen    (err_msiaddrh_swen),
          .swdata  (err_msiaddrh_swdata),

          .hwen    (1'b0),
          .hwdata  ('0),

          .hwrdata (err_rpt_reg.err_msiaddrh.msiaddrh)
        );
      end
      else begin : gen_msiaddrh_hardwired_zero
        assign err_rpt_reg.err_msiaddrh = '0;
      end
    end
    else begin : gen_msi_regs_hardwired_zeros
      assign err_rpt_reg.err_cfg.msi_en  = 1'b0;
      assign err_rpt_reg.err_cfg.msidata = '0;
      assign err_rpt_reg.err_msiaddr     = '0;
      assign err_rpt_reg.err_msiaddrh    = '0;
    end

    assign err_rpt_reg.err_cfg.rsv1               = '0;   // Drive reserved bits default zero
    assign err_rpt_reg.err_cfg.stall_violation_en = 1'b0;

    // ########### ERR_INFO ###########
    regfield #(
      .DW      (1),
      .SWACCESS("W1C"),
      .RESVAL  (1'b0)
    ) u_err_info_v
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (err_info_v_swen),
      .swdata  (err_info_v_swdata),

      .hwen    (eic_rfm.err_info.v.hwen),
      .hwdata  (eic_rfm.err_info.v.hwdata),

      .hwrdata (err_rpt_reg.err_info.v)
    );

    regfield #(
      .DW      (2),
      .SWACCESS("RO"),
      .RESVAL  ('0)
    ) u_err_info_ttype
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (1'b0),
      .swdata  ('0),

      .hwen    (eic_rfm.err_info.ttype.hwen),
      .hwdata  (eic_rfm.err_info.ttype.hwdata),

      .hwrdata (err_rpt_reg.err_info.ttype)
    );

    if (CFG.MSI_EN) begin : gen_msi_werr_flop
      regfield #(
        .DW      (1),
        .SWACCESS("W1C"),
        .RESVAL  (1'b0)
      ) u_err_info_msi_werr
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (err_info_msi_werr_swen),
        .swdata  (err_info_msi_werr_swdata),

        .hwen    (eic_rfm.err_info.msi_werr.hwen),
        .hwdata  (eic_rfm.err_info.msi_werr.hwdata),

        .hwrdata (err_rpt_reg.err_info.msi_werr)
      );
    end
    else begin : gen_msi_werr_zero
      assign err_rpt_reg.err_info.msi_werr = 1'b0;
    end

    regfield #(
      .DW      (4),
      .SWACCESS("RO"),
      .RESVAL  ('0)
    ) u_err_info_etype
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (1'b0),
      .swdata  ('0),

      .hwen    (eic_rfm.err_info.etype.hwen),
      .hwdata  (eic_rfm.err_info.etype.hwdata),

      .hwrdata (err_rpt_reg.err_info.etype)
    );

    if (CFG.MFR_EN) begin : gen_mfr_reg
      regfield #(
        .DW      (1),
        .SWACCESS("RO"),
        .RESVAL  (1'b0)
      ) u_err_info_svc
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (1'b0),
        .swdata  ('0),

        .hwen    (err_info_svc_hwen),
        .hwdata  (err_info_svc_hwdata),

        .hwrdata (err_rpt_reg.err_info.svc)
      );

      // ########### ERR_MFR ###########
      regfield #(
        .DW      (16),
        .SWACCESS("RO"),
        .RESVAL  ('0)
      ) u_err_mfr_svw
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (1'b0),
        .swdata  ('0),

        .hwen    (err_mfr_svw_hwen),
        .hwdata  (err_mfr_svw_hwdata),

        .hwrdata (err_rpt_reg.err_mfr.svw)
      );

      regfield #(
        .DW      (12),
        .SWACCESS("RW"),
        .RESVAL  ('0)
      ) u_err_mfr_svi
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (err_mfr_svi_swen),
        .swdata  (err_mfr_svi_swdata),

        .hwen    (err_mfr_svi_hwen),
        .hwdata  (err_mfr_svi_hwdata),

        .hwrdata (err_rpt_reg.err_mfr.svi)
      );

      regfield #(
        .DW      (1),
        .SWACCESS("RO"),
        .RESVAL  (1'b0)
      ) u_err_mfr_svs
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (1'b0),
        .swdata  ('0),

        .hwen    (err_mfr_svs_hwen),
        .hwdata  (err_mfr_svs_hwdata),

        .hwrdata (err_rpt_reg.err_mfr.svs)
      );
    end
    else begin : gen_mfr_reg_hardwired_zero
      assign err_rpt_reg.err_info.svc = 1'b0;
      assign err_rpt_reg.err_mfr      = '0;
    end

    // ########### ERR_REQADDR ###########
    regfield #(
      .DW      (32),
      .SWACCESS("RO"),
      .RESVAL  ('0)
    ) u_err_reqaddr
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (1'b0),
      .swdata  ('0),

      .hwen    (eic_rfm.err_reqaddr.hwen),
      .hwdata  (eic_rfm.err_reqaddr.hwdata),

      .hwrdata (err_rpt_reg.err_reqaddr.addr)
    );

    if (CFG.ADDRH_EN) begin : gen_err_reqaddrh_reg

      // ########### ERR_REQADDRH ###########
      regfield #(
        .DW      (18),
        .SWACCESS("R0"),
        .RESVAL  ('0)
      ) u_err_reqaddrh
      (
        .clk     (clk),
        .rst_n   (rst_n),

        .swen    (1'b0),
        .swdata  ('0),

        .hwen    (eic_rfm.err_reqaddrh.hwen),
        .hwdata  (eic_rfm.err_reqaddrh.hwdata),

        .hwrdata (err_rpt_reg.err_reqaddrh.addrh)
      );
    end
    else begin : gen_err_reqaddrh_hardwired_zeros
      assign err_rpt_reg.err_reqaddrh.addrh = '0;
    end

    // ########### ERR_REQID ###########
    regfield #(
      .DW      (16),
      .SWACCESS("RO"),
      .RESVAL  ('0)
    ) u_err_reqid_rrid
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (1'b0),
      .swdata  ('0),

      .hwen    (eic_rfm.err_reqid.rrid.hwen),
      .hwdata  (eic_rfm.err_reqid.rrid.hwdata),

      .hwrdata (err_rpt_reg.err_reqid.rrid)
    );

    regfield #(
      .DW      (16),
      .SWACCESS("RO"),
      .RESVAL  ('0)
    ) u_err_reqid_eid
    (
      .clk     (clk),
      .rst_n   (rst_n),

      .swen    (1'b0),
      .swdata  ('0),

      .hwen    (eic_rfm.err_reqid.eid.hwen),
      .hwdata  (eic_rfm.err_reqid.eid.hwdata),

      .hwrdata (err_rpt_reg.err_reqid.eid)
    );
  end
  else begin : gen_error_capture_regs_hardwired_zeros

    // Drive all error registers zero when ERROR_CAPTURE_EN is 0
    assign err_rpt_reg = '{
      err_cfg      : '0,
      err_info     : '0,
      err_reqaddr  : '0,
      err_reqaddrh : '0,
      err_reqid    : '0,
      err_mfr      : '0,
      err_msiaddr  : '0,
      err_msiaddrh : '0
    };
  end

endmodule
