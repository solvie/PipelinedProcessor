library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity processor is
GENERIC(
	ram_size : INTEGER := 1024
);
port(
	clock : IN std_logic;
	reset : IN std_logic;
	-- The ports below are only exposed so that instruction memory can be loaded externally before the processor starts its business
	writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	address: IN INTEGER RANGE 0 TO ram_size-1 := 0;
	mem_write: IN STD_LOGIC;
	mem_read: IN STD_LOGIC;
	readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	waitrequest: OUT STD_LOGIC;

	write_to_file: IN std_logic;
	-- FOR MEM
	readdata_m: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	waitrequest_m: OUT STD_LOGIC;
	data_ready: in std_logic :='0'

);
end processor;

architecture
behavior of processor is

component IF_stage is
port(
	clock : IN std_logic;
	reset : IN std_logic;
	mux_input_to_stage1 : IN std_logic_vector(31 downto 0); -- this will come from the EX/MEM buffer
	mux_select_sig_to_stage1 : IN std_logic;
	mux_output_stage_1 : INOUT std_logic_vector(31 downto 0);
	pc_out_as_int : OUT Integer range 0 to 1023 :=0;
	predict_taken : in std_logic;
	address_output : IN std_logic_vector(31 downto 0)
 );
end component;

component instruction_memory IS
GENERIC(
	ram_size : INTEGER := 1024
);
PORT (
	clock: IN STD_LOGIC;
	writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	address: IN INTEGER RANGE 0 TO ram_size-1;
	memwrite: IN STD_LOGIC;
	memread: IN STD_LOGIC;
	readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	waitrequest: OUT STD_LOGIC;
	data_ready: in STD_LOGIC
);
END component;

component IF_ID_pipe is
PORT(
	clock : IN std_logic;
	reset : IN std_logic;
	instruction_in : IN std_logic_vector(31 downto 0);
	instruction_out : OUT std_logic_vector(31 downto 0);
	instr_loc_in : IN std_logic_vector(31 downto 0);
	instr_loc_out : OUT std_logic_vector(31 downto 0);
	previous_pc_in : in integer;
	previous_pc_out : out integer;
	branch_outcome_in : in std_logic;
	branch_outcome_out : out std_logic;
	branch_index_in : in integer;
	branch_index_out : out integer;
	predict_taken_in : in std_logic;
	predict_taken_out : out std_logic
);
end component;

component ID_stage is
PORT(
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
	--funct : out std_logic_vector(5 downto 0);
	shamt : out std_logic_vector(4 downto 0);
	r_s: out std_logic_vector (4 downto 0);
	pseudo_address : out std_logic_vector(25 downto 0);
	n_pseudo_address : out std_logic_vector(31 downto 0);
	-- from control
	RegDst   : out std_logic;
	--ALUSrc   : out std_logic;
	MemtoReg : out std_logic;
	MemRead  : out std_logic;
	MemWrite : out std_logic;
	Branch   : out std_logic;
	RegWrite : out std_logic;
	ALUcalc_operationcode : out std_logic_vector(3 downto 0 );
	write_to_file : in std_logic;
	jumping : out std_logic;
	data_memory_data : out std_logic_vector (31 downto 0);
	data_memory_address: out std_logic_vector (31 downto 0);
	previous_pc_output_in : in integer;
	branch_outcome_out : out std_logic;
	branch_index_out : out integer;
	predict_taken_in : in std_logic

);
end component;

