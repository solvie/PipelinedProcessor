library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_stage is
port( 
	clock : IN std_logic;
	reset : IN std_logic;
	
	instruction: in std_logic_vector(31 downto 0);
	instruction_loc_in : in std_logic_vector(31 downto 0);
	instruction_loc_out : out std_logic_vector(31 downto 0);
	
	-- from registers
	wb_addr : in std_logic_vector (4 downto 0);
	wb_data : in std_logic_vector (31 downto 0);
	
	data_out_left: out std_logic_vector (31 downto 0);
	data_out_right: out std_logic_vector (31 downto 0);
	data_out_imm: out std_logic_vector (31 downto 0); -- sign/zero extended value will come out
	funct : out std_logic_vector(5 downto 0);
	shamt : out std_logic_vector(4 downto 0);
	r_s: out std_logic_vector (4 downto 0);
	pseudo_address : out std_logic_vector(25 downto 0);
	
	-- from control
	RegDst   : out std_logic;
	ALUSrc   : out std_logic;
	MemtoReg : out std_logic;
	MemRead  : out std_logic;
	MemWrite : out std_logic;
	Branch   : out std_logic;
	
	ALUcalc_operationcode : out std_logic_vector(3 downto 0 )
);
end ID_stage;


architecture behavior of ID_stage is
component registers is
port( 
	clock : in std_logic;
	reset : in std_logic;
	
	instruction : in std_logic_vector(31 downto 0);
	
	wb_signal : in std_logic;
	wb_addr : in std_logic_vector (4 downto 0);
	wb_data : in std_logic_vector (31 downto 0);
	
	data_out_left: out std_logic_vector (31 downto 0);
	data_out_right: out std_logic_vector (31 downto 0);
	data_out_imm: out std_logic_vector (31 downto 0); -- sign/zero extended value will come out
	
	shamt : out std_logic_vector(4 downto 0);
	funct : out std_logic_vector(5 downto 0);
	r_s: out std_logic_vector (4 downto 0);
	opcode: out std_logic_vector(5 downto 0);
	pseudo_address : out std_logic_vector(25 downto 0)
 );
end component;

component control is
port(
	clock : in std_logic;
	reset : in std_logic;
	
	opcode : in std_logic_vector(5 downto 0);
	
	RegDst   : out std_logic;
	ALUSrc   : out std_logic;
	MemtoReg : out std_logic;
	RegWrite : out std_logic;
	MemRead  : out std_logic;
	MemWrite : out std_logic;
	Branch   : out std_logic;
	
	ALUcalc_operationcode : out std_logic_vector(3 downto 0)
);
end component;

signal	s_opcode: std_logic_vector(5 downto 0);
signal	s_regWrite: std_logic;

begin
ctrl : control
port map(
	clock =>clock,
	reset =>reset,
	opcode =>s_opcode,
	RegDst   =>RegDst,
	ALUSrc   =>ALUSrc,
	MemtoReg =>MemtoReg,
	RegWrite =>s_regWrite,
	MemRead  =>MemRead,
	MemWrite =>MemWrite,
	Branch   =>Branch,
	ALUcalc_operationcode => ALUcalc_operationcode
);

reg : registers
port map(
	clock =>clock,
	reset =>reset,
	
	instruction =>instruction,
	
	wb_signal  =>s_regWrite,
	wb_addr    =>wb_addr,
	wb_data    =>wb_data,
	
	data_out_left =>data_out_left,
	data_out_right=>data_out_right,
	data_out_imm  =>data_out_imm,
	shamt         =>shamt,
	funct         =>funct,
	r_s           =>r_s,
	opcode        =>s_opcode,
	pseudo_address=>pseudo_address
);

process (instruction_loc_in) begin
  instruction_loc_out <= instruction_loc_in;
end process;
	
end;
