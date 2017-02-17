# this script simply copies the generated bitstream to a general folder
set projd [get_property DIRECTORY [current_project]]
# seperate project gets created for every Vivado-action, hence projd doesn't point to the expected root!
cd $projd
file copy -force system_design_wrapper.bit ../../firmware/
