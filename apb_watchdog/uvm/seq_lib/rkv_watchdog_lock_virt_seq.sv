`ifndef RKV_WATCHDOG_LOCK_VIRT_SEQ_SV
`define RKV_WATCHDOG_LOCK_VIRT_SEQ_SV
  
class rkv_watchdog_lock_virt_seq extends rkv_watchdog_base_virtual_sequence;
  `uvm_object_utils(rkv_watchdog_lock_virt_seq)

  function new (string name = "rkv_watchdog_lock_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    int rd_val;
    uvm_status_e status = UVM_IS_OK;
    super.body(); 

    `uvm_info("body", "Entered...", UVM_LOW)
    rgm.WDOGLOCK.read( status, rd_val);
    void'(diff_value( rd_val[0] , 'h0 ));  // check current status
    `uvm_do_with( loadcount_seq, { load_val == 'h20; } )
    check_unlock_control_status();
    rgm.WDOGLOCK.write( status, 'b0 );
    rgm.WDOGLOCK.read( status, rd_val );
    void'(diff_value( rd_val[0] , 'b1 ));// lock the watchdog
    #2us;
    check_lock_control_status();
    //`uvm_do_with( loadcount_seq, { load_val == 'hff; })
    //`uvm_do( disable_inrt_seq )
    //`uvm_do( enable_rst_seq )

    rgm.WDOGLOCK.write( status, 'h1ACCE551 );
    rgm.WDOGLOCK.read( status, rd_val );
    void'(diff_value( rd_val[0], 'b0 ));  // unlock the watchdog
    check_unlock_control_status();
    //`uvm_do( disable_inrt_seq )
    //`uvm_do( enable_rst_seq )
    //`uvm_do( enable_inrt_seq )
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask
 
  virtual task check_unlock_control_status();
    bit rd_val, wt_val;
    rgm.WDOGCONTROL.mirror(status);   
    wt_val = ~rgm.WDOGCONTROL.INTEN.get();
    rgm.WDOGCONTROL.INTEN.set( wt_val );  //write a different value
    rgm.WDOGCONTROL.update(status);
    rgm.WDOGCONTROL.read( status, rd_val );
    void'(diff_value( rd_val, wt_val ));  // check if the write is successful
  endtask
  
  virtual task check_lock_control_status();
    bit rd_val, wt_val;
    rgm.WDOGCONTROL.mirror(status);
    wt_val = ~rgm.WDOGCONTROL.INTEN.get();  
    rgm.WDOGCONTROL.INTEN.set( wt_val );  //write a different value
    rgm.WDOGCONTROL.update(status);
    rgm.WDOGCONTROL.read( status, rd_val );
    rd_val = !rd_val;
    void'(diff_value( rd_val, wt_val ));  //check the write is failed
  endtask 
  

  // mis : interrupt status register
  // ris : raw interrupt register
  virtual task check_mis_ris(input bit mis, input bit ris);
    rgm.WDOGRIS.mirror(status);

    void'(this.diff_value( ris , rgm.WDOGRIS.RAWINT.get() ));
    rgm.WDOGMIS.mirror(status);
    void'(this.diff_value( mis , rgm.WDOGMIS.INT.get() ));
  endtask

endclass


`endif
