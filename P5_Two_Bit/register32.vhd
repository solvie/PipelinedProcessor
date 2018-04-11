library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity register32 is
generic(
  	size : INTEGER := 32
);
port( 
	rst: in std_logic; -- reset
	clk: in std_logic;
	ld: in std_logic; -- load
	d: in std_logic_vector(size-1 downto 0); -- data input
	q: out std_logic_vector(size-1 downto 0) -- output
 );
end entity register32;

architecture imp of register32 is

begin 
    process(clk, rst)
    begin
        if rst = '1' then
            q <=  std_logic_vector(to_unsigned(0,size));
        elsif rising_edge(clk) then
           if ld = '1' then
               q <= d;
           end if;
        end if;
    end process;
END imp;
