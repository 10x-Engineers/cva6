
class axi_s_write_response_seq extends axi_s_seq;
    `uvm_object_utils(axi_s_write_response_seq)

    axi_s_seq_item req;
    axi_s_seq_item rsp;
    bit resp_a;

    function new(string name = "axi_s_write_response_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Starting write_response_seq", UVM_MEDIUM)
        rsp = axi_s_seq_item::type_id::create("rsp");
        start_item(rsp);
        $display("AXI_S_seq: valid=%h, data=%h",req.BID, req.BUSER);
            if (!rsp.randomize() with{
                 BID == req.BID;
                 BUSER == req.BUSER; 
                 resp_a -> BRESP == SLVERR;
            })begin
                `uvm_error(get_name(), "REQ Randomization Failed @axi_sequence")
            end
        finish_item(rsp);
        `uvm_info(get_type_name(), "write_response_seq completed", UVM_MEDIUM)
    endtask

endclass
