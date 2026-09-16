transcript on
if ![file isdirectory DE0_CV_iputf_libs] {
	file mkdir DE0_CV_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vlog "C:/Users/user/Downloads/TDI/pll_sim/pll.vo"

vlog -vlog01compat -work work +incdir+C:/Users/user/Downloads/TDI {C:/Users/user/Downloads/TDI/fifo.v}
vlog -sv -work work +incdir+C:/Users/user/Downloads/TDI/design {C:/Users/user/Downloads/TDI/design/TDI.sv}
vlog -sv -work work +incdir+C:/Users/user/Downloads/TDI/design {C:/Users/user/Downloads/TDI/design/spi_rx.sv}

