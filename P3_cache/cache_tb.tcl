proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/fsm_tb/clk
    add wave -position end sim:/fsm_tb/s_reset
    add wave -position end sim:/fsm_tb/s_input
    add wave -position end sim:/fsm_tb/s_output
}

;#    clock : in std_logic;
;#    reset : in std_logic;
;#
;#    -- Avalon interface --
;#    s_addr : in std_logic_vector (31 downto 0);
;#    s_read : in std_logic;
;#    s_readdata : out std_logic_vector (31 downto 0);
;#    s_write : in std_logic;
;#    s_writedata : in std_logic_vector (31 downto 0);
;#    s_waitrequest : out std_logic; 

    m_addr : out integer range 0 to ram_size-1;
    m_read : out std_logic;
    m_readdata : in std_logic_vector (7 downto 0);
    m_write : out std_logic;
    m_writedata : out std_logic_vector (7 downto 0);
    m_waitrequest : in std_logic

vlib work

;# Compile components if any
vcom fsm.vhd
vcom fsm_tb.vhd

;# Start simulation
vsim fsm_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run for 50 ns
run 50ns
