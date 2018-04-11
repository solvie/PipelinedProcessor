library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity one_bit_predictor is
    Port ( instruction : IN STD_LOGIC_VECTOR (31 downto 0);
    	   pc_as_int_input : IN integer;
           predict_taken   : out STD_LOGIC := '0'
           );
end one_bit_predictor;

architecture Behavioral of one_bit_predictor is
begin
    if(instruction(31 downto 26) = "000100") then

    end if;
end Behavioral;