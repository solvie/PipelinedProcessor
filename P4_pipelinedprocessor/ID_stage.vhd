library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_stage is

end ID_stage;

architecture behavior of ID_stage is
component registers is
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
end component;

signal rst : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal s_instruction : std_logic_vector(31 downto 0);
	
signal s_wb_signal : std_logic;
signal	s_wb_addr : std_logic_vector (4 downto 0);
signal	s_wb_data : std_logic_vector (31 downto 0);
	
signal	s_data_out_left: std_logic_vector (31 downto 0);
signal	s_data_out_right: std_logic_vector (31 downto 0);
signal	s_data_out_imm: std_logic_vector (31 downto 0); -- sign/zero extended value will come out
signal	s_shamt : std_logic_vector(4 downto 0);
signal	s_funct : std_logic_vector(5 downto 0);
signal	s_r_d: std_logic_vector (4 downto 0);
signal	s_opcode: std_logic_vector(5 downto 0);
signal	s_pseudo_address : std_logic_vector(25 downto 0);

begin
reg : registers
port map(
  clock =>clk,
  reset =>rst,
	
	-- Avalon interface --
  instruction =>s_instruction,
	
	wb_signal =>s_wb_signal,
	wb_addr =>s_wb_addr,
	wb_data =>s_wb_data,
	
	data_out_left=>s_data_out_left,
	data_out_right=>s_data_out_right,
	data_out_imm=>s_data_out_imm,
	shamt =>s_shamt,
	funct =>s_funct,
	r_d=>s_r_d,
	opcode=>s_opcode,
	pseudo_address =>s_pseudo_address
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

  rst<='1';
  wait for 1*clk_period;
  rst<='0';
  --s_instruction <= "000011 00001 00001 00001 00001 000000"
  s_wb_signal<='1';
  s_wb_addr <="00001";
	s_wb_data <="11111111111111111111111111111111";
	
  wait for 1*clk_period;
  s_wb_signal<='0';
  s_instruction <= "00001100001000010000100001000000";
  
  wait for 1*clk_period;
  s_instruction <= "00011100011000110001100011000001";
  
  wait for 1*clk_period;
  s_instruction <= "00001100001000010000100001000000";
  
  wait for 1*clk_period;
  s_instruction <= "00001100001000010000100001000000";
  
  wait for 1*clk_period;
  s_wb_signal<='1';
  s_wb_addr <="00011";
	s_wb_data <="11111111111111111111111111111111";
	s_instruction <= "00011100011000110001100011000000";
  wait for 1*clk_period;
  s_wb_signal<='0';
  s_instruction <= "00011100011000110001100011000000";

wait;

end process;
	
end;
