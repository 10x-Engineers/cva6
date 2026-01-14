package c_model_pkg;

  import config_cycle_acc_pkg::*;

  typedef struct packed {
    bit        is_amo;   // Indicates the AMO Access
    bit [31:0] perm;     // Type of permission requested  //0,1,2
    bit [31:0] size;     // Size of each access in the transaction
    bit [31:0] length;   // Length of the transaction
    bit [63:0] addr;     // Target address for the transaction
    bit [15:0] rrid;     // Requester ID
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

  typedef struct {
    logic             valid;
    iopmp_trans_req   data;
  } pipe_entry_t;

  typedef enum {REQ_NONE, REQ_READ, REQ_WRITE} req_t;

    // FSM States for response generation
  typedef enum bit {
    AHB_REQ    = 1'b0,         // 0 : Indicates that RFM is either waiting for valid request or processing the appropriate response of a valid request based in address decode
    RESP_ERROR = 1'b1          // 1 : Indicates that the incoming request address is illegal or misaligned. In that case, error is reported to AHB-LITE Interface
  } response_state_e;

  // Local parameters for base address of section 1 and 2
  // Base Address of each section must be 64K byte aligned
  localparam logic [15:0] BASE_ADDR_OF_SECT_1    = BASE_ADDR[31:16];
  localparam logic [15:0] BASE_ADDR_OF_SECT_2    = BASE_ADDR[31:16] + ENTRY_OFFSET[31:16];

  localparam              REG_SIZE               = 4;             // Register size in IOPMP is 4 byte
  localparam logic [15:0] MAX_BASE_REG_OFFSET    = 16'h007C;      // This parameter indicates the maximum value of offset address that lies in BASE region
  localparam logic [15:0] MDCFG_START_OFFSET     = 16'h0800;      // This parameter indicates the start offset address of MDCFG region
  localparam logic [15:0] SRCMD_START_OFFSET     = 16'h1000;      // This parameter indicates the start offset address of SRCMD region

endpackage