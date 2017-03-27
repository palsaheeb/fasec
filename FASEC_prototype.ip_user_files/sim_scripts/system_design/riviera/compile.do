vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm
vlib riviera/processing_system7_bfm_v2_0_5
vlib riviera/hdl_lib
vlib riviera/lib_cdc_v1_0_2
vlib riviera/proc_sys_reset_v5_0_9
vlib riviera/generic_baseblocks_v2_1_0
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/axi_register_slice_v2_1_9
vlib riviera/fifo_generator_v13_1_1
vlib riviera/axi_data_fifo_v2_1_8
vlib riviera/axi_crossbar_v2_1_10
vlib riviera/proc_common_v3_00_a
vlib riviera/axi_lite_ipif_v1_01_a
vlib riviera/lib_pkg_v1_0_2
vlib riviera/lib_fifo_v1_0_5
vlib riviera/lib_srl_fifo_v1_0_2
vlib riviera/axi_datamover_v5_1_11
vlib riviera/axi_sg_v4_1_3
vlib riviera/axi_dma_v7_1_10
vlib riviera/axi_lite_ipif_v3_0_4
vlib riviera/axi_uartlite_v2_0_13
vlib riviera/axi_protocol_converter_v2_1_9

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm
vmap processing_system7_bfm_v2_0_5 riviera/processing_system7_bfm_v2_0_5
vmap hdl_lib riviera/hdl_lib
vmap lib_cdc_v1_0_2 riviera/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_9 riviera/proc_sys_reset_v5_0_9
vmap generic_baseblocks_v2_1_0 riviera/generic_baseblocks_v2_1_0
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_9 riviera/axi_register_slice_v2_1_9
vmap fifo_generator_v13_1_1 riviera/fifo_generator_v13_1_1
vmap axi_data_fifo_v2_1_8 riviera/axi_data_fifo_v2_1_8
vmap axi_crossbar_v2_1_10 riviera/axi_crossbar_v2_1_10
vmap proc_common_v3_00_a riviera/proc_common_v3_00_a
vmap axi_lite_ipif_v1_01_a riviera/axi_lite_ipif_v1_01_a
vmap lib_pkg_v1_0_2 riviera/lib_pkg_v1_0_2
vmap lib_fifo_v1_0_5 riviera/lib_fifo_v1_0_5
vmap lib_srl_fifo_v1_0_2 riviera/lib_srl_fifo_v1_0_2
vmap axi_datamover_v5_1_11 riviera/axi_datamover_v5_1_11
vmap axi_sg_v4_1_3 riviera/axi_sg_v4_1_3
vmap axi_dma_v7_1_10 riviera/axi_dma_v7_1_10
vmap axi_lite_ipif_v3_0_4 riviera/axi_lite_ipif_v3_0_4
vmap axi_uartlite_v2_0_13 riviera/axi_uartlite_v2_0_13
vmap axi_protocol_converter_v2_1_9 riviera/axi_protocol_converter_v2_1_9

vlog -work xil_defaultlib -v2k5 -sv "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_base.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_dpdistram.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_dprom.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_sdpram.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_spram.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_sprom.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_tdpram.sv" \

vcom -work xpm -93 \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work processing_system7_bfm_v2_0_5 -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_arb_wr.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_arb_rd.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_arb_wr_4.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_arb_rd_4.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_arb_hp2_3.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_arb_hp0_1.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_ssw_hp.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_sparse_mem.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_reg_map.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_ocm_mem.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_intr_wr_mem.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_intr_rd_mem.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_fmsw_gp.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_regc.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_ocmc.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_interconnect_model.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_gen_reset.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_gen_clock.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_ddrc.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_axi_slave.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_axi_master.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_afi_slave.v" \
"../../../ipstatic/processing_system7_bfm_v2_0/hdl/processing_system7_bfm_v2_0_processing_system7_bfm.v" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ip/system_design_processing_system7_0_0/sim/system_design_processing_system7_0_0.v" \

