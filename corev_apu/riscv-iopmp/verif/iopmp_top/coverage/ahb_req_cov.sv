  `define AHB_REQ tb_top.iopmp_dut.rfm.ahb_req_q

  // AHB_REQ.01. Assertion: For a valid AHB Request, HSIZE must be 3'b010 (4 bytes access)
  rfm_assert_hsize: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`AHB_REQ.hready && `AHB_REQ.hsel && (`AHB_REQ.htrans == 2'b10)) |-> (`AHB_REQ.hsize == 3'b010))
  ) else $fatal (1, "Assertion Failed: HSIZE must be 3'b010");

  // AHB_REQ.02. Assertion: For a valid AHB Request, HPROT must be 4'b0011 (Non-bufferable, Non-cacheable, privileged access, data access)
  rfm_assert_hprot: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`AHB_REQ.hready && `AHB_REQ.hsel && (`AHB_REQ.htrans == 2'b10)) |-> (`AHB_REQ.hprot == 4'b0011))
  ) else $fatal (1, "Assertion Failed: HPROT must be 4'b0011");

  // AHB_REQ.03. Assertion: For a valid AHB Request, HBURST must be 3'b000 (Single)
  rfm_assert_hburst: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`AHB_REQ.hready && `AHB_REQ.hsel && (`AHB_REQ.htrans == 2'b10)) |-> (`AHB_REQ.hburst == 3'b000))
  ) else $fatal (1, "Assertion Failed: HBURST must be 3'b000");

  // AHB_REQ.04. Assertion: For a valid AHB Request, HMASTLOCK must be 1'b0 (Not a locked transfer)
  rfm_assert_hmastlock: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`AHB_REQ.hready && `AHB_REQ.hsel && (`AHB_REQ.htrans == 2'b10)) |-> (`AHB_REQ.hmastlock == 1'b0))
  ) else $fatal (1, "Assertion Failed: HMASTLOCK must be 1'b0");

  // AHB_REQ.05. Assertion: When HREADY and HSEL are asserted, then HTRANS should be either 2'b10 (NONSEQ) or 2'b00 (IDLE)
  rfm_assert_htrans: assert property (
    @(posedge clk) disable iff (~tb_top.iopmp_dut.rst_n) ((`AHB_REQ.hready && `AHB_REQ.hsel) |-> ((`AHB_REQ.htrans == 2'b10) || (`AHB_REQ.htrans == 2'b00)))
  ) else $fatal (1, "Assertion Failed: HTRANS must be 2'b00 or 2'b10");