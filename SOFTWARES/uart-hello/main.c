// ----------------------------------------------------------------------------
// Copyright (c) 2020-2025 RVX contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"
#include "pmu.h"

#define UART_0       (UartController   *)0x80000000
#define UART_1       (UartController   *)0x80001000
#define UART_2       (UartController   *)0x80002000
#define UART_3       (UartController   *)0x80003000
#define PMU          (PmuController    *)0x80004000
#define TIMER        (MTimerController *)0x80010000
#define DEFAULT_SPI  (SpiController    *)0x80040000

#define DEFAULT_UART UART_0
#define PMU_MASK      0xffff00ff

void print_readout_value(const uint8_t rdata) {
  uint8_t val = rdata;
  char str_val[4] = "xxx\0";
  /*
  * Problemas no COMPILADOR
  */
  // for (int i = 1; i <= 3; i++)
  // {
  //   str_val[3 - i] = (uint8_t)((val % 10UL) + '0');
  //   val = val / 10;
  // }
  // str_val[3] = '\0';
  // char str_val[4] = "xxx\0";
  uart_write_string(DEFAULT_UART, "Read out value: ");
  uart_write_string(DEFAULT_UART, str_val);
  uart_write_string(DEFAULT_UART, "\n");
}

void timer_setup (uint32_t time) {
  mtimer_set_compare(TIMER, time);
  mtimer_clear_counter(TIMER);
  mtimer_enable(TIMER);
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_MTI);
  csr_global_enable_irq();
  while (1)
    ;
}

// Variável global com o estado da PMU
static uint32_t status_pmu = 0;
void test_pmu() {
  uint8_t last_one = 0;
  if (status_pmu == 0)
    status_pmu = 1;
  else
    status_pmu = (status_pmu << 1) | 1;

  
  // printf("PMU: 0x%08X\n", status_pmu);

  // buffer para a string
  char bin_str[33]; // 32 bits + '\0'
  // converter status_pmu para string binária
  for (int i = 31; i >= 0; i--) {
    bin_str[31-i] = (status_pmu & (1 << i)) ? '1' : '0';
    if (status_pmu & (1 << i)) 
      last_one = i;
  }
  bin_str[32] = '\0';
  char *tmp = &last_one;

  uart_write_string(UART_0, "PMU: 0x");
  uart_write_string(UART_0, bin_str);
  uart_write_string(UART_0, "\n");

  pmu_get_save(PMU);
  pmu_get_restore(PMU);
  pmu_get_iso(PMU);
  pmu_get_sleep(PMU);
  // switch (last_one)
  // {
  // case 1 ... 7:
    pmu_set_save(PMU,status_pmu & PMU_MASK);
  //   break;
  // case 8 ... 15:
    pmu_set_restore(PMU,status_pmu>>8);
  //   break;
  // case 16 ... 23:
    pmu_set_iso(PMU,status_pmu>>16);
  //   break;
  // case 24 ... 31:
    pmu_set_sleep(PMU,status_pmu>>24);
  //   break;
  
  // default:
  //   break;
  // }
}

// Overrides the standard interrupt handler for Machine Timer interrupts
__NAKED void mti_irq_handler()
{
  mtimer_clear_counter(TIMER);
  test_pmu();
  __ASM_VOLATILE("mret");
}

// UART interrupt signal is connected to Fast IRQ #0
__NAKED void fast0_irq_handler(void)
{
  spi_wait_ready(DEFAULT_SPI);
  spi_select(DEFAULT_SPI, 0);
  spi_write(DEFAULT_SPI, 0x9f);
  volatile uint8_t read_val = spi_transfer(DEFAULT_SPI, 0x00);
  spi_deselect(DEFAULT_SPI);
  if (uart_read(DEFAULT_UART) == '\n') // Enter key
  {
    print_readout_value(read_val);
    uart_write_string(DEFAULT_UART, "Manufacturer: ");
    if (read_val == 0x01)
      uart_write_string(DEFAULT_UART, "Infineon\n");
    else if (read_val == 0xC2)
      uart_write_string(DEFAULT_UART, "Macronix\n");
    else if (read_val == 0x20)
      uart_write_string(DEFAULT_UART, "Micron\n");
    else
      uart_write_string(DEFAULT_UART, "Unknown\n");
  }
  __ASM_VOLATILE("mret");
}


void main(void)
{
  timer_setup(32000);
  uart_write_string(UART_0, "Hello World from RVX!\n");
  uart_write_string(UART_1, "Aqui vai uma Espumante");
  uart_write_string(UART_2, "BEM,");
  uart_write_string(UART_3, "MAS BEM BELA.");

  // TESTE PMU
  timer_setup(640000);
  //----------------------
  //    FROM SPI DEMO
  //----------------------
  uart_write_string(DEFAULT_UART, "RVX - SPI demo");
  uart_write_string(DEFAULT_UART, "\n\nPress Enter to read the SPI Flash Manufacturer ID.\n");
  // Enable UART interrupts
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_F0I);
  csr_global_enable_irq();
  // Configure the controller
  spi_set_mode(DEFAULT_SPI, SPI_MODE0_CPOL0_CPHA0);
  // Wait for interrupts

  uart_write_string(UART_3, "1");
  uart_write_string(UART_3, "\n");
  while (1)
    ;
}