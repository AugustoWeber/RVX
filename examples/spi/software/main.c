// ----------------------------------------------------------------------------
// Copyright (c) 2020-2025 RVX contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#include "libsteel.h"

#define UART_0  (UartController   *)0x80000000
#define UART_1  (UartController   *)0x80001000
#define UART_2  (UartController   *)0x80002000
#define UART_3  (UartController   *)0x80003000
#define TIMER_0 (MTimerController *)0x80010000
#define GPIO_0  (GpioController   *)0x80020000
#define SPI_0   (SpiController    *)0x80030000

#define DEFAULT_MTIMER  TIMER_0
#define DEFAULT_UART    UART_0
#define DEFAULT_GPIO    GPIO_0
#define DEFAULT_SPI     SPI_0

#define CPU_FREQUENCY 50000000

void print_readout_value(const uint8_t rdata)
{
  uint8_t val = rdata;
  char str_val[4] = "xxx\0";
  for (int i = 1; i <= 3; i++)
  {
    str_val[3 - i] = (uint8_t)((val % 10UL) + '0');
    val /= 10;
  }
  str_val[3] = '\0';
  uart_write_string(DEFAULT_UART, "Read out value: ");
  uart_write_string(DEFAULT_UART, str_val);
  uart_write_string(DEFAULT_UART, "\n");
}


void blink_setup () {
  gpio_set_output(DEFAULT_GPIO, 0);
  gpio_set_output(DEFAULT_GPIO, 1);
  gpio_set_input(DEFAULT_GPIO, 2);
  gpio_write(DEFAULT_GPIO, 0, HIGH);
  // while (1)
  // {
  //   uint32_t button_state = gpio_read(DEFAULT_GPIO, 2);
  //   gpio_write(DEFAULT_GPIO, 1, button_state);
  // }
}

void blink_togle () {
  gpio_toggle(DEFAULT_GPIO,1);
}

// UART interrupt signal is connected to Fast IRQ #0
__NAKED void fast0_irq_handler(void) {
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

__NAKED void fast1_irq_handler  (void) {__ASM_VOLATILE("mret");}
__NAKED void fast2_irq_handler  (void) {__ASM_VOLATILE("mret");}
__NAKED void fast3_irq_handler  (void) {__ASM_VOLATILE("mret");}
__NAKED void fast4_irq_handler  (void) {__ASM_VOLATILE("mret");}
__NAKED void fast5_irq_handler  (void) {__ASM_VOLATILE("mret");}
__NAKED void fast6_irq_handler  (void) {__ASM_VOLATILE("mret");}
__NAKED void fast7_irq_handler  (void) {__ASM_VOLATILE("mret");}
__NAKED void fast8_irq_handler  (void) {__ASM_VOLATILE("mret");}
__NAKED void fast9_irq_handler  (void) {__ASM_VOLATILE("mret");}
__NAKED void fast10_irq_handler (void) {__ASM_VOLATILE("mret");}
__NAKED void fast11_irq_handler (void) {__ASM_VOLATILE("mret");}
__NAKED void fast12_irq_handler (void) {__ASM_VOLATILE("mret");}
__NAKED void fast13_irq_handler (void) {__ASM_VOLATILE("mret");}
__NAKED void fast14_irq_handler (void) {__ASM_VOLATILE("mret");}
__NAKED void fast15_irq_handler (void) {__ASM_VOLATILE("mret");}

__NAKED void mti_irq_handler (void) {
  mtimer_clear_counter(DEFAULT_MTIMER);
  blink_togle();
  uart_write_string(DEFAULT_UART, "Time elapsed: 1 sec\n");
  __ASM_VOLATILE("mret");
}

void main(void)
{
  blink_setup ();
  // SET Interruptions
  mtimer_set_compare  (DEFAULT_MTIMER, CPU_FREQUENCY/100);
  mtimer_clear_counter(DEFAULT_MTIMER);
  mtimer_enable       (DEFAULT_MTIMER);
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_MTI);
  csr_global_enable_irq();

  uart_write_string(DEFAULT_UART, "RVX - SPI demo");
  uart_write_string(DEFAULT_UART, "\n\nPress Enter to read the SPI Flash Manufacturer ID.\n");
  // Enable UART interrupts
  csr_enable_vectored_mode_irq();
  CSR_SET(CSR_MIE, MIP_MIE_MASK_F0I);
  csr_global_enable_irq();
  // Configure the controller
  spi_set_mode(DEFAULT_SPI, SPI_MODE0_CPOL0_CPHA0);
  // Wait for interrupts
  uart_write_string(UART_3, "1\n");

  // Forever Loop
  while (1);
}
