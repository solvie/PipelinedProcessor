library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2_to_1 is
    Port ( SEL : in  STD_LOGIC;
           A   : in  STD_LOGIC_VECTOR (31 downto 0);
           B   : in  STD_LOGIC_VECTOR (31 downto 0);
           Output   : out STD_LOGIC_VECTOR (31 downto 0));
end mux_2_to_1;

architecture Behavioral of mux_2_to_1 is
begin
    Output <= A when (SEL = '1') else B;
end Behavioral;