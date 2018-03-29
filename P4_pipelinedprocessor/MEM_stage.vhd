library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_stage is
port( 
	clock : IN std_logic;
	ALUOuput_mem_in: in STD_LOGIC_VECTOR (31 downto 0);
	address: IN INTEGER;
	MemRead : in std_logic;
	MemWrite : in std_logic;

	ALUOut: out STD_LOGIC_VECTOR (31 downto 0);
	mem_out: out STD_LOGIC_VECTOR (31 DOWNTO 0);
	--instruction_in: IN std_logic_vector(31 downto 0);
	--instruction_out: OUT std_logic_vector(31 downto 0);
	mux3_control_in : in std_logic;
	mux3_control_out: out std_logic;
	write_to_file : in std_logic;
	pseudo_address_in : in std_logic_vector(25 downto 0);
	pseudo_address_out : out std_logic_vector(25 downto 0);
	r_s_in: in std_logic_vector(4 downto 0);
	r_s_out: out std_logic_vector(4 downto 0)
);
end MEM_stage;


architecture behavior of MEM_stage is

component data_memory is
GENERIC(
	ram_size : INTEGER := 8192;
	mem_delay : time := 0 ns;
	clock_period : time := 1 ns
);
PORT (
	clock: IN STD_LOGIC;
	writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	address: IN INTEGER;-- RANGE 0 TO ram_size-1;
	memwrite: IN STD_LOGIC;
	memread: IN STD_LOGIC;
	readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	waitrequest: OUT STD_LOGIC;
	write_to_file: in STD_LOGIC
);
end component;


signal waitrequest: std_logic;

begin

MEM_s : data_memory
port map(
	clock => clock,
	writedata => ALUOuput_mem_in,
	address => address, 
	memwrite => MemWrite,
	memread => MemRead,
	readdata => mem_out,
	waitrequest => waitrequest,
	write_to_file => write_to_file
	
);

--process (instruction_in) begin
	--instruction_out <= instruction_in;
--end process;

process (ALUOuput_mem_in) begin
	ALUOut <= ALUOuput_mem_in;
end process;

process (r_s_in) begin
	r_s_out <= r_s_in;
end process;
	
end;
