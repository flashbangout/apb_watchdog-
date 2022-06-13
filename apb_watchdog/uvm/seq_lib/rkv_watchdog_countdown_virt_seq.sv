`ifndef RKV_WATCHDOG_COUNTDOWN_VIRT_SEQ_SV
`define RKV_WATCHDOG_COUNTDOWN_VIRT_SEQ_SV
  
class rkv_watchdog_countdown_virt_seq extends rkv_watchdog_base_virtual_sequence;
  `uvm_object_utils(rkv_watchdog_countdown_virt_seq)

  function new (string name = "rkv_watchdog_countdown_virt_seq");
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
     repeat(3) begin
       
       `uvm_do_with( int_wait_clr_seq, { delay == 10; interval inside {[10:20]}; })
       wait_int_rise();

     end
    #2us;
   `uvm_do_with( int_wait_clr_seq, { delay == 10; interval inside {[10:20]}; })
    #1us;
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask



endclass


`endif
