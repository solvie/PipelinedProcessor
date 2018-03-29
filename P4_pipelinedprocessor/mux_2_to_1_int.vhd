library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2_to_1_int is
    Port ( SEL : in  STD_LOGIC;
           A   : in  integer;
           B   : in  integer;
           Output : in integer 
           );
end mux_2_to_1_int;

architecture Behavioral of mux_2_to_1_int is
begin
    Output <= A when (SEL = '1') else B;
end Behavioral;