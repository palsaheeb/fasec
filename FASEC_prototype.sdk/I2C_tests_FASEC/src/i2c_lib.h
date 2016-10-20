/******************************************************************************
*
* Copyright (C) CERN, 2016
* Pieter Van Trappen
* CERN TE-ABT-EC
* Licence: GPL v2 or later
*
******************************************************************************/

#ifndef SRC_I2C_LIB_H_
#define SRC_I2C_LIB_H_

#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"

u32 i2c_readReg(u32 base, u32 addr);
void i2c_writeReg(u32 base, u32 addr, u32 val);
int waitTransfer(u32 base);
int waitAck(u32 base);
int OCI2C_init(u32 base);
void OCI2C_print_regs(u32 base, u32 start, u32 end);
u32 readReg_24AA64(u32 base, u8 slave, u8 readAddrH, u8 readAddrL);
u32 readReg_mcp23017(u32 base, u8 slave, u8 readAddr);
int writeReg_mcp23017(u32 base, u8 slave, u8 writeAddr, u8 val);


#endif /* SRC_I2C_LIB_H_ */
