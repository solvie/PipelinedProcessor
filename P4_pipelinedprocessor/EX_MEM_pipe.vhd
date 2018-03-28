library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_MEM_pipe is
  port( 
  reset : IN std_logic;
	clock : IN std_logic;
	
	ALUOuput :	in STD_LOGIC_VECTOR (31 downto 0);
  zeroOut :	in STD_LOGIC;
	mux3_control : in std_logic;
	MemRead : in std_logic;
	MemWrite : in std_logic;
	address : in std_logic_vector(31 downto 0);
	
	mem_writedata: out STD_LOGIC_VECTOR (31 DOWNTO 0);
	mem_address: out INTEGER;-- RANGE 0 TO ram_size-1;
	mem_memwrite: out STD_LOGIC;
	mem_memread: out STD_LOGIC;
	
	mem_write_to_file: out STD_LOGIC
 );
end EX_MEM_pipe;

architecture behavior of EX_MEM_pipe is

begin

process(reset, clock)
    begin
        if reset = '1' then
            ALUOutput <= "00000000000000000000000000000000";
            zeroOut <= "00000000000000000000000000000000";
          	 mux3_control <= "00000000000000000000000000000000";
          	 MemRead <= "00000000000000000000000000000000";
         	  MemWrite <= "00000000000000000000000000000000";
         	  address<=
        elsif rising_edge(clock) then
            mem_writedata <=ALUOuput;
	          mem_address<=address;
           	mem_memwrite<=MemWrite;
           	mem_memread<=MemRead;
           	mem_write_to_file <='1'
        end if;
    end process;
end;