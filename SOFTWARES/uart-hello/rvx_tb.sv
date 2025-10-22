`timescale 1ns / 1ps

module tb_rvx;

  parameter UART_BAUD_RATE = 115200;
  parameter MEMORY_FILE = "./../build/programa.hex";

  // Clock and reset
  logic clock;
  logic reset;
  logic halt;

  // UART
  logic [3:0]uart_rx;
  wire  [3:0]uart_tx;
  logic [3:0]uart_tx_done;
  // logic [3:0]uart_rx_done;

  // GPIO
  logic [3:0] gpio_input;
  wire  [3:0] gpio_oe;
  wire  [3:0] gpio_output;

  // SPI
  wire        sclk;
  wire        pico;
  logic       poci;
  wire  [2:0] cs;

  

  // Instantiate the Device Under Test (DUT)
  rvx_wrapper #(.MEMORY_INIT_FILE(MEMORY_FILE) )dut (
    .clock    (clock),
    .reset    (reset),
    .halt     (halt),
    .uart_rx  (uart_rx),
    .uart_tx  (uart_tx),
    .gpio_input(gpio_input),
    .gpio_oe  (gpio_oe),
    .gpio_output(gpio_output),
    .sclk     (sclk),
    .pico     (pico),
    .poci     (poci),
    .cs       (cs)
  );

  generate
    for (genvar uart_id = 0;uart_id <4 ; uart_id++) begin
      // tb_uart_tx_file #(
      //   .BAUD_RATE (UART_BAUD_RATE), 
      //   .FILE_NAME($sformatf("uart%0d_tx.hex", uart_id))
      // ) uart_tx_i(
      //   .rst_ni (reset),
      //   .enable_i(1'b0),
      //   .tx_o (uart_rx[uart_id]),
      //   .done_o(uart_rx_done[uart_id])
      // );

      uart_tb_rx #(
        .BAUD_RATE (UART_BAUD_RATE),
        .FILENAME ($sformatf("uart%0d_recived.txt", uart_id)) 
      ) uart_rx_i (
        .rx (uart_tx[uart_id]),
        .rx_en (1'b1),
        .word_done(uart_tx_done[uart_id])
      );
    end
  endgenerate

  // UART_0 RX <--- TX UART_3
  assign uart_rx[0] = uart_tx[3];

  // ***********************************
  initial
  begin: timing_format
    $timeformat(-9, 0, "ns", 9);
  end: timing_format

  task do_wait (input integer clocks);
    begin
      repeat (clocks) @(posedge clock);
    end
  endtask


  `ifdef MEM_ARM
  task memWrite(input [12:0] address, input [31:0] data, input [3:0] byte_enable);
    begin
      // Escreve
      @(negedge clock);
      force tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.wdata_i = data;
      force tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.addr_i = address;
      force tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.we_n_i = 0;
      force tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.be_i   = byte_enable;
      force tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.req_i  = 1;
      @(posedge clock);
      // Retorna os valores padrões
      // @(posedge clk);
      @(posedge clock);
      // $display("[%t] Writing address 0x%h, Value 0x%h", $time, address, data);
      force tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.addr_i = 0;
      force tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.be_i   = 0;
      force tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.we_n_i = 1;
      force tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.req_i  = 0;
    end
  endtask //automatic

  // Inicializa a memória
  task MEM_INIT ();
    begin
      parameter int MEMORY_SIZE = 8192;
      logic  [31:0] tmp_mem[0:MEMORY_SIZE-1];
      $display("[%t] Writing the program to memory.",$time);
      for (int i = 0; i< MEMORY_SIZE/4; i++ ) begin
          tmp_mem[i] = 0;
        end
      // tmp_array = {tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.MEM_CLUSTER[0].sram.uPRIM0.array[33:18] , tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.MEM_CLUSTER[0].sram.uPRIM0.array[15:0]};
      // integer i;
      // initial begin: Memory_init
      //   
      //   for (i = 0; i < MEMORY_SIZE; i = i + 1) 
      //     tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.MEM_CLUSTER[0].sram.uPRIM0.array[i] = 0;
      if (MEMORY_FILE != "")
      begin
        $readmemh(MEMORY_FILE, tmp_mem);
        for (int i = 0; i< MEMORY_SIZE; i++ ) begin
          memWrite(i,tmp_mem[i],'hf);
        end
        release tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.wdata_i;
        release tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.addr_i;
        release tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.we_n_i;
        release tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.be_i;
        release tb_rvx.dut.rvx_instance.rvx_ram_i.rvx_sram_i.req_i;
      end 
      $display("[%t] Program writen to memory.\n",$time);
    end
  endtask
  `endif


  // Clock generation
  initial begin
    clock = 0;
    forever #10 clock = ~clock; // 50 MHz clock
  end

  // Power On
  `ifdef UPF
  initial begin
    reg state;
    state=$supply_on("tb_rvx.dut.rvx_instance.VSS", 0.0);
    state=$supply_on("tb_rvx.dut.rvx_instance.VDD", 0.8);
  end
  `endif //UPF

  initial begin
    reset = 1;
    #327750ns;
    reset = 0;
    halt = 0;
  end

  // Reset and basic stimulus
  initial begin
    // Initialize inputs
    `ifdef MEM_ARM
    MEM_INIT();
    `endif // MEM_ARM
    // reset = 1;
    // halt = 0;

    // uart_rx = 1;
    gpio_input = 4'b0000;
    poci = 0;

    // Apply reset
    @(negedge reset)
    // reset = 0;

    // Basic GPIO test
    #10;
    gpio_input = 4'b1010;

    // Simulate halt
    #50;
    halt = 1;
    do_wait(1);
    halt = 0;

    // SPI input change
    #30;
    poci = 1;

    // UART test signal (idle -> start -> data bits)
    do_wait(2);
    // uart_rx = 0; // Start bit
    do_wait(4);
    // uart_rx = 1; // Stop bit

    // Simulation end
    #20000000;
    // $finish;
  end

  // Optional: Monitor signals
  // initial begin
  //   $monitor("Time=%0t | Reset=%b | Halt=%b | GPIO_IN=%b | GPIO_OUT=%b | UART_TX=%b | SPI_CS=%b",
  //             $time, reset, halt, gpio_input, gpio_output, uart_tx, cs);
  // end

endmodule
