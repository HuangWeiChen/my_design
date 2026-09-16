onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider 01257024
add wave -noupdate -divider CNN
add wave -noupdate /testbench/DE0_CV1/t1/clk
add wave -noupdate -radix hexadecimal /testbench/DE0_CV1/t1/conv_data
add wave -noupdate /testbench/DE0_CV1/t1/update
add wave -noupdate /testbench/DE0_CV1/t1/rdreq
add wave -noupdate -radix unsigned /testbench/DE0_CV1/t1/x
add wave -noupdate -radix unsigned /testbench/DE0_CV1/t1/y
add wave -noupdate /testbench/DE0_CV1/t1/start
add wave -noupdate -radix unsigned /testbench/DE0_CV1/t1/cnt_input
add wave -noupdate -radix hexadecimal /testbench/DE0_CV1/t1/shift_reg
add wave -noupdate /testbench/DE0_CV1/t1/fsm_ps
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {289913742 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 83
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
WaveRestoreZoom {289500213 ps} {290291169 ps}
