#vsim -voptargs=+acc work.testbench
vsim -c -sv_seed random work.testbench
view structure wave signals

do wave.do

log -r *
run -all