vcom -work hdl_lib -93 \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v3_1_0/ip_cores/hdl_lib/modules/general/spi_transceiver.vhd" \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v3_1_0/ip_cores/hdl_lib/modules/general/doubleBufferEdge.vhd" \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v3_1_0/ip_cores/hdl_lib/modules/general/counterUpDown.vhd" \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v3_1_0/ip_cores/hdl_lib/modules/main_pkg.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v3_1_0/FASEC_hwtest.srcs/sources_1/new/dac7716_spi.vhd" \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v3_1_0/FASEC_hwtest.srcs/sources_1/new/pulseMeasure.vhd" \

vcom -work hdl_lib -93 \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v3_1_0/ip_cores/hdl_lib/modules/axi4/axi4lite_slave.vhd" \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v3_1_0/ip_cores/hdl_lib/modules/general/clockDivider.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v3_1_0/FASEC_hwtest.srcs/sources_1/new/general_fmc.vhd" \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v3_1_0/FASEC_hwtest.srcs/sources_1/new/top_mod.vhd" \
"../../../bd/system_design/ip/system_design_fasec_hwtest_0_0/sim/system_design_fasec_hwtest_0_0.vhd" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../ipstatic/lib_cdc_v1_0/hdl/src/vhdl/cdc_sync.vhd" \

vcom -work proc_sys_reset_v5_0_9 -93 \
"../../../ipstatic/proc_sys_reset_v5_0/hdl/src/vhdl/upcnt_n.vhd" \
"../../../ipstatic/proc_sys_reset_v5_0/hdl/src/vhdl/sequence_psr.vhd" \
"../../../ipstatic/proc_sys_reset_v5_0/hdl/src/vhdl/lpf.vhd" \
"../../../ipstatic/proc_sys_reset_v5_0/hdl/src/vhdl/proc_sys_reset.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ip/system_design_rst_processing_system7_0_100M_2/sim/system_design_rst_processing_system7_0_100M_2.vhd" \

vlog -work generic_baseblocks_v2_1_0 -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_carry_and.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_carry_latch_and.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_carry_latch_or.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_carry_or.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_carry.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_command_fifo.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_comparator_mask_static.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_comparator_mask.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_comparator_sel_mask_static.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_comparator_sel_mask.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_comparator_sel_static.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_comparator_sel.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_comparator_static.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_comparator.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_mux_enc.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_mux.v" \
"../../../ipstatic/generic_baseblocks_v2_1/hdl/verilog/generic_baseblocks_v2_1_nto1_mux.v" \

vlog -work axi_infrastructure_v1_1_0 -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog/axi_infrastructure_v1_1_axi2vector.v" \
"../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog/axi_infrastructure_v1_1_axic_srl_fifo.v" \
"../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog/axi_infrastructure_v1_1_vector2axi.v" \

vlog -work axi_register_slice_v2_1_9 -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/axi_register_slice_v2_1/hdl/verilog/axi_register_slice_v2_1_axic_register_slice.v" \
"../../../ipstatic/axi_register_slice_v2_1/hdl/verilog/axi_register_slice_v2_1_axi_register_slice.v" \

vlog -work fifo_generator_v13_1_1 -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/fifo_generator_v13_1/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_1_1 -93 \
"../../../ipstatic/fifo_generator_v13_1/hdl/fifo_generator_v13_1_rfs.vhd" \

vlog -work fifo_generator_v13_1_1 -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/fifo_generator_v13_1/hdl/fifo_generator_v13_1_rfs.v" \

vlog -work axi_data_fifo_v2_1_8 -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_axic_fifo.v" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_fifo_gen.v" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_axic_srl_fifo.v" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_axic_reg_srl_fifo.v" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_ndeep_srl.v" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_axi_data_fifo.v" \

