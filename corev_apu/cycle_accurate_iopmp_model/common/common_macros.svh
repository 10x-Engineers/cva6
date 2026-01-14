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
    logic config_prot_illegal1     = SRCMD_FMT_1 && (!req_offset_addr[3]);     \
    logic config_prot_illegal2     = (MDCFG_FMT_1 || MDCFG_FMT_2) &&       \
                                    (req_offset_addr[3] && (!req_offset_addr[2])); \
    logic config_prot_legal        = is_section_1 && config_prot_maybe_legal &&    \
                                    (!(config_prot_illegal1 || config_prot_illegal2)); \
                                                                                  \
    logic err_rpt1_maybe_legal     = is_base_register && (req_offset_addr[6:4] == 3'b110) \
                                    && ERROR_CAPTURE_EN;                      \
    logic err_rpt1_illegal1        = (!ADDRH_EN) && (&req_offset_addr[3:2]);   \
    logic err_rpt1_legal           = err_rpt1_maybe_legal && (!err_rpt1_illegal1); \
                                                                                  \
    logic err_rpt2_maybe_legal     = is_base_register && (req_offset_addr[6:4] == 3'b111) \
                                    && ERROR_CAPTURE_EN;                      \
    logic err_rpt2_illegal1        = (!MFR_EN) && ((!req_offset_addr[3]) && req_offset_addr[2]); \
    logic err_rpt2_illegal2        = (!MSI_EN) && (req_offset_addr[3]);        \
    logic err_rpt2_illegal3        = (MSI_EN) && (!ADDRH_EN) && (&req_offset_addr[3:2]); \
    logic err_rpt2_legal           = err_rpt2_maybe_legal &&                       \
                                    (!(err_rpt2_illegal1 || err_rpt2_illegal2 || err_rpt2_illegal3)); \
                                                                                  \
    logic err_rpt_legal            = is_section_1 && (err_rpt1_legal || err_rpt2_legal); \
                                                                                  \
    logic base_reg_legal           = info_legal || prog_prot_legal ||              \
                                    config_prot_legal || err_rpt_legal;           \
                                                                                  \
    logic mdcfg_legal              = MDCFG_FMT_0 && is_section_1 &&            \
                                    (req_offset_addr >= MDCFG_START_OFFSET) &&    \
                                    (req_offset_addr <= MAX_MDCFG_OFFSET);        \
                                                                                  \
    logic is_srcmd_register        = (SRCMD_FMT_0 &&                           \
                                    (req_offset_addr >= SRCMD_START_OFFSET) &&    \
                                    (req_offset_addr <= MAX_SRCMD_FMT_0_OFFSET)) || \
                                    (SRCMD_FMT_2 &&                           \
                                    (req_offset_addr >= SRCMD_START_OFFSET) &&    \
                                    (req_offset_addr <= MAX_SRCMD_FMT_2_OFFSET)); \
                                                                                  \
    logic srcmd_illegal1           = (&req_offset_addr[4:3]);                      \
    logic srcmd_illegal2           = SRCMD_FMT_0 && (!SPS_EN) && (|req_offset_addr[4:3]); \
    logic srcmd_illegal3           = SRCMD_FMT_2 && (|req_offset_addr[4:3]);   \
    logic srcmd_legal              = is_section_1 && is_srcmd_register &&          \
                                    (!(srcmd_illegal1 || srcmd_illegal2 || srcmd_illegal3)); \
                                                                                  \
    logic is_entry_array           = (req_offset_addr <= MAX_ENTRY_ARRAY_OFFSET);  \
    logic entry_array_illegal1     = (&req_offset_addr[3:2]);                      \
    logic entry_array_illegal2     = (!ADDRH_EN) && ((!req_offset_addr[3]) && req_offset_addr[2]); \
    logic entry_array_legal        = is_section_2 && is_entry_array &&             \
                                    (!(entry_array_illegal1 || entry_array_illegal2)); \
                                                                                  \
    logic is_addr_legal_section_1  = base_reg_legal || mdcfg_legal || srcmd_legal; \
                                                                                  \
    is_addr_legal = (is_addr_legal_section_1 || entry_array_legal) &&              \
                    addr_aligned && valid_req;                                     \
  end