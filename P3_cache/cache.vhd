library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;

entity cache is
generic(
  ram_size : INTEGER := 32768;
  word_size : INTEGER := 32;
  cache_size : INTEGER := 32
);
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic; 
    
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is

-- declare signals here
signal input_tag : std_logic_vector(19 downto 0);
signal input_index : Integer;
signal input_byteoffset : std_logic_vector(1 downto 0);

-- cache block declaration
type cache_body is array(0 to 31) of std_logic_vector(148 downto 0);
signal cache : cache_body;

begin
  
process (clock)
  
begin
-- make circuits here
  input_tag<=s_addr(31 downto 12);
  input_index<=conv_integer(s_addr(11 downto 2));
  input_byteoffset<=s_addr(1 downto 0);
  
  IF cache(input_index)(147 downto 128) = input_tag and cache(input_index)(148)='1' THEN
      IF input_byteoffset = "00" THEN
        s_readdata <=cache(input_index)(127 downto 96);
      ELSIF input_byteoffset = "01" THEN
        s_readdata <=cache(input_index)(95 downto 64);
      ELSIF input_byteoffset = "10" THEN
        s_readdata <=cache(input_index)(63 downto 32);
      ELSIF input_byteoffset = "11" THEN
        s_readdata <=cache(input_index)(31 downto 0);
      END IF;
  
  END IF;
  
  ----for loop
  --FOR I IN 0 TO cache_size-1 LOOP   
  --END LOOP;








end process;

end arch;