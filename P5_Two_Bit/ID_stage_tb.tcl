proc AddWaves {} {
	#Add waves we're interested in to the Wave window
    add wave -position end sim:/ID_stage_tb/clock
    add wave -position end sim:/ID_stage_tb/rst
		add wave -position end sim:/ID_stage_tb/s_instruction
    add wave -position end sim:/ID_stage_tb/s_data_out_left
    add wave -position end sim:/ID_stage_tb/s_data_out_right
    add wave -position end sim:/ID_stage_tb/s_data_out_imm
    add wave -position end sim:/ID_stage_tb/s_shamt
    add wave -position end sim:/ID_stage_tb/s_r_s
    add wave -position end sim:/ID_stage_tb/s_pseudo_address
    add wave -position end sim:/ID_stage_tb/s_RegDst

    add wave -position end sim:/ID_stage_tb/s_MemtoReg
    add wave -position end sim:/ID_stage_tb/s_MemRead
    add wave -position end sim:/ID_stage_tb/s_MemWrite
    add wave -position end sim:/ID_stage_tb/s_Branch

}

proc AddAll {} {
;#add all waves
    add wave -r /*
}

vlib work

;# Compile components if any
vcom registers.vhd
vcom control.vhd
vcom ID_stage.vhd
vcom ID_stage_tb.vhd

;# Start simulation
vsim ID_stage_tb

;# Generate a clock with 1ns period
force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
;# AddWaves
AddAll

;# Run for 100ns
run 100ns
