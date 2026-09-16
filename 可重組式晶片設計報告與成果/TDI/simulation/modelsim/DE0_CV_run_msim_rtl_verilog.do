transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/A610/Desktop/DE0_CV {C:/Users/A610/Desktop/DE0_CV/pll.vo}
vlog -vlog01compat -work work +incdir+C:/Users/A610/Desktop/DE0_CV/pll {C:/Users/A610/Desktop/DE0_CV/pll/pll_0002.v}
vlog -sv -work work +incdir+C:/Users/A610/Desktop/DE0_CV/design {C:/Users/A610/Desktop/DE0_CV/design/spi_rx.sv}
vlog -sv -work work +incdir+C:/Users/A610/Desktop/DE0_CV/design {C:/Users/A610/Desktop/DE0_CV/design/DE0_CV.sv}

