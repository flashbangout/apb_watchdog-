`ifndef RKV_WATCHDOG_RELOAD_VIRT_SEQ_SV
`define RKV_WATCHDOG_RELOAD_VIRT_SEQ_SV
  
class rkv_watchdog_reload_virt_seq extends rkv_watchdog_base_virtual_sequence;
  `uvm_object_utils(rkv_watchdog_reload_virt_seq)

  function new (string name = "rkv_watchdog_reload_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    int rd_val;
    uvm_status_e status = UVM_IS_OK;
    super.body(); 

    `uvm_info("body", "Entered...", UVM_LOW)
    `uvm_do_with( loadcount_seq, { load_val == 'h20; })
    `uvm_do( enable_inrt_seq )
    `uvm_do( enable_rst_seq )
    #1us;
    `uvm_do_with( loadcount_seq, { load_val == 'h1; })
    wait_int_rise();
    @(posedge vif.wdg_clk);  //reload after int assert.
    `uvm_do_with( loadcount_seq, { load_val == 'h30; })
    
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask



endclass


`endif
