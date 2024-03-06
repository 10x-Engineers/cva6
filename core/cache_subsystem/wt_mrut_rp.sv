module wt_mrut_rp
  import ariane_pkg::*;
  import wt_cache_pkg::*;
#(
    parameter config_pkg::cva6_cfg_t CVA6Cfg = config_pkg::cva6_cfg_empty,
    parameter logic [CACHE_ID_WIDTH-1:0] AmoTxId = 1,  // TX id to be used for AMOs
    parameter int unsigned NumPorts = 4  // number of miss ports
    // ID to be used for read and AMO transactions.
    // note that the write buffer uses all IDs up to DCACHE_MAX_TX-1 for write transactions
) (
    input logic                                                 clk_i,                      // Clock
    input logic                                                 rst_ni,                     // Asynchronous reset active low
    // Cache management
    input logic                                                 enable_i,                   // from CSR
    input logic                                                 flush_i,                    // high until acknowledged
    // cache miss
    input logic                                                 miss_i,                     // way missed on a ld/st (read/write)
    input logic                                                 cache_en,                   // cache enable
    //cache hit
    input logic                 [DCACHE_SET_ASSOC-1:0]          rd_hit_oh,                  //hit way of the cache-- one hot
    input logic [NumPorts-1:0]  [DCACHE_CL_IDX_WIDTH-1:0]       rd_idx,                     //read indext 
    //cache write 
    input logic                 [DCACHE_CL_IDX_WIDTH-1:0]       wr_cl_idx,                  //write index(set) of cache 
    input logic                                                 wr_cl_vld,                  //write cache valid bit
    input logic                 [DCACHE_SET_ASSOC-1:0]          wr_cl_we,                   //write way of cache- one hot 
    //cache way replacement 
    input logic                 [$clog2(DCACHE_SET_ASSOC)-1:0]  rnd_way_i,                  //rnd_way may be get in to check current value
    input logic                                                 update_lfsr_i,all_ways_valid_i,      //lfsr enable signal

    output logic                [$clog2(DCACHE_SET_ASSOC)-1:0]  mrut_r_way_o                // output of mrut: it will be connected with rnd_way of missunit

);


logic           [255:0]         [DCACHE_SET_ASSOC-1:0]           MRU_q, MRU_d;              // MRU bit of cache
logic           [255:0]         [DCACHE_SET_ASSOC-1:0]           MRUT_q, MRUT_d;            // MRUT bit of cache

logic                           [$clog2(DCACHE_SET_ASSOC)-1:0]   s_mrut ;                   //[2:0]                            
logic                           [$clog2(DCACHE_SET_ASSOC)-1:0]   s_mru_d, s_mru_q;          //2[2:0]

logic                           [$clog2(DCACHE_SET_ASSOC)-1:0]   repl_way;                  // way going to be replaced
logic                           [$clog2(DCACHE_SET_ASSOC)-1:0]   random_bit;                // random number

logic [7:0]     temp_mrut       [DCACHE_CL_IDX_WIDTH-1:0];                                  //temporary variable of MRUT
logic [7:0]     temp_mru_d      [DCACHE_CL_IDX_WIDTH-1:0];                                  //temporary variable of MRU
logic [7:0]     temp_mru_q      [DCACHE_CL_IDX_WIDTH-1:0];                                  //temporary variable of MRU

/////////////////////////////////////////////////////////////////////////////////////////////

//function convert one hot to 3 bit 
function automatic logic [2:0] OneHotTo3Bit(input logic [7:0] one_hot_input);
    case (one_hot_input)
      8'b00000001: OneHotTo3Bit = 3'b000;
      8'b00000010: OneHotTo3Bit = 3'b001;
      8'b00000100: OneHotTo3Bit = 3'b010;
      8'b00001000: OneHotTo3Bit = 3'b011;
      8'b00010000: OneHotTo3Bit = 3'b100;
      8'b00100000: OneHotTo3Bit = 3'b101;
      8'b01000000: OneHotTo3Bit = 3'b110;
      8'b10000000: OneHotTo3Bit = 3'b111;
      default: OneHotTo3Bit = 3'b000; // Handle invalid or multiple bits set cases
    endcase
endfunction

assign mrut_r_way_o = repl_way;

