#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology LATTICE-XP2
set_option -part LFXP2_5E
set_option -package TN144I
set_option -speed_grade -6

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std sysv

#map options
set_option -frequency 200
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false

add_file -constraint {C:/Users/charles/Desktop/fpga/Practicals/05 - Registers/TestProject/Test.fdc}
set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0
set_option -vhdl2008 1

set_option -seqshift_no_replicate 0

#-- add_file options
set_option -include_path {C:/Users/charles/Desktop/fpga/Practicals/05 - Registers/TestProject}
add_file -verilog -vlog_std sysv {C:/Users/charles/Desktop/fpga/Practicals/05 - Registers/Structures/Structures.v}
add_file -verilog -vlog_std sysv {C:/Users/charles/Desktop/fpga/Practicals/05 - Registers/UART/UART.v}
add_file -verilog -vlog_std sysv {C:/Users/charles/Desktop/fpga/Practicals/05 - Registers/UART_PACKETS/UART_packets.v}
add_file -verilog -vlog_std sysv {C:/Users/charles/Desktop/fpga/Practicals/05 - Registers/Registers/Registers.v}
add_file -verilog -vlog_std sysv {C:/Users/charles/Desktop/fpga/Practicals/05 - Registers/ReadController/ReadController.v}
add_file -verilog -vlog_std sysv {C:/Users/charles/Desktop/fpga/Practicals/05 - Registers/WriteController/WriteController.v}
add_file -verilog -vlog_std sysv {C:/Users/charles/Desktop/fpga/Practicals/05 - Registers/Test/Test.v}

#-- top module name
set_option -top_module Test

#-- set result format/file last
project -result_file {C:/Users/charles/Desktop/fpga/Practicals/05 - Registers/TestProject/impl1/TestProject_impl1.edi}

#-- error message log file
project -log_file {TestProject_impl1.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run -clean
