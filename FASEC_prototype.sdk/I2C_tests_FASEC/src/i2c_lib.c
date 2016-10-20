/******************************************************************************
*
* Copyright (C) CERN, 2016
* Pieter Van Trappen
* CERN TE-ABT-EC
* Licence: GPL v2 or later
*
******************************************************************************/

#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"

// I2C OC registers
#define PREL	0x0		// clock prescale low
#define PREH	0x1		// clock prescale high
#define CTR		0x2		// control register
#define TXR		0x3		// transmit register (W)
#define RXR		0x3		// receive register (R)
#define CR		0x4		// command register (W)
#define SR		0x4		// status register (R)
// masks
#define CTR_EN 7
#define CR_STA 7
#define CR_STO 6
#define CR_RD 5
#define CR_WR 4
#define CR_ACK 3
#define SR_RXACK 7
#define SR_TIP 1
// misc
#define TIMEOUT 2000	// high timeout needed because of I2C clock = 100 kHz

u32 i2c_readReg(u32 base, u32 addr){
	return Xil_In32(base + (addr<<2));
}
void i2c_writeReg(u32 base, u32 addr, u32 val){
	Xil_Out32(base + (addr<<2), val);
}

int waitTransfer(u32 base){
	int i;
	for(i=TIMEOUT;i!=0;i--){
		if ((i2c_readReg(base, SR) & 1<<SR_TIP) == 0x0){
//			usleep(100);	// sleep 100 us otherwise spurious 'no RxACK' -- no influence
			return 0;
		}
	}
	print("ERROR: transfer not completed\n\r");
	i2c_writeReg(base, CR, 1<<CR_STO);	// stop signal to abort data transfer
	return (i==0)?1:0;	// return 0 when success
}

int waitAck(u32 base){
	if ((i2c_readReg(base, SR) & 1<<SR_RXACK) != 0x0){
		print("ERROR: no byte RxACK from slave seen!\n\r");
		i2c_writeReg(base, CR, 1<<CR_STO);	// stop signal to abort data transfer
		return 2;
	} else{
		return 0;
	}
}
int OCI2C_init(u32 base){
	if ((i2c_readReg(base, CTR) & 1<<CTR_EN) == 1<<CTR_EN)
		i2c_writeReg(base, CTR, 0<<CTR_EN);	// disable EN bit so we can set the prescale value
	i2c_writeReg(base, PREL, 0xC8);	// 100MHz/(5*0.1MHz)
	i2c_writeReg(base, PREH, 0x00);
	print("prescale value set \n\r");
	i2c_writeReg(base, CTR, 1<<CTR_EN);	// enable core without interrupts
	return 0;
}

void OCI2C_print_regs(u32 base, u32 start, u32 end){
	int i;
	print("** OCI2C register print starting **\n\r");
	for (i=start; i<end+1;i++){
		printf("I2C master register %#010x: %#010x \n\r", (unsigned int)base + (i<<2),
				(unsigned int)i2c_readReg(base, i));
	}
	print("OCI2C register print finished \n\r");
}

u32 readReg_24AA64(u32 base, u8 slave, u8 readAddrH, u8 readAddrL){
	// send control byte (write)
	i2c_writeReg(base, TXR, slave<<1 | 0x0);	// address & write-bit
	i2c_writeReg(base, CR, 1<<CR_STA | 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
	// send read-addresses high
//		print("sending read address high\n\r");
	if (waitAck(base)!=0)
		return 2;
	i2c_writeReg(base, TXR, readAddrH);
	i2c_writeReg(base, CR, 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
	// send read-addresses low
//		print("sending read address low\n\r");
	if (waitAck(base)!=0)
		return 2;
	i2c_writeReg(base, TXR, readAddrL);
	i2c_writeReg(base, CR, 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
	// send control byte (read)
//		print("sending control byte for reading\n\r");
	if (waitAck(base)!=0)
		return 2;
	i2c_writeReg(base, TXR, slave<<1 | 0x1);	// address & read-bit
	i2c_writeReg(base, CR, 1<<CR_STA | 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
	// send CR byte to prepare read
//		print("reading ...\n\r");
	if (waitAck(base)!=0)
		return 2;
	i2c_writeReg(base, CR, 1<<CR_RD | 1<<CR_ACK | 1<<CR_STO);
	if (waitTransfer(base)!=0)
		return 1;
	// read output
	return i2c_readReg(base, RXR);
}

u32 readReg_mcp23017(u32 base, u8 slave, u8 readAddr){
//		print("sending control byte - write\n\r");
	i2c_writeReg(base, TXR, slave<<1 | 0x0);	// address & write-bit
	i2c_writeReg(base, CR, 1<<CR_STA | 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
//		print("sending read address\n\r");
	if (waitAck(base)!=0)
		return 2;
	i2c_writeReg(base, TXR, readAddr);
	i2c_writeReg(base, CR, 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
//		print("sending control byte for reading\n\r");
	if (waitAck(base)!=0)
		return 2;
	i2c_writeReg(base, TXR, slave<<1 | 0x1);	// address & read-bit
	i2c_writeReg(base, CR, 1<<CR_STA | 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
//		print("reading ...\n\r");
	if (waitAck(base)!=0)
		return 2;
	i2c_writeReg(base, CR, 1<<CR_RD | 1<<CR_ACK | 1<<CR_STO);
	if (waitTransfer(base)!=0)
		return 1;
	// read output
	return i2c_readReg(base, RXR);
}

int writeReg_mcp23017(u32 base, u8 slave, u8 writeAddr, u8 val){
	/*
	 * IOCON all 0 by default, hence:
	 *  same bank reg - sequential regs
	 *  address pointer increments
	 */
//		print("sending control byte - write\n\r");
	i2c_writeReg(base, TXR, slave<<1 | 0x0);	// address & write-bit
	i2c_writeReg(base, CR, 1<<CR_STA | 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
//		print("sending write address\n\r");
	if (waitAck(base)!=0)
		return 2;
	i2c_writeReg(base, TXR, writeAddr);
	i2c_writeReg(base, CR, 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
//		print("sending control byte for writing\n\r");
	if (waitAck(base)!=0)
		return 2;
	i2c_writeReg(base, TXR, slave<<1 | 0x0);	// address & write-bit
	i2c_writeReg(base, CR, 1<<CR_STA | 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
//		print("sending data byte for write ...\n\r");
	if (waitAck(base)!=0)
		return 2;
	i2c_writeReg(base,TXR,val);
	i2c_writeReg(base, CR, 1<<CR_STO | 1<<CR_WR);
	if (waitTransfer(base)!=0)
		return 1;
	if (waitAck(base)!=0)
		return 2;
	// finished
	return 0;
}
