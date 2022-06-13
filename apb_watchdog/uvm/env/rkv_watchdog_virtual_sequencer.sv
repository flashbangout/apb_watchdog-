`ifndef RKV_WATCHDOG_VIRTUAL_SEQUENCER_SV
`define RKV_WATCHDOG_VIRTUAL_SEQUENCER_SV

class rkv_watchdog_virtual_sequencer extends uvm_sequencer;

  // add sub-instances' sqr handles below for routing
  apb_master_sequencer apb_mst_sqr;
  rkv_watchdog_config cfg;
  rkv_watchdog_rgm rgm;

  `uvm_component_utils(rkv_watchdog_virtual_sequencer)


  function new (string name = "rkv_watchdog_virtual_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(rkv_watchdog_config)::get(this, "", "cfg",cfg)) begin
      `uvm_fatal("GTCFG","cannot get cfg from confgdb")
    end
    if(!uvm_config_db#(rkv_watchdog_rgm)::get(this, "", "rgm",rgm)) begin
      `uvm_fatal("GTCFG","cannot get rgm from confgdb")
    end
  endfunction

  

endclass


`endif