always_ff@(posedge clk_i or posedge rst_ni) begin
    if(!rst_ni) begin

        MRU_q               <=      '0;
        MRUT_q              <=      '0;
        s_mru_q             <=      '0;
        temp_mru_q[0]       <=      '0;
        temp_mru_q[1]       <=      '0;
        temp_mru_q[2]       <=      '0;
        temp_mru_q[3]       <=      '0;
        temp_mru_q[4]       <=      '0;
        temp_mru_q[5]       <=      '0;
        temp_mru_q[6]       <=      '0;
        temp_mru_q[7]       <=      '0;

    end else begin

        MRU_q               <=      MRU_d;
        MRUT_q              <=      MRUT_d;
        s_mru_q             <=      s_mru_d;
        temp_mru_q[0]       <=      temp_mru_d[0];
        temp_mru_q[1]       <=      temp_mru_d[1];
        temp_mru_q[2]       <=      temp_mru_d[2];
        temp_mru_q[3]       <=      temp_mru_d[3];
        temp_mru_q[4]       <=      temp_mru_d[4];
        temp_mru_q[5]       <=      temp_mru_d[5];
        temp_mru_q[6]       <=      temp_mru_d[6];
        temp_mru_q[7]       <=      temp_mru_d[7];
    end
end

always_comb begin
    MRUT_d              =   MRUT_q;
    MRU_d               =   '0;
    s_mru_d             =   '0;
    s_mrut              =   '0;

    temp_mru_d[0]         =   temp_mru_q[0];
    temp_mru_d[1]         =   temp_mru_q[1];
    temp_mru_d[2]         =   temp_mru_q[2];
    temp_mru_d[3]         =   temp_mru_q[3];
    temp_mru_d[4]         =   temp_mru_q[4];
    temp_mru_d[5]         =   temp_mru_q[5];
    temp_mru_d[6]         =   temp_mru_q[6];
    temp_mru_d[7]         =   temp_mru_q[7];
    temp_mrut[0]        =   '0;
    temp_mrut[1]        =   '0;
    temp_mrut[2]        =   '0;
    temp_mrut[3]        =   '0;
    temp_mrut[4]        =   '0;
    temp_mrut[5]        =   '0;
    temp_mrut[6]        =   '0;
    temp_mrut[7]        =   '0;
    random_bit          =   '0;
    repl_way            =   '0;

  if(enable_i && cache_en) begin
    
    if(wr_cl_vld) begin                                                          // write valid 

        MRUT_d[wr_cl_idx][OneHotTo3Bit(wr_cl_we)]  = 1'b0;                       //load the MRUT of current write index and way to 0
        MRU_d [wr_cl_idx][OneHotTo3Bit(wr_cl_we)]  = 1'b1;                       //load the MRU of current write index and way to 1

        for (integer i = 0; i < DCACHE_SET_ASSOC; i++) begin  

            if (MRU_d[rd_idx[1]][i] == 0) begin                                 //searching for MRU having 0 bits
                temp_mru_d[s_mru_d] = i;                                        //storing the temp_mru
                s_mru_d++;                                                      //mru counter
            end
        end
    
    end else if(rd_hit_oh >> 0 && !wr_cl_vld) begin                             //hit valid

        MRUT_d[rd_idx[1]][OneHotTo3Bit(rd_hit_oh)]  = 1'b1;                     //load the MRUT of current write index and way  to 1
        MRU_d [rd_idx[1]][OneHotTo3Bit(rd_hit_oh)]  = 1'b1;                     //load the MRU of current write index and way to 1

        for (integer i = 0; i < DCACHE_SET_ASSOC; i++) begin  

            if (MRU_d[rd_idx[1]][i] == 0) begin                                 //searching for MRU having 0 bits
                temp_mru_d[s_mru_d] = i;                                        //storing the temp_mru
                s_mru_d++;                                                      //mru counter
            end
        end
 
    end else if(miss_i && all_ways_valid_i)begin                                //miss valid

        for (integer i = 0; i < DCACHE_SET_ASSOC; i++) begin  

            if(MRUT_q[rd_idx[1]][i] == 0 && MRU_q[rd_idx[1]][i] == 0 ) begin    //searching for MRUT having 0 bits
                temp_mrut[s_mrut] = i;                                          // storing into temp_mrut
                s_mrut++;                                                       //mrut counter
            end

            if (temp_mru_q[i] > 0) begin                                        //searching for MRU having 0 bits
                s_mru_d++;                                                      //mru counter
            end

        end
        if(s_mrut > 0) begin                                                    // check if there is any MRUT bit = 0
                                                                                //randomly select the index of temp_mrut and get its corresponding value 
            random_bit = rnd_way_i % s_mrut;                                    //mod of random bit inorder to get into range.
            repl_way = temp_mrut[random_bit];                                   //read the bit from temp_mrut

        end else begin                                                          //check if there is MRU bit available     

            random_bit = rnd_way_i % s_mru_d;                                    //mod of random bit inorder to get into range.
            repl_way = temp_mru_q[random_bit];                                   //read the bit from temp_mrut
            
        end 
     end
    end
end

endmodule