library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stage1_tb is
end stage1_tb;

architecture 
behavior of stage1_tb is

component adder32 is
generic(
  	size : INTEGER := 32
);
port( 
	input1: in std_logic_vector(size-1 downto 0); -- input
	input2: in std_logic_vector(size-1 downto 0); -- will be hardcoded to 4 from outside
	result: out std_logic_vector(size-1 downto 0) -- output
 );
end component;

component register32 is
generic(
  	size : INTEGER := 32
);
port( 
	rst: in std_logic; -- reset
	clk: in std_logic;
	ld: in std_logic; -- load
	d: in std_logic_vector(size-1 downto 0); -- data input
	q: out std_logic_vector(size-1 downto 0) ); -- output
end component;

-- test signals 
signal reset : std_logic := '0';
signal clock : std_logic := '0';
signal load : std_logic := '0';
signal data : std_logic_vector(31 downto 0);
signal qout : std_logic_vector(31 downto 0);
signal four : std_logic_vector(31 downto 0):=std_logic_vector(to_unsigned(4,32));

constant clk_period : time := 1 ns;

begin

-- Connect the components which we instantiated above to their
-- respective signals

dut: register32 
port map(
    clk => clock,
    rst => reset,
    ld => load,
    d => data,
    q => qout
);

add: adder32 
port map(
    input1 => qout,
    input2 => four,
    result => data
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

-- Resetting all values, then initializing in preparation for tests
  --data <= "00000000000000000000000000001010"; 
  reset<='1';
  wait for 1*clk_period;
  reset<='0';
  wait for 1*clk_period;

  load <= '1'; 


wait;

end process;
	
end;