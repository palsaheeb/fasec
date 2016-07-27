connect -url tcp:127.0.0.1:3121
source /home/pieter/Development/projects/FIDS/FASEC_prototype/FASEC_prototype.sdk/system_design_wrapper_hw_platform_0/ps7_init.tcl
targets -set -filter {name =~"APU" && jtag_cable_name =~ "Platform Cable USB II 0000150f6b7901"} -index 0
loadhw /home/pieter/Development/projects/FIDS/FASEC_prototype/FASEC_prototype.sdk/system_design_wrapper_hw_platform_0/system.hdf
targets -set -filter {name =~"APU" && jtag_cable_name =~ "Platform Cable USB II 0000150f6b7901"} -index 0
stop
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Platform Cable USB II 0000150f6b7901"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Platform Cable USB II 0000150f6b7901"} -index 0
dow /home/pieter/Development/projects/FIDS/FASEC_prototype/FASEC_prototype.sdk/Mem-Test_FASEC/Debug/Mem-Test_FASEC.elf
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Platform Cable USB II 0000150f6b7901"} -index 0
con
