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
	address: IN INTEGER RANGE 0 TO ram_size-1;
	mem_write: IN STD_LOGIC;
	mem_read: IN STD_LOGIC;
	readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	waitrequest: OUT STD_LOGIC;

	write_to_file: IN std_logic;
	-- FOR MEM
	readdata_m: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	waitrequest_m: OUT STD_LOGIC

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
	pc_out_as_int : OUT Integer
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
	instr_loc_out : OUT std_logic_vector(31 downto 0)
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
	-- from control
	RegDst   : out std_logic;
	--ALUSrc   : out std_logic;
	MemtoReg : out std_logic;
	MemRead  : out std_logic;
	MemWrite : out std_logic;
	Branch   : out std_logic;
	ALUcalc_operationcode : out std_logic_vector(3 downto 0 );
	write_to_file : in std_logic
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
	MemWrite : out std_logic
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
	out_MemWrite: out std_logic;
	pseudo_address_out: out std_logic_vector(25 downto 0);
	r_s_out: out std_logic_vector (4 downto 0)
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
	mem_address: out INTEGER;-- RANGE 0 TO ram_size-1;
	mem_memwrite: out STD_LOGIC;
	mem_memread: out STD_LOGIC;
	mux3_control_out : out std_logic;
  	--zeroOut_out: out std_logic;

  	pseudo_address : in std_logic_vector(25 downto 0);
  	mem_pseudo_address : out std_logic_vector(25 downto 0);
  	r_s_in : in std_logic_vector(4 downto 0);
  	r_s_out: out std_logic_vector(4 downto 0)

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

	ALUOut: out STD_LOGIC_VECTOR (31 downto 0);
	mem_out: out STD_LOGIC_VECTOR (31 DOWNTO 0);
	--instruction_in: IN std_logic_vector(31 downto 0);
	--instruction_out: OUT std_logic_vector(31 downto 0);
	pseudo_address_in: in STD_LOGIC_VECTOR (25 downto 0);
	pseudo_address_out: out STD_LOGIC_VECTOR (25 downto 0);
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
    r_s_out: out std_logic_vector(4 downto 0)
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
    r_s_out : out STD_LOGIC_VECTOR (4 downto 0)
	);
end component;

component mux_2_to_1_int is
    Port ( SEL : in  STD_LOGIC;
           A   : in  integer;
           B   : in  integer;
           Output   : out integer
           );
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
signal wb_addr: std_logic_vector(4 downto 0);
signal wb_data: std_logic_vector(31 downto 0);
--signal write_to_file: std_logic;
--ID -> ID_EX
signal instr_loc_p_s_2: std_logic_vector(31 downto 0);
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
-- EX
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
signal pseudo_address_p_s: std_logic_vector(25 downto 0);
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

--temp
signal zeroOut_out_temp: STD_LOGIC_VECTOR (25 downto 0);

signal mem_address: INTEGER RANGE 0 to 1023;
signal wb_signal_temp: std_logic := '1';


signal data_ready: STD_LOGIC;




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

select_address: mux_2_to_1_int
port map(
    SEL => data_ready,
    A => address,
    B => pc_out_as_int,
    Output =>mem_address
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
    mux_input_to_stage1 => mux_input_to_stage1,
    mux_select_sig_to_stage1 => '0',
    mux_output_stage_1 => instr_loc_s_p,
    pc_out_as_int => pc_out_as_int
);

ifid_pipe: IF_ID_pipe
port map(
    clock => clock,
    reset => reset,
	instruction_in => instruction_s_p,
	instruction_out => instr_loc_p_s,
	instr_loc_in => instr_loc_s_p,
	instr_loc_out => instruction_out_p_s
);

id_s: ID_stage
port map(
	-- inputs
    clock => clock,
    reset => reset,
	instruction => instr_loc_p_s,
	instruction_loc_in => instruction_out_p_s,
	instruction_loc_out => instruction_out_p_s_2,
	wb_addr => wb_addr,
	wb_data => wb_data,
	wb_signal => wb_signal_temp,
	-- from registers
	data_out_left=>s_p_2_data_out_left,
	data_out_right=>s_p_2_data_out_right,
	data_out_imm=>s_p_2_data_out_imm,
--	funct =>s_p_2_funct,
	shamt =>s_p_2_shamt,
	r_s=>s_p_2_r_s,
	pseudo_address=>s_p_2_pseudo_address,
	-- from control
	RegDst   =>s_p_2_RegDst,
	--ALUSrc  => s_p_2_MemtoReg,
	MemtoReg=> s_p_2_MemtoReg,
	MemRead  =>s_p_2_MemRead,
	MemWrite =>s_p_2_MemWrite,
	Branch   =>s_p_2_Branch,
	ALUcalc_operationcode =>s_p_2_ALUcalc_operationcode,
	write_to_file =>write_to_file
);

