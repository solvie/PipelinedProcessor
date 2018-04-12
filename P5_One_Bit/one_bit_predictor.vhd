library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
entity one_bit_predictor is
    Port ( clock : IN std_logic;
            instruction : IN STD_LOGIC_VECTOR (31 downto 0);
           pc_as_int_input: in integer;
           previous_pc_output: out integer;
           address_output : out STD_LOGIC_VECTOR(31 downto 0);
           branch_outcome : in std_logic := '0';
           branch_index : in integer:= 0;
           predict_taken   : out STD_LOGIC := '0'
           );
end one_bit_predictor;

architecture Behavioral of one_bit_predictor is
type one_bit_bpb is array(15 downto 0) of std_logic;
signal btb1: one_bit_bpb := (others => '0');
begin

process(branch_index)
begin
btb1(branch_index) <= branch_outcome;
end process;

process(clock)
begin
    if(instruction(31 downto 26) = "000100") then
        if(btb1(to_integer(unsigned(instruction(3 downto 0)))) = '0') then
            predict_taken <= '0';
            address_output <= std_logic_vector(resize(unsigned(instruction(15 downto 0)),32) + pc_as_int_input);
            previous_pc_output <= pc_as_int_input;
        else
            predict_taken <= '1';
            address_output <= std_logic_vector(resize(unsigned(instruction(15 downto 0)),32) + pc_as_int_input);
            previous_pc_output <= pc_as_int_input;
        end if;
    else
        predict_taken <= '0';
    end if;

end process;
end Behavioral;