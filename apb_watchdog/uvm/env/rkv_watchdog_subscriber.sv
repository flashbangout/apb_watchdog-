
`ifndef RKV_WATCHDOG_SUBSCRIBER_SV
`define RKV_WATCHDOG_SUBSCRIBER_SV

`uvm_analysis_imp_decl(_apb)

class rkv_watchdog_subscriber extends uvm_component;

  rkv_watchdog_config cfg;
  rkv_watchdog_rgm rgm;
  virtual rkv_watchdog_if vif;
  local uvm_event_pool _ep;
  uvm_event wdg_inten_e;          //interrupt enable event
  uvm_event wdg_resen_e;          //restet enable event
  uvm_event wdg_load_e;           //load access event
  uvm_event wdg_reg_fd_e;         //register access event(frontdoor)
  uvm_event wdg_reg_bd_e;         //
  uvm_event wdg_assert_inrt_e;    //interrupt asserted event 
  uvm_event wdg_int_clr_e;        //interrupt clear event
  uvm_event wdg_intdis_e;         //interrupt disable event
  uvm_event wdg_assert_res_e;     //reset asserted event
  bit enable; 

  uvm_analysis_imp_apb #(apb_transfer, rkv_watchdog_subscriber) apb_trans_observed_imp;

  `uvm_component_utils(rkv_watchdog_subscriber)

  function new (string name = "rkv_watchdog_subscriber", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_trans_observed_imp = new("apb_trans_observed_imp",this);
    if(!uvm_config_db#(rkv_watchdog_config)::get(this, "", "cfg",cfg)) begin
      `uvm_fatal("GTCFG","cannot get cfg from configdb")
    end
    if(!uvm_config_db#(rkv_watchdog_rgm)::get(this, "", "rgm",rgm)) begin
      `uvm_fatal("GTCFG","cannot get rgm from confgdb")
    end
    _ep = new("_ep");
    wdg_reg_fd_e = _ep.get("wdg_reg_fd_e");
    wdg_reg_bd_e = _ep.get("wdg_reg_bd_e");
    wdg_load_e = _ep.get("wdg_load_e");
    wdg_inten_e = _ep.get("wdg_inten_e");
    wdg_resen_e = _ep.get("wdg_resen_e");
    wdg_assert_inrt_e = _ep.get("wdg_assert_inrt_e");
    wdg_int_clr_e = _ep.get("wdg_int_clr_e");
    wdg_intdis_e = _ep.get("wdg_intdis_e");
    wdg_assert_res_e = _ep.get("wdg_assert_res_e");
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = cfg.vif;
    
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    do_events_check();
  endtask
  virtual function write_apb(apb_transfer t);
    uvm_reg r;
    r = rgm.map.get_reg_by_offset(t.addr);
    wdg_reg_fd_e.trigger(r);
  endfunction

  virtual task do_events_check();
   uvm_object tmp;
   uvm_reg r;
   fork
    begin
      forever begin
        fork 
          wdg_reg_fd_e.wait_trigger_data(tmp);
          wdg_reg_fd_e.wait_trigger_data(tmp);
        join_any
        disable fork;
        void'($cast(r, tmp));
        #1ps; // get the updated value from predictor
        if(r.get_name() == "WDOGCONTROL") begin
          if(rgm.WDOGCONTROL.INTEN.get() == 'b1) wdg_inten_e.trigger();
          if(rgm.WDOGCONTROL.RESEN.get() == 'b0) wdg_resen_e.trigger();
          if(rgm.WDOGCONTROL.INTEN.get() == 'b0) wdg_intdis_e.trigger();
        end
        else if(r.get_name() == "WDOGLOAD") begin
          if(rgm.WDOGLOAD.LOADVAL.get() != 'b0 ) wdg_load_e.trigger();
        end
        else if(r.get_name() == "WDOGINTCLR") begin
          if(rgm.WDOGINTCLR.INTCLR.get() == 'b1 ) wdg_int_clr_e.trigger();
        end
      end
    end
   join_none

  endtask

endclass



`endif // RKV_WATCHDOG_subscriber_SV
