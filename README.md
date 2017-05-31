# FASEC prototype project
This Vivado 2016.2 project incorperates several cores (see te-abt-ec/cores
repo) and its aim is to fully test the FASEC card
[http://www.ohwr.org/projects/fasec/wiki](http://www.ohwr.org/projects/fasec/wiki). The
design is modular and by using AXI4-Lite slaves the XADC, FMC-slots, etc. will
be tested. Several FMCs are being used to validate the full design.

## Hardware testing
The following has been tested so far:
* DDR3 full range
* FMCs I2C bus
* PL output LEDs
...

The project itself is not uploaded, to recreate it after cloning the repo:
$ git submodule init
$ git submodule update --recursive
$ vivado -mode batch -source syn/fasec_prototype_project-generation.tcl

Now the project can be openend with Vivado. There's a hacky script to update
some fasec_hwtest AXI4-Lite registers to include build time and commit
number. To use, run bitstream generation as follows from the Tcl Console:
> cd [get_property DIRECTORY [current_project]]; source FASEC_prototype.srcs/tcl/set_registers.tcl
