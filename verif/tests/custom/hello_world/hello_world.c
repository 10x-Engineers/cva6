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
#include <stdarg.h>
#include "uart.h"

//IOPMP Registers
#define IOPMP_BASE 0x00200000
#define IOPMP_HWCFG0 0x0008
#define IOPMP_HWCFG1 0x000C
#define IOPMP_HWCFG2 0x0010
#define IOPMP_ERR_CFG 0x0060
#define IOPMP_ERR_INFO 0x0064
#define IOPMP_MDSTALL 0x0030
#define IOPMP_SRCMD_TABLE_OFFSET 0x1000
#define IOPMP_MDCFG_TABLE_OFFSET 0x0800
#define IOPMP_ENTRY_TABLE_OFFSET 0x10000
#define MDCFG_OFFSET 0x4
#define ENTRY_ADDR_OFFSET 0x10
#define SRCMD_EN_OFFSET 0x20


// DMA Registers
#define DMA_BASE 0x00400000
#define REG_SRC_ADDR 0x0
#define REG_DST_ADDR 0x8
#define REG_LEN 0x10
#define REG_CTRL 0x14
#define REG_STATUS 0x18
#define BULK_SIZE 0x100
// #define printf c_print


static volatile uint8_t src_buf[BULK_SIZE] __attribute__((aligned(4096)));
static volatile uint8_t dst_buf[BULK_SIZE] __attribute__((aligned(4096)));
uintptr_t src_phys = (uintptr_t)src_buf;
uintptr_t dst_phys = (uintptr_t)dst_buf;
// uint8_t tube_busy;

// void wait(unsigned int pause) {
// 	for (unsigned int i = 0; i < pause; ++i)
// 	  __asm__ volatile("nop");
// }

// int c_print_str(const char * fmt) {
// 	int i = 0;
// 	do {
// 	  write_serial(fmt[i]);
// 	  i++;
// 	} while (i < 79 && fmt[i] != '\0');
// 	tube_busy =0;
// 	return 1;
//   }
//   int c_print(const char * fmt, ...) {
// 	va_list args;
// 	int tmp, count = 0;
// 	char buffer[160];
// 	const char *parse_str = fmt;
// 	int flag = 0;
// 	while (tube_busy!=0)
// 	  wait(10);
// 	tube_busy = 1;
// 	while ((*parse_str != '\0') || (count++)) {
// 	  if ((*parse_str == '%') || (count >= 160)) {
// 		if (count == 160) {
// 		  c_print_str("String too long for printf function\n");
// 		}
// 		flag = 1;
// 		break;
// 	  }
// 	  parse_str++;
// 	}
// 	if (flag == 0) {
// 	  c_print_str(fmt);
// 	  return 0;
// 	}
// 	va_start(args, fmt);
// 	tmp = vsprintf(buffer, fmt, args);
// 	va_end(args);
// 	count = 0;
// 	do {
// 	  write_serial(buffer[count]);
// 	  count++;
// 	} while (count < 79 && buffer[count] != '\0');
// 	tube_busy =0;
// 	return tmp;
//   }

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

int compare_bufs(const uint8_t *a, const uint8_t *b, uint32_t n) {
    int mismatches = 0;
    for (uint32_t i = 0; i < n; ++i) {
        if (a[i] != b[i]) mismatches++;
    }
    return mismatches;
}

// Helper function to print buffer data
void hexdump_buf(const uint8_t *buf, uint32_t n) {
    const char *hex = "0123456789ABCDEF";
    for (uint32_t i = 0; i < n; ++i) {
        uint8_t v = buf[i];
        write_serial(hex[v >> 4]);
        write_serial(hex[v & 0xF]);
        if ((i & 0xF) == 0xF) print_uart("\n");
        else print_uart(" ");
    }
    print_uart("\n");
}

