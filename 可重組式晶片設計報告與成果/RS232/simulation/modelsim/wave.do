onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider 01257024
add wave -noupdate /testbench/rs232_1/clk
add wave -noupdate /testbench/rs232_1/rst
add wave -noupdate /testbench/rs232_1/rx
add wave -noupdate /testbench/rs232_1/tx
add wave -noupdate /testbench/rs232_1/tx_ack
add wave -noupdate /testbench/rs232_1/tx_req
add wave -noupdate /testbench/rs232_1/write
add wave -noupdate /testbench/rs232_1/tx_cnt
add wave -noupdate /testbench/rs232_1/data_r
add wave -noupdate -radix hexadecimal /testbench/rs232_1/tx_data
add wave -noupdate /testbench/rs232_1/rs232_rx_1/fsm_ns
add wave -noupdate /testbench/rs232_1/rs232_rx_1/fsm_ps
add wave -noupdate /testbench/rs232_1/Low_Pass_Filter_1/reset_counter
add wave -noupdate {/testbench/rs232_1/reg_file[2]}
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/addr
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/data
add wave -noupdate -radix hexadecimal {/testbench/rs232_1/reg_file[19]}
add wave -noupdate -radix unsigned {/testbench/rs232_1/reg_file[2]}
add wave -noupdate /testbench/rs232_1/rs232_rx_1/write
add wave -noupdate /testbench/rs232_1/rs232_rx_1/tx_req
add wave -noupdate /testbench/rs232_1/rs232_rx_1/tx_cnt
add wave -noupdate /testbench/rs232_1/rs232_rx_1/bit_flag
add wave -noupdate -radix unsigned /testbench/rs232_1/rs232_rx_1/pkg_cnt
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/head
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/addr1
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/addr2
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/data1
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/data2
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/r_w
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/chk_sum
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/chk_sum_acc
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/tail
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/addr
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_rx_1/data
add wave -noupdate -radix hexadecimal /testbench/rs232_1/rs232_tx_1/tx_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {13221706000 ps} 0}
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
WaveRestoreZoom {0 ps} {15042342 ns}
