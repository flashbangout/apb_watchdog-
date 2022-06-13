
`ifndef APB_TESTS_SV
`define APB_TESTS_SV

import apb_pkg::*;

class apb_env extends uvm_env;
  apb_master_agent mst;
  apb_slave_agent slv;
  `uvm_component_utils(apb_env)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mst = apb_master_agent::type_id::create("mst", this);
    slv = apb_slave_agent::type_id::create("slv", this);
  endfunction
endclass

class apb_base_test extends uvm_test;
  apb_env env;
  `uvm_component_utils(apb_base_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction
endclass

class apb_base_test_sequence extends uvm_sequence #(apb_transfer);
  bit[31:0] mem[bit[31:0]];
  `uvm_object_utils(apb_base_test_sequence)
  function new(string name=""); 
    super.new(name);
  endfunction : new
  function bit check_mem_data(bit[31:0] addr, bit[31:0] data);
    if(mem.exists(addr)) begin
      if(data != mem[addr]) begin
        `uvm_error("CMPDATA", $sformatf("addr 32'h%8x, READ DATA expected 32'h%8x != actual 32'h%8x", addr, mem[addr], data))
        return 0;
      end
      else begin
        `uvm_info("CMPDATA", $sformatf("addr 32'h%8x, READ DATA 32'h%8x comparing success!", addr, data), UVM_LOW)
        return 1;
      end
    end
    else begin
      if(data != DEFAULT_READ_VALUE) begin
        `uvm_error("CMPDATA", $sformatf("addr 32'h%8x, READ DATA expected 32'h%8x != actual 32'h%8x", addr, DEFAULT_READ_VALUE, data))
        return 0;
      end
      else begin
        `uvm_info("CMPDATA", $sformatf("addr 32'h%8x, READ DATA 32'h%8x comparing success!", addr, data), UVM_LOW)
        return 1;
      end
    end
  endfunction: check_mem_data

  task wait_reset_release();
    @(negedge apb_tb.rstn);
    @(posedge apb_tb.rstn);
  endtask

  task wait_cycles(int n);
    repeat(n) @(posedge apb_tb.clk);
  endtask

  function bit[31:0] get_rand_addr();
    bit[31:0] addr;
    void'(std::randomize(addr) with {addr[31:12] == 0; addr[1:0] == 0;addr != 0;});
    return addr;
  endfunction
endclass

class apb_single_transaction_sequence extends apb_base_test_sequence;
  apb_master_single_write_sequence single_write_seq;
  apb_master_single_read_sequence single_read_seq;
  apb_master_write_read_sequence write_read_seq;
  rand int test_num = 100;
  constraint cstr{
    soft test_num == 100;
  }
  `uvm_object_utils(apb_single_transaction_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction : new
  task body();
    bit[31:0] addr;
    this.wait_reset_release();
    this.wait_cycles(10);

    // TEST continous write transaction
    `uvm_info(get_type_name(), "TEST continous write transaction...", UVM_LOW)
    repeat(test_num) begin
      addr = this.get_rand_addr();
      `uvm_do_with(single_write_seq, {addr == local::addr; data == local::addr;})
      mem[addr] = addr;
    end

    // TEST continous read transaction
    `uvm_info(get_type_name(), "TEST continous read transaction...", UVM_LOW)
    repeat(test_num) begin
      addr = this.get_rand_addr();
      `uvm_do_with(single_read_seq, {addr == local::addr;})
      void'(this.check_mem_data(addr, single_read_seq.data));
    end

    // TEST read transaction after write transaction
    `uvm_info(get_type_name(), "TEST read transaction after write transaction...", UVM_LOW)
    repeat(test_num) begin
      addr = this.get_rand_addr();
      `uvm_do_with(single_write_seq, {addr == local::addr; data == local::addr;})
      mem[addr] = addr;
      `uvm_do_with(single_read_seq, {addr == local::addr;})
      void'(this.check_mem_data(addr, single_read_seq.data));
    end


    // TEST read transaction immediately after write transaction
    `uvm_info(get_type_name(), "TEST read transaction immediately after write transaction", UVM_LOW)
    repeat(test_num) begin
      addr = this.get_rand_addr();
      `uvm_do_with(write_read_seq, {addr == local::addr; data == local::addr;})
      mem[addr] = addr;
      void'(this.check_mem_data(addr, write_read_seq.data));
    end

    // TODO
    // TEST write twice and read immediately with burst transaction
    `uvm_info(get_type_name(), "TEST write twice and read immediately with burst transaction...", UVM_LOW)
    repeat(test_num) begin
      addr = this.get_rand_addr();
      // WRITE first time
      `uvm_do_with(req,  {trans_kind == WRITE; 
                    addr == local::addr; 
                    data == local::addr;
                    idle_cycles == 0;
                   })
      mem[addr] = addr;
      get_response(rsp);
      // WRITE second time
      `uvm_do_with(req,  {trans_kind == WRITE; 
                    addr == local::addr; 
                    data == local::addr<<2;
                    idle_cycles == 0;
                   })
      mem[addr] = addr<<2;
      get_response(rsp);
      // READ immediately after WRITE
      `uvm_do_with(req, {trans_kind == READ; addr == local::addr;})
      get_response(rsp);
      void'(this.check_mem_data(addr, rsp.data));
    end

    this.wait_cycles(10);
  endtask
endclass: apb_single_transaction_sequence

class apb_single_transaction_test extends apb_base_test;
  `uvm_component_utils(apb_single_transaction_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    apb_single_transaction_sequence seq = new();
    phase.raise_objection(this);
    super.run_phase(phase);
    seq.start(env.mst.sequencer);
    phase.drop_objection(this);
  endtask
endclass: apb_single_transaction_test

class apb_burst_transaction_sequence extends apb_base_test_sequence;
  apb_master_burst_write_sequence burst_write_seq;
  apb_master_burst_read_sequence burst_read_seq;
  rand int test_num = 100;
  constraint cstr{
    soft test_num == 100;
  }
  `uvm_object_utils(apb_burst_transaction_sequence)
  function new(string name=""); 
    super.new(name);
  endfunction : new
  task body();
    bit[31:0] addr;
    this.wait_reset_release();
    this.wait_cycles(10);

    // TEST continous write transaction
    repeat(test_num) begin
      addr = this.get_rand_addr();
      `uvm_do_with(burst_write_seq, {addr == local::addr;})
      foreach(burst_write_seq.data[i]) begin
        mem[addr+(i<<2)] = burst_write_seq.data[i];
      end
      `uvm_do_with(burst_read_seq, {addr == local::addr; data.size() == burst_write_seq.data.size();})
      foreach(burst_read_seq.data[i]) begin
        void'(this.check_mem_data(addr+(i<<2), burst_write_seq.data[i]));
      end
    end

    this.wait_cycles(10);
  endtask
endclass: apb_burst_transaction_sequence

class apb_burst_transaction_test extends apb_base_test;
  `uvm_component_utils(apb_burst_transaction_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    apb_burst_transaction_sequence seq = new();
    phase.raise_objection(this);
    super.run_phase(phase);
    seq.start(env.mst.sequencer);
    phase.drop_objection(this);
  endtask
endclass: apb_burst_transaction_test



`endif // APB_TESTS_SV
