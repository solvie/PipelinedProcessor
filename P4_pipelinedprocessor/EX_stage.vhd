library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_stage is
port(
	clock : IN std_logic;

	ALUcalc_operationcode : in std_logic_vector(3 downto 0 );
	data_out_left: in std_logic_vector (31 downto 0);
	data_out_right: in std_logic_vector (31 downto 0);
	data_out_imm: in std_logic_vector (31 downto 0); -- sign/zero extended value will come out
  --funct : in stdm_logic_vector(5 downto 0);
	shamt : in std_logic_vector(4 downto 0);
	r_s: in std_logic_vector (4 downto 0);
	pseudo_address : in std_logic_vector(25 downto 0);
  
  instruction_location_in : in std_logic_vector(31 downto 0);
	mux1_control : in std_logic;
	mux2_control : in std_logic;
	mux3_control : in std_logic;
	MemRead : in std_logic;
	MemWrite : in std_logic;
	MemToReg : in std_logic;
	Jump: in std_logic;

  ALUOutput :	out STD_LOGIC_VECTOR (31 downto 0):="00000000000000000000000000000000";
  zeroOut :	out STD_LOGIC;
	address : out STD_LOGIC_VECTOR (31 downto 0);
  out_mux3_control : out std_logic;
  out_MemRead: out std_logic;
  out_MemWrite: out std_logic;
  out_MemToReg : out std_logic;
  pseudo_address_out: out std_logic_vector(25 downto 0);
  r_s_out: out std_logic_vector (4 downto 0)
);
end EX_stage;

architecture behavior of EX_stage is
component ALUcalc is
port(
    clock : in STD_LOGIC;
	A : in  STD_LOGIC_VECTOR (31 downto 0);
    B : in  STD_LOGIC_VECTOR (31 downto 0);
    operationcode : in STD_LOGIC_VECTOR (3 downto 0);
	jump : in STD_LOGIC;
	zero : out STD_LOGIC := '0';
	alucalcresult : out STD_LOGIC_VECTOR (31 downto 0)
 );
end component;

component mux_2_to_1 is
    Port (
        SEL : in  STD_LOGIC;
        A   : in  STD_LOGIC_VECTOR (31 downto 0);
        B   : in  STD_LOGIC_VECTOR (31 downto 0);
        Output   : out STD_LOGIC_VECTOR (31 downto 0)
    );
end component;

signal mux1out : std_logic_vector(31 downto 0);
signal mux2out : std_logic_vector(31 downto 0);

begin


mux1 : mux_2_to_1
Port map(
    SEL => mux1_control,
    A  =>  instruction_location_in,
    B  =>  data_out_left,
    Output =>mux1out
);

mux2 : mux_2_to_1
Port map(
    SEL => mux2_control,
    A  => data_out_right,
    B  => data_out_imm,
    Output => mux2out
);

ALU : ALUcalc
port map(
    clock =>clock,
	A =>mux1out,
    B =>mux2out,
	Jump => Jump,
    operationcode =>ALUcalc_operationcode,
	zero =>zeroOut,
	alucalcresult =>ALUOutput

 );
 
process(clock) begin 
	out_MemToReg <=MemToReg;
	address <= data_out_right;
	out_mux3_control<=mux3_control;
	out_MemRead<=	MemRead;
	out_MemWrite<=	MemWrite;
	pseudo_address_out <= pseudo_address;
	r_s_out <= r_s;
end process;

end;
