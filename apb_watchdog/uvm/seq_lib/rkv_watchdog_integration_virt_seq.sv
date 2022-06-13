`ifndef RKV_WATCHDOG_INTEGRATION_VIRT_SEQ_SV
`define RKV_WATCHDOG_INTEGRATION_VIRT_SEQ_SV

class rkv_watchdog_integration_virt_seq extends rkv_watchdog_base_virtual_sequence;
  `uvm_object_utils(rkv_watchdog_integration_virt_seq)
  function new (string name = "rkv_watchdog_integration_virt_seq");
    super.new(name);
  endfunction

  task body();
    super.body();
    `uvm_info("body", "Entered...", UVM_LOW)
    `uvm_info("SEQSTART", "virtual sequence body started!!", UVM_LOW)
  
    void'(this.diff_value( vif.wdogint, 'b0));
    void'(this.diff_value( vif.wdogres, 'b0));

    wt_val = 'h1;
    rgm.WDOGITCR.write(status, wt_val);
    rgm.WDOGITCR.read(status, rd_val);
    void'(this.diff_value( rd_val, wt_val));
    
    wt_val = 'b11;
    rgm.WDOGITOP.write(status, wt_val);
    void'(this.diff_value( vif.wdogint, 'b1));
    void'(this.diff_value( vif.wdogres, 'b1));

    wt_val = 'b01;
    rgm.WDOGITOP.WDOGINT.set('b1);
    rgm.WDOGITOP.WDOGRES.set('b0);
    rgm.WDOGITOP.update(status);
    void'(this.diff_value( vif.wdogint, 'b1));
    void'(this.diff_value( vif.wdogres, 'b0));
    
    wt_val = 'b10;
    rgm.WDOGITOP.WDOGINT.set('b0);
    rgm.WDOGITOP.WDOGRES.set('b1);
    rgm.WDOGITOP.update(status);
    void'(this.diff_value( vif.wdogint, 'b0));
    void'(this.diff_value( vif.wdogres, 'b1));
    
    wt_val = 'h0;
    rgm.WDOGITCR.write(status, wt_val);
    rgm.WDOGITCR.read(status, rd_val);
    void'(this.diff_value( rd_val, wt_val));
    
    wt_val = 'b11;
    rgm.WDOGITOP.WDOGINT.set('b1);
    rgm.WDOGITOP.WDOGRES.set('b1);
    rgm.WDOGITOP.update(status);
    void'(this.diff_value( vif.wdogint, 'b0));
    void'(this.diff_value( vif.wdogres, 'b0));
    
    #1us;
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask
endclass

`endif 
