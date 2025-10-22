module rvx_pmu (
  // Global signals
  input   logic          clock,
  input   logic          reset,

  // IO interface
  input  logic   [4:0 ]  rw_address,
  output logic   [31:0]  read_data,
  input  logic           read_request,
  output logic           read_response,
  input  logic   [7:0]   write_data,
  input  logic           write_request,
  output logic           write_response,

  // PMU Control Signals
  output  logic   [7:0]  save_o,
  output  logic   [7:0]  rest_o,
  output  logic   [7:0]  iso_o,
  output  logic   [7:0]  sleep_o,
  input   logic   [7:0]  sleep_i // ACK from SW cells

);

  // Register Map
  localparam REG_SAVE  = 5'h00;
  localparam REG_REST  = 5'h04;
  localparam REG_ISO   = 5'h08;
  localparam REG_SLEEP = 5'h0c;

  logic [7:0] save;
  logic [7:0] rest;
  logic [7:0] iso;
  logic [7:0] sleep;

  always @(posedge clock) begin:HandShake
    if (reset) begin
      read_response  <= 1'b0;
      write_response <= 1'b0;
    end
    else begin
      read_response  <= read_request;
      write_response <= write_request;
    end
  end

  //
  // Read
  //
  always @(posedge clock) begin:READ
    if (reset)
      read_data <= 32'h00000000;
    else if (rw_address == REG_SAVE  && read_request == 1'b1)
      read_data <= {24'b0, save};
    else if (rw_address == REG_REST  && read_request == 1'b1)
      read_data <= {24'b0, rest};
    else if (rw_address == REG_ISO   && read_request == 1'b1)
      read_data <= {24'b0, iso};
    else if (rw_address == REG_SLEEP && read_request == 1'b1)
      read_data <= {24'b0, sleep};
    else
      read_data <= 32'h00000000;
  end


  //
  // Write 
  //
  always @(posedge clock) begin:WRITE
    if (reset) begin
      save  <= 8'b0;
      rest  <= 8'b0;
      iso   <= 8'b0;
      sleep <= 8'b0;
    end
    // Write to the register signals
    else if (rw_address == REG_SAVE  && write_request == 1'b1)
      save <= write_data;
    else if (rw_address == REG_REST  && write_request == 1'b1)
      rest <= write_data;
    else if (rw_address == REG_ISO   && write_request == 1'b1)
      iso <= write_data;
    else if (rw_address == REG_SLEEP && write_request == 1'b1)
      sleep <= write_data;
    // Garantee a pulse for save and restore signals
    // else if (save != 0) 
    //   save <= 0;
    // else if (rest != 0)
    //   rest <= 0;
    
  end

  assign save_o = save;
  assign rest_o = rest;
  assign iso_o  = iso;
  assign sleep_o = sleep;


endmodule