vlog -work axi_crossbar_v2_1_10 -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_addr_arbiter_sasd.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_addr_arbiter.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_addr_decoder.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_arbiter_resp.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_crossbar_sasd.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_crossbar.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_decerr_slave.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_si_transactor.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_splitter.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_wdata_mux.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_wdata_router.v" \
"../../../ipstatic/axi_crossbar_v2_1/hdl/verilog/axi_crossbar_v2_1_axi_crossbar.v" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ip/system_design_xbar_0/sim/system_design_xbar_0.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/xilinx.com/xlconstant_v1_1/xlconstant.vhd" \
"../../../bd/system_design/ip/system_design_xlconstant_3_2/sim/system_design_xlconstant_3_2.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/proc_common_v3_30_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_conv_funs_pkg.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/proc_common_v3_30_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_proc_common_pkg.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/proc_common_v3_30_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_ipif_pkg.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/proc_common_v3_30_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_family_support.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/proc_common_v3_30_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_family.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/proc_common_v3_30_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_soft_reset.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/proc_common_v3_30_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_pselect_f.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/axi_lite_ipif_v1_01_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_address_decoder.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/axi_lite_ipif_v1_01_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_slave_attachment.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/interrupt_control_v2_01_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_interrupt_control.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/axi_lite_ipif_v1_01_a/hdl/src/vhdl/system_design_xadc_wiz_0_0_axi_lite_ipif.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/system_design_xadc_wiz_0_0_drp_arbiter.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/system_design_xadc_wiz_0_0_drp_to_axi_stream.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/system_design_xadc_wiz_0_0_xadc_core_drp.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/system_design_xadc_wiz_0_0_axi_xadc.vhd" \
"../../../bd/system_design/ip/system_design_xadc_wiz_0_0/system_design_xadc_wiz_0_0.vhd" \

vcom -work proc_common_v3_00_a -93 \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/proc_common_pkg.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/family_support.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/pselect_f.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/ipif_pkg.vhd" \

vcom -work axi_lite_ipif_v1_01_a -93 \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/address_decoder.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/slave_attachment.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/axi_lite_ipif.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/hdl/xadc_axis_fifo_adapter.vhd" \
"../../../bd/system_design/ip/system_design_xadc_axis_fifo_adapter_0_0/sim/system_design_xadc_axis_fifo_adapter_0_0.vhd" \

vcom -work lib_pkg_v1_0_2 -93 \
"../../../ipstatic/lib_pkg_v1_0/hdl/src/vhdl/lib_pkg.vhd" \

vcom -work lib_fifo_v1_0_5 -93 \
"../../../ipstatic/lib_fifo_v1_0/hdl/src/vhdl/async_fifo_fg.vhd" \
"../../../ipstatic/lib_fifo_v1_0/hdl/src/vhdl/sync_fifo_fg.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -93 \
"../../../ipstatic/lib_srl_fifo_v1_0/hdl/src/vhdl/cntr_incr_decr_addn_f.vhd" \
"../../../ipstatic/lib_srl_fifo_v1_0/hdl/src/vhdl/dynshreg_f.vhd" \
"../../../ipstatic/lib_srl_fifo_v1_0/hdl/src/vhdl/srl_fifo_rbu_f.vhd" \
"../../../ipstatic/lib_srl_fifo_v1_0/hdl/src/vhdl/srl_fifo_f.vhd" \

vcom -work axi_datamover_v5_1_11 -93 \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_reset.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_afifo_autord.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_sfifo_autord.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_fifo.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_cmd_status.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_scc.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_strb_gen2.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_pcc.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_addr_cntl.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_rdmux.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_rddata_cntl.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_rd_status_cntl.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_wr_demux.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_wrdata_cntl.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_wr_status_cntl.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_skid2mm_buf.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_skid_buf.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_rd_sf.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_wr_sf.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_stbs_set.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_stbs_set_nodre.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_ibttcc.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_indet_btt.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_dre_mux2_1_x_n.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_dre_mux4_1_x_n.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_dre_mux8_1_x_n.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_mm2s_dre.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_s2mm_dre.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_ms_strb_set.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_mssai_skid_buf.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_slice.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_s2mm_scatter.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_s2mm_realign.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_s2mm_basic_wrap.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_s2mm_omit_wrap.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_s2mm_full_wrap.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_mm2s_basic_wrap.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_mm2s_omit_wrap.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover_mm2s_full_wrap.vhd" \
"../../../ipstatic/axi_datamover_v5_1/hdl/src/vhdl/axi_datamover.vhd" \

