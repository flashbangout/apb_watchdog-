`ifndef RKV_WATCHDOG_APBACC_VIRT_SEQ_SV
`define RKV_WATCHDOG_APBACC_VIRT_SEQ_SV

class rkv_watchdog_apbacc_virt_seq extends rkv_watchdog_base_virtual_sequence;
  `uvm_object_utils(rkv_watchdog_apbacc_virt_seq)

  function new (string name = "rkv_watchdog_apbacc_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    int rd_val;
    super.body(); 

    `uvm_info("body", "Entered...", UVM_LOW)
    // TODO in sub-class
    
    `uvm_do_on_with(apb_rd_seq,p_sequencer.apb_mst_sqr,{addr=='hFE0;})
    rd_val = apb_rd_seq.data;
    void'(this.diff_value( rd_val , 'h24));
    `uvm_do_on_with(apb_rd_seq,p_sequencer.apb_mst_sqr,{addr=='hFE4;})
    rd_val = apb_rd_seq.data;
    void'(this.diff_value( rd_val , 'hb8));
    `uvm_do_on_with(apb_rd_seq,p_sequencer.apb_mst_sqr,{addr=='hFE8;})
    rd_val = apb_rd_seq.data;
    void'(this.diff_value( rd_val , 'h1b));
    `uvm_do_on_with(apb_rd_seq,p_sequencer.apb_mst_sqr,{addr=='hFEc;})
    rd_val = apb_rd_seq.data;
    void'(this.diff_value( rd_val , 'hb0));
    `uvm_do_on_with(apb_rd_seq,p_sequencer.apb_mst_sqr,{addr=='hFE0;})
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask



endclass

`endif  
