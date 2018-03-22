proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/IF_stage/clock
    add wave -position end sim:/IF_stage/reset
    add wave -position end sim:/IF_stage/load
    add wave -position end sim:/IF_stage/pc_out
}

proc AddAll {} {
;#add all waves
    add wave -r /*
}

vlib work

;# Compile components if any
vcom IF_stage.vhd
vcom register32.vhd
vcom adder32.vhd
vcom InstructionMemory.vhd
vcom mux_2_to_1.vhd


;# Start simulation
vsim IF_stage

;# Generate a clock with 1ns period
force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
 AddWaves
;#AddAll

;# Run for 50ns
run 50ns