void dma_read_memory () {
	uint64_t wr_src_addr = (uint64_t)src_phys;
	iopmp_write64(DMA_BASE, REG_SRC_ADDR, wr_src_addr);
	print_uart_addr((uint64_t)src_phys);
	print_uart("\nDMA Write Successful on src_addr \n");

	uint64_t wr_dst_addr = 0x3;
	iopmp_write64(DMA_BASE, REG_DST_ADDR, wr_dst_addr);
	print_uart("\nDMA Write Successful on dst_addr \n");

	uint32_t ctrl_reg_addr = 0x1UL;
	iopmp_write32(DMA_BASE, REG_CTRL, ctrl_reg_addr);
	print_uart("\nDMA sent transaction \n\n");

	uint32_t rd_ctrl_reg;

    // keep reading until the value becomes 0
    do {
        rd_ctrl_reg = iopmp_read32(DMA_BASE, REG_CTRL);
    } while (rd_ctrl_reg != 0);

    // once it becomes zero, print
    print_uart_addr((uint64_t)rd_ctrl_reg);
    print_uart("\nDMA Read Transaction Successful\n");
}

void dma_write_memory () {

	uint64_t wr_src_addr = 0x3;
	iopmp_write64(DMA_BASE, REG_SRC_ADDR, wr_src_addr);
	print_uart("\nDMA Write Successful on src_addr \n");

	uint64_t wr_dst_addr = (uint64_t)dst_phys;
	iopmp_write64(DMA_BASE, REG_DST_ADDR, wr_dst_addr);
	print_uart_addr((uint64_t)dst_phys);
	print_uart("\nDMA Write Successful on dst_addr \n");

	uint32_t ctrl_reg_addr = 0x3UL;
	iopmp_write32(DMA_BASE, REG_CTRL, ctrl_reg_addr);
	print_uart("\nDMA sent transaction \n\n");

	uint32_t rd_ctrl_reg;
	// keep reading until the value becomes 0
    do {
        rd_ctrl_reg = iopmp_read32(DMA_BASE, REG_CTRL);
    } while (rd_ctrl_reg != 0);

	// once it becomes zero, print
    print_uart_addr((uint64_t)rd_ctrl_reg);
    print_uart("\nDMA Write Transaction Successful\n");

}

