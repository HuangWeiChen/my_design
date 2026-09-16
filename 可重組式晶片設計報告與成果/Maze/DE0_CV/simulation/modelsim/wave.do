onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/rst_n
add wave -noupdate -radix binary /testbench/landform
add wave -noupdate /testbench/valid
add wave -noupdate /testbench/ready
add wave -noupdate -radix unsigned /testbench/action
add wave -noupdate /testbench/finish
add wave -noupdate /testbench/dut/valid
add wave -noupdate -radix unsigned /testbench/dut/map
add wave -noupdate /testbench/dut/fsm_ns
add wave -noupdate /testbench/dut/fsm_ps
add wave -noupdate -radix unsigned /testbench/dut/cnt_x
add wave -noupdate -radix unsigned /testbench/dut/cnt_y
add wave -noupdate -radix unsigned /testbench/dut/cnt_money
add wave -noupdate -radix unsigned /testbench/dut/cnt_get
add wave -noupdate -radix unsigned /testbench/dut/x
add wave -noupdate -radix unsigned /testbench/dut/y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6095890 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 78
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
configure wave -timelineunits ps
update
WaveRestoreZoom {5965570 ps} {6715560 ps}
