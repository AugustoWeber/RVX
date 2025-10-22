// *****************************************************************************
// Copyright (c) 2023 SMDH, Inc. All rights reserved.
// SMDH Confidential Proprietary
// This file is sole intellectual property of SMDH.
// Use, copy or distribution of this code is not allowed without SMDH's explicit
// written consent.
// *****************************************************************************
//      Author: Kevin Paula Morais
//        Date: 23/02/2024
//        File: tb_uart_tx_file
// Description: Test module used to send a file from disk, through the UART
//              protocol.
// *****************************************************************************

module tb_uart_tx_file #(
  parameter BAUD_RATE = 115200,
  string    FILE_NAME = "uart_tx.hex"
)(
  input  logic rst_ni,
  input  logic enable_i,
  output logic tx_o,
  output logic done_o
);

  // ***********************************
  // set bit period in ns
  timeunit 1ns;
  localparam NS_UNIT_SCALER = 1000000000;
  real BIT_PERIOD = (NS_UNIT_SCALER/BAUD_RATE);

  // ***********************************
  // create driving clock
  logic clk;
  initial
  begin
    clk = 1;
    forever clk = #(BIT_PERIOD/2) ~clk;
  end

  // ***********************************
  logic       tx_busy;
  logic       tx_start;
  integer     tx_data_pos;
  logic [7:0] tx_data;

  string      line;
  integer     fd;   //file descriptor

  // ***********************************
  // open file to be sent, and load all
  // of it's content
  initial
  begin
    fd = $fopen(FILE_NAME, "r");
    if (!fd)
      $display("[%m] Failed to open TX file : %s", FILE_NAME);
    else
      $display("[%m] TX File open : %s", FILE_NAME);
  end

  // ***********************************
  // tx logic
  always_ff @(posedge(clk), negedge rst_ni)
  begin
    if (!rst_ni)
    begin
      tx_busy     <= 0;
      tx_o        <= 1;
      tx_data_pos <= 0;
      done_o      <= 0;
    end
    if (enable_i)
    begin
      if ((tx_start) & (!tx_busy))
      begin
        // send startupt bit 0
        tx_busy     <= 1;
        tx_o        <= 0;
        tx_data_pos <= 0;
      end
      else if ((tx_busy) & (tx_data_pos < $size(tx_data)))
      begin
        tx_busy     <= 1;
        tx_o        <= tx_data[tx_data_pos];
        tx_data_pos <= tx_data_pos+1;
      end
      else
      begin
        // if ending a tx, check if we are done sending everything
        if ((tx_busy) & $feof(fd) & (line.len() == 0))
          done_o <= 1;

        tx_busy <= 0;
        tx_o    <= 1;
      end
    end
    else
      tx_o <= 1;
  end

  // ***********************************
  // read data from file
  always_ff @(posedge(clk), negedge rst_ni)
  begin
    if (!rst_ni)
    begin
      tx_start <= 0;
      tx_data  <= 0;
      line     <= "";
    end
    else
    begin
      tx_start <= 0;

      if ((fd != 0) & enable_i)
      begin
        if (!$feof(fd))
        begin
          // load new line if needed
          if (line.len() == 0)
            $fgets(line, fd);

          // set next data if not busy
          // (from ascii to it's binary value)
          if ((line.len() > 0) & (!tx_busy) & (!tx_start))
          begin
            tx_data <= {1'b1 ,line.getc(0)};

            if (line.len() > 2)
              line <= line.substr(1, line.len()-1);
            else if (line.len() == 2)
              line <= line.substr(1, 1);
            else if (line.len() == 1)
              line <= ""; //set as empty, so we can read the next line

            tx_start <= 1;
          end

        end
        else
        begin
          // TODO:
          // // close file
          // if (!fd)
          // begin
          //   $fclose(fd);
          //   fd <= 0;
          // end
        end
      end
    end
  end

endmodule
