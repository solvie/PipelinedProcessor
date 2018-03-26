library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_stage is
port( 
	clock : IN std_logic;
	
	op_code_alu : in std_logic_vector(5 downto 0 );
	data_out_left: in std_logic_vector (31 downto 0);
	data_out_right: in std_logic_vector (31 downto 0);
	data_out_imm: in std_logic_vector (31 downto 0); -- sign/zero extended value will come out

	shamt : in std_logic_vector(4 downto 0);
	r_d: in std_logic_vector (4 downto 0);
	pseudo_address : in std_logic_vector(25 downto 0);
	
	
	-- from control
	RegDst   : in std_logic;
	ALUSrc   : in std_logic;
	MemtoReg : in std_logic;
	RegWrite : in std_logic;
	MemRead  : in std_logic;
	MemWrite : in std_logic;
	Branch   : in std_logic
);
end EX_stage;

architecture behavior of EX_stage is
component ALUcalc is
port( 
    clock : in STD_LOGIC;
	  A : in  STD_LOGIC_VECTOR (31 downto 0);
    B : in  STD_LOGIC_VECTOR (31 downto 0);
    operationcode : in STD_LOGIC_VECTOR (3 downto 0);
		zero : out STD_LOGIC := '0';
		alucalcresult : out STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
		
    Output   : out STD_LOGIC_VECTOR (31 downto 0));
 );
end component;

component ALUctrl is
    Port ( 
        clock : in STD_LOGIC;
        opcode : in  STD_LOGIC_VECTOR (5 downto 0);
        ALUcalc_operationcode : out  STD_LOGIC_VECTOR (3 downto 0)
		);
end component;

signal e_ALUOpCode : std_logic_vector(3 downto 0);

begin

ctrl : ALUctrl
port map(
  clock =>clock,
	
)
   

end;
