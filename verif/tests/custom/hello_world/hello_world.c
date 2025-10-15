/*
**
** Copyright 2020 OpenHW Group
**
** Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     https://solderpad.org/licenses/
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
**
*/

#include <stdint.h>
#include <stdio.h>
#include "uart.h"

//IOPMP Registers
#define IOPMP_BASE 0x00200000
#define IOPMP_HWCFG0 0x0008
#define IOPMP_HWCFG1 0x000C
#define IOPMP_HWCFG2 0x0010
#define IOPMP_ERR_CFG 0x0060

// DMA Registers
#define DMA_BASE 0x00400000
#define REG_SRC_ADDR 0x0
#define REG_DST_ADDR 0x8
#define REG_LEN 0x10
#define REG_CTRL 0x14
#define REG_STATUS 0x18
#define BULK_SIZE 0x100


static uint8_t src_buf[BULK_SIZE] __attribute__((aligned(4096)));
static uint8_t dst_buf[BULK_SIZE] __attribute__((aligned(4096)));

uint32_t iopmp_read32(uintptr_t base, uint32_t off)
{
    volatile uint32_t *p = (volatile uint32_t *)(base + off);
    return *p;
}

uint32_t iopmp_write32(uintptr_t base, uint32_t off, uint32_t val)
{
    volatile uint32_t *p = (volatile uint32_t *)(base + off);
    *p=val;
}

uint64_t iopmp_write64(uintptr_t base, uint32_t off, uint64_t val)
{
    volatile uint64_t *p = (volatile uint64_t *)(base + off);
    *p=val;
}

int main(int argc, char* arg[]) {

	for (unsigned i = 0; i < BULK_SIZE; ++i) {
        src_buf[i] = (uint8_t)(i & 0xFF);
        dst_buf[i] = 0xEE;
    }

	uintptr_t src_phys = (uintptr_t)src_buf;
	uintptr_t dst_phys = (uintptr_t)dst_buf;
	// print_uart_addr((uint64_t)src_phys);
	// print_uart("\nAddress of RAM \n");

	// uint32_t hwcfg2 = iopmp_read32(IOPMP_BASE,IOPMP_ERR_CFG);
	// print_uart_addr((uint64_t)hwcfg2);
	// print_uart("\nRead Successful From ErrorCFG Reg \n");

	uint32_t err_cfg = 0x2UL;
	iopmp_write32(IOPMP_BASE, IOPMP_ERR_CFG, err_cfg);
	print_uart("\nWrite Successful on ErrorCFG Reg  \n\n");

	// hwcfg2 = iopmp_read32(IOPMP_BASE,IOPMP_ERR_CFG);
	// print_uart_addr((uint64_t)hwcfg2);
	// print_uart("\nRead after write Successful on ErrorCFG Reg  \n\n");

	// uint32_t src_addr = iopmp_read32(DMA_BASE,REG_SRC_ADDR);
	// print_uart_addr((uint64_t)src_addr);
	// print_uart("\nDMA Read Successful from src_addr \n");

	uint64_t wr_src_addr = (uint64_t)src_phys;
	iopmp_write64(DMA_BASE, REG_SRC_ADDR, wr_src_addr);
	print_uart("\nDMA Write Successful on src_addr \n");

	// src_addr = iopmp_read32(DMA_BASE,REG_SRC_ADDR);
	// print_uart_addr((uint64_t)src_addr);
	// print_uart("\nDMA Read after write Successful on src_addr \n\n\n");

	// uint32_t dst_addr = iopmp_read32(DMA_BASE,REG_DST_ADDR);
	// print_uart_addr((uint64_t)dst_addr);
	// print_uart("\nDMA Read Successful from dst_addr \n");

	uint32_t wr_dst_addr = 0x3UL;
	iopmp_write32(DMA_BASE, REG_DST_ADDR, wr_dst_addr);
	print_uart("\nDMA Write Successful on dst_addr \n");

	// dst_addr = iopmp_read32(DMA_BASE,REG_DST_ADDR);
	// print_uart_addr((uint64_t)dst_addr);
	// print_uart("\nDMA Read after write Successful on dst_addr \n");

	uint32_t ctrl_reg_addr = 0x1UL;
	iopmp_write32(DMA_BASE, REG_CTRL, ctrl_reg_addr);
	print_uart("\nDMA sent transaction \n");

	// uint32_t rd_ctrl_reg;

    // // keep reading until the value becomes 0
    // do {
    //     rd_ctrl_reg = iopmp_read32(DMA_BASE, REG_CTRL);
    // } while (rd_ctrl_reg != 0);

    // // once it becomes zero, print
    // print_uart_addr((uint64_t)rd_ctrl_reg);
    // print_uart("\nDMA Read Transaction Successful\n");

	print_uart("\n\nDone :)\n\n");

	return 0;
}
