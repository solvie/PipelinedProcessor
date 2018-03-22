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

}

proc AddAll {} {
;#add all waves
    add wave -r /*
}

vlib work

;# Compile components if any
vcom registers.vhd
vcom ID_stage.vhd

;# Start simulation
vsim ID_stage

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
 AddWaves
;#AddAll

;# Run for 300 ns
run 300ns
