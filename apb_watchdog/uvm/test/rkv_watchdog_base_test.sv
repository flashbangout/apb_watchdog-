`ifndef RKV_WATCHDOG_BASE_TEST_SV
`define RKV_WATCHDOG_BASE_TEST_SV

virtual class rkv_watchdog_base_test extends uvm_test;

  rkv_watchdog_env env;
  rkv_watchdog_config cfg;
  rkv_watchdog_rgm rgm;

  function new (string name = "rkv_watchdog_base_test", uvm_component parent);
    super.new(name, parent);
    rgm = rkv_watchdog_rgm::type_id::create("rgm", this);
    rgm.build();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = rkv_watchdog_config::type_id::create("cfg");
    uvm_config_db#(rkv_watchdog_config)::set(this,"env","cfg",cfg);
    uvm_config_db#(rkv_watchdog_rgm)::set(this,"env","rgm",rgm);
    env = rkv_watchdog_env::type_id::create("env", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    cfg.rgm = rgm;
  endfunction

 task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    do_init_clks();
    do_init_regs();
    phase.drop_objection(this);
  endtask

  virtual function bit diff_value(int val1, int val2, string id = "value_compare");
      if(val1 != val2) begin
        `uvm_error("[CMPERR]", $sformatf("ERROR! %s val1 %8x != val2 %8x", id, val1, val2)) 
        return 0;
      end
      else begin
        `uvm_info("[CMPSUC]", $sformatf("SUCCESS! %s val1 %8x == val2 %8x", id, val1, val2), UVM_LOW)
        return 1;
      end
    endfunction
  virtual task do_init_clks();
    // wait reset posedge
    #1ns;
    @(negedge env.cfg.vif.apb_rstn);
    @(posedge env.cfg.vif.apb_rstn);
   // wait(env.apb_mst.vif.rstn == 1 );
   // wait(env.apb_mst.vif.rstn == 0 );
   // wait(env.apb_mst.vif.rstn == 1 );
    // TODO in sub-class
  endtask

  virtual task do_init_regs();
    // TODO in sub-class
  endtask


endclass

`endif
