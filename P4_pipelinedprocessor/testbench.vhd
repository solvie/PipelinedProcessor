library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity testbench is
end testbench;

architecture
behavior of testbench is

component processor is
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
	waitrequest_m: OUT STD_LOGIC;
	data_ready: in std_logic


);
end component;

constant clk_period : time := 1 ns;

signal clock : std_logic := '0';
signal reset : std_logic;
signal mux_input_to_stage1 : std_logic_vector(31 downto 0);
signal mux_select_sig_to_stage1: std_logic;
signal mux_output_stage_1 : std_logic_vector(31 downto 0);
signal pc_out_as_int: Integer;

--initialize instruction memory
signal im_addr : integer range 0 to 1023;
signal im_read : std_logic;
signal im_readdata : std_logic_vector (31 downto 0);
signal im_write : std_logic;
signal im_writedata : std_logic_vector (31 downto 0);
signal im_waitrequest : std_logic;
signal verify_instMem: std_logic_vector (31 downto 0);
signal verify_pc_out: std_logic_vector (31 downto 0);

signal temp_readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal tempp_waitrequest: std_logic;

signal im_write_to_file: std_logic;
file file_VECTORS : text;
file file_Output : text;

signal data_ready_m: std_logic;
begin

real_cpu: processor
port map(
	clock => clock,
	reset => reset,
	-- The ports below are only exposed so that instruction memory can be loaded externally before the processor starts its business
	writedata => im_writedata,
	address =>im_addr,
	mem_write => im_write,
	mem_read => im_read,
	readdata => im_readdata,
	waitrequest => im_waitrequest,

	write_to_file=> im_write_to_file,

	-- FOR MEM
	readdata_m =>temp_readdata,
	waitrequest_m => tempp_waitrequest,
	data_ready => data_ready_m
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
variable v_OLINE: line;
variable v_temp_sig: std_logic_vector (31 downto 0);
variable i: integer := 0;
variable j: integer := 0;

begin
data_ready_m <= '0';
wait until rising_edge(clock);
im_write_to_file <= '0';
im_read <= '1';
im_read <= '0';
  file_open(file_VECTORS, "program.txt",  read_mode);
	im_write <= '1';
  	while not endfile(file_VECTORS) and i < 1024 loop
		im_addr <= i;
		readline(file_VECTORS, v_ILINE);
		read(v_ILINE, v_temp_sig);
		im_writedata <= v_temp_sig;
		i := i + 1;
		wait for 1*clk_period;
	end loop;
file_close(file_VECTORS);

	wait for 1*clk_period;
	im_write <= '0';
	data_ready_m <= '1';
	--i := i - 1;
--	im_addr <= 0;

--im_read <= '1';
--while i>= 0 loop
--	im_addr <= i;
--	verify_instMem <= im_readdata;
--	i := i - 1;
--	wait for 1*clk_period;
--end loop;
--im_read <= '0';



--reading instructinon mem using pc

reset<='1';
mux_select_sig_to_stage1<= '1';
mux_input_to_stage1 <= std_logic_vector(to_unsigned(0,32));
wait for 1*clk_period;
reset<='0';


--im_read <= '1';
--verify_pc_out <= std_logic_vector(to_unsigned(0,32));
--wait for 1*clk_period;
--while verify_pc_out /= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" loop
--	im_addr <= pc_out_as_int;
--	wait for 1*clk_period;
--	verify_pc_out <= im_readdata;
--end loop;
--verify_pc_out <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
--im_read <= '0';
-------Write to file-------------------------------
--file_open(file_Output, "output_results.txt", write_mode);

--im_read <= '1';
--wait for 1*clk_period;
--while j < i loop
--	im_addr <= j;
--	wait for 1*clk_period;
--	write(v_OLINE, im_readdata, right, 32);
--	writeline(file_Output, v_OLINE);
--	j := j + 1;
--end loop;


-----------------------------------------------

  --wait for 1*clk_period;
  --mux_select_sig_to_stage1<= '0';

  --wait for 1*clk_period;
  --mux_select_sig_to_stage1<= '1';


  wait for i*5*clk_period;
  im_write_to_file <= '1';

wait;
end process;

end;
