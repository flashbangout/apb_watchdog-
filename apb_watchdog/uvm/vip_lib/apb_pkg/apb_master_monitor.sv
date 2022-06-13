
`ifndef APB_MASTER_MONITOR_SV
`define APB_MASTER_MONITOR_SV

function apb_master_monitor::new(string name, uvm_component parent=null);
  super.new(name, parent);
  item_collected_port = new("item_collected_port",this);
  //trans_collected = new();
endfunction:new

// build
function void apb_master_monitor::build();
   super.build();
endfunction : build  

task apb_master_monitor::monitor_transactions();
   forever begin
 
      // Extract data from interface into transaction
      collect_transfer();

      // Check transaction
      if (checks_enable)
 	      perform_transfer_checks();

      // Update coverage
      if (coverage_enable)
 	      perform_transfer_coverage();

      // Publish to subscribers
      item_collected_port.write(trans_collected);

   end
endtask // monitor_transactions
   

task apb_master_monitor::run();
  fork
    monitor_transactions();
  join_none
endtask // run
  
  
task apb_master_monitor::collect_transfer();
  apb_transfer t;
  // Advance clock
  @(vif.cb_mon iff (vif.cb_mon.psel === 1'b1 && vif.cb_mon.penable === 1'b0));
    trans_collected = apb_transfer::type_id::create("trans_collected");
    case(vif.cb_mon.pwrite)
      1'b1    : begin
                  @(vif.cb_mon);
                  trans_collected.addr = vif.cb_mon.paddr;
                  trans_collected.data = vif.cb_mon.pwdata;
                  trans_collected.trans_kind = WRITE;
                end 
      1'b0    : begin
                  @(vif.cb_mon);
                  trans_collected.addr = vif.cb_mon.paddr;
                  trans_collected.data = vif.cb_mon.prdata;
                  trans_collected.trans_kind = READ;
                end
      default : `uvm_error(get_type_name(), "ERROR pwrite signal value")
    endcase
    //item_collected_port.write(t);
endtask: collect_transfer 


// perform_transfer_checks
function void apb_master_monitor::perform_transfer_checks();

 // USER: do some checks on the transfer here

endfunction : perform_transfer_checks

// perform_transfer_coverage
function void apb_master_monitor::perform_transfer_coverage();

 // USER: coverage implementation
  -> apb_master_cov_transaction;	

endfunction : perform_transfer_coverage

`endif // APB_MASTER_MONITOR_SV

