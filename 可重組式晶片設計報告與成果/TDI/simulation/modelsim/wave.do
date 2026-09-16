onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider 01257024
add wave -noupdate -divider SPI
add wave -noupdate /testbench/dut/spi_rx_1/clk
add wave -noupdate /testbench/dut/spi_rx_1/sclk
add wave -noupdate -radix hexadecimal /testbench/dut/spi_rx_1/mosi
add wave -noupdate /testbench/dut/spi_rx_1/ssn
add wave -noupdate /testbench/dut/spi_rx_1/sclk
add wave -noupdate /testbench/dut/spi_rx_1/rst
add wave -noupdate -radix hexadecimal /testbench/dut/spi_rx_1/data
add wave -noupdate -divider fifo
add wave -noupdate -radix hexadecimal /testbench/dut/fifo_1/data
add wave -noupdate /testbench/dut/fifo_1/sclr
add wave -noupdate /testbench/dut/fifo_1/rdreq
add wave -noupdate /testbench/dut/fifo_1/wrreq
add wave -noupdate -radix hexadecimal /testbench/dut/fifo_1/q
add wave -noupdate -divider TDI
add wave -noupdate /testbench/dut/clk
add wave -noupdate /testbench/dut/rst
add wave -noupdate -radix hexadecimal /testbench/dut/mosi
add wave -noupdate /testbench/dut/start
add wave -noupdate -radix hexadecimal /testbench/dut/pixel_output
add wave -noupdate /testbench/dut/update
add wave -noupdate /testbench/dut/shift
add wave -noupdate -radix unsigned /testbench/dut/update_cnt
add wave -noupdate /testbench/dut/rdreq
add wave -noupdate -radix unsigned /testbench/dut/x
add wave -noupdate -radix unsigned /testbench/dut/y
add wave -noupdate -radix hexadecimal /testbench/dut/shift_reg
add wave -noupdate /testbench/dut/fsm_ns
add wave -noupdate /testbench/dut/fsm_ps
add wave -noupdate -radix hexadecimal -childformat {{{/testbench/dut/deb_a[10]} -radix hexadecimal} {{/testbench/dut/deb_a[9]} -radix hexadecimal} {{/testbench/dut/deb_a[8]} -radix hexadecimal} {{/testbench/dut/deb_a[7]} -radix hexadecimal} {{/testbench/dut/deb_a[6]} -radix hexadecimal} {{/testbench/dut/deb_a[5]} -radix hexadecimal} {{/testbench/dut/deb_a[4]} -radix hexadecimal} {{/testbench/dut/deb_a[3]} -radix hexadecimal} {{/testbench/dut/deb_a[2]} -radix hexadecimal} {{/testbench/dut/deb_a[1]} -radix hexadecimal} {{/testbench/dut/deb_a[0]} -radix hexadecimal}} -subitemconfig {{/testbench/dut/deb_a[10]} {-radix hexadecimal} {/testbench/dut/deb_a[9]} {-radix hexadecimal} {/testbench/dut/deb_a[8]} {-radix hexadecimal} {/testbench/dut/deb_a[7]} {-radix hexadecimal} {/testbench/dut/deb_a[6]} {-radix hexadecimal} {/testbench/dut/deb_a[5]} {-radix hexadecimal} {/testbench/dut/deb_a[4]} {-radix hexadecimal} {/testbench/dut/deb_a[3]} {-radix hexadecimal} {/testbench/dut/deb_a[2]} {-radix hexadecimal} {/testbench/dut/deb_a[1]} {-radix hexadecimal} {/testbench/dut/deb_a[0]} {-radix hexadecimal}} /testbench/dut/deb_a
add wave -noupdate -radix hexadecimal /testbench/dut/deb_b
add wave -noupdate -radix hexadecimal /testbench/dut/data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {948632725 ps} 0}
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
WaveRestoreZoom {947937918 ps} {949085920 ps}
