`ifndef RKV_WATCHDOG_CONFIG_SVH
`define RKV_WATCHDOG_CONFIG_SVH

`include "rkv_watchdog_config.sv"
class rkv_watchdog_config extends uvm_object;
  int seq_check_count;
  int seq_error_count;
  int scb_check_count;
  int scb_error_count;

  bit enable_cov = 1;
  bit enable_scb = 1;

  `uvm_object_utils(rkv_watchdog_config)
  apb_config apb_cfg;
  // USER to specify the config items
  virtual rkv_watchdog_if vif; 
  rkv_watchdog_rgm rgm;

  function new (string name = "rkv_watchdog_config");
    super.new(name);
    apb_cfg = apb_config::type_id::create("apb_cfg");

  endfunction : new


endclass
`endif