void compare_buffers () {
	print_uart("\nComparing buffers...\n");
	int mismatches = compare_bufs(src_buf, dst_buf, 8);
	if (mismatches == 0) {
		print_uart("PASS: buffers match\n");
		print_uart("Dumping first 8 bytes of dst_buf:\n");
		hexdump_buf(dst_buf, 8);
		print_uart("Dumping first 8 bytes of src_buf:\n");
		hexdump_buf(src_buf, 8);
	} else {
		print_uart("FAIL: mismatches = ");
		print_uart_addr(mismatches);
		print_uart("\n");
		print_uart("Dumping first 8 bytes of dst_buf:\n");
		hexdump_buf(dst_buf, 8);
		print_uart("Dumping first 8 bytes of src_buf:\n");
		hexdump_buf(src_buf, 8);
	}
}
	void read_err_info() {
		uint32_t err_info = iopmp_read32(IOPMP_BASE,IOPMP_ERR_INFO);
		print_uart_addr((uint64_t)err_info);
		print_uart(" <----------- Error_Info Reg Content\n\n");
	}

	void update_iopmp_settings() {
		uint32_t srcmd_en = 0x2;		// rrid-2 is associated with MD-0
		iopmp_write32(IOPMP_BASE,(SRCMD_EN_OFFSET*2)+IOPMP_SRCMD_TABLE_OFFSET, srcmd_en);
		print_uart("\nWrite Successful at SRCMD_EN Registers\n\n");

		iopmp_write32(IOPMP_BASE,(SRCMD_EN_OFFSET*2)+0x8+IOPMP_SRCMD_TABLE_OFFSET, srcmd_en);
		print_uart("\nWrite Successful at SRCMD_R Registers\n\n");

		iopmp_write32(IOPMP_BASE,(SRCMD_EN_OFFSET*2)+0x10+IOPMP_SRCMD_TABLE_OFFSET, srcmd_en);
		print_uart("\nWrite Successful at SRCMD_W Registers\n\n");

		uint32_t mdcfg_reg = 0x2;		// MD-0 is associated with Entry 0,1
		iopmp_write32(IOPMP_BASE,(MDCFG_OFFSET*0)+IOPMP_MDCFG_TABLE_OFFSET, mdcfg_reg);
		print_uart("\nWrite Successful at MDCFG Registers\n\n");

		uint32_t entry_addr = (uint64_t)src_phys >> 2;		// Entry-0 address
		iopmp_write32(IOPMP_BASE,(ENTRY_ADDR_OFFSET*0)+IOPMP_ENTRY_TABLE_OFFSET, entry_addr);
		print_uart("\nWrite Successful at ENTRY_ADDR-0 Registers\n\n");

		uint32_t entry_cfg = 0x19;		// Entry-0 read permissions
		iopmp_write32(IOPMP_BASE,(ENTRY_ADDR_OFFSET*0)+0x8+IOPMP_ENTRY_TABLE_OFFSET, entry_cfg);
		print_uart("\nWrite Successful at ENTRY_CFG-0 Registers\n\n");

		entry_addr = (uint64_t)dst_phys >> 2;		// Entry-1 address
		iopmp_write32(IOPMP_BASE,(ENTRY_ADDR_OFFSET*1)+IOPMP_ENTRY_TABLE_OFFSET, entry_addr);
		print_uart("\nWrite Successful at ENTRY_ADDR-1 Registers\n\n");

		entry_cfg = 0x1B;		// Entry-1 write permissions
		iopmp_write32(IOPMP_BASE,(ENTRY_ADDR_OFFSET*1)+0x8+IOPMP_ENTRY_TABLE_OFFSET, entry_cfg);
		print_uart("\nWrite Successful at ENTRY_CFG-1 Registers\n\n");
	}

	void stall_all_md(){
		uint32_t mdstall = 0x1UL;
		iopmp_write32(IOPMP_BASE, IOPMP_MDSTALL, mdstall);
		print_uart("\nStalled All MD's\n\n");

		uint32_t is_busy;
		// keep reading until the value becomes 0
		do {
			is_busy = iopmp_read32(DMA_BASE, IOPMP_MDSTALL);
		} while ((is_busy & 0x1 ) != 0);

		print_uart("\nIs_busy is zero, update settings\n\n");

		update_iopmp_settings();
		print_uart("\nSetting Updates Sucessful\n\n");

		mdstall = 0x0;
		iopmp_write32(IOPMP_BASE, IOPMP_MDSTALL, mdstall);
		print_uart("\nResume all transactions\n\n");

	}

int main(int argc, char* arg[]) {

	for (unsigned i = 0; i < BULK_SIZE; ++i) {
        src_buf[i] = (uint8_t)(i & 0xFF);
        dst_buf[i] = 0xEE;
    }

	dma_read_memory();
	dma_write_memory();
	compare_buffers();

	// for (unsigned i = 0; i < BULK_SIZE; ++i) {
    //     src_buf[i] = (uint8_t)((BULK_SIZE-1-i) & 0xFF);
    //     dst_buf[i] = 0xEE;
    // }

	// uint32_t enable_iopmp = 0x80000000;
	// iopmp_write32(IOPMP_BASE, IOPMP_HWCFG0, enable_iopmp);
	// print_uart("\nIOPMP Enabled  \n\n");

	// // dma_read_memory();
	// // dma_write_memory();
	// // compare_buffers();

	// // read_err_info();

	// // uint32_t clr_err_info_v = 0x1UL;
	// // iopmp_write32(IOPMP_BASE, IOPMP_ERR_INFO, clr_err_info_v);
	// // print_uart("\n Cleared Error_Info V bit\n\n");

	// // read_err_info();

	// stall_all_md();
	// dma_read_memory();
	// dma_write_memory();
	// compare_buffers();

	return 0;
}
