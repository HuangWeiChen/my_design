vsim -gui work.testbench

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider PORT
add wave -noupdate -radix unsigned /testbench/dut/clk
add wave -noupdate -radix unsigned /testbench/dut/rst_n
add wave -noupdate -radix unsigned /testbench/dut/landform
add wave -noupdate -radix unsigned /testbench/dut/valid
add wave -noupdate -radix unsigned /testbench/dut/ready
add wave -noupdate -radix unsigned /testbench/dut/action
add wave -noupdate /testbench/dut/finish
add wave -noupdate -divider STATE
add wave -noupdate -radix unsigned /testbench/dut/ps
add wave -noupdate -radix unsigned /testbench/dut/ns
add wave -noupdate -radix unsigned /testbench/dut/store
add wave -noupdate -divider CNT
add wave -noupdate -radix unsigned /testbench/dut/cnt_x
add wave -noupdate -radix unsigned /testbench/dut/cnt_y
add wave -noupdate -divider MAP
add wave -noupdate -radix unsigned /testbench/dut/treasure_total
add wave -noupdate -radix unsigned /testbench/dut/treasure_collected
add wave -noupdate /testbench/dut/reached_1717
add wave -noupdate /testbench/dut/fill_this_cell
add wave -noupdate -radix unsigned -childformat {{{/testbench/dut/map[0]} -radix unsigned} {{/testbench/dut/map[1]} -radix unsigned} {{/testbench/dut/map[2]} -radix unsigned} {{/testbench/dut/map[3]} -radix unsigned} {{/testbench/dut/map[4]} -radix unsigned} {{/testbench/dut/map[5]} -radix unsigned} {{/testbench/dut/map[6]} -radix unsigned} {{/testbench/dut/map[7]} -radix unsigned} {{/testbench/dut/map[8]} -radix unsigned} {{/testbench/dut/map[9]} -radix unsigned} {{/testbench/dut/map[10]} -radix unsigned} {{/testbench/dut/map[11]} -radix unsigned} {{/testbench/dut/map[12]} -radix unsigned} {{/testbench/dut/map[13]} -radix unsigned} {{/testbench/dut/map[14]} -radix unsigned} {{/testbench/dut/map[15]} -radix unsigned} {{/testbench/dut/map[16]} -radix unsigned} {{/testbench/dut/map[17]} -radix unsigned} {{/testbench/dut/map[18]} -radix unsigned}} -expand -subitemconfig {{/testbench/dut/map[0]} {-height 15 -radix unsigned} {/testbench/dut/map[1]} {-height 15 -radix unsigned} {/testbench/dut/map[2]} {-height 15 -radix unsigned} {/testbench/dut/map[3]} {-height 15 -radix unsigned} {/testbench/dut/map[4]} {-height 15 -radix unsigned} {/testbench/dut/map[5]} {-height 15 -radix unsigned} {/testbench/dut/map[6]} {-height 15 -radix unsigned} {/testbench/dut/map[7]} {-height 15 -radix unsigned} {/testbench/dut/map[8]} {-height 15 -radix unsigned} {/testbench/dut/map[9]} {-height 15 -radix unsigned} {/testbench/dut/map[10]} {-height 15 -radix unsigned} {/testbench/dut/map[11]} {-height 15 -radix unsigned} {/testbench/dut/map[12]} {-height 15 -radix unsigned} {/testbench/dut/map[13]} {-height 15 -radix unsigned} {/testbench/dut/map[14]} {-height 15 -radix unsigned} {/testbench/dut/map[15]} {-height 15 -radix unsigned} {/testbench/dut/map[16]} {-height 15 -radix unsigned} {/testbench/dut/map[17]} {-height 15 -radix unsigned} {/testbench/dut/map[18]} {-height 15 -radix unsigned}} /testbench/dut/map
add wave -noupdate -radix unsigned /testbench/dut/landform_in
add wave -noupdate /testbench/dut/stall_flag
add wave -noupdate /testbench/dut/stalling
add wave -noupdate -divider <NULL>
add wave -noupdate -expand -group TB -radix unsigned /testbench/map
add wave -noupdate -expand -group TB -radix unsigned /testbench/map_index
add wave -noupdate -expand -group TB -radix unsigned /testbench/start_sending
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7343410 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 400
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
WaveRestoreZoom {0 ps} {25614750 ps}

run -all
