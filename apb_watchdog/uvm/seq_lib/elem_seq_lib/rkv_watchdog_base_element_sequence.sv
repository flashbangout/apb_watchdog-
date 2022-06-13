`ifndef RKV_WATCHDOG_BASE_ELEMENT_SEQUENCE_SV
`define RKV_WATCHDOG_BASE_ELEMENT_SEQUENCE_SV

class rkv_watchdog_base_element_sequence extends uvm_sequence;
  `uvm_object_utils(rkv_watchdog_base_element_sequence)
  `uvm_declare_p_sequencer(rkv_watchdog_virtual_sequencer)
  rkv_watchdog_config cfg;
  rkv_watchdog_rgm rgm;  
  int rd_val,wt_val;
  uvm_status_e status = UVM_IS_OK;
  virtual rkv_watchdog_if vif;
  function new (string name = "rkv_watchdog_base_element_sequence");
    super.new(name);
    //cfg = rkv_watchdog_config::type_id::create("cfg");
  endfunction

  virtual task body();
    // get cfg from p_sequencer
    cfg = p_sequencer.cfg;
    // get rgm from p_sequencer
    rgm = cfg.rgm;
    vif = cfg.vif;
    `uvm_info("body", "Entered...", UVM_LOW)
    // TODO in sub-class
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask


virtual function bit diff_value(int val1, int val2, string id = "value_compare");
      cfg.seq_check_count++;
      if(val1 != val2) begin
        cfg.seq_error_count++;
        `uvm_error("[CMPERR]", $sformatf("ERROR! %s val1 %8x != val2 %8x", id, val1, val2)) 
        return 0;
      end
      else begin
        `uvm_info("[CMPSUC]", $sformatf("SUCCESS! %s val1 %8x == val2 %8x", id, val1, val2), UVM_LOW)
        return 1;
      end
    endfunction
endclass

`endif  