component ID_EX_pipe is
PORT(
	clock : IN std_logic;
	reset : IN std_logic;
	--id output
	instruction_loc_in : in std_logic_vector(31 downto 0);
	instruction_loc_out : out std_logic_vector(31 downto 0);
	d_data_out_left: in std_logic_vector (31 downto 0);
	d_data_out_right: in std_logic_vector (31 downto 0);
	d_data_out_imm: in std_logic_vector (31 downto 0); -- sign/zero extended value will come out
	--d_funct : in std_logic_vector(5 downto 0);
	d_shamt : in std_logic_vector(4 downto 0);
	d_r_s: in std_logic_vector (4 downto 0);
	d_pseudo_address : in std_logic_vector(25 downto 0);
	-- from control
	d_RegDst   : in std_logic;
	d_MemtoReg : in std_logic;
	d_MemRead  : in std_logic;
	d_MemWrite : in std_logic;
	d_RegWrite : in std_logic;
	d_Branch   : in std_logic;
	d_ALUcalc_operationcode : in std_logic_vector(3 downto 0 );
	-- EX
	ALUcalc_operationcode : out std_logic_vector(3 downto 0 );
	data_out_left: out std_logic_vector (31 downto 0);
	data_out_right: out std_logic_vector (31 downto 0);
	data_out_imm: out std_logic_vector (31 downto 0); -- sign/zero extended value will come out
--	funct : out std_logic_vector(5 downto 0);
	shamt : out std_logic_vector(4 downto 0);
	r_s: out std_logic_vector (4 downto 0);
	pseudo_address : out std_logic_vector(25 downto 0);
	-- from control
	mux1_control : out std_logic;
	mux2_control : out std_logic;
	mux3_control : out std_logic;
	MemRead : out std_logic;
	MemWrite : out std_logic;
	MemToReg : out std_logic;
	data_memory_data_out: out std_logic_vector (31 downto 0);
	data_memory_address_out: out std_logic_vector (31 downto 0);
	data_memory_data_in: in std_logic_vector (31 downto 0);
	data_memory_address_in: in std_logic_vector (31 downto 0)
);
end component;

component EX_stage is
PORT(
	clock : IN std_logic;

	ALUcalc_operationcode : in std_logic_vector(3 downto 0 );
	data_out_left: in std_logic_vector (31 downto 0);
	data_out_right: in std_logic_vector (31 downto 0);
	data_out_imm: in std_logic_vector (31 downto 0); -- sign/zero extended value will come out
	--funct : in std_logic_vector(5 downto 0);
	shamt : in std_logic_vector(4 downto 0);
	r_s: in std_logic_vector (4 downto 0);
	pseudo_address : in std_logic_vector(25 downto 0);
	instruction_location_in: in std_logic_vector (31 downto 0);
	mux1_control : in std_logic;
	mux2_control : in std_logic;
	mux3_control : in std_logic;
	MemRead : in std_logic;
	MemWrite : in std_logic;
	MemToReg : in std_logic;

	ALUOutput :	out STD_LOGIC_VECTOR (31 downto 0);
	zeroOut :	out STD_LOGIC;
	address : out STD_LOGIC_VECTOR (31 downto 0);
	out_mux3_control : out std_logic;
	out_MemRead: out std_logic;
	out_MemWrite: out std_logic;
	out_MemToReg : out std_logic;
	pseudo_address_out: out std_logic_vector(25 downto 0);
	r_s_out: out std_logic_vector (4 downto 0);
	data_memory_data_out: out std_logic_vector (31 downto 0);
  data_memory_data_in: in std_logic_vector (31 downto 0);
  data_memory_address_in: in std_logic_vector (31 downto 0)
);
end component;

component EX_MEM_pipe is
port(
	clock : IN std_logic;
	reset : IN std_logic;
	ALUOuput :	in STD_LOGIC_VECTOR (31 downto 0);
	zeroOut :	in STD_LOGIC;
	mux3_control : in std_logic;
	MemRead : in std_logic;
	MemWrite : in std_logic;
	address : in std_logic_vector(31 downto 0);

	mem_writedata: out STD_LOGIC_VECTOR (31 DOWNTO 0);
	mem_address: out INTEGER RANGE 0 TO ram_size-1;
	mem_memwrite: out STD_LOGIC;
	mem_memread: out STD_LOGIC;
	mux3_control_out : out std_logic;
  	--zeroOut_out: out std_logic;

  	pseudo_address : in std_logic_vector(25 downto 0);
  	mem_pseudo_address : out std_logic_vector(31 downto 0);
  	r_s_in : in std_logic_vector(4 downto 0);
  	r_s_out: out std_logic_vector(4 downto 0);
  	MemToReg : in std_logic;
   out_MemToReg : out std_logic;
      data_memory_data_in : in std_logic_vector(31 downto 0)
 );
end component;