vcom -work axi_sg_v4_1_3 -93 \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_pkg.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_reset.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_sfifo_autord.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_afifo_autord.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_fifo.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_cmd_status.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_rdmux.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_addr_cntl.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_rddata_cntl.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_rd_status_cntl.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_scc.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_wr_demux.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_scc_wr.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_skid2mm_buf.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_wrdata_cntl.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_wr_status_cntl.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_skid_buf.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_mm2s_basic_wrap.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_s2mm_basic_wrap.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_datamover.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_ftch_sm.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_ftch_pntr.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_ftch_cmdsts_if.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_ftch_mngr.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_cntrl_strm.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_ftch_queue.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_ftch_noqueue.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_ftch_q_mngr.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_updt_cmdsts_if.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_updt_sm.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_updt_mngr.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_updt_queue.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_updt_noqueue.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_updt_q_mngr.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg_intrpt.vhd" \
"../../../ipstatic/axi_sg_v4_1/hdl/src/vhdl/axi_sg.vhd" \

vcom -work axi_dma_v7_1_10 -93 \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_pkg.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_reset.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_rst_module.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_lite_if.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_register.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_register_s2mm.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_reg_module.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_skid_buf.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_afifo_autord.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_s2mm.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_sofeof_gen.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_smple_sm.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_mm2s_sg_if.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_mm2s_sm.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_mm2s_cmdsts_if.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_mm2s_sts_mngr.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_mm2s_cntrl_strm.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_mm2s_mngr.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_s2mm_sg_if.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_s2mm_sm.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_s2mm_cmdsts_if.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_s2mm_sts_mngr.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_s2mm_sts_strm.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_s2mm_mngr.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma_cmd_split.vhd" \
"../../../ipstatic/axi_dma_v7_1/hdl/src/vhdl/axi_dma.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ip/system_design_axi_dma_0_0/sim/system_design_axi_dma_0_0.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xlconcat_v2_1/xlconcat.vhd" \
"../../../bd/system_design/ip/system_design_xlconcat_0_0/sim/system_design_xlconcat_0_0.vhd" \

vlog -work fifo_generator_v13_1_1 -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ip/system_design_wrc_1p_kintex7_0_0/ip_cores/xilinx_ip/mux_buffering_fifo/sim/mux_buffering_fifo.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/genram_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/memory_loader_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wishbone_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/lm32_sw/wrc.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/fabric/wr_fabric_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/xilinx/generic_dpram_sameclock.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/xilinx/generic_dpram_dualclock.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/xilinx/lm32_dpram_sameclock.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/endpoint_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_registers_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/xilinx/generic_dpram.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/common/gencores_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/endpoint_private_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/inferred_sync_fifo.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/inferred_async_fifo.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wbgen2/wbgen2_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_crc32_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_sync_detect.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_sync_detect_16bit.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/common/gc_crc_gen.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/common/gc_extend_pulse.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/common/gc_sync_ffs.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/common/gc_pulse_synchronizer.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/xilinx/gc_shiftreg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/generic/generic_async_fifo.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/generic/generic_sync_fifo.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_uart/simple_uart_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/timing/dmtd_with_deglitcher.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_mini_nic/minic_wbgen2_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_softpll_ng/spll_wbgen2_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_tx_pcs_8bit.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_tx_pcs_16bit.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rx_pcs_16bit.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_autonegotiation.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_pcs_tbi_mdio_wb.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rx_wb_master.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rx_oob_insert.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rx_early_address_match.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_clock_alignment_fifo.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_packet_filter.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rx_vlan_unit.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_ts_counter.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rx_status_reg_insert.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rtu_header_extract.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rx_buffer.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rx_pcs_8bit.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rx_crc_size_check.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_tx_header_processor.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_tx_crc_inserter.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_tx_inject_ctrl.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_tx_packet_injection.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_tx_vlan_unit.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/generic_shiftreg_fifo.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/genrams/xilinx/generic_simple_dpram.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_onewire_master/sockit_owm.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_uart/uart_async_rx.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_uart/uart_async_tx.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_uart/uart_baud_gen.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_uart/simple_uart_wb.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/src/lm32_addsub.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_slave_adapter/wb_slave_adapter.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wbgen2/wbgen2_eic.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wbgen2/wbgen2_fifo_sync.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/platform/artix7/jtag_tap.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wrc_core_2p/wrc_syscon_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/common/gc_pulse_synchronizer2.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/timing/dmtd_phase_meas.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_softpll_ng/softpll_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_softpll_ng/spll_wb_slave.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_1000basex_pcs.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_rx_path.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_timestamping_unit.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_leds_controller.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_wishbone_controller.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_pps_gen/pps_gen_wb.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/ep_tx_path.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_onewire_master/wb_onewire_master.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_uart/wb_simple_uart.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/src/jtag_cores.v" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/src/lm32_adder.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/src/lm32_dp_ram.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/src/lm32_logic_op.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/src/lm32_ram.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/src/lm32_shifter.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_mini_nic/minic_wb_slave.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/platform/artix7/lm32_multiplier.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wrc_core_2p/wrc_syscon_wb.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_softpll_ng/spll_aligner.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/common/gc_frequency_meter.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/gen7s-cores/modules/gen7s_cores_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_softpll_ng/wr_softpll_ng.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/wr_endpoint.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_pps_gen/wr_pps_gen.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_mini_nic/wr_mini_nic.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_onewire_master/xwb_onewire_master.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_uart/xwb_simple_uart.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_crossbar/sdb_rom.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_crossbar/xwb_crossbar.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wrc_core_2p/xwr_syscon_wb.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/generated/lm32_allprofiles.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wrc_core_2p/wrcore_2p_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/fabric/xwrf_mux.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_mini_nic/xwr_mini_nic.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_softpll_ng/xwr_softpll_ng.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_endpoint/xwr_endpoint.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_pps_gen/xwr_pps_gen.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_dpram/xwb_dpram.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_spi/spi_clgen.v" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_spi/spi_shift.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_crossbar/xwb_sdb_crossbar.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/generated/xwb_lm32.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wrc_core_2p/wrc_periph.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/wr-cores/modules/wrc_core/wrcore_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_tbi_phy/disparity_gen_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_dacs/spec_serial_dac.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_spi/spi_top.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/gen7s-cores/modules/pll_ad9516_spi/PLL_SPI_ctrl_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wrc_core/wr_core.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/wr-cores/platform/xilinx/wr_gtp_phy/whiterabbit_gtxe2_channel_wrapper_gt.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_dacs/spec_serial_dac_arb.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/platform/xilinx/wr_gtp_phy_artix7/wr_a7_gtps_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/gen7s-cores/modules/common/ext_pll_10_to_62_compensated.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/wr-cores/modules/wrc_core/xwr_core.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/wr-cores/platform/xilinx/wr_gtp_phy/wr_gtx_phy_kintex7.vhd" \

