proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/stage1_tb/clock
    add wave -position end sim:/stage1_tb/reset
    add wave -position end sim:/stage1_tb/load
    add wave -position end sim:/stage1_tb/data
    add wave -position end sim:/stage1_tb/qout
}

proc AddAll {} {
;#add all waves
    add wave -r /*
}

vlib work

;# Compile components if any
vcom stage1_tb.vhd
vcom register32.vhd


;# Start simulation
vsim stage1_tb

;# Generate a clock with 1ns period
force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
 AddWaves
;#AddAll

;# Run for 50ns
run 50ns
