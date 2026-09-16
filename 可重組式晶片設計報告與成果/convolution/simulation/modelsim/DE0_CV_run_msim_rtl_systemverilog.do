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


vlog "E:/CNN/pll_sim/pll.vo"

vlog -vlog01compat -work work +incdir+E:/CNN {E:/CNN/fifo.v}
vlog -sv -work work +incdir+E:/CNN/design {E:/CNN/design/CNN.sv}
vlog -sv -work work +incdir+E:/CNN/design {E:/CNN/design/spi_rx.sv}
vlog -sv -work work +incdir+E:/CNN/design {E:/CNN/design/DE0_CV.sv}

