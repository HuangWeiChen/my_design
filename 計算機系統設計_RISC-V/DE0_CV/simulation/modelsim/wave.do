onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TOP LEVEL INPUTS}
add wave -noupdate -radix unsigned /testbench/clk
add wave -noupdate -radix unsigned /testbench/rst
add wave -noupdate -divider PC
add wave -noupdate -radix hexadecimal /testbench/a1/jump_addr_
add wave -noupdate -radix hexadecimal /testbench/a1/pc
add wave -noupdate -divider PROM
add wave -noupdate -radix hexadecimal /testbench/a1/inst_
add wave -noupdate /testbench/a1/opcode_
add wave -noupdate /testbench/a1/funct3_
add wave -noupdate /testbench/a1/funct7_
add wave -noupdate /testbench/a1/addr_rd_
add wave -noupdate /testbench/a1/addr_rs1
add wave -noupdate /testbench/a1/addr_rs2
add wave -noupdate -radix hexadecimal /testbench/a1/imm_
add wave -noupdate -radix hexadecimal /testbench/a1/ps
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[0]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[1]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[2]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[3]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[4]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[5]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[6]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[7]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[8]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[9]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[10]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[11]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[12]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[13]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[14]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[15]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[16]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[17]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[18]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[19]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[20]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[21]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[22]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[23]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[24]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[25]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[26]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[27]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[28]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[29]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[30]}
add wave -noupdate -radix hexadecimal {/testbench/a1/regs[31]}
add wave -noupdate -divider LSU
add wave -noupdate -radix hexadecimal {/testbench/a1/LSU1/ram_0/ram[0]}
add wave -noupdate -radix hexadecimal {/testbench/a1/LSU1/ram_0/ram[1]}
add wave -noupdate -radix hexadecimal {/testbench/a1/LSU1/ram_1/ram[0]}
add wave -noupdate -radix hexadecimal {/testbench/a1/LSU1/ram_1/ram[1]}
add wave -noupdate -radix hexadecimal {/testbench/a1/LSU1/ram_2/ram[0]}
add wave -noupdate -radix hexadecimal {/testbench/a1/LSU1/ram_2/ram[1]}
add wave -noupdate -radix hexadecimal {/testbench/a1/LSU1/ram_3/ram[0]}
add wave -noupdate -radix hexadecimal {/testbench/a1/LSU1/ram_3/ram[1]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1183 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {256 ps}
