proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/Overall_tb/clock
    add wave -position end sim:/Overall_tb/reset
    add wave -position end sim:/Overall_tb/mux_input_to_stage1
    add wave -position end sim:/Overall_tb/mux_select_sig_to_stage1
    add wave -position end sim:/Overall_tb/mux_output_stage_1
    add wave -position end sim:/Overall_tb/verify_instMem
    #add wave -position end sim:/Overall_tb/memory_out_stage_1
}

proc AddAll {} {
;#add all waves
    add wave -r /*
}

vlib work

;# Compile components if any
vcom instruction_memory.vhd
vcom IF_stage_for_Overall_Testing.vhd
vcom register32.vhd
vcom mux_2_to_1.vhd
vcom adder32.vhd
vcom Overall_tb.vhd

;# Start simulation
vsim Overall_tb

;# Generate a clock with 1ns period
force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
 AddWaves
;#AddAll

;# Run for 50ns
run 50ns