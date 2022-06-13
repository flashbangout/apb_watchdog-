`ifndef RKV_WATCHDOG_INRT_WAIT_CLEAR_SV
`define RKV_WATCHDOG_INRT_WAIT_CLEAR_SV
  
class rkv_watchdog_inrt_wait_clear extends rkv_watchdog_base_element_sequence;
  `uvm_object_utils(rkv_watchdog_inrt_wait_clear)
  rand int delay,interval;  //delay is the time for clear after inten asserted
                            //interval is the refresh frequency

  constraint cstr{
    soft delay inside{[10:100]};
    soft interval inside{[1:10]};
  };
  function new (string name = "rkv_watchdog_inrt_wait_clear");
    super.new(name);
  endfunction

  virtual task body();
    super.body();
    forever begin
      rgm.WDOGMIS.mirror(status);
      if(rgm.WDOGMIS.INT.get()) begin  //check if the interrut happened
         break; 
      end
      repeat(interval) @(posedge vif.apb_clk);
    end
    repeat(delay) @(posedge vif.wdg_clk);
    // rgm.WDOGINTCLR.INTCLR.set('b1);
    // rgm.WDOGINTCLR.update(status);
    rgm.WDOGINTCLR.write(status, 'b1);  // clear the inten signal
  endtask



endclass


`endif
