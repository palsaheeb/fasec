# this scripts queries some variables and put them
# in a VHDL file for use during synthesis
# start manually as follows:
# cd /home/pieter/Development/projects/FIDS/FASEC_prototype; source FASEC_prototype.srcs/tcl/set_registers.tcl; reset_run synth_1; launch_runs synth_1 -force -jobs 4; launch_runs impl_1 -to_step write_bitstream -jobs 4

# xilinc tcl info:
# each class can have many properties, to list them:
# llength [list_property -class bd_cell]
# list_property [get_bd_cells fasec*]

# FIXME: Vivado 'Generate Output Products' deletes the backup-file while the topfile is kept BUT without the DEADBEE. strings
# possible solution: store the backupfile in the modules folder? OK but:
# FIXME: if IP changes, the old backup file will 'undo' the top_mod.vhd changes by copying in the backup file!

# settings
set filefilter *top_mod*
set git {/usr/bin/git}
set backupext .old
set backupnm {modules/fasec_hwtest/top_mod.vhd.old}

set projd [get_property DIRECTORY [current_project]]
puts $projd
set bdd [get_files -of_objects [get_filesets sources_1] *bd]
# using get_files avoids having to know the IP version etc.
set topfile [get_files -of_objects [get_filesets sources_1] $filefilter]
puts $topfile
if [llength $topfile]!=1 {
    return -1 error "ERROR: more than one topfile found!"
}

cd $projd
set dateCode [format %08X [clock seconds]]
set gitCode [string range [exec $git log --format=%H -n 1] 0 7]

# create backup file if it doesn't exist to preserve the DEADBEE. strings
if [file exists $backupnm]==0 {
    file copy -force $topfile $backupnm
}

# replace the strings from the backupfile, then write to output file
# backupfile will remain unmodified
set fr [open $backupnm r]
set fw [open $topfile r+]
if [string first DEADBEE1 [read $fr]]==-1 {
    return -1 error "ERROR: specific string sequence not found in backupfile!"
}
seek $fr 0; # back to beginning for reading
set cont [regsub -all {DEADBEE1} [read $fr] $dateCode]
set cont [regsub -all {DEADBEE2} $cont $gitCode]
seek $fw 0; # go to beginning of file to overwrite
puts $fw $cont
close $fw
close $fr

puts "SUCCESS: done"

