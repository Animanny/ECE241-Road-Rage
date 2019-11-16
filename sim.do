# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files

vlog fill.v
vlog playerCar.v
vlog backgroundImage.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver fill


#log all signals and add some signals to waveform window
log {/*} -r
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# force {CLOCK_50} 0 0ns , 1 {5ns} -r 10ns
# The first commands sets clk to after 0ns, then sets it to 1 after 5ns. This cycle repeats after 10ns.

force {CLOCK_50} 0 0ns , 1 {5ns} -r 10ns

# xin increment test without sufficent speedcount
force {SW[9]} 1
run 10ns

# xin increment test without sufficent speedcount
force {SW[9]} 0
run 10ns

# decrementing to incrementing change test
force {KEY[2]} 0
run 10ns

# xin decrement test with sufficent speedcount
force {SW[6]} 1
run 10ns

run 1000ns