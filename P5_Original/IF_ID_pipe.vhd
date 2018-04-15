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
	instr_loc_out : OUT std_logic_vector(31 downto 0);
	previous_pc_in : in integer;
	previous_pc_out : out integer;
	branch_outcome_in : in std_logic;
	branch_outcome_out : out std_logic := '0';
	branch_index_in : in integer;
	branch_index_out : out integer  := 0;
	predict_taken_in : in std_logic;
	predict_taken_out : out std_logic
 );
end IF_ID_pipe;

architecture behavior of IF_ID_pipe is

begin

process(reset,clock)
    begin
        if reset = '1' then
            instruction_out  <= (others => '0');
            instr_loc_out	 <= (others => '0');
            previous_pc_out <= 0;
			branch_outcome_out <= '0';
			branch_index_out <= 0;
			predict_taken_out <= '0';
        elsif (rising_edge(clock)) then
			instruction_out   <= instruction_in;
			instr_loc_out     <= instr_loc_in;
			previous_pc_out <= previous_pc_in;
			branch_outcome_out <= branch_outcome_in;
			branch_index_out <= branch_index_in;
			predict_taken_out <= predict_taken_in;
		end if;
    end process;
end;
