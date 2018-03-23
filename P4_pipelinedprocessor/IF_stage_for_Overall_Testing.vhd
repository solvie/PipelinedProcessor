library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_stage is
port( 
	clock : IN std_logic;
	reset : IN std_logic;
	mux_input_to_stage1 : IN std_logic_vector(31 downto 0); -- this will come from the EX/MEM buffer
	mux_select_sig_to_stage1 : IN std_logic;
	mux_output_stage_1 : INOUT std_logic_vector(31 downto 0)
	--memory_out_stage_1 : OUT std_logic_vector(31 downto 0)
 );
end IF_stage;

architecture behavior of IF_stage is
component adder32 is
port( 
	input1: in std_logic_vector(31 downto 0); -- input
	input2: in std_logic_vector(31 downto 0); -- will be hardcoded to 4 from outside
	result: out std_logic_vector(31 downto 0) -- output
 );
end component;

component register32 is
port( 
	rst: in std_logic; -- reset
	clk: in std_logic;
	ld: in std_logic; -- load
	d: in std_logic_vector(31 downto 0); -- data input
	q: out std_logic_vector(31 downto 0) ); -- output
end component;

component mux_2_to_1 is
Port ( 
	SEL : in  STD_LOGIC;
        A   : in  STD_LOGIC_VECTOR (31 downto 0);
        B   : in  STD_LOGIC_VECTOR (31 downto 0);
        Output   : out STD_LOGIC_VECTOR (31 downto 0)
);
end component;

signal load : std_logic := '1';
signal adder_out : std_logic_vector(31 downto 0);
signal pc_out : std_logic_vector(31 downto 0);
signal four : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(4,32));

begin
pc: register32 
port map(
	clk => clock,
	rst => reset,
	ld => load,
	d => mux_output_stage_1,
	q => pc_out
);

adder: adder32 
port map(
	input1 => pc_out,
 	input2 => four,
	result => adder_out
);

mux: mux_2_to_1
port map(
	SEL => mux_select_sig_to_stage1,
	A   => adder_out,
	B   => mux_input_to_stage1,
	Output   => mux_output_stage_1
);
	
end;