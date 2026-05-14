# ----------------------------------------------------------------------------
# Copyright (c) 2020-2025 RVX contributors
#
# This work is licensed under the MIT License, see LICENSE file for details.
# SPDX-License-Identifier: MIT
# ----------------------------------------------------------------------------

MAKEFLAGS += --no-print-directory

ifdef TOOLCHAIN_PREFIX
TOOLCHAIN_PREFIX_FLAG = -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX}
endif

ifdef PREFIX
TOOLCHAIN_PREFIX_FLAG = -DTOOLCHAIN_PREFIX="${PREFIX}/bin/riscv32-unknown-elf-"
endif

# RTL_LIST = ../../../hardware/*.v
# RTL_LIST += ../../../hardware/*.sv
# # RTL_LIST += ../rvx_wrapper.v 
# RTL_LIST += ../../../../sram/rtl/sram_wrapper.sv
# RTL_LIST += ../../../../sram/sram_8192/sram_8192_emulation.v
# RTL_LIST += ../../../hardware/tb_tools/*.sv
# RTL_LIST += ../*.v
# RTL_LIST += ../*.sv

RTL_LIST  = ../../../hardware/rvx_bus.v
RTL_LIST += ../../../hardware/rvx_macros.vh
RTL_LIST += ../../../hardware/rvx_core.v 
RTL_LIST += ../../../hardware/rvx_gpio.v 
RTL_LIST += ../../../hardware/rvx_mtimer.v 
RTL_LIST += ../../../hardware/rvx_ram.v 
RTL_LIST += ../../../hardware/rvx_spi.v 
RTL_LIST += ../../../hardware/rvx_uart.v 
RTL_LIST += ../../../hardware/rvx.v 
RTL_LIST += ../../../hardware/rvx_pmu.sv 
RTL_LIST += ../../../hardware/tb_tools/uart_rx_module.sv 
# RTL_LIST += ../../../hardware/tb_tools/uart_tx_file.sv
RTL_LIST += ../../../../sram/rtl/sram_wrapper.sv
RTL_LIST += ../../../../sram/sram_8192/sram_8192_emulation.v 
RTL_LIST += ../rvx_wrapper.v 
RTL_LIST += ../rvx_tb.sv
XRUN_ARGS  = -64bit -sv -v93 -mess -timescale 1ns/1ps -access +rw -clean -gui
XRUN_ARGS += -define MEMORY_FILE="./../build/programa.hex"
XRUN_ARGS += -top tb_rvx
XRUN_ARGS_MEM += ${XRUN_ARGS} -defineall MEM_ARM 
XRUN_ARGS_PWR = ${XRUN_ARGS} -defineall UPF -lps_1801 ../../../hardware/rvx_steel.upf -lps_logfile lps.log -lps_verbose 3 -lps_psn_verbose 2
# XRUN_ARGS_PWR += -upf_enable_hdl_compile -upf_enable_supply_check
# xrun(64): 24.09-s005: (c) Copyright 1995-2025 Cadence Design Systems, Inc.
# xrun: *SE,BDOPT: Unknown option -upf_enable_hdl_compile.
# xrun: *SE,BDOPT: Unknown option -upf_enable_supply_check.
XRUN_ARGS_MEM_PWR = ${XRUN_ARGS_PWR} -defineall MEM_ARM 

all: sim

debug:
	@mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Debug ${TOOLCHAIN_PREFIX_FLAG} ..
	@$(MAKE) -C build

release:
	@mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Release ${TOOLCHAIN_PREFIX_FLAG} ..
	@$(MAKE) -C build

sim:
	@mkdir -p sim && cd sim && xrun ${RTL_LIST} ${XRUN_ARGS}

sim-mem:
	@mkdir -p sim-mem && cd sim-mem && xrun -clean && xrun ${RTL_LIST} ${XRUN_ARGS_MEM}

sim-pwr:
	@mkdir -p sim-pwr && cd sim-pwr && xrun -clean &&  xrun ${RTL_LIST} ${XRUN_ARGS_PWR}

sim-all:
	@mkdir -p sim-pwr && cd sim-mem-pwr && xrun -clean &&  xrun ${RTL_LIST} ${XRUN_ARGS_MEM_PWR}

clean:
# 	@rm -rf build dump
	@echo "Build directory deleted."
	@rm -rf sim

clean-pwr:
	@rm -rf sim-pwr

.PHONY: debug release sim clean
