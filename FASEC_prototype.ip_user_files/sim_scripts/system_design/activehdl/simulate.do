onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+system_design -pli "/local/EDA/Xilinx/Vivado/2016.2/lib/lnx64.o/libxil_vsim.so" -L unisims_ver -L unimacro_ver -L secureip -L processing_system7_bfm_v2_0_5 -L xil_defaultlib -O5 xil_defaultlib.system_design xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {system_design.udo}

run -all

endsim

quit -force
