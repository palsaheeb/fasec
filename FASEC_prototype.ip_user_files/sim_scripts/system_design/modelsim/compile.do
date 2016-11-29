vlib work
vlib msim

vlib msim/processing_system7_bfm_v2_0_5
vlib msim/xil_defaultlib
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
vlib msim/axi_protocol_converter_v2_1_9

vmap processing_system7_bfm_v2_0_5 msim/processing_system7_bfm_v2_0_5
vmap xil_defaultlib msim/xil_defaultlib
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
vmap axi_protocol_converter_v2_1_9 msim/axi_protocol_converter_v2_1_9

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
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v2_7_0/FASEC_hwtest.srcs/sources_1/new/dac7716_spi.vhd" \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v2_7_0/FASEC_hwtest.srcs/sources_1/new/general_fmc.vhd" \
"../../../bd/system_design/ipshared/user.org/fasec_hwtest_v2_7_0/FASEC_hwtest.srcs/sources_1/new/top_mod.vhd" \
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

vcom -work xil_defaultlib -64 -93 \
"../../../bd/system_design/hdl/system_design.vhd" \

vlog -work xil_defaultlib "glbl.v"

