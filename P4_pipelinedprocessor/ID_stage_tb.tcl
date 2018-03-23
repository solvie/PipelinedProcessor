proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/ID_stage/clk
    add wave -position end sim:/ID_stage/rst

    add wave -position end sim:/ID_stage/s_data_out_left
    add wave -position end sim:/ID_stage/s_data_out_right
    add wave -position end sim:/ID_stage/s_data_out_imm 
    add wave -position end sim:/ID_stage/s_shamt
    add wave -position end sim:/ID_stage/s_funct 
    add wave -position end sim:/ID_stage/s_r_d
    add wave -position end sim:/ID_stage/s_opcode
    add wave -position end sim:/ID_stage/s_pseudo_address
    add wave -position end sim:/ID_stage/s_RegDst   
    add wave -position end sim:/ID_stage/s_ALUSrc  
    add wave -position end sim:/ID_stage/s_MemtoReg
    add wave -position end sim:/ID_stage/s_RegWrite
    add wave -position end sim:/ID_stage/s_MemRead 
    add wave -position end sim:/ID_stage/s_MemWrite
    add wave -position end sim:/ID_stage/s_Branch  
    add wave -position end sim:/ID_stage/s_ALUctrl 

}

proc AddAll {} {
;#add all waves
    add wave -r /*
}

vlib work

;# Compile components if any
vcom registers.vhd
vcom ID_stage.vhd
vcom control.vhd

;# Start simulation
vsim ID_stage

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
 AddWaves
;#AddAll

;# Run for 100ns
run 100ns
