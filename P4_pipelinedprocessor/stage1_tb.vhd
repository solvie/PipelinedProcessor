library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stage1_tb is
end stage1_tb;

architecture 
behavior of stage1_tb is

component IF_stage is
port( 
	clock : IN std_logic;
	reset : IN std_logic;
	mux_input_to_stage1 : IN std_logic_vector(31 downto 0); -- this will come from the EX/MEM buffer
	mux_select_sig_to_stage1 : IN std_logic;
	mux_output_stage_1 : INOUT std_logic_vector(31 downto 0)
	--memory_out_stage_1 : OUT std_logic_vector(31 downto 0)
 );
end component;

constant clk_period : time := 1 ns;

signal clock : std_logic := '0';
signal reset : std_logic;
signal mux_input_to_stage1 : std_logic_vector(31 downto 0);
signal mux_select_sig_to_stage1: std_logic;
signal mux_output_stage_1 : std_logic_vector(31 downto 0);
--signal memory_out_stage_1 : std_logic_vector(31 downto 0);

begin

stage1: IF_stage 
port map(
    clock => clock,
    reset => reset,
    mux_input_to_stage1 => mux_input_to_stage1,
    mux_select_sig_to_stage1 => mux_select_sig_to_stage1,
    mux_output_stage_1 => mux_output_stage_1
    --memory_out_stage_1 => memory_out_stage_1
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
  mux_select_sig_to_stage1<= '1';
  mux_input_to_stage1 <= std_logic_vector(to_unsigned(0,32));
  wait for 1*clk_period;
  reset<='0';

  wait for 7*clk_period;
  mux_select_sig_to_stage1<= '0';

  wait for 1*clk_period;
  mux_select_sig_to_stage1<= '1';

wait;

end process;
	
end;