vcom -work hdl_lib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/hdl_lib/modules/general/doubleBuffer.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/hdl_lib/modules/general/doubleBufferVector.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/hdl_lib/modules/general/shiftRegister.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_spi/spi_defines.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_si57x_interface/si570_if_wbgen2_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_eca/eca_pkg.vhd" \

vcom -work hdl_lib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/hdl_lib/modules/axi4/axis_wbm_bridge.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_irq/wb_irq_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/modules/wr_tlu/wb_cores_pkg_gsi.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_simple_pwm/simple_pwm_wbgen2_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/platform/xilinx/wb_xilinx_fpga_loader/xloader_registers_pkg.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/platform/xilinx/wr_gtp_phy_artix7/gtp_serie7_wrapper/gtpe_sync_block.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/platform/xilinx/wr_gtp_phy_artix7/gtp_serie7_wrapper/gtpe_gtrxreset_seq.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/platform/xilinx/wr_gtp_phy_artix7/gtp_serie7_wrapper/gtp2p_wizard_sync_pulse.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/platform/xilinx/wr_gtp_phy_artix7/gtp_serie7_wrapper/gtpe_channel_gt.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/platform/xilinx/wr_gtp_phy_artix7/gtp_serie7_wrapper/gtp2p_wizard_tx_manual_phase_align.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/platform/xilinx/wr_gtp_phy_artix7/gtp_serie7_wrapper/whiterabbit_gtpe_2pchannel_wrapper_gt.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/platform/xilinx/wr_gtp_phy_artix7/gtp_serie7_wrapper/wr_gtp_phy_artix7.vhd" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_lm32/src/lm32_include.v" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/general-cores/modules/wishbone/wb_spi/timescale.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/ip_cores/wr-cores/platform/xilinx/wr_gtp_phy/gtp_bitslide.vhd" \
"../../../bd/system_design/ipshared/cern/wrc_1p_kintex7_v3_1_0/top/wrc-1p-kintex7/wrc_1p_kintex7_top.vhd" \
"../../../bd/system_design/ip/system_design_wrc_1p_kintex7_0_0/sim/system_design_wrc_1p_kintex7_0_0.vhd" \

