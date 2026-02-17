// ---------------------------------------------------------------------
// Default signal names and reset value (edit these once per project)
// ---------------------------------------------------------------------
`define DEFAULT_CLK    clk
`define DEFAULT_RSTN   rst_n
`define DEFAULT_RSTVAL '0

// ---------------------------------------------------------------------
// Base version (full arguments)
// ---------------------------------------------------------------------
`define FF_RST_ASYNC(Q, D, C, RSTn, RSTVAL) \
  always_ff @(posedge C or negedge RSTn) begin \
    if (!RSTn) Q <= RSTVAL; \
    else       Q <= D; \
  end

// ---------------------------------------------------------------------
// Simplified version using defaults
// ---------------------------------------------------------------------
`define IOPMP_FF(Q, D) \
  `FF_RST_ASYNC(Q, D, `DEFAULT_CLK, `DEFAULT_RSTN, `DEFAULT_RSTVAL)

