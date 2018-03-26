library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_WB_pipe is
port( 
	clock : IN std_logic;
	reset : IN std_logic;
	mem_in : IN std_logic_vector(31 downto 0); -- memory from data memory in
	mem_out : OUT std_logic_vector(31 downto 0); -- memory from data memory out
	ALU_in : IN std_logic_vector(31 downto 0); -- EX ALU in 
	ALU_out : OUT std_logic_vector(31 downto 0); --EX ALU out
	instruction_in : IN std_logic_vector(31 downto 0); -- instruction in 
	instruction_out : OUT std_logic_vector(31 downto 0); -- instruction out
    sel_sig_in : IN std_logic; -- select signal for mux in WB stage in
    sel_sig_out : OUT std_logic -- select signal for mux in WB stage out
 );
end MEM_WB_pipe;

architecture behavior of MEM_WB_pipe is

begin

process(reset, clock)
    begin
        if reset = '1' then
            mem_out <= (others => '0'); 
            ALU_out <= (others => '0');
            instruction_out <= (others => '0');
        elsif rising_edge(clock) then
            mem_out	<= instruction_in;
            ALU_out	<= ALU_in;
            instruction_out <= instruction_in;
            sel_sig_out <= sel_sig_in;
        end if;
    end process;
end;