vcom -work axi_lite_ipif_v3_0_4 -93 \
"../../../ipstatic/axi_lite_ipif_v3_0/hdl/src/vhdl/ipif_pkg.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0/hdl/src/vhdl/pselect_f.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0/hdl/src/vhdl/address_decoder.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0/hdl/src/vhdl/slave_attachment.vhd" \
"../../../ipstatic/axi_lite_ipif_v3_0/hdl/src/vhdl/axi_lite_ipif.vhd" \

vcom -work axi_uartlite_v2_0_13 -93 \
"../../../ipstatic/axi_uartlite_v2_0/hdl/src/vhdl/dynshreg_i_f.vhd" \
"../../../ipstatic/axi_uartlite_v2_0/hdl/src/vhdl/uartlite_tx.vhd" \
"../../../ipstatic/axi_uartlite_v2_0/hdl/src/vhdl/uartlite_rx.vhd" \
"../../../ipstatic/axi_uartlite_v2_0/hdl/src/vhdl/baudrate.vhd" \
"../../../ipstatic/axi_uartlite_v2_0/hdl/src/vhdl/uartlite_core.vhd" \
"../../../ipstatic/axi_uartlite_v2_0/hdl/src/vhdl/axi_uartlite.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/system_design/ip/system_design_axi_uartlite_0_0/sim/system_design_axi_uartlite_0_0.vhd" \
"../../../bd/system_design/ip/system_design_xlconstant_6_0/sim/system_design_xlconstant_6_0.vhd" \
"../../../bd/system_design/ipshared/cern.ch/axi_wb_i2c_master_v3_1_1/modules/i2c_master_bit_ctrl.vhd" \
"../../../bd/system_design/ipshared/cern.ch/axi_wb_i2c_master_v3_1_1/modules/i2c_master_byte_ctrl.vhd" \
"../../../bd/system_design/ipshared/cern.ch/axi_wb_i2c_master_v3_1_1/modules/i2c_master_top.vhd" \
"../../../bd/system_design/ipshared/cern.ch/axi_wb_i2c_master_v3_1_1/modules/axis_to_i2c_wbs.vhd" \
"../../../bd/system_design/ipshared/cern.ch/axi_wb_i2c_master_v3_1_1/sim/axis_to_i2c_wbs_tb.vhd" \
"../../../bd/system_design/ip/system_design_axi_wb_i2c_master_2_0/sim/system_design_axi_wb_i2c_master_2_0.vhd" \
"../../../bd/system_design/ip/system_design_axi_wb_i2c_master_0_1/sim/system_design_axi_wb_i2c_master_0_1.vhd" \
"../../../bd/system_design/ip/system_design_rst_wrc_1p_kintex7_0_62M_0/sim/system_design_rst_wrc_1p_kintex7_0_62M_0.vhd" \
"../../../bd/system_design/hdl/system_design.vhd" \

vlog -work axi_protocol_converter_v2_1_9 -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_a_axi3_conv.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_axi3_conv.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_axilite_conv.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_r_axi3_conv.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_w_axi3_conv.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b_downsizer.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_decerr_slave.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s_simple_fifo.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s_wrap_cmd.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s_incr_cmd.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s_wr_cmd_fsm.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s_rd_cmd_fsm.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s_cmd_translator.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s_b_channel.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s_r_channel.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s_aw_channel.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s_ar_channel.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_b2s.v" \
"../../../ipstatic/axi_protocol_converter_v2_1/hdl/verilog/axi_protocol_converter_v2_1_axi_protocol_converter.v" \

vlog -work xil_defaultlib -v2k5 "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ip/system_design_auto_pc_0/sim/system_design_auto_pc_0.v" \
"../../../bd/system_design/ip/system_design_auto_pc_1/sim/system_design_auto_pc_1.v" \
"../../../bd/system_design/ip/system_design_auto_pc_2/sim/system_design_auto_pc_2.v" \

vlog -work xil_defaultlib "glbl.v"

