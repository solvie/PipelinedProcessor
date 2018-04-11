library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_3_to_1 is
    Port ( SEL_Jump : in  STD_LOGIC;
    	   SEL_Predictor : in STD_LOGIC;
           A   : in  STD_LOGIC_VECTOR (31 downto 0);
           B   : in  STD_LOGIC_VECTOR (31 downto 0);
           C   : in STD_LOGIC_VECTOR(31 downto 0);
           Output   : out STD_LOGIC_VECTOR (31 downto 0));
end mux_3_to_1;

architecture Behavioral of mux_3_to_1 is
begin
--process(SEL_Jump, SEL_Predictor)
--begin
  Output <= A when (SEL_Jump = '1') else 
            C when (SEL_Predictor = '1') else
            B;
	--if(SEL_Jump = '1') then
	--	Output <= A;
	--elsif(SEL_Predictor = '1') then
	--	Output <= C;
	--else
	--	Output <= B;
 --   end if;
--end process;
end Behavioral;