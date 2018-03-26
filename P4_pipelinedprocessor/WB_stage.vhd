library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WB_stage is
    Port ( SEL : in  STD_LOGIC;
           memory_input   : in  STD_LOGIC_VECTOR (31 downto 0);
           ALU_input   : in  STD_LOGIC_VECTOR (31 downto 0);
           Output   : out STD_LOGIC_VECTOR (31 downto 0));
end WB_stage;

architecture Behavioral of WB_stage is
begin
    Output <= ALU_input when (SEL = '1') else memory_input;
end Behavioral;