library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_WB_pipe is
port( 
	clock : IN std_logic;
	reset : IN std_logic;
	mem_in : IN std_logic_vector(31 downto 0); --output memory from data memory
	mem_out : OUT std_logic_vector(31 downto 0); -- input into wb
	ALU_in : IN std_logic_vector(31 downto 0); --output EX ALU
	ALU_out : OUT std_logic_vector(31 downto 0); --input EX ALU into wb
	instruction_in : IN std_logic_vector(31 downto 0);
	instruction_out : OUT std_logic_vector(31 downto 0)
 );
end MEM_WB_pipe;

architecture behavior of MEM_WB_pipe is

begin

process(reset, clock)
    begin
        if reset = '1' then
            mem_out     <= (others => '0'); 
            ALU_out	 <= (others => '0');
            instruction_out	 <= (others => '0');
        elsif rising_edge(clock) then
            mem_out	<= instruction_in;
            ALU_out	<= ALU_in;
            instruction_out <= instruction_in;
        end if;
    end process;
end;