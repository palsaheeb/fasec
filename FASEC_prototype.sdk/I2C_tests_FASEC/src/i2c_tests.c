/******************************************************************************
*
* Copyright (C) CERN, 2016
* Pieter Van Trappen
* CERN TE-ABT-EC
* Licence: GPL v2 or later
*
******************************************************************************/

/*
 * i2c_tests.c: FASEC I2C tests, specifically for the EDA02327 Tester FMC
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"
#include "limits.h"
#include "i2c_lib.h"

#define OCI2CBASEFMC	0x43c00000		// I2C core for FMC1-2 I2C bus
#define OCI2CBASEFE		0x43c10000		// I2C core for FASEC EEPROM
#define FHWTEST			0x43c20000		// FASEC HW-TEST core base
#define OCI2CF1TEST		0x43c30000		// FMC1 TESTER EDA-2327
#define OCI2CF2TEST		0x43c40000		// FMC2 TESTER EDA-2327

// FMC Tester addressing
#define FT_IC2		0x24
#define FT_IC1		0x27
#define FHWTEST_FMC1	0x0
#define FHWTEST_FMC2	0x4

u32 readReg(u32 base, u32 addr){
	return Xil_In32(base + (addr<<2));
}
void writeReg(u32 base, u32 addr, u32 val){
	Xil_Out32(base + (addr<<2), val);
}

int main()
{
	u32 readVal;
	u32 readAddrH;
	int i;
	char inputChar;
	u8 slave_addr;
	u32 oic_base;

	// init platform and all OCI2C cores
    init_platform();
	OCI2C_init(OCI2CBASEFMC);
	OCI2C_init(OCI2CBASEFE);
	OCI2C_init(OCI2CF1TEST);
	OCI2C_init(OCI2CF2TEST);

	// start values
	oic_base = OCI2CBASEFMC;
	slave_addr = 0x50;	// for FMC1 with GA=00

	// user menu
	print("Menu enabled, use keyboard input\n\r");
	for (;;){
		setvbuf(stdin, NULL, _IONBF, 0);	// unbuffered stdin to avoid having to hit enter after char
		inputChar = getchar();
		if (inputChar=='a'){
			xil_printf("I2C cores: 1- FMC1-2; 2- FASEC EEPROM; 3- FMC1 TESTER; 4- FMC2 TESTER\n\r");
			setvbuf(stdin, NULL, _IONBF, 0);	// unbuffered stdin to avoid having to hit enter after char
			inputChar = getchar();
			if (inputChar=='2')
				oic_base = OCI2CBASEFE;	// needs slave addr 0x50
			else if (inputChar=='3')
				oic_base = OCI2CF1TEST;
			else if (inputChar=='4')
				oic_base = OCI2CF2TEST;
			else
				oic_base = OCI2CBASEFMC;
			printf("OCI2C core set to %#10x \n\r", (unsigned int)oic_base);
		} else if (inputChar=='r'){
			// read 12 first bytes when addressing EEPROM
			if( oic_base!=OCI2CBASEFE && oic_base!=OCI2CBASEFMC ){
				xil_printf("Incorrect I2C core, ignoring...\n\r");
			} else{
				readAddrH = 0x0;
				xil_printf("-----------------------------------\n\r");
				for (i=0;i<12;i++){
					readVal = readReg_24AA64(oic_base, slave_addr,readAddrH,(u8)i);
					printf("EEPROM register %#06x: %#04x \n\r", (unsigned int)(readAddrH<<8 | i), (unsigned int)readVal);
				}
				xil_printf("-----------------------------------\n\r");
			}
		} else if (inputChar=='s'){
			if (slave_addr==0x50)
				slave_addr=0x52;
			else
				slave_addr=0x50;
			printf("EEPROM slave address now %#04x \n\r", (unsigned int)slave_addr);
		}else if (inputChar=='e'){
			xil_printf("exiting from main..\n\r");
			return 0;
		}else if (inputChar=='t'){
			// FMC1 slot depends on I2C-core selection 'a'
			slave_addr = FT_IC2;
			xil_printf("-----------------------------------\n\r");
			for (i=0;i<4;i++){
				readVal = readReg_mcp23017(oic_base, slave_addr,(u8)i);
				printf("FMC1 MCP23017 register %#04x: %#04x \n\r", (unsigned int)i, (unsigned int)readVal);
			}
			xil_printf("-----------------------------------\n\r");
		}else if (inputChar=='h'){
			xil_printf("-----------------------------------\n\r");
			for (i=0; i<8;i++){
				printf("FASEC HW-TEST core register %#010x: %#010x \n\r", (unsigned int)FHWTEST + (i<<2),
					(unsigned int)readReg(FHWTEST, i));
			}
			xil_printf("-----------------------------------\n\r");
		} else if(inputChar=='w'){
			// FMC1 slot depends on I2C-core selection 'a'
			slave_addr = FT_IC2;
			// enabling 2 LSB outputs (IODIRB)
			writeReg_mcp23017(oic_base, slave_addr,0x01,0xfc);
			// writing counter value
			writeReg_mcp23017(oic_base, slave_addr,0x13,0x00);
			xil_printf("write finished\n\r");
		} else if(inputChar=='c'){
			//TODO: use a 0x01 shift operation to verify all lines
			//TODO: add word 2 and 3, however some high-Z needed!!
			//TODO: stop test if I2C error thrown
			u32 cntr, cntr_min, cntr_max;
			cntr_min = 0xfffff000;
			cntr_max = 0xffffffff;
			xil_printf("starting counter test (%d values, might take a while)...\n\r", cntr_max-cntr_min);
			for (cntr=cntr_min; cntr<cntr_max; cntr++){	// 0-4294967295
				// send lower 16 bits
				slave_addr = FT_IC2;
				// enabling 8 LSB outputs (IODIRB); 8 MSB outputs (IODIRA)
				writeReg_mcp23017(oic_base, slave_addr,0x01,0x00);
				writeReg_mcp23017(oic_base, slave_addr,0x00,0x00);
				// writing 16 LSB counter value
				writeReg_mcp23017(oic_base, slave_addr,0x13,(cntr&0x00ff));
				writeReg_mcp23017(oic_base, slave_addr,0x12,(cntr&0xff00)>>8);
				// send lower 16 bits
				slave_addr = FT_IC1;
				// enabling 8 LSB outputs (IODIRB); 8 MSB outputs (IODIRA)
				writeReg_mcp23017(oic_base, slave_addr,0x01,0x00);
				writeReg_mcp23017(oic_base, slave_addr,0x00,0x00);
				// writing 32-16 bits counter value
				writeReg_mcp23017(oic_base, slave_addr,0x13,(cntr&0x00ff0000)>>16);
				writeReg_mcp23017(oic_base, slave_addr,0x12,(cntr&0xff000000)>>24);
				// sleep for comm and propagation delays
				usleep(1000);
				i = (oic_base==OCI2CF1TEST)?FHWTEST_FMC1:FHWTEST_FMC2;
				if (cntr!=readReg(FHWTEST, i+1))
					printf("counter value sent (I2C) vs read (FPGA): %u vs %u\n\r", cntr, readReg(FHWTEST, i+1));
			}
			xil_printf("write test done, successful if no errors thrown\n\r");
		}
		else{
			xil_printf("Help Menu \n\r");
			xil_printf("--------- \n\r");
			xil_printf("a: change I2C-core address\n\r");
			xil_printf("r: read first 12 bytes from EEPROM \n\r");
			xil_printf("e: exit from main() \n\r");
			xil_printf("s: swap between FMC1-2 EEPROM addresses\n\r");
			xil_printf("t: Tester FMCs, read bytes from IC2\n\r");
			xil_printf("h: Read bytes from FASEC HW-TEST core\n\r");
			xil_printf("w: write to Tester FMCs\n\r");
			xil_printf("c: start Tester FMC line counter validation\n\r");
		}
	}

    cleanup_platform();
    return 0;
}
