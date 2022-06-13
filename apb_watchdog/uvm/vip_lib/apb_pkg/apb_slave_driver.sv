
`ifndef APB_SLAVE_DRIVER_SV
`define APB_SLAVE_DRIVER_SV

function apb_slave_driver::new (string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

task apb_slave_driver::run();
   fork
     get_and_drive();
     reset_listener();
     drive_response();
   join_none
endtask : run

task apb_slave_driver::get_and_drive();
  forever begin
    seq_item_port.get_next_item(req);
    `uvm_info(get_type_name(), "sequencer got next item", UVM_HIGH)
    void'($cast(rsp, req.clone()));
    rsp.set_sequence_id(req.get_sequence_id());
    seq_item_port.item_done(rsp);
    `uvm_info(get_type_name(), "sequencer item_done_triggered", UVM_HIGH)
  end
endtask : get_and_drive

task apb_slave_driver::drive_response();
  `uvm_info(get_type_name(), "drive_response", UVM_HIGH)
  forever begin
    @(vif.cb_slv);
    if(vif.cb_slv.psel === 1'b1 && vif.cb_slv.penable === 1'b0) begin
      case(vif.cb_slv.pwrite)
        1'b1    : this.do_write();
        1'b0    : this.do_read();
        default : `uvm_error(get_type_name(), "ERROR pwrite signal value")
      endcase
    end
    else begin
      this.do_idle();
    end
  end
endtask : drive_response

task apb_slave_driver::reset_listener();
  `uvm_info(get_type_name(), "reset_listener ...", UVM_HIGH)
  fork
    forever begin
      @(negedge vif.rstn); // ASYNC reset
      vif.prdata <= 0;
      this.mem.delete(); // reset internal memory
    end
  join_none
endtask: reset_listener

task apb_slave_driver::do_idle();
  `uvm_info(get_type_name(), "do_idle", UVM_HIGH)
  vif.cb_slv.prdata <= 0;
endtask: do_idle

task apb_slave_driver::do_write();
  bit[31:0] addr;
  bit[31:0] data;
  `uvm_info(get_type_name(), "do_write", UVM_HIGH)
  @(vif.cb_slv);
  addr = vif.cb_slv.paddr;
  data = vif.cb_slv.pwdata;
  mem[addr] = data;
endtask: do_write

task apb_slave_driver::do_read();
  bit[31:0] addr;
  bit[31:0] data;
  `uvm_info(get_type_name(), "do_read", UVM_HIGH)
  wait(vif.penable === 1'b1);
  addr = vif.cb_slv.paddr;
  if(mem.exists(addr))
    data = mem[addr];
  else
    data = DEFAULT_READ_VALUE;
  #1ps;
  vif.prdata <= data;
  @(vif.cb_slv);
endtask: do_read

`endif // APB_SLAVE_DRIVER_SV
