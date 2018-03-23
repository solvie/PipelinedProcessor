library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity Overall_tb is
end Overall_tb;

architecture 
behavior of Overall_tb is

component IF_stage is
port( 
	clock : IN std_logic;
	reset : IN std_logic;
	mux_input_to_stage1 : IN std_logic_vector(31 downto 0); -- this will come from the EX/MEM buffer
	mux_select_sig_to_stage1 : IN std_logic;
	mux_output_stage_1 : INOUT std_logic_vector(31 downto 0)
	--memory_out_stage_1 : OUT std_logic_vector(31 downto 0)
 );
end component;

component instruction_memory IS
	GENERIC(
		ram_size : INTEGER := 1024;
		mem_delay : time := 1 ns;
		clock_period : time := 1 ns
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

constant clk_period : time := 1 ns;

signal clock : std_logic := '0';
signal reset : std_logic;
signal mux_input_to_stage1 : std_logic_vector(31 downto 0);
signal mux_select_sig_to_stage1: std_logic;
signal mux_output_stage_1 : std_logic_vector(31 downto 0);
--signal memory_out_stage_1 : std_logic_vector(31 downto 0);

--initialize instruction memory
signal im_addr : integer range 0 to 1023;
signal im_read : std_logic;
signal im_readdata : std_logic_vector (31 downto 0);
signal im_write : std_logic;
signal im_writedata : std_logic_vector (31 downto 0);
signal im_waitrequest : std_logic; 
signal verify_instMem: std_logic_vector (31 downto 0);


file file_VECTORS : text;
begin

LoadToInstMem: instruction_memory 
port map(
    clock => clock,
    writedata => im_writedata,
    address => im_addr,
    memwrite => im_write,
    memread => im_read,
    readdata => im_readdata,
    waitrequest => im_waitrequest
);

stage1: IF_stage 
port map(
    clock => clock,
    reset => reset,
    mux_input_to_stage1 => mux_input_to_stage1,
    mux_select_sig_to_stage1 => mux_select_sig_to_stage1,
    mux_output_stage_1 => mux_output_stage_1
    --memory_out_stage_1 => memory_out_stage_1
);

clk_process : process
begin
  clock <= '0';
  wait for clk_period/2;
  clock <= '1';
  wait for clk_period/2;
end process;

test_process : process
variable v_ILINE: line;
variable v_temp_sig: std_logic_vector (31 downto 0);
variable i: integer := 0;

begin
  file_open(file_VECTORS, "program.txt",  read_mode);
	im_write <= '1';
  	while not endfile(file_VECTORS) and i < 1024 loop
		readline(file_VECTORS, v_ILINE);
		read(v_ILINE, v_temp_sig);
		im_addr <= i;
		im_writedata <= v_temp_sig;
		i := i + 1;
		wait for 1*clk_period;
	end loop;
	im_write <= '0';
i := i - 1;
im_read <= '1';
while i>= 0 loop
im_addr <= i;
verify_instMem <= im_readdata;
i := i - 1;
wait for 1*clk_period;
end loop;
im_read <= '0';


  reset<='1';
  mux_select_sig_to_stage1<= '1';
  mux_input_to_stage1 <= std_logic_vector(to_unsigned(0,32));
  wait for 1*clk_period;
  reset<='0';

  wait for 7*clk_period;
  mux_select_sig_to_stage1<= '0';

  wait for 1*clk_period;
  mux_select_sig_to_stage1<= '1';


wait;

end process;
	
end;