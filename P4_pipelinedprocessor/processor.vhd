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

	mux_input_to_stage1 : IN std_logic_vector(31 downto 0); -- temp, should come from ex/mem
	mux_select_sig_to_stage1 : IN std_logic;-- temp, should come from mem stage
	instruction_out : OUT std_logic_vector(31 downto 0); -- temp CONNECT TO ID stage
	instr_loc_out : OUT std_logic_vector(31 downto 0); -- temp CONNECT TO ID stage
	
	-- The ports below are only exposed so that instruction memory can be loaded externally before the processor starts its business
	writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	address: IN INTEGER RANGE 0 TO ram_size-1;
	memwrite: IN STD_LOGIC;
	memread: IN STD_LOGIC;
	readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	waitrequest: OUT STD_LOGIC
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
		waitrequest: OUT STD_LOGIC
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

signal mux_output_stage_1: std_logic_vector(31 downto 0);
signal pc_out_as_int: Integer;
signal instruction: std_logic_vector(31 downto 0);

begin

LoadToInstMem: instruction_memory 
port map(
    clock => clock,
    writedata => writedata,
    address => address,
    memwrite => memwrite,
    memread => memread,
    readdata => instruction,
    waitrequest => waitrequest
);

if_s: IF_stage 
port map(
    clock => clock,
    reset => reset,
    mux_input_to_stage1 => mux_input_to_stage1,
    mux_select_sig_to_stage1 => mux_select_sig_to_stage1,
    mux_output_stage_1 => mux_output_stage_1,
    pc_out_as_int => pc_out_as_int
);

ifid_pipe: IF_ID_pipe 
port map(
    clock => clock,
    reset => reset,
	instruction_in => instruction,
	instruction_out => instruction_out,
	instr_loc_in => mux_output_stage_1,
	instr_loc_out =>instr_loc_out
);


	
end;