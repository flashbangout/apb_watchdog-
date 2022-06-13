
`ifndef RKV_WATCHDOG_COV_SV
`define RKV_WATCHDOG_COV_SV

class rkv_watchdog_cov extends rkv_watchdog_subscriber;
  
  bit [31:0] reg_control_val;
  bit [31:0] reg_load_val;
  event reg_control_acc_sv_e; 
  event reg_load_acc_sv_e;
  `uvm_component_utils(rkv_watchdog_cov)
  covergroup watchdog_control_cg with function sample(bit[31:0] val, string field);
    option.name = "watchdog control coverage";
    INTEN: coverpoint val iff(field == "INTEN"){
      bins enable            = {'b1};
      bins dis               = {'b0};
      bins interrupt_enable  = ('b0 => 'b1); 
      bins interrupt_disable = ('b1 => 'b0); 
      }
    RESEN: coverpoint val iff(field == "RESEN"){
      bins reset_enable = ('b0 => 'b1); 
      bins reset_disable = ('b1 => 'b0); 
      }
  endgroup

covergroup t1_watchdog_control_cg (ref bit[31:0] val) @(reg_control_acc_sv_e);
    option.name = "T1 watchdog control coverage";
    INTEN: coverpoint val[0] {
      bins enable            = {'b1};
      bins dis               = {'b0};
      bins interrupt_enable  = ('b0 => 'b1); 
      bins interrupt_disable = ('b1 => 'b0); 
      }
    RESEN: coverpoint val[1] {
      bins enable        = {'b1};
      bins dis           = {'b0}; 
      bins reset_enable  = ('b0 => 'b1); 
      bins reset_disable = ('b1 => 'b0); 
      }
  endgroup

covergroup t2_watchdog_load_cg (ref bit[31:0] val) @(reg_load_acc_sv_e);
    option.name = "T2 watchdog load coverage";
    LOAD: coverpoint val {
      bins min            = {'b1};
      bins max            = {'hffffffff};
      bins mid            = {[2:'hfffffffe]}; 
      bins intialload     = ('hffffffff => 'h????????); 
      bins reload         = ([1:'hffffffff] => [1:'hffffffff]);
      }
  endgroup

covergroup t3_watchdog_int_clr_cg with function sample(bit[31:0] val, string feild);
    option.name = "T3 watchdog interrupt clear coverage";
    INTCLR: coverpoint val iff(feild == "INTCLR"){
      bins clear_int = {'b1};
      }
  endgroup

covergroup t4_watchdog_lock_cg with function sample(bit[31:0] val, string feild);
    option.name = "T4 watchdog lock coverage";
    LOCK: coverpoint val iff(feild == "LOCK"){
      bins lock_enable = {'b0};
      bins lock_disble = {'b1};
      bins lock_acc    = {'h1acce551};
      }
  endgroup

  function new (string name = "rkv_watchdog_cov", uvm_component parent);
    super.new(name, parent);
    watchdog_control_cg = new();
    t1_watchdog_control_cg = new(this.reg_control_val);
    t2_watchdog_load_cg = new(this.reg_load_val);
    t3_watchdog_int_clr_cg = new();
    t4_watchdog_lock_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = cfg.vif;
    enable = cfg.enable_cov;
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    do_cover_events_check();
  endtask
  
  task do_cover_events_check();
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
          watchdog_control_cg.sample(rgm.WDOGCONTROL.INTEN.get(),"INTEN"); 
          watchdog_control_cg.sample(rgm.WDOGCONTROL.RESEN.get(),"RESEN"); 
          reg_control_val = rgm.WDOGCONTROL.get();
          ->reg_control_acc_sv_e; 
        end
        else if(r.get_name() == "WDOGLOAD" ) begin
          reg_load_val = rgm.WDOGLOAD.get();
          ->reg_load_acc_sv_e;
        end
        else if(r.get_name() == "WDOGINTCLR") begin
          t3_watchdog_int_clr_cg.sample(rgm.WDOGINTCLR.get(), "INTCLR");
        end
        else if(r.get_name() == "WDOGLOCK") begin
          t4_watchdog_lock_cg.sample(rgm.WDOGLOCK.get(), "LOCK");
        end
      end
    end
   join_none
  endtask

endclass



`endif
