library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_tb is
end cache_tb;

architecture behavior of cache_tb is

component cache is
generic(
    ram_size : INTEGER := 32768
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
end component;

component memory is 
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    waitrequest: OUT STD_LOGIC
);
end component;
	
-- test signals 
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal s_addr : std_logic_vector (31 downto 0);
signal s_read : std_logic;
signal s_readdata : std_logic_vector (31 downto 0);
signal s_write : std_logic;
signal s_writedata : std_logic_vector (31 downto 0);
signal s_waitrequest : std_logic;

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic; 

begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: cache 
port map(
    clock => clk,
    reset => reset,

    s_addr => s_addr,
    s_read => s_read,
    s_readdata => s_readdata,
    s_write => s_write,
    s_writedata => s_writedata,
    s_waitrequest => s_waitrequest,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_write => m_write,
    m_writedata => m_writedata,
    m_waitrequest => m_waitrequest
);

MEM : memory
port map (
    clock => clk,
    writedata => m_writedata,
    address => m_addr,
    memwrite => m_write,
    memread => m_read,
    readdata => m_readdata,
    waitrequest => m_waitrequest
);
				

clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin

-- put your tests here

 reset<='1';
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait for 1*clk_period;

  -- CASES NOT DIRTY
  --1) write in 0x00000000 (BLOCK 0 IN INDEX 0)
  s_read <= '0'; 
  s_write <='1';
  s_addr <= "00000000000000000000000000000000"; 
  s_writedata <= "11100000000000000000000000000101";
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;
  
  --2) read from 0x00000000
  s_read <= '1'; 
  s_write <='0';
  s_addr <= "00000000000000000000000000000000"; 
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;
  
  --3) write to 0x00000001 (BLOCK 1 IN INDEX 0)
  s_read <= '0'; 
  s_write <='1';
  s_addr <= "00000000000000000000000000000001"; 
  s_writedata <= "10111000000000011100000000010010";
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;
  
  --4) read from 0x00000001
  s_read <= '1'; 
  s_write <='0';
  s_addr <= "00000000000000000000000000000001"; 
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;

  --5) write to 0x00000001 (BLOCK 2 IN INDEX 0)
  s_read <= '0'; 
  s_write <='1';
  s_addr <= "00000000000000000000000000000010"; 
  s_writedata <= "00000000000000000000000000000000";
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;

  --6) write to 0x00000001 (BLOCK 3 IN INDEX 0)
  s_read <= '0'; 
  s_write <='1';
  s_addr <= "00000000000000000000000000000011"; 
  s_writedata <= "11111111111111111111111111111111";
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;

  -- Up to this point, one block has been written to.
  
  -- blocks = 32blocks, 2048 in mem, 2^6 address difference for direct mapped
  -- CASE DIRTY BIT = 1 on addr 0x00000000 from 1) and tag is not equal, addr 0x00000000 and addr 0x00000032

  --7) write in 0x00000032 (BLOCK 0 AT INDEX 0, BUT FOR DIFFERENT TAG THAN BEFORE)
  -- cache miss happens here, and must evict current cache entry at index 0 to replace with this one
  s_read <= '0'; 
  s_write <='1';
  s_addr <= "00000000000000000001000000000000";  
  s_writedata <= "00000000000000000000000000000100";
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;
  
  --8) read from 0x00000032 
  s_read <= '1'; 
  s_write <='0';
  s_addr <= "00000000000000000001000000000000"; 
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;
  
  --9) check 0x00000000
  s_read <= '1'; 
  s_write <='0';
  s_addr <= "00000000000000000000000000000000"; 
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;
  
  --10) write invalid clean 
  s_read <= '0';
  s_write <= '1';
  s_addr <= std_logic_vector(to_unsigned(16, 32)); 
  s_writedata <= "00001111000111101011010100001111";
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0'; 
  wait for 1*clk_period;
  
  --11) write valid dirty
  s_read <= '0';
  s_write <= '1';
  s_writedata <= "11000000000000001100000000000011";
  s_addr <= std_logic_vector(to_unsigned(16, 32)); 
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;
  
  --12) read data from 9)
  s_read <= '1';
  s_write <= '0';
  s_addr <= std_logic_vector(to_unsigned(16, 32)); 
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;
  
  --13)retest
  --write
  s_read <= '0'; 
  s_write <='1';
  s_addr <= "00000000000000000000000000000000"; 
  s_writedata <= "00000000000000000000000000000001";
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
  wait until s_waitrequest = '0';
  wait for 1*clk_period;
  
  --14) read
  s_read <= '1'; 
  s_write <='0';
  s_addr <= "00000000000000000000000000000000"; 
  wait for 1*clk_period;
  reset<='0';
  s_write <= '0' ;
  s_read <= '0'; 
wait;


end process;
	
end;