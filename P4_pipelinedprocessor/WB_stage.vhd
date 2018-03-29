library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WB_stage is
    Port ( SEL : in  STD_LOGIC;
           memory_input   : in  STD_LOGIC_VECTOR (31 downto 0);
           ALU_input   : in  STD_LOGIC_VECTOR (31 downto 0);
           Output_wb   : out STD_LOGIC_VECTOR (31 downto 0);
           pseudo_address_in : in STD_LOGIC_VECTOR (25 downto 0);
    	   pseudo_address_out : out STD_LOGIC_VECTOR (25 downto 0);
    	   clock : IN std_logic;
    	   r_s_in : in STD_LOGIC_VECTOR (4 downto 0);
    	   r_s_out : out STD_LOGIC_VECTOR (4 downto 0)
);
end WB_stage;

architecture Behavioral of WB_stage is
begin
    Output_wb <= memory_input when (SEL = '1') else memory_input;
    pseudo_address_out <= pseudo_address_in;
    r_s_out <= r_s_in;
end Behavioral;