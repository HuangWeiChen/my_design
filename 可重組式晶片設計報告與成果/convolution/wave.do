onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider 01257024
add wave -noupdate /testbench/DE0_CV1/s2/clk
add wave -noupdate /testbench/DE0_CV1/s2/mosi
add wave -noupdate /testbench/DE0_CV1/s2/ssn
add wave -noupdate /testbench/DE0_CV1/s2/sclk
add wave -noupdate /testbench/DE0_CV1/s2/rst
add wave -noupdate -radix hexadecimal /testbench/DE0_CV1/s2/data
add wave -noupdate /testbench/DE0_CV1/s2/sclk_posedge
add wave -noupdate -radix unsigned /testbench/DE0_CV1/s2/receive_data_counter
add wave -noupdate -radix hexadecimal /testbench/DE0_CV1/s2/shift_data
add wave -noupdate -radix hexadecimal /testbench/DE0_CV1/s2/address
add wave -noupdate /testbench/DE0_CV1/s2/write_en
add wave -noupdate -radix hexadecimal /testbench/DE0_CV1/s2/data
add wave -noupdate /testbench/DE0_CV1/s2/fsm2_ns
add wave -noupdate /testbench/DE0_CV1/s2/fsm2_ps
add wave -noupdate -radix unsigned /testbench/DE0_CV1/s2/sclk_data_counter
add wave -noupdate /testbench/DE0_CV1/s2/read_data_reg
add wave -noupdate /testbench/DE0_CV1/s2/load_shift_read_data
add wave -noupdate /testbench/DE0_CV1/s2/read_en
add wave -noupdate /testbench/DE0_CV1/s2/miso
add wave -noupdate -radix hexadecimal /testbench/DE0_CV1/s2/read_data
add wave -noupdate -radix hexadecimal {/testbench/DE0_CV1/s2/reg_file[0]}
add wave -noupdate -radix hexadecimal {/testbench/DE0_CV1/s2/reg_file[85]}
add wave -noupdate -radix hexadecimal {/testbench/DE0_CV1/s2/reg_file[170]}
add wave -noupdate -radix hexadecimal {/testbench/DE0_CV1/s2/reg_file[255]}
add wave -noupdate /testbench/DE0_CV1/s2/shift_read_data
add wave -noupdate /testbench/DE0_CV1/s2/ssn_negedge
add wave -noupdate {/testbench/DE0_CV1/s2/reg_file[174]}
add wave -noupdate {/testbench/DE0_CV1/s2/reg_file[114]}
add wave -noupdate -radix hexadecimal /testbench/get_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {5887736 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 73
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {15164193 ps} {41115365 ps}
