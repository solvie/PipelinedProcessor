proc AddWaves {} {
	#Add waves we're interested in to the Wave window


add wave -position end sim:/EX_stage_tb/rst
add wave -position end sim:/EX_stage_tb/clk

	
add wave -position end sim:/EX_stage_tb/s_ALUcalc_operationcode
add wave -position end sim:/EX_stage_tb/s_data_out_left
add wave -position end sim:/EX_stage_tb/s_data_out_right
add wave -position end sim:/EX_stage_tb/s_data_out_imm
add wave -position end sim:/EX_stage_tb/s_funct 

add wave -position end sim:/EX_stage_tb/s_r_s
add wave -position end sim:/EX_stage_tb/s_pseudo_address

add wave -position end sim:/EX_stage_tb/s_mux1_control
add wave -position end sim:/EX_stage_tb/s_mux2_control
add wave -position end sim:/EX_stage_tb/s_mux3_control
add wave -position end sim:/EX_stage_tb/s_MemRead
add wave -position end sim:/EX_stage_tb/s_MemWrite
	
add wave -position end sim:/EX_stage_tb/s_zeroOut
	
add wave -position end sim:/EX_stage_tb/s_out_mux3_control
add wave -position end sim:/EX_stage_tb/s_out_MemRead
add wave -position end sim:/EX_stage_tb/s_out_MemWrite
add wave -position end sim:/EX_stage_tb/s_address
add wave -position end sim:/EX_stage_tb/s_ALUOutput

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
;# AddWaves
AddAll

;# Run for 100ns
run 100ns
