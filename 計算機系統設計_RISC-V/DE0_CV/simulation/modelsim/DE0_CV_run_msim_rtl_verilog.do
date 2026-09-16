transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/user/Downloads/DE0_CV/design {C:/Users/user/Downloads/DE0_CV/design/mul.sv}
vlog -sv -work work +incdir+C:/Users/user/Downloads/DE0_CV/design {C:/Users/user/Downloads/DE0_CV/design/div.sv}
vlog -sv -work work +incdir+C:/Users/user/Downloads/DE0_CV/design {C:/Users/user/Downloads/DE0_CV/design/RAM.sv}
vlog -sv -work work +incdir+C:/Users/user/Downloads/DE0_CV/design {C:/Users/user/Downloads/DE0_CV/design/LSU.sv}
vlog -sv -work work +incdir+C:/Users/user/Downloads/DE0_CV/design {C:/Users/user/Downloads/DE0_CV/design/Program_Rom.sv}
vlog -sv -work work +incdir+C:/Users/user/Downloads/DE0_CV/design {C:/Users/user/Downloads/DE0_CV/design/risc_v.sv}
vlog -sv -work work +incdir+C:/Users/user/Downloads/DE0_CV/design {C:/Users/user/Downloads/DE0_CV/design/alu.sv}

