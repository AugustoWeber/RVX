// ----------------------------------------------------------------------------
// Copyright (c) 2020-2025 RVX contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

module rvx_ram #(

  // Memory size in bytes
  parameter MEMORY_SIZE      = 8192,

  // File with program and data
  parameter MEMORY_INIT_FILE = ""

  ) (

  // Global signals

  input   wire          clock,
  input   wire          reset,

  // IO interface

  input  wire   [31:0]  rw_address,
  output reg    [31:0]  read_data,
  input  wire           read_request,
  output reg            read_response,
  input  wire   [31:0]  write_data,
  input  wire   [3:0 ]  write_strobe,
  input  wire           write_request,
  output reg            write_response

  );

`ifndef MEM_ARM
  wire                        reset_internal;
  wire [31:0]                 effective_address;
  wire                        invalid_address;

  reg                         reset_reg;
  reg [31:0]                  ram [0:(MEMORY_SIZE)-1];

  always @(posedge clock)
    reset_reg <= reset;

  assign reset_internal = reset | reset_reg;
  assign invalid_address = $unsigned(rw_address) >= $unsigned(MEMORY_SIZE);

  integer i;
  initial begin
    for (i = 0; i < MEMORY_SIZE; i = i + 1) ram[i] = 32'h00000000;
    if (MEMORY_INIT_FILE != "")
      $readmemh(MEMORY_INIT_FILE,ram);
  end

  assign effective_address =
    $unsigned(rw_address[31:0] >> 2);

  always @(posedge clock) begin
    if (reset_internal | invalid_address)
      read_data <= 32'h00000000;
    else
      read_data <= ram[effective_address];
  end

  always @(posedge clock) begin
    if(write_request) begin
      if(write_strobe[0])
        ram[effective_address][7:0  ] <= write_data[7:0  ];
      if(write_strobe[1])
        ram[effective_address][15:8 ] <= write_data[15:8 ];
      if(write_strobe[2])
        ram[effective_address][23:16] <= write_data[23:16];
      if(write_strobe[3])
        ram[effective_address][31:24] <= write_data[31:24];
    end
  end

  always @(posedge clock) begin
    if (reset_internal) begin
      read_response  <= 1'b0;
      write_response <= 1'b0;
    end
    else begin
      read_response  <= read_request;
      write_response <= write_request;
    end
  end

  // Avoid warnings about intentionally unused pins/wires
  wire unused_ok = &{1'b0, effective_address[31:11], 1'b0};


`else //MEM_ARM

  // integer i;
  // initial begin: Memory_init
  //   // wire tmp_array;
  //   reg [31:0] tmp_array = {tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.MEM_CLUSTER[0].sram.uPRIM0.array[33:18] , tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.MEM_CLUSTER[0].sram.uPRIM0.array[15:0]};
  //   for (i = 0; i < MEMORY_SIZE; i = i + 1) 
  //     tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.MEM_CLUSTER[0].sram.uPRIM0.array[i] = 0;
  //   if (MEMORY_INIT_FILE != "")
  //     $readmemh(MEMORY_INIT_FILE, tmp_array);
  // end
  // reg read_data_o;
  reg be;
  always @(posedge clock) begin
    if (reset) begin
      read_response  <= 1'b0;
      write_response <= 1'b0;
      be <= 0;
    end
    else begin
      read_response  <= read_request;
      write_response <= write_request;
      if (write_request)
        be <= !write_strobe;
      else if (read_request)
        be <= 0;
    end
  end
  // reg tmp_read, tmp_write;
  // always @(posedge clock) begin
  //   if (reset) begin
  //     read_response  <= 1'b0;
  //     write_response <= 1'b0;
  //   end
  //   else begin
  //     tmp_read  <= read_request;
  //     tmp_write <= write_request;
  //     read_response  <= tmp_read;
  //     write_response <= tmp_write;
  //     be <= (write_request | tmp_write | write_response) ? !write_strobe : 'hf;
  //   end
  // end

  // assign read_data = read_request ? read_data_o : 32'd0;
  // Define width of address based on number of words.
  localparam integer ADDR_WIDTH = (MEMORY_SIZE > 32'd1) ? $clog2(MEMORY_SIZE) : 32'd1;
  sram_wrapper #(
    .NUM_WORDS (MEMORY_SIZE)
  )
  rvx_sram_i (
    .clk    (clock), // Clock
    .rst_n  (reset), // Asynchronous reset active low
    // input ports
    .req_i  (write_request | read_request ),      // 2 cycles on request
    .we_n_i (!write_request    ),  // write enable
    .addr_i (rw_address [ADDR_WIDTH+1:2]),  // request address
    .wdata_i (write_data      ),  // write data
    .be_i   (be       ), //!write_strobe     ),  // write byte enable
    .STOV   (1'b0     ),
    .EMA    (3'b100   ),
    .EMAW   (2'b10     ),
    .EMAS   (1'b0     ), 
    .RET1N  (1'b1     ),
    .RAWL   (1'b1     ),
    .RAWLM  (2'b01    ),
    .WABL   (1'b1     ), 
    .WABLM  (3'b001   ),
    .PowerDown (1'b0  ),
    // output ports
    .PowerDown_Ready(),
    .rdata_o(read_data)    // read data
  );
`endif //MEM_ARM
endmodule
