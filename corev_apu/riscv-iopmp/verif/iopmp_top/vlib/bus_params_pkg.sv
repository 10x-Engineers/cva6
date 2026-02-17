

package bus_params_pkg;

  // Bus address width
  localparam int BUS_AW = 64;

  // Bus data width (must be a multiple of 8)
  localparam int BUS_DW = 64;

  // Bus data mask width (number of byte lanes)
  localparam int BUS_DBW = (BUS_DW >> 3);

  // Bus transfer size width (number of bits needed to select the number of bytes)
  localparam int BUS_SZW = $clog2($clog2(BUS_DBW) + 1);

  // Data Size
  localparam int BUS_DS = 3;

  // ID Width
  localparam int BUS_IDW = 5;

  localparam int BUS_U_R      = 6;
  localparam int BUS_U_W      = 6;
  localparam int BUS_U_SLAVE  = 11;

  `define AHB_ADDR_WIDTH 32
  `define AHB_DATA_WIDTH 64

  `define AXI_ADDR_WIDTH 64
  // width of axuser signal
  `define R_USER_WIDTH 6
  `define W_USER_WIDTH 6
  // width of id signal
  `define AXI_ID_WIDTH 5

  `define AXI_DATA_WIDTH 64

  `define WIDTH 8
  `define RD_ADDR_LOCK 0
  `define RD_ADDR_PROT 1
  `define RD_ADDR_CACHE 15
  `define WR_ADDR_LOCK 0
  `define WR_ADDR_PROT 1
  `define WR_ADDR_CACHE 15

  `define ENTRY_OFFSET 65536

endpackage