component MEM_stage is
	PORT (
	clock : IN std_logic;
	--reset : IN std_logic;
	ALUOuput_mem_in: in STD_LOGIC_VECTOR (31 downto 0);
	address: IN INTEGER;
	MemRead : in std_logic;
	MemWrite : in std_logic;
 	MemToReg : in std_logic;
  out_MemToReg : out std_logic;
	ALUOut: out STD_LOGIC_VECTOR (31 downto 0);
	mem_out: out STD_LOGIC_VECTOR (31 DOWNTO 0);
	--instruction_in: IN std_logic_vector(31 downto 0);
	--instruction_out: OUT std_logic_vector(31 downto 0);
	mux3_control_in : in std_logic;
	mux3_control_out: out std_logic;
	write_to_file : in std_logic;
	r_s_in: in std_logic_vector(4 downto 0);
	r_s_out: out std_logic_vector(4 downto 0)
	);
end component;

component MEM_WB_pipe is
	PORT (
	clock : IN std_logic;
	reset : IN std_logic;
	mem_in : IN std_logic_vector(31 downto 0); -- memory from data memory in
	mem_out : OUT std_logic_vector(31 downto 0); -- memory from data memory out
	ALU_in : IN std_logic_vector(31 downto 0); -- EX ALU in
	ALU_out : OUT std_logic_vector(31 downto 0); --EX ALU out
	--instruction_in : IN std_logic_vector(31 downto 0); -- instruction in
	--instruction_out : OUT std_logic_vector(31 downto 0); -- instruction out
    --sel_sig_in : IN std_logic; -- select signal for mux in WB stage in
    --sel_sig_out : OUT std_logic; -- select signal for mux in WB stage out
    mux3_control_in : in std_logic;
    mux3_control_out : out std_logic;
    pseudo_address_in : in std_logic_vector(25 downto 0);
    pseudo_address_out : out std_logic_vector(25 downto 0);
    r_s_in: in std_logic_vector(4 downto 0);
    r_s_out: out std_logic_vector(4 downto 0);
    MemToReg : in std_logic;
   out_MemToReg : out std_logic
	);
end component;

component WB_stage is
	PORT (
	SEL : in  STD_LOGIC;
    memory_input   : in  STD_LOGIC_VECTOR (31 downto 0);
    ALU_input   : in  STD_LOGIC_VECTOR (31 downto 0);
    Output_wb   : out STD_LOGIC_VECTOR (31 downto 0);
    pseudo_address_in : in STD_LOGIC_VECTOR (25 downto 0);
    pseudo_address_out : out STD_LOGIC_VECTOR (25 downto 0);
    clock : IN std_logic;
	r_s_in : in STD_LOGIC_VECTOR (4 downto 0);
    r_s_out : out STD_LOGIC_VECTOR (4 downto 0);
    wb_signal_in5 : in std_logic;
    wb_signal_out5 : out std_logic
	);
end component;

component mux_2_to_1_int is
    Port ( SEL : in  STD_LOGIC;
           A   : in  integer;
           B   : in  integer;
           Output   : out integer
           );
end component;

