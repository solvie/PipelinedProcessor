library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_stage_tb is
port(
	instruction: in std_logic_vector(31 downto 0);
	instruction_loc_in : in std_logic_vector(31 downto 0);
	instruction_loc_out : out std_logic_vector(31 downto 0)

);
end ID_stage_tb;

architecture behavior of ID_stage_tb is
component ID_stage is
port(
	clock : IN std_logic;
	reset : IN std_logic;

	instruction: in std_logic_vector(31 downto 0);
	instruction_loc_in : in std_logic_vector(31 downto 0);
	instruction_loc_out : out std_logic_vector(31 downto 0);

	-- from registers
	wb_signal : in std_logic;
	wb_addr : in std_logic_vector (4 downto 0);
	wb_data : in std_logic_vector (31 downto 0);

	data_out_left: out std_logic_vector (31 downto 0);
	data_out_right: out std_logic_vector (31 downto 0);
	data_out_imm: out std_logic_vector (31 downto 0); -- sign/zero extended value will come out

	shamt : out std_logic_vector(4 downto 0);
	r_s: out std_logic_vector (4 downto 0);
	pseudo_address : out std_logic_vector(25 downto 0);

	-- from control
	RegDst   : out std_logic;
	MemtoReg : out std_logic;
	MemRead  : out std_logic;
	MemWrite : out std_logic;
	Branch   : out std_logic;

	ALUcalc_operationcode : out std_logic_vector(3 downto 0);

	write_to_file : in std_logic
);
end component;

signal rst : std_logic := '0';
signal clock : std_logic := '0';

constant clk_period : time := 1 ns;

signal s_instruction : std_logic_vector(31 downto 0);

signal s_wb_signal : std_logic;
signal	s_wb_addr : std_logic_vector (4 downto 0);
signal	s_wb_data : std_logic_vector (31 downto 0);

signal	s_data_out_left: std_logic_vector (31 downto 0);
signal	s_data_out_right: std_logic_vector (31 downto 0);
signal	s_data_out_imm: std_logic_vector (31 downto 0); -- sign/zero extended value will come out
signal	s_shamt : std_logic_vector(4 downto 0);
signal	s_r_s: std_logic_vector (4 downto 0);
signal	s_pseudo_address : std_logic_vector(25 downto 0);

signal  s_RegDst   : std_logic;
signal	s_MemtoReg : std_logic;
signal	s_RegWrite : std_logic;
signal	s_MemRead  : std_logic;
signal	s_MemWrite : std_logic;
signal	s_Branch   : std_logic;

signal ALUcalc_operationcode : std_logic_vector(3 downto 0);

signal s_write_to_file : std_logic;

begin

id_s : ID_stage
port map(
	clock =>clock,
	reset =>rst,

	instruction =>s_instruction,
	instruction_loc_in=> instruction_loc_in,
	instruction_loc_out=>instruction_loc_out,
  wb_signal =>s_wb_signal,
	wb_addr    =>s_wb_addr,
	wb_data    =>s_wb_data,

	data_out_left =>s_data_out_left,
	data_out_right=>s_data_out_right,
	data_out_imm  =>s_data_out_imm,

	shamt         =>s_shamt,
	r_s           =>s_r_s,
	pseudo_address=>s_pseudo_address,

  RegDst   => s_RegDst,

  MemtoReg => s_MemtoReg,
  MemRead  => s_MemRead,
  MemWrite => s_MemWrite,
  Branch   => s_Branch,

  ALUcalc_operationcode => ALUcalc_operationcode,
  write_to_file => s_write_to_file
);


clock_process : process
begin
  clock <= '0';
  wait for clk_period/2;
  clock <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin

  rst<='1';

  wait for 1*clk_period;
  rst<='0';
	s_wb_signal<='0';
  --s_instruction <= "000011 00001 00001 00001 00001 000000"
--  s_instruction <= "00000000000000000000000000000000";


  wait for 1*clk_period;
  s_instruction <= "00001100001000010000100001000000";
	s_wb_signal<='1';
	s_wb_addr <="00011";
	s_wb_data <="11111111111111111111111111111111";
	wait for 1*clk_period;
  s_instruction <= "00001100001000010000100001000001";
	s_wb_signal<='1';
	s_wb_addr <="00100";
	s_wb_data <="11111111111111111111111111111111";
	wait for 1*clk_period;
  s_instruction <= "00001100001000010000100001000010";
	s_wb_signal<='1';
	s_wb_addr <="00101";
	s_wb_data <="11111111111111111111111111111111";
--  wait for 1*clk_period;
--  s_instruction <= "00011100011000110001100011000001";

--  wait for 1*clk_period;
--  s_instruction <= "00001100001000010000100001000000";

--  wait for 1*clk_period;
--  s_instruction <= "00001100001000010000100001000000";

--  wait for 1*clk_period;
--  s_wb_signal<='1';
--  s_wb_addr <="00011";
--	s_wb_data <="11111111111111111111111111111111";
--	s_instruction <= "00011100011000110001100011000000";
--  wait for 1*clk_period;
--  s_wb_signal<='0';
--  s_instruction <= "00011100011000110001100011100101";
--  wait for 1*clk_period;
--  s_instruction <= "10001000011000110001100011100101";
--
--  wait for 1*clk_period;
--  s_instruction <= "00000000011000110001100011100101";
--  wait for 1*clk_period;
--  s_instruction <= "10001100011000110001100011100101";
--  wait for 1*clk_period;
--  s_instruction <= "10101100011000110001100011100101";
--  wait for 1*clk_period;
--  s_instruction <= "00010000011000110001100011100101";
  wait for 1*clk_period;
  s_write_to_file <= '1';
wait;

end process;

end;
