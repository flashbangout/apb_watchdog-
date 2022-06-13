
`ifndef RKV_WATCHDOG_ENV_SV
`define RKV_WATCHDOG_ENV_SV

class rkv_watchdog_env extends uvm_env;

  apb_master_agent apb_mst;
  rkv_watchdog_virtual_sequencer virt_sqr;
  rkv_watchdog_config cfg;
  rkv_watchdog_rgm rgm;
  rkv_watchdog_adapter adp;
  uvm_reg_predictor #(apb_transfer) predictor;
  rkv_watchdog_scoreboard scb;
  rkv_watchdog_cov cov;
  
  `uvm_component_utils(rkv_watchdog_env)

  function new (string name = "rkv_watchdog_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_mst = apb_master_agent::type_id::create("apb_mst", this);
    scb = rkv_watchdog_scoreboard::type_id::create("scb", this);
    cov = rkv_watchdog_cov::type_id::create("cov", this);
    
    if(!uvm_config_db#(rkv_watchdog_config)::get(this, "", "cfg",cfg)) begin
      `uvm_fatal("GTCFG","cannot get cfg from configdb")
    end
    
    if(!uvm_config_db#(virtual rkv_watchdog_if)::get(this, "", "vif",cfg.vif)) begin
      `uvm_fatal("GTCFG","cannot get vif from confgdb")
    end
    virt_sqr = rkv_watchdog_virtual_sequencer::type_id::create("virt_sqr", this);
    uvm_config_db#(rkv_watchdog_config)::set(this,"virt_sqr","cfg",cfg);
    uvm_config_db#(rkv_watchdog_config)::set(this,"scb","cfg",cfg);
    uvm_config_db#(rkv_watchdog_config)::set(this,"cov","cfg",cfg);
    uvm_config_db#(apb_config)::set(this,"apb_mst","cfg",cfg.apb_cfg);

    if(!uvm_config_db#(rkv_watchdog_rgm)::get(this, "", "rgm",rgm)) begin
      rgm = rkv_watchdog_rgm::type_id::create("rgm", this);
      rgm.build();
    end
    uvm_config_db#(rkv_watchdog_rgm)::set(this,"*","rgm", rgm);
    adp = rkv_watchdog_adapter::type_id::create("adp", this);
    predictor = uvm_reg_predictor#(apb_transfer)::type_id::create("predictor", this);
    
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    virt_sqr.apb_mst_sqr = apb_mst.sequencer;
    rgm.map.set_sequencer(apb_mst.sequencer, adp);
    apb_mst.monitor.item_collected_port.connect(predictor.bus_in);
    apb_mst.monitor.item_collected_port.connect(scb.apb_trans_observed_imp);
    apb_mst.monitor.item_collected_port.connect(cov.apb_trans_observed_imp);
    predictor.map = rgm.map;
    predictor.adapter = adp;
  endfunction

  function void report_phase(uvm_phase phase);
    string reports;
    super.report_phase(phase);
    reports = {"\n"};
    reports = {reports, $sformatf("====================================== \n")};

    reports = {reports, $sformatf("compare test summary \n")};
    reports = {reports, $sformatf("seq check counts:%0d.\n", cfg.seq_check_count)};
    reports = {reports, $sformatf("seq check error counts:%0d. \n", cfg.seq_error_count)};
    reports = {reports, $sformatf("scoreboard check counts:%0d \n", cfg.scb_check_count)};
    reports = {reports, $sformatf("scoreboard error check counts:%0d. \n", cfg.scb_error_count)};
    reports = {reports, $sformatf("====================================== \n")};
    `uvm_info("test summary", reports, UVM_LOW)
  endfunction


endclass



`endif // RKV_WATCHDOG_ENV_SV
