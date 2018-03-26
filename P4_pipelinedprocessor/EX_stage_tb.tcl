proc AddWaves {} {
	#Add waves we're interested in to the Wave window
    add wave -position end sim:/EX_stage_tb/clk
    add wave -position end sim:/EX_stage_tb/rst

}

proc AddAll {} {
;#add all waves
    add wave -r /*
}

vlib work

;# Compile components if any
vcom ALUcalc.vhd
vcom mux_2_to_1.vhd
vcom EX_stage.vhd
vcom EX_stage_tb.vhd

;# Start simulation
vsim EX_stage_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
 AddWaves
;#AddAll

;# Run for 100ns
run 100ns
