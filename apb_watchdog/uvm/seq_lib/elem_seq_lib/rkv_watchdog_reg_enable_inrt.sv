`ifndef RKV_WATCHDOG_REG_ENABLE_INRT_SV
`define RKV_WATCHDOG_REG_ENABLE_INRT_SV
  
class rkv_watchdog_reg_enable_inrt extends rkv_watchdog_base_element_sequence;
  `uvm_object_utils(rkv_watchdog_reg_enable_inrt)

  function new (string name = "rkv_watchdog_reg_enable_inrt");
    super.new(name);
  endfunction

  virtual task body();
    int rd_val;
    
    super.body();
    rgm.WDOGCONTROL.mirror(status);
    @(posedge vif.apb_clk); 
    rgm.WDOGCONTROL.INTEN.set('b1);
    rgm.WDOGCONTROL.update(status);
  
  endtask



endclass


`endif
