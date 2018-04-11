library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_stage_tb is
port(
	clock : IN std_logic;

	ALUcalc_operationcode : in std_logic_vector(3 downto 0 );
	data_out_left: in std_logic_vector (31 downto 0);
	data_out_right: in std_logic_vector (31 downto 0);
	data_out_imm: in std_logic_vector (31 downto 0); -- sign/zero extended value will come out
  --funct : in std_logic_vector(5 downto 0);
	shamt : in std_logic_vector(4 downto 0);
	r_s: in std_logic_vector (4 downto 0);
	pseudo_address : in std_logic_vector(25 downto 0);

	-- from control
	--RegDst   : in std_logic;
	--ALUSrc   : in std_logic;
	--MemtoReg : in std_logic;
	--RegWrite : in std_logic;
	--MemRead  : in std_logic;
	--MemWrite : in std_logic;
	--Branch   : in std_logic
	mux1_control : in std_logic;
	mux2_control : in std_logic;
	mux3_control : in std_logic;
	MemRead : in std_logic;
	MemWrite : in std_logic;

  ALUOutput :	out STD_LOGIC_VECTOR (31 downto 0);
  zeroOut :	out STD_LOGIC;

  out_mux3_control : out std_logic;
  out_MemRead: out std_logic;
  out_MemWrite: out std_logic

);
end EX_stage_tb;

architecture behavior of EX_stage_tb is
component EX_stage is
port(
	clock : in std_logic;
	ALUcalc_operationcode : in std_logic_vector(3 downto 0 );
	data_out_left: in std_logic_vector (31 downto 0);
	data_out_right: in std_logic_vector (31 downto 0);
	data_out_imm: in std_logic_vector (31 downto 0); -- sign/zero extended value will come out
  --funct : in std_logic_vector(5 downto 0);
	shamt : in std_logic_vector(4 downto 0);
	r_s: in std_logic_vector (4 downto 0);
	pseudo_address : in std_logic_vector(25 downto 0);

	-- from control
	--RegDst   : in std_logic;
	--ALUSrc   : in std_logic;
	--MemtoReg : in std_logic;
	--RegWrite : in std_logic;
	--MemRead  : in std_logic;
	--MemWrite : in std_logic;
	--Branch   : in std_logic
	mux1_control : in std_logic;
	mux2_control : in std_logic;
	mux3_control : in std_logic;
	MemRead : in std_logic;
	MemWrite : in std_logic;

  ALUOutput :	out STD_LOGIC_VECTOR (31 downto 0);
  zeroOut :	out STD_LOGIC;
	address : out STD_LOGIC_VECTOR (31 downto 0);
  out_mux3_control : out std_logic;
  out_MemRead: out std_logic;
  out_MemWrite: out std_logic
);
end component;

signal rst : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal	s_ALUcalc_operationcode : std_logic_vector(3 downto 0 );
signal	s_data_out_left: std_logic_vector (31 downto 0);
signal	s_data_out_right: std_logic_vector (31 downto 0);
signal	s_data_out_imm: std_logic_vector (31 downto 0); -- sign/zero extended value will come out
signal s_funct : std_logic_vector(5 downto 0);
signal	s_shamt : std_logic_vector(4 downto 0);
signal	s_r_s: std_logic_vector (4 downto 0);
signal	s_pseudo_address : std_logic_vector(25 downto 0);

signal	s_mux1_control : std_logic;
signal	s_mux2_control : std_logic;
signal	s_mux3_control : std_logic;
signal	s_MemRead : std_logic;
signal	s_MemWrite : std_logic;

signal s_ALUOutput : STD_LOGIC_VECTOR (31 downto 0);
signal s_zeroOut : STD_LOGIC;
signal s_address : STD_LOGIC_VECTOR (31 downto 0);
signal s_out_mux3_control : std_logic;
signal s_out_MemRead: std_logic;
signal s_out_MemWrite: std_logic;

begin
ex_stage2: EX_stage
port map(
	clock =>clk,

	ALUcalc_operationcode =>s_ALUcalc_operationcode,
	data_out_left=>s_data_out_left,
	data_out_right=>s_data_out_right,
	data_out_imm=> s_data_out_imm,
  --funct =>s_funct,
	shamt =>s_shamt,
	r_s => s_r_s,
	pseudo_address =>s_pseudo_address,
  address => s_address,
	mux1_control =>s_mux1_control,
	mux2_control =>s_mux2_control,
	mux3_control =>s_mux3_control,
	MemRead => s_MemRead,
	MemWrite => s_MemWrite,

  ALUOutput =>s_ALUOutput,
  zeroOut =>s_zeroOut,

  out_mux3_control =>s_out_mux3_control,
  out_MemRead =>s_out_MemRead,
  out_MemWrite=>s_out_MemWrite
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


  wait for 1*clk_period;

  --s_instruction <= "000011 00001 00001 00001 00001 000000"
	s_ALUcalc_operationcode <= "0000";
	s_data_out_left <= "00000000000000000000000000000101";
	s_data_out_right <= "00000000000000000000000000000010";
	
  wait for 1*clk_period;
  assert(s_ALUOutput = "00000000000000000000000000000111") report "error";
  s_ALUcalc_operationcode <= "1001";
  wait for 1*clk_period;
  assert(s_ALUOutput = "00000000000000000000000000000001") report "error";
  s_ALUcalc_operationcode <= "1010";
  wait for 1*clk_period;
  assert(s_ALUOutput = "00000000000000000000000000000010") report "error";

  --slt
  s_data_out_left <= "00000000000000000000000000000001";
	s_data_out_right <= "00000000000000000000000000000010";
  
s_ALUcalc_operationcode <= "0100";
  wait for 1*clk_period;
  assert(s_ALUOutput = "00000000000000000000000000000001") report "error slt";

  wait;

end process;

end;