component mux_2_to_1 is
    Port ( SEL : in  STD_LOGIC;
           A   : in  STD_LOGIC_VECTOR (31 downto 0);
           B   : in  STD_LOGIC_VECTOR (31 downto 0);
           Output   : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component mux_3_to_1 is
    Port ( SEL_Jump : in  STD_LOGIC;
    	   SEL_Predictor : in STD_LOGIC;
           A   : in  STD_LOGIC_VECTOR (31 downto 0);
           B   : in  STD_LOGIC_VECTOR (31 downto 0);
           C   : in STD_LOGIC_VECTOR(31 downto 0);
           Output   : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component one_bit_predictor is
    Port ( instruction : IN STD_LOGIC_VECTOR (31 downto 0);
    	   pc_as_int_input: in integer;
    	   clock : IN std_logic;
    	   previous_pc_output: out integer;
    	   address_output : out STD_LOGIC_VECTOR(31 downto 0);
    	   branch_outcome : in std_logic;
    	   branch_index : in integer;
           predict_taken   : out STD_LOGIC);
end component;

-- signals connecting components together
-- IF
signal mux_input_to_stage1: std_logic_vector(31 downto 0) :="00000000000000000000000000000000";
signal mux_select_sig_to_stage1: std_logic:='0';

--IF-> IF_ID
signal instr_loc_s_p: std_logic_vector(31 downto 0);
signal pc_out_as_int: Integer;
signal instruction_s_p: std_logic_vector(31 downto 0);
--IF_ID-> ID
signal instr_loc_p_s: std_logic_vector(31 downto 0);
signal instruction_out_p_s: std_logic_vector(31 downto 0);
-- ID
signal wb_signal: std_logic :='0';
signal wb_addr: std_logic_vector(4 downto 0);
signal wb_data: std_logic_vector(31 downto 0);
--signal write_to_file: std_logic;
--ID -> ID_EX
--signal instr_loc_p_s_2: std_logic_vector(31 downto 0);
signal instruction_out_p_s_2: std_logic_vector(31 downto 0);

-- ID_EX
signal s_p_2_data_out_left:  std_logic_vector (31 downto 0);
signal s_p_2_data_out_right:  std_logic_vector (31 downto 0);
signal s_p_2_data_out_imm:  std_logic_vector (31 downto 0); -- sign/zero extended value will come out
--signal s_p_2_funct :  std_logic_vector(5 downto 0);
signal s_p_2_shamt :  std_logic_vector(4 downto 0);
signal s_p_2_r_s:  std_logic_vector (4 downto 0);
signal s_p_2_pseudo_address :  std_logic_vector(25 downto 0);
signal s_p_2_RegDst   :  std_logic;
signal s_p_2_MemtoReg :  std_logic;
signal s_p_2_MemRead  :  std_logic;
signal s_p_2_MemWrite :  std_logic;
signal s_p_2_Branch   :  std_logic;
signal s_p_2_ALUcalc_operationcode :  std_logic_vector(3 downto 0 );

signal s_p_3_MemtoReg :  std_logic;
-- EX
signal p_s_3_instruction_location_in : std_logic_vector(31 downto 0 );
signal p_s_3_ALUcalc_operationcode : std_logic_vector(3 downto 0 );
signal p_s_3_data_out_left: std_logic_vector (31 downto 0);
signal p_s_3_data_out_right: std_logic_vector (31 downto 0);
signal p_s_3_data_out_imm: std_logic_vector (31 downto 0); -- sign/zero extended value will come out
--signal p_s_3_funct : std_logic_vector(5 downto 0);
signal p_s_3_shamt : std_logic_vector(4 downto 0);
signal p_s_3_r_s: std_logic_vector (4 downto 0);
signal p_s_3_pseudo_address : std_logic_vector(25 downto 0);

signal p_s_3_mux1_control : std_logic;
signal p_s_3_mux2_control : std_logic;
signal p_s_3_mux3_control : std_logic;
signal p_s_3_MemRead : std_logic;
signal p_s_3_MemWrite : std_logic;

-- EX_MEM
signal ALUOuput_s_p : STD_LOGIC_VECTOR (31 downto 0);
signal zeroOut_s_p : STD_LOGIC;
signal mux3_control_s_p : std_logic;
signal MemRead_s_p : std_logic;
signal MemWrite_s_p : std_logic;
signal address_s_p : std_logic_vector(31 downto 0);
signal pseudo_address_s_p : std_logic_vector(25 downto 0);
signal r_s_s_p: std_logic_vector (4 downto 0);

--MEM
signal pseudo_address_p_s: std_logic_vector(31 downto 0);
signal writedata_p_s:  STD_LOGIC_VECTOR (31 DOWNTO 0);
signal address_p_s:  INTEGER;-- RANGE 0 TO ram_size-1;
signal memwrite_p_s:  STD_LOGIC;
signal memread_p_s:  STD_LOGIC;
signal write_to_file_p_s:  STD_LOGIC;
signal p_s_4_pseudo_address: std_logic_vector(25 downto 0);
signal mux3_control_out_p_s_3: std_logic;
signal r_s_p_s_4: std_logic_vector (4 downto 0);

--MEM_WB
signal pseudo_address_s_p_4: std_logic_vector(25 downto 0);
signal mux3_control_out_s_p_4: std_logic;
signal mem_out_s_p_4: STD_LOGIC_VECTOR (31 downto 0);
signal ALUOut_s_p_4: STD_LOGIC_VECTOR (31 downto 0);
signal r_s_s_p_4: std_logic_vector (4 downto 0);

--WB
signal mux3_control_out_p_s_5: std_logic;
signal mem_out_p_s_5: STD_LOGIC_VECTOR (31 downto 0);
signal ALUOut_p_s_5: STD_LOGIC_VECTOR (31 downto 0);
signal pseudo_address_p_s_5: STD_LOGIC_VECTOR (25 downto 0);
signal r_s_p_s_5: std_logic_vector (4 downto 0);

--wbsignal
signal wbs_id_pipe: std_logic;
signal wbs_pipe_ex: std_logic;
signal wbs_ex_pipe: std_logic;
signal wbs_pipe_mem: std_logic;
signal wbs_mem_pipe: std_logic;
signal wbs_pipe_wb: std_logic;

--mux_2_to_1
signal address_b_or_j : STD_LOGIC_VECTOR (31 downto 0);
signal isJumping : std_logic;
signal n_pseudo_address :STD_LOGIC_VECTOR (31 downto 0);
--temp
signal zeroOut_out_temp: STD_LOGIC_VECTOR (25 downto 0);

signal mem_address: INTEGER RANGE 0 to 1023;

signal temp_wb_signal: std_logic;

signal data_memory_data_1 : std_logic_vector (31 downto 0);
signal data_memory_address_1 : std_logic_vector (31 downto 0);

signal data_memory_data_2 : std_logic_vector (31 downto 0);
signal data_memory_address_2 : std_logic_vector (31 downto 0);

signal data_memory_data_3 : std_logic_vector (31 downto 0);

--signal data_ready: STD_LOGIC;
signal pc_mod : std_logic :='0';


signal predict_taken : std_logic;
signal address_output : STD_LOGIC_VECTOR(31 downto 0);
signal previous_pc_output_1 : integer;
signal previous_pc_output_2 : integer;
signal branch_outcome_1 : std_logic;
signal branch_index_1 : integer;



signal branch_outcome_temp_1 : std_logic;
signal branch_outcome_temp_2 : std_logic;
signal branch_index_in_temp_3 : integer;
signal branch_index_out_temp_4 : integer;
signal predict_taken_1 : std_logic;
--
begin

--process
--begin
--if(data_ready='1') then
--mem_address <= pc_out_as_int;
--else
--mem_address <= address;
--end if;
--end process;
process (clock)
	BEGIN
	--if (rising_edge(clock)) then
		pc_mod <= isJumping;
	--end if;
end process;

select_address: mux_2_to_1_int
port map(
    SEL => data_ready,
    A => pc_out_as_int,
    B => address,
    Output =>mem_address
);


b_orj : mux_2_to_1
	 Port map (
	 SEL =>isJumping,
	 A =>n_pseudo_address,
	 B =>pseudo_address_p_s,
	 Output => address_b_or_j
);

--b_orj : mux_3_to_1
--	 Port map (
--	SEL_Jump => isJumping,
--	SEL_Predictor => predict_taken,
--	A => n_pseudo_address,
--	B => pseudo_address_p_s,
--	C => address_output,
--	Output=>address_b_or_j
--);

one_bit_pred: one_bit_predictor
port map(
	clock => clock,
	instruction => instruction_s_p,
   	pc_as_int_input => pc_out_as_int,
   	previous_pc_output => previous_pc_output_1,
   	address_output =>address_output,
   	branch_outcome => branch_outcome_1,
   	branch_index => branch_index_1,
   	predict_taken=>predict_taken
);

LoadToInstMem: instruction_memory
port map(
    clock => clock,
    writedata => writedata,
    address => mem_address,
    memwrite => mem_write,
    memread => mem_read,
    readdata => instruction_s_p,
    waitrequest => waitrequest,
    data_ready => data_ready
);
if_s: IF_stage
port map(
    clock => clock,
    reset => reset,
    mux_input_to_stage1 => address_b_or_j,
    mux_select_sig_to_stage1 => isJumping,
    mux_output_stage_1 => instr_loc_s_p,
    pc_out_as_int => pc_out_as_int,
    predict_taken => predict_taken,
	address_output => address_output
);

ifid_pipe: IF_ID_pipe
port map(
    clock => clock,
    reset => reset,
	instruction_in => instruction_s_p,
	instruction_out => instruction_out_p_s,
	instr_loc_in => instr_loc_s_p,
	instr_loc_out => instr_loc_p_s,
	previous_pc_in => previous_pc_output_1,
	previous_pc_out => previous_pc_output_2,
	branch_outcome_in => branch_outcome_temp_1,
	branch_outcome_out => branch_outcome_1,
	branch_index_in => branch_index_in_temp_3,
	branch_index_out => branch_index_1,
	predict_taken_in => predict_taken,
	predict_taken_out => predict_taken_1
);

id_s: ID_stage
port map(
	-- inputs
    clock => clock,
    reset => reset,
	instruction => instruction_out_p_s,
	instruction_loc_in => instr_loc_p_s,
	instruction_loc_out => instruction_out_p_s_2,
	wb_addr => wb_addr,
	wb_data => wb_data,
	wb_signal => wb_signal,
	-- from registers
	data_out_left=>s_p_2_data_out_left,
	data_out_right=>s_p_2_data_out_right,
	data_out_imm=>s_p_2_data_out_imm,
--	funct =>s_p_2_funct,
	shamt =>s_p_2_shamt,
	r_s=>s_p_2_r_s,
	pseudo_address=>s_p_2_pseudo_address,
	n_pseudo_address=> n_pseudo_address,
	-- from control
	RegDst   =>s_p_2_RegDst,
	--ALUSrc  => s_p_2_MemtoReg,
	MemtoReg=> s_p_2_MemtoReg,
	MemRead  =>s_p_2_MemRead,
	MemWrite =>s_p_2_MemWrite,
	Branch   =>s_p_2_Branch,
	RegWrite =>wbs_id_pipe,
	ALUcalc_operationcode =>s_p_2_ALUcalc_operationcode,
	write_to_file =>write_to_file,
	jumping => isJumping,
	data_memory_data => data_memory_data_1,
	data_memory_address => data_memory_address_1,
	previous_pc_output_in => previous_pc_output_2,
	branch_outcome_out => branch_outcome_temp_1,
	branch_index_out => branch_index_in_temp_3,
	predict_taken_in => predict_taken_1
);

idex_pipe: ID_EX_pipe
port map(
	clock =>clock,
	reset=>reset,
	instruction_loc_in =>instruction_out_p_s_2,
	instruction_loc_out =>p_s_3_instruction_location_in,
	--id output
    d_data_out_left=>s_p_2_data_out_left,
	d_data_out_right=>s_p_2_data_out_right,
	d_data_out_imm=>s_p_2_data_out_imm,
	d_shamt=>s_p_2_shamt,
	d_r_s=>s_p_2_r_s,
	d_pseudo_address=>s_p_2_pseudo_address,
	-- from control
	d_RegDst  =>s_p_2_RegDst,
	d_MemtoReg =>s_p_2_MemtoReg,
	d_MemRead  =>s_p_2_MemRead,
	d_MemWrite =>s_p_2_MemWrite,
	d_RegWrite => wbs_id_pipe,
	d_Branch=>s_p_2_Branch,
	d_ALUcalc_operationcode =>s_p_2_ALUcalc_operationcode,
	-- EX
	ALUcalc_operationcode =>p_s_3_ALUcalc_operationcode,
	data_out_left=>p_s_3_data_out_left,
	data_out_right=>p_s_3_data_out_right,
	data_out_imm=>p_s_3_data_out_imm,
	--funct =>p_s_3_funct,
	shamt=>p_s_3_shamt,
	r_s=>p_s_3_r_s,
	pseudo_address=>p_s_3_pseudo_address,
	-- from control
	mux1_control =>p_s_3_mux1_control,
	mux2_control =>p_s_3_mux2_control,
	mux3_control =>p_s_3_mux3_control,
	MemRead=>p_s_3_MemRead,
	MemWrite =>p_s_3_MemWrite,
	MemToReg=>wbs_pipe_ex,
	data_memory_data_out=> data_memory_data_2,
	data_memory_address_out=> data_memory_address_2,
	data_memory_data_in => data_memory_data_1,
	data_memory_address_in=> data_memory_address_1

);


ex_s: EX_stage
port map(
	clock => clock,

	ALUcalc_operationcode=>s_p_2_ALUcalc_operationcode,
	data_out_left=>p_s_3_data_out_left,
	data_out_right=>p_s_3_data_out_right,
	data_out_imm=>p_s_3_data_out_imm,
	--funct =>p_s_3_funct,
	shamt =>p_s_3_shamt,
	r_s=>p_s_3_r_s,
	pseudo_address=>p_s_3_pseudo_address,
	instruction_location_in => p_s_3_instruction_location_in,
	mux1_control =>s_p_2_Branch,
	mux2_control =>s_p_2_RegDst,
	mux3_control =>s_p_2_MemtoReg,
	MemRead=>p_s_3_MemRead,
	MemWrite=>p_s_3_MemWrite,
	MemToReg=>wbs_pipe_ex,
	ALUOutput =>ALUOuput_s_p,
	zeroOut =>zeroOut_s_p,
	address =>address_s_p,
	out_mux3_control =>mux3_control_s_p,
	out_MemRead=>MemRead_s_p,
	out_MemWrite=>MemWrite_s_p,
	out_MemToReg=>wbs_ex_pipe,
	pseudo_address_out => pseudo_address_s_p,
	r_s_out => r_s_s_p,
	data_memory_data_out => data_memory_data_3,
  	data_memory_data_in => data_memory_data_2,
  	data_memory_address_in => data_memory_address_2
);

exmem_pipe: EX_MEM_pipe
port map(
	reset =>reset,
	clock =>clock,

	ALUOuput=>ALUOuput_s_p,
	zeroOut =>zeroOut_s_p,
	mux3_control =>mux3_control_s_p,
	MemRead =>MemRead_s_p,
	MemWrite =>MemWrite_s_p,
	address =>address_s_p,
	MemToReg=>wbs_ex_pipe,
	mem_writedata=>writedata_p_s,
	mem_address=>address_p_s,
	mem_memwrite=>memwrite_p_s,
	mem_memread=>memread_p_s,
	mux3_control_out =>mux3_control_out_p_s_3,--does not do anything yet
  	---zeroOut_out => zeroOut_out_temp, --does not do anything yet

  	pseudo_address => pseudo_address_s_p,
  	mem_pseudo_address => pseudo_address_p_s,
	out_MemToReg =>wbs_pipe_mem,
  	r_s_in => r_s_s_p,
  	r_s_out => r_s_p_s_4,
  	data_memory_data_in =>  data_memory_data_3
);

mem_s: MEM_stage
port map(
	clock => clock,
	ALUOuput_mem_in => writedata_p_s,
	address => address_p_s,
	MemRead => memread_p_s,
	MemWrite => memwrite_p_s,
	MemToReg=>wbs_pipe_mem,
	ALUOut => ALUOut_s_p_4,
	mem_out => mem_out_s_p_4,
	--instruction_in => write_to_file_p_s,
	--instruction_out => write_to_file_p_s,
  out_MemToReg=>wbs_mem_pipe,
	write_to_file => write_to_file,
	mux3_control_in => mux3_control_out_p_s_3,
	mux3_control_out => mux3_control_out_s_p_4,
	r_s_in => r_s_p_s_4,
	r_s_out => r_s_s_p_4

);

memwb_pipe: MEM_WB_pipe
port map(
	clock => clock,
	reset => reset,
	mux3_control_in => mux3_control_out_s_p_4,
    mux3_control_out => mux3_control_out_p_s_5,
	mem_in => mem_out_s_p_4, -- memory from data memory in
	mem_out => mem_out_p_s_5,  -- memory from data memory out
	ALU_in => ALUOut_s_p_4, -- EX ALU in
	ALU_out => wb_data, --EX ALU out
	--instruction_in : IN std_logic_vector(31 downto 0); -- instruction in
	--instruction_out : OUT std_logic_vector(31 downto 0); -- instruction out
    --sel_sig_in => mux3_control_out_s_p_4, -- select signal for mux in WB stage in
    --sel_sig_out : OUT std_logic -- select signal for mux in WB stage out
    pseudo_address_in => pseudo_address_s_p_4,
    pseudo_address_out => pseudo_address_p_s_5,
    MemToReg=>wbs_mem_pipe,
    out_MemToReg=>wb_signal,
    r_s_in => r_s_s_p_4,
    r_s_out => r_s_p_s_5

);

wb_s: WB_stage
port map(
	SEL => mux3_control_out_p_s_5,
	memory_input => mem_out_p_s_5,
	ALU_input => ALUOut_p_s_5,

	pseudo_address_in => pseudo_address_p_s_5,
	pseudo_address_out => zeroOut_out_temp,
	clock => clock,
	r_s_in => r_s_p_s_5,
  r_s_out => wb_addr,
  wb_signal_in5 =>temp_wb_signal
  --wb_signal_out5 => wb_signal

);


end;
