onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -pli "/local/EDA/Xilinx/Vivado/2016.2/lib/lnx64.o/libxil_vsim.so" -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L xpm -L processing_system7_bfm_v2_0_5 -L xil_pvtmisc -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_9 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_9 -L fifo_generator_v13_1_1 -L axi_data_fifo_v2_1_8 -L axi_crossbar_v2_1_10 -L gig_ethernet_pcs_pma_v15_2_1 -L proc_common_v3_00_a -L axi_lite_ipif_v1_01_a -L lib_pkg_v1_0_2 -L lib_fifo_v1_0_5 -L lib_srl_fifo_v1_0_2 -L axi_datamover_v5_1_11 -L axi_sg_v4_1_3 -L axi_dma_v7_1_10 -L axi_protocol_converter_v2_1_9 -lib xil_defaultlib xil_defaultlib.system_design xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {system_design.udo}

run -all

quit -force
