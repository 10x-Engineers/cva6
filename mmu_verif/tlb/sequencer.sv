class sequencer extends uvm_sequencer #(seq_item );

    `uvm_component_utils(sequencer)

     uvm_tlm_analysis_fifo #(seq_item) fifo_ap;

    function new(string name ,uvm_component parent);
        super.new(name,parent);
        fifo_ap = new("fifo_ap", this);

    endfunction 
    
endclass 
