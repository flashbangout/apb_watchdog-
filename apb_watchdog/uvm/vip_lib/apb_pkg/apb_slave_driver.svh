
`ifndef APB_SLAVE_DRIVER_SVH
`define APB_SLAVE_DRIVER_SVH

class apb_slave_driver extends uvm_driver #(apb_transfer);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  apb_config cfg;

  // USER: Add your fields here
  bit[31:0] mem [bit[31:0]];

  // This macro performs UVM object creation, type control manipulation, and 
  // factory registration
  `uvm_component_utils_begin(apb_slave_driver)
     // USER: Register fields here
  `uvm_component_utils_end

  // new - constructor
  extern function new (string name, uvm_component parent);

  // uvm run phase
  extern virtual task run();

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////

  // The virtual interface used to drive and view HDL signals.
  virtual apb_if vif;

  // This is the method that is responsible for getting sequence transactions 
  // and driving the transaction into the DUT
  extern virtual protected task get_and_drive();
  
  // This method drives response onto the interface
  extern virtual protected task drive_response();
  // This method that is drive idle respone
  extern protected task do_idle();
  // This method that is proceed write transaction
  extern protected task do_write();
  // This method that is proceed read transaction
  extern protected task do_read();
  

  // This method reset interface signals
  extern virtual protected task reset_listener();
  
endclass : apb_slave_driver

`endif // APB_SLAVE_DRIVER_SVH
