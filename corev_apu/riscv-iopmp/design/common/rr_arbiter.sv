module rr_arbiter #(
  parameter int unsigned NUMIN   = 64,   // Number of inputs to be arbitrated.
  parameter int unsigned DATAWIDTH = 32, // Data width of the payload in bits. Not needed if `DATATYPE` is overwritten.
  parameter type         DATATYPE = logic [DATAWIDTH-1:0], // Data type of the payload, can be overwritten with custom type. Only use of `DATAWIDTH`.
  parameter bit          EXT_PRI = 0,
  parameter bit          PRI_VEC = 0,

  // Dependent parameter, do *not* overwrite.
  // Width of the arbitration priority signal and the arbitrated index.
  parameter int unsigned IDXWIDTH = (NUMIN > 32'd1) ? $clog2(NUMIN) : 32'd1,

  // Dependent parameter, do *not* overwrite.
  // Type for defining the arbitration priority and arbitrated index signal.
  parameter type idx_t = logic [IDXWIDTH-1:0]
)(
  input  logic                 clk,       // Clock, positive edge triggered
  input  logic                 rst_n,     // Asynchronous reset, active low

  input  logic [NUMIN-1:0]     valid_req, // Input data valid signal
  input  DATATYPE [NUMIN-1:0]  reqs,      // Input requests
  input  logic                 out_req_gnt,   // Tell the arbiter that new data is requested
  input  logic [NUMIN-1:0]     pri,           // Unused if EXT_PRI==0

  output logic [NUMIN-1:0]     in_req_gnt, // Grant input request
  output logic                 req_gnt_valid, // Indicate that output data (Granted request) is valid
  output DATATYPE              req_gnt      // Next arbitrated data - Request Granted
);

  logic [NUMIN-1:0] gnt_req;

  assign req_gnt_valid = |valid_req;
  assign in_req_gnt = gnt_req & {NUMIN{out_req_gnt}};
  assign req_gnt = (gnt_req[0] ? reqs[0] : '0) | (gnt_req[1] ? reqs[1] : '0);

  arb_rr #(
    .REQS(NUMIN),
    .EXT_PRI(EXT_PRI),
    .PRI_VEC(PRI_VEC)
  ) arbiter_rr (
    .clk   (clk),
    .rst_n (rst_n),
    .req   (valid_req),
    .pri   (pri),
    .gnt   (gnt_req)
  );

endmodule
