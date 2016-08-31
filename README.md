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
