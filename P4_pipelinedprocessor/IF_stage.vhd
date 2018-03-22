library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_stage is

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

component memory is
GENERIC(
	ram_size : INTEGER := 32768;
	mem_delay : time := 1 ns;
	clock_period : time := 1 ns
);
port (
	clock: IN STD_LOGIC;
	writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	address: IN INTEGER RANGE 0 TO ram_size-1;
	memwrite: IN STD_LOGIC;
	memread: IN STD_LOGIC;
	readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
	waitrequest: OUT STD_LOGIC
);
end component;

component mux_2_to_1 is
    Port ( SEL : in  STD_LOGIC;
           A   : in  STD_LOGIC_VECTOR (31 downto 0);
           B   : in  STD_LOGIC_VECTOR (31 downto 0);
           Output   : out STD_LOGIC_VECTOR (31 downto 0));
end component;


signal reset : std_logic := '0';
signal clock : std_logic := '0';
signal load : std_logic := '0';
signal selectsig : std_logic;

signal adder_out : std_logic_vector(31 downto 0);
signal mux_out : std_logic_vector(31 downto 0);
signal pc_out : std_logic_vector(31 downto 0);
signal four : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(4,32));

signal temp : std_logic_vector(31 downto 0); -- this will come from the EX/MEM buffer

constant clk_period : time := 1 ns;

begin

pc: register32 
port map(
	clk => clock,
	rst => reset,
	ld => load,
	d => mux_out,
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
	SEL => selectsig,
	A   => adder_out,
	B   => temp,
	Output   => mux_out
);

clk_process : process
begin
  clock <= '0';
  wait for clk_period/2;
  clock <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin

  reset<='1';
  selectsig<= '1';
  temp <= std_logic_vector(to_unsigned(40,32));
  wait for 1*clk_period;
  reset<='0';
  wait for 1*clk_period;
  load <= '1'; 

  wait for 5*clk_period;
  selectsig<= '0';

wait;

end process;
	
end;