idex_pipe: ID_EX_pipe
port map(
	clock =>clock,
	reset=>reset,
	instruction_loc_in =>instr_loc_p_s_2,
	instruction_loc_out =>instruction_out_p_s_2,
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
	MemWrite =>p_s_3_MemWrite
);


ex_s: EX_stage
port map(
	clock => clock,

	ALUcalc_operationcode=>p_s_3_ALUcalc_operationcode,
	data_out_left=>p_s_3_data_out_left,
	data_out_right=>p_s_3_data_out_right,
	data_out_imm=>p_s_3_data_out_imm,
	--funct =>p_s_3_funct,
	shamt =>p_s_3_shamt,
	r_s=>p_s_3_r_s,
	pseudo_address=>p_s_3_pseudo_address,

	mux1_control =>p_s_3_mux1_control,
	mux2_control =>p_s_3_mux2_control,
	mux3_control =>p_s_3_mux3_control,
	MemRead=>p_s_3_MemRead,
	MemWrite=>p_s_3_MemWrite,

	ALUOutput =>ALUOuput_s_p,
	zeroOut =>zeroOut_s_p,
	address =>address_s_p,
	out_mux3_control =>mux3_control_s_p,
	out_MemRead=>MemRead_s_p,
	out_MemWrite=>MemWrite_s_p,
	pseudo_address_out => pseudo_address_s_p,
	r_s_out => r_s_s_p
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

	mem_writedata=>writedata_p_s,
	mem_address=>address_p_s,
	mem_memwrite=>memwrite_p_s,
	mem_memread=>memread_p_s,
	mux3_control_out =>mux3_control_out_p_s_3,--does not do anything yet
  	---zeroOut_out => zeroOut_out_temp, --does not do anything yet

  	pseudo_address => pseudo_address_s_p,
  	mem_pseudo_address => pseudo_address_p_s,

  	r_s_in => r_s_s_p,
  	r_s_out => r_s_p_s_4
);

mem_s: MEM_stage
port map(
	clock => clock,
	ALUOuput_mem_in => writedata_p_s,
	address => address_p_s,
	MemRead => memread_p_s,
	MemWrite => memwrite_p_s,

	ALUOut => ALUOut_s_p_4,
	mem_out => mem_out_s_p_4,
	--instruction_in => write_to_file_p_s,
	--instruction_out => write_to_file_p_s,

	write_to_file => write_to_file,
	mux3_control_in => mux3_control_out_p_s_3,
	mux3_control_out => mux3_control_out_s_p_4,
	pseudo_address_in => pseudo_address_p_s,
	pseudo_address_out => pseudo_address_s_p_4,
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
	ALU_out => ALUOut_p_s_5, --EX ALU out
	--instruction_in : IN std_logic_vector(31 downto 0); -- instruction in
	--instruction_out : OUT std_logic_vector(31 downto 0); -- instruction out
    --sel_sig_in => mux3_control_out_s_p_4, -- select signal for mux in WB stage in
    --sel_sig_out : OUT std_logic -- select signal for mux in WB stage out
    pseudo_address_in => pseudo_address_s_p_4,
    pseudo_address_out => pseudo_address_p_s_5,
    r_s_in => r_s_s_p_4,
    r_s_out => r_s_p_s_5

);

wb_s: WB_stage
port map(
	SEL => mux3_control_out_p_s_5,
	memory_input => mem_out_p_s_5,
	ALU_input => ALUOut_p_s_5,
	Output_wb => wb_data,
	pseudo_address_in => pseudo_address_p_s_5,
	pseudo_address_out => zeroOut_out_temp,
	clock => clock,
	r_s_in => r_s_p_s_5,
    r_s_out => wb_addr

);


end;
