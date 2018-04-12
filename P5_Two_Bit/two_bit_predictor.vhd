library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
entity two_bit_predictor is
    Port ( clock : IN std_logic;
            instruction : IN STD_LOGIC_VECTOR (31 downto 0);
    	   pc_as_int_input: in integer;
    	   previous_pc_output: out integer;
    	   address_output : out STD_LOGIC_VECTOR(31 downto 0);
    	   branch_outcome : in std_logic;
    	   branch_index : in integer:= 0;
           predict_taken   : out STD_LOGIC := '0'
           );
end two_bit_predictor;

architecture Behavioral of two_bit_predictor is
type two_bit_bpb is array(15 downto 0) of std_logic_vector(1 downto 0);
signal btb1: two_bit_bpb := (others => "00");
begin
process(branch_outcome)
begin
if(btb1(branch_index) = "00") then
    if(branch_outcome = '1') then
        btb1(branch_index) <= "01";
    else 
        btb1(branch_index) <= "00";
    end if;

elsif(btb1(branch_index) = "01") then
    if(branch_outcome = '1') then
        btb1(branch_index) <= "11";
    else 
        btb1(branch_index) <= "00";
    end if;

elsif(btb1(branch_index) = "01") then
    if(branch_outcome = '1') then
        btb1(branch_index) <= "11";
    else 
        btb1(branch_index) <= "00";
    end if;
elsif(btb1(branch_index) = "11") then
    if(branch_outcome = '1') then
        btb1(branch_index) <= "11";
    else 
        btb1(branch_index) <= "10";
    end if;

elsif(btb1(branch_index) = "10") then
    if(branch_outcome = '1') then
        btb1(branch_index) <= "11";
    else 
        btb1(branch_index) <= "00";
    end if;

end if;
end process;

process(clock)
begin
    if(instruction(31 downto 26) = "000100") then --beq
    	if(btb1(to_integer(unsigned(instruction(3 downto 0))))(1) = '0') then
    		predict_taken <= '0';
            address_output <= std_logic_vector(resize(unsigned(instruction(15 downto 0)),32) + pc_as_int_input);
            previous_pc_output <= pc_as_int_input;
    	else
    		predict_taken <= '1';
    		address_output <= std_logic_vector(resize(unsigned(instruction(15 downto 0)),32) + pc_as_int_input);
    		previous_pc_output <= pc_as_int_input;
    	end if;
    elsif (instruction(31 downto 26) = "000101") then --bne
        if(btb1(to_integer(unsigned(instruction(3 downto 0))))(1) = '0') then
            predict_taken <= '0';
            address_output <= std_logic_vector(resize(unsigned(instruction(15 downto 0)),32) + pc_as_int_input);
            previous_pc_output <= pc_as_int_input;
        else
            predict_taken <= '1';
            address_output <= std_logic_vector(resize(unsigned(instruction(15 downto 0)),32) + pc_as_int_input);
            previous_pc_output <= pc_as_int_input;
        end if;
    else
        previous_pc_output <= pc_as_int_input;
        predict_taken <= '0';
    end if;
end process;

end Behavioral;