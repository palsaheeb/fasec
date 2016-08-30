create_clock -period 10.000 -name clock_ps -waveform {0.000 5.000} [get_ports ps_clk_i]
create_clock -period 10.000 -name clock_axi -waveform {0.000 5.000} [get_ports s00_axi_aclk]
