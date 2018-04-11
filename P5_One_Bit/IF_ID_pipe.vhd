library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_ID_pipe is
port(
	clock : IN std_logic;
	reset : IN std_logic;
	instruction_in : IN std_logic_vector(31 downto 0);
	instruction_out : OUT std_logic_vector(31 downto 0);
	instr_loc_in : IN std_logic_vector(31 downto 0);
	instr_loc_out : OUT std_logic_vector(31 downto 0)
 );
end IF_ID_pipe;

architecture behavior of IF_ID_pipe is

begin

process(reset,clock)
    begin
        if reset = '1' then
            instruction_out  <= (others => '0');
            instr_loc_out	 <= (others => '0');
        elsif (rising_edge(clock)) then
			instruction_out   <= instruction_in;
			instr_loc_out     <= instr_loc_in;
		end if;
    end process;
end;
