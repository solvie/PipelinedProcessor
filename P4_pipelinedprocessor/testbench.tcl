proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/testbench/clock
    add wave -position end sim:/testbench/reset
    #add wave -position end sim:/testbench/im_read
    #add wave -position end sim:/Overall_tb/im_readdata
    #add wave -position end sim:/testbench/im_writedata
    #add wave -position end sim:/testbench/pc_out_as_int
add wave -position end sim:/testbench/real_cpu/s_p_2_r_s
add wave -position end sim:/testbench/real_cpu/ALUOuput_s_p
add wave -position end sim:/testbench/real_cpu/p_s_3_mux2_control
add wave -position end sim:/testbench/real_cpu/p_s_3_mux1_control
add wave -position end sim:/testbench/real_cpu/p_s_3_data_out_left
add wave -position end sim:/testbench/real_cpu/p_s_3_data_out_right
add wave -position end sim:/testbench/real_cpu/p_s_3_ALUcalc_operationcode
add wave -position end sim:/testbench/real_cpu/out_MemToReg

add wave -position end sim:/testbench/real_cpu/id_s/*

}

proc AddAll {} {
;#add all waves
    add wave -r /*
}

vlib work

;# Compile components if any
vcom instruction_memory.vhd
vcom IF_stage.vhd
vcom register32.vhd
vcom mux_2_to_1.vhd
vcom adder32.vhd
vcom testbench.vhd
vcom ALUcalc.vhd
vcom mux_2_to_1_int.vhd
vcom EX_stage.vhd
vcom registers.vhd
vcom control.vhd
vcom ID_stage.vhd
vcom data_memory.vhd
vcom EX_MEM_pipe.vhd
vcom MEM_WB_pipe.vhd
vcom IF_ID_pipe.vhd
vcom ID_EX_pipe.vhd
vcom control.vhd
vcom processor.vhd
vcom MEM_stage.vhd
vcom WB_stage.vhd

;# Start simulation
vsim testbench

;# Generate a clock with 1ns period
force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves
;#AddAll

;# Run for 50ns
run 200ns
