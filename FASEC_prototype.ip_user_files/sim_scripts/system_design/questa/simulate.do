onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -pli "/local/EDA/Xilinx/Vivado/2016.2/lib/lnx64.o/libxil_vsim.so" -lib xil_defaultlib system_design_opt

do {wave.do}

view wave
view structure
view signals

do {system_design.udo}

run -all

quit -force
