library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;

entity registers is
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
  instruction : in std_logic_vector(31 downto 0);
	
	wb_signal : in std_logic;
	wb_addr : in std_logic_vector (4 downto 0);
	wb_data : in std_logic_vector (31 downto 0);
	
	data_out_left: out std_logic_vector (31 downto 0);
	data_out_right: out std_logic_vector (31 downto 0);
	data_out_imm: out std_logic_vector (31 downto 0); -- sign/zero extended value will come out
	shamt : out std_logic_vector(4 downto 0);
	funct : out std_logic_vector(5 downto 0);
	r_d: out std_logic_vector (4 downto 0);
	opcode: out std_logic_vector(5 downto 0);
	pseudo_address : out std_logic_vector(25 downto 0)
);
end registers;

architecture arch of registers is
type registers_body is array(0 to 31) of std_logic_vector(31 downto 0);
signal register_block : registers_body;

begin
process(clock)
begin
	if rising_edge(clock) then
    --normal operation
	  if (reset = '1') then
	    --reset all registers
			register_block<= ("00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000");
		elsif(wb_signal ='1')then
    		register_block(to_integer(unsigned(wb_addr)))<= wb_data;
		else
		  opcode <=instruction(31 downto 26);
		  data_out_left<=register_block(to_integer(unsigned(instruction(25 downto 21))));
		  data_out_right<=register_block(to_integer(unsigned(instruction(20 downto 16))));
		  r_d<=instruction(15 downto 11);
		  shamt<=instruction(10 downto 6);
		  funct<=instruction(5 downto 0);
		  pseudo_address<= instruction(25 downto 0);
		  if(
        instruction(31 downto 26) = "001100" or --andi
        instruction(31 downto 26) = "001101" --ori
      ) then
      --zero extension
      data_out_imm <= std_logic_vector(resize(unsigned(instruction(15 downto 0)),32));--zero extend
      else
      data_out_imm <= std_logic_vector(resize(signed(instruction(15 downto 0)),32));--zero extend
      end if;
    end if;
 end if;
end process;
end arch;