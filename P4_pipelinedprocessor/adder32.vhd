library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity adder32 is -- This is an adder with 32 bit inputs
port( 
	input1: in std_logic_vector(31 downto 0); -- input
	input2: in std_logic_vector(31 downto 0); -- will be hardcoded to 4 from outside
	result: out std_logic_vector(31 downto 0) -- output
 );
end entity adder32;

architecture imp of adder32 is

begin 
    process(input1)
    begin
	if (not Is_X(input1)) then 
		result<= std_logic_vector(unsigned(input1)+unsigned(input2));
	end if;
    end process;
END imp;
