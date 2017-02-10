vlib work
vlib msim

vlib msim/xil_defaultlib
vlib msim/xpm
vlib msim/processing_system7_bfm_v2_0_5
vlib msim/xil_pvtmisc
vlib msim/lib_cdc_v1_0_2
vlib msim/proc_sys_reset_v5_0_9
vlib msim/generic_baseblocks_v2_1_0
vlib msim/axi_infrastructure_v1_1_0
vlib msim/axi_register_slice_v2_1_9
vlib msim/fifo_generator_v13_1_1
vlib msim/axi_data_fifo_v2_1_8
vlib msim/axi_crossbar_v2_1_10
vlib msim/gig_ethernet_pcs_pma_v15_2_1
vlib msim/proc_common_v3_00_a
vlib msim/axi_lite_ipif_v1_01_a
vlib msim/lib_pkg_v1_0_2
vlib msim/lib_fifo_v1_0_5
vlib msim/lib_srl_fifo_v1_0_2
vlib msim/axi_datamover_v5_1_11
vlib msim/axi_sg_v4_1_3
vlib msim/axi_dma_v7_1_10
vlib msim/axi_protocol_converter_v2_1_9

vmap xil_defaultlib msim/xil_defaultlib
vmap xpm msim/xpm
vmap processing_system7_bfm_v2_0_5 msim/processing_system7_bfm_v2_0_5
vmap xil_pvtmisc msim/xil_pvtmisc
vmap lib_cdc_v1_0_2 msim/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_9 msim/proc_sys_reset_v5_0_9
vmap generic_baseblocks_v2_1_0 msim/generic_baseblocks_v2_1_0
vmap axi_infrastructure_v1_1_0 msim/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_9 msim/axi_register_slice_v2_1_9
vmap fifo_generator_v13_1_1 msim/fifo_generator_v13_1_1
vmap axi_data_fifo_v2_1_8 msim/axi_data_fifo_v2_1_8
vmap axi_crossbar_v2_1_10 msim/axi_crossbar_v2_1_10
vmap gig_ethernet_pcs_pma_v15_2_1 msim/gig_ethernet_pcs_pma_v15_2_1
vmap proc_common_v3_00_a msim/proc_common_v3_00_a
vmap axi_lite_ipif_v1_01_a msim/axi_lite_ipif_v1_01_a
vmap lib_pkg_v1_0_2 msim/lib_pkg_v1_0_2
vmap lib_fifo_v1_0_5 msim/lib_fifo_v1_0_5
vmap lib_srl_fifo_v1_0_2 msim/lib_srl_fifo_v1_0_2
vmap axi_datamover_v5_1_11 msim/axi_datamover_v5_1_11
vmap axi_sg_v4_1_3 msim/axi_sg_v4_1_3
vmap axi_dma_v7_1_10 msim/axi_dma_v7_1_10
vmap axi_protocol_converter_v2_1_9 msim/axi_protocol_converter_v2_1_9

vlog -work xil_defaultlib -64 -incr -sv "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_base.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_dpdistram.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_dprom.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_sdpram.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_spram.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_sprom.sv" \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_tdpram.sv" \

vcom -work xpm -64 -93 \
"/local/EDA/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work processing_system7_bfm_v2_0_5 -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
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

vlog -work xil_defaultlib -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ip/system_design_processing_system7_0_0/sim/system_design_processing_system7_0_0.v" \

vcom -work xil_pvtmisc -64 -93 \
"../../../../FASEC_prototype.srcs/sources_1/bd/system_design/ipshared/cern.ch/xil_pvtmisc_v1_2/doubleBufferEdge.vhd" \
"../../../../FASEC_prototype.srcs/sources_1/bd/system_design/ipshared/cern.ch/xil_pvtmisc_v1_2/clockDivider.vhd" \
"../../../../FASEC_prototype.srcs/sources_1/bd/system_design/ipshared/cern.ch/xil_pvtmisc_v1_2/shiftRegister.vhd" \
"../../../../FASEC_prototype.srcs/sources_1/bd/system_design/ipshared/cern.ch/xil_pvtmisc_v1_2/myPackage.vhd" \
"../../../../FASEC_prototype.srcs/sources_1/bd/system_design/ipshared/cern.ch/xil_pvtmisc_v1_2/doubleBufferVector.vhd" \
"../../../../FASEC_prototype.srcs/sources_1/bd/system_design/ipshared/cern.ch/xil_pvtmisc_v1_2/doubleBuffer.vhd" \
"../../../../FASEC_prototype.srcs/sources_1/bd/system_design/ipshared/cern.ch/xil_pvtmisc_v1_2/axis_wbm_bridge.vhd" \
"../../../../FASEC_prototype.srcs/sources_1/bd/system_design/ipshared/cern.ch/xil_pvtmisc_v1_2/axi4lite_slave.vhd" \
"../../../../FASEC_prototype.srcs/sources_1/bd/system_design/ipshared/cern.ch/xil_pvtmisc_v1_2/spi_transceiver.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v2_8_1/FASEC_hwtest.srcs/sources_1/new/dac7716_spi.vhd" \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v2_8_1/FASEC_hwtest.srcs/sources_1/new/general_fmc.vhd" \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v2_8_1/FASEC_hwtest.srcs/sources_1/new/top_mod.vhd" \
"../../../bd/system_design/ip/system_design_fasec_hwtest_0_0/sim/system_design_fasec_hwtest_0_0.vhd" \
"../../../bd/system_design/ipshared/user.org/axi_wb_i2c_master_v2_5_1/src/i2c_master_bit_ctrl.vhd" \
"../../../bd/system_design/ipshared/user.org/axi_wb_i2c_master_v2_5_1/src/i2c_master_byte_ctrl.vhd" \
"../../../bd/system_design/ipshared/user.org/axi_wb_i2c_master_v2_5_1/src/i2c_master_top.vhd" \
"../../../bd/system_design/ipshared/user.org/axi_wb_i2c_master_v2_5_1/src/axis_to_i2c_wbs_v1_0.vhd" \
"../../../bd/system_design/ip/system_design_axi_wb_i2c_master_0_0/sim/system_design_axi_wb_i2c_master_0_0.vhd" \

vcom -work lib_cdc_v1_0_2 -64 -93 \
"../../../ipstatic/lib_cdc_v1_0/hdl/src/vhdl/cdc_sync.vhd" \

vcom -work proc_sys_reset_v5_0_9 -64 -93 \
"../../../ipstatic/proc_sys_reset_v5_0/hdl/src/vhdl/upcnt_n.vhd" \
"../../../ipstatic/proc_sys_reset_v5_0/hdl/src/vhdl/sequence_psr.vhd" \
"../../../ipstatic/proc_sys_reset_v5_0/hdl/src/vhdl/lpf.vhd" \
"../../../ipstatic/proc_sys_reset_v5_0/hdl/src/vhdl/proc_sys_reset.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/system_design/ip/system_design_rst_processing_system7_0_100M_2/sim/system_design_rst_processing_system7_0_100M_2.vhd" \
"../../../bd/system_design/ip/system_design_axi_wb_i2c_master_1_0/sim/system_design_axi_wb_i2c_master_1_0.vhd" \

vlog -work generic_baseblocks_v2_1_0 -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
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

vlog -work axi_infrastructure_v1_1_0 -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog/axi_infrastructure_v1_1_axi2vector.v" \
"../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog/axi_infrastructure_v1_1_axic_srl_fifo.v" \
"../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog/axi_infrastructure_v1_1_vector2axi.v" \

vlog -work axi_register_slice_v2_1_9 -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/axi_register_slice_v2_1/hdl/verilog/axi_register_slice_v2_1_axic_register_slice.v" \
"../../../ipstatic/axi_register_slice_v2_1/hdl/verilog/axi_register_slice_v2_1_axi_register_slice.v" \

vlog -work fifo_generator_v13_1_1 -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/fifo_generator_v13_1/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_1_1 -64 -93 \
"../../../ipstatic/fifo_generator_v13_1/hdl/fifo_generator_v13_1_rfs.vhd" \

vlog -work fifo_generator_v13_1_1 -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/fifo_generator_v13_1/hdl/fifo_generator_v13_1_rfs.v" \

vlog -work axi_data_fifo_v2_1_8 -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_axic_fifo.v" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_fifo_gen.v" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_axic_srl_fifo.v" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_axic_reg_srl_fifo.v" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_ndeep_srl.v" \
"../../../ipstatic/axi_data_fifo_v2_1/hdl/verilog/axi_data_fifo_v2_1_axi_data_fifo.v" \

vlog -work axi_crossbar_v2_1_10 -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
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

vlog -work xil_defaultlib -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ip/system_design_xbar_0/sim/system_design_xbar_0.v" \

vcom -work gig_ethernet_pcs_pma_v15_2_1 -64 -93 \
"../../../ipstatic/gig_ethernet_pcs_pma_v15_2/hdl/gig_ethernet_pcs_pma_v15_2_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/system_design_gig_ethernet_pcs_pma_0_0_resets.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/system_design_gig_ethernet_pcs_pma_0_0_clocking.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/system_design_gig_ethernet_pcs_pma_0_0_support.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/system_design_gig_ethernet_pcs_pma_0_0_gt_common.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/transceiver/system_design_gig_ethernet_pcs_pma_0_0_cpll_railing.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/transceiver/system_design_gig_ethernet_pcs_pma_0_0_gtwizard.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/transceiver/system_design_gig_ethernet_pcs_pma_0_0_gtwizard_multi_gt.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/transceiver/system_design_gig_ethernet_pcs_pma_0_0_gtwizard_gt.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/transceiver/system_design_gig_ethernet_pcs_pma_0_0_gtwizard_init.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/transceiver/system_design_gig_ethernet_pcs_pma_0_0_tx_startup_fsm.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/transceiver/system_design_gig_ethernet_pcs_pma_0_0_rx_startup_fsm.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/system_design_gig_ethernet_pcs_pma_0_0_reset_sync.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/system_design_gig_ethernet_pcs_pma_0_0_sync_block.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/transceiver/system_design_gig_ethernet_pcs_pma_0_0_reset_wtd_timer.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/transceiver/system_design_gig_ethernet_pcs_pma_0_0_transceiver.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/system_design_gig_ethernet_pcs_pma_0_0_block.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/sgmii_adapt/system_design_gig_ethernet_pcs_pma_0_0_clk_gen.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/sgmii_adapt/system_design_gig_ethernet_pcs_pma_0_0_rx_rate_adapt.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/sgmii_adapt/system_design_gig_ethernet_pcs_pma_0_0_tx_rate_adapt.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/sgmii_adapt/system_design_gig_ethernet_pcs_pma_0_0_clock_div.vhd" \
"../../../bd/system_design/ip/system_design_gig_ethernet_pcs_pma_0_0/synth/system_design_gig_ethernet_pcs_pma_0_0.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xlconstant_v1_1/xlconstant.vhd" \
"../../../bd/system_design/ip/system_design_xlconstant_0_0/sim/system_design_xlconstant_0_0.vhd" \
"../../../bd/system_design/ip/system_design_xlconstant_1_0/sim/system_design_xlconstant_1_0.vhd" \
"../../../bd/system_design/ip/system_design_xlconstant_1_1/sim/system_design_xlconstant_1_1.vhd" \
"../../../bd/system_design/ip/system_design_xlconstant_0_1/sim/system_design_xlconstant_0_1.vhd" \
"../../../bd/system_design/ip/system_design_xlconstant_3_0/sim/system_design_xlconstant_3_0.vhd" \
"../../../bd/system_design/ip/system_design_xlconstant_3_1/sim/system_design_xlconstant_3_1.vhd" \
"../../../bd/system_design/ip/system_design_xlconstant_3_2/sim/system_design_xlconstant_3_2.vhd" \
"../../../bd/system_design/ip/system_design_xlconstant_0_2/sim/system_design_xlconstant_0_2.vhd" \
"../../../bd/system_design/ip/system_design_axi_wb_i2c_master_2_0/sim/system_design_axi_wb_i2c_master_2_0.vhd" \
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

vcom -work proc_common_v3_00_a -64 -93 \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/proc_common_pkg.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/family_support.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/pselect_f.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/ipif_pkg.vhd" \

vcom -work axi_lite_ipif_v1_01_a -64 -93 \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/address_decoder.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/slave_attachment.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/vhdl/axi_lite_ipif.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/system_design/ipshared/xilinx.com/xadc_axis_fifo_adapter_v1_0/fifo_adapter.srcs/sources_1/imports/hdl/xadc_axis_fifo_adapter.vhd" \
"../../../bd/system_design/ip/system_design_xadc_axis_fifo_adapter_0_0/sim/system_design_xadc_axis_fifo_adapter_0_0.vhd" \

vcom -work lib_pkg_v1_0_2 -64 -93 \
"../../../ipstatic/lib_pkg_v1_0/hdl/src/vhdl/lib_pkg.vhd" \

vcom -work lib_fifo_v1_0_5 -64 -93 \
"../../../ipstatic/lib_fifo_v1_0/hdl/src/vhdl/async_fifo_fg.vhd" \
"../../../ipstatic/lib_fifo_v1_0/hdl/src/vhdl/sync_fifo_fg.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -64 -93 \
"../../../ipstatic/lib_srl_fifo_v1_0/hdl/src/vhdl/cntr_incr_decr_addn_f.vhd" \
"../../../ipstatic/lib_srl_fifo_v1_0/hdl/src/vhdl/dynshreg_f.vhd" \
"../../../ipstatic/lib_srl_fifo_v1_0/hdl/src/vhdl/srl_fifo_rbu_f.vhd" \
"../../../ipstatic/lib_srl_fifo_v1_0/hdl/src/vhdl/srl_fifo_f.vhd" \

vcom -work axi_datamover_v5_1_11 -64 -93 \
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

vcom -work axi_sg_v4_1_3 -64 -93 \
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

vcom -work axi_dma_v7_1_10 -64 -93 \
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

vcom -work xil_defaultlib -64 -93 \
"../../../bd/system_design/ip/system_design_axi_dma_0_0/sim/system_design_axi_dma_0_0.vhd" \
"../../../bd/system_design/ipshared/xilinx.com/xlconcat_v2_1/xlconcat.vhd" \
"../../../bd/system_design/ip/system_design_xlconcat_0_0/sim/system_design_xlconcat_0_0.vhd" \

vlog -work axi_protocol_converter_v2_1_9 -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
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

vlog -work xil_defaultlib -64 -incr "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" "+incdir+../../../ipstatic/axi_infrastructure_v1_1/hdl/verilog" "+incdir+../../../ipstatic/processing_system7_bfm_v2_0/hdl" \
"../../../bd/system_design/ip/system_design_auto_pc_0/sim/system_design_auto_pc_0.v" \
"../../../bd/system_design/ip/system_design_auto_pc_1/sim/system_design_auto_pc_1.v" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/system_design/hdl/system_design.vhd" \

vlog -work xil_defaultlib "glbl.v"

