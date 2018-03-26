--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY instruction_memory IS
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
END instruction_memory;

ARCHITECTURE rtl OF instruction_memory IS
	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block: MEM;
	SIGNAL read_address_reg: INTEGER RANGE 0 to ram_size-1;
	SIGNAL write_waitreq_reg: STD_LOGIC := '1';
	SIGNAL read_waitreq_reg: STD_LOGIC := '1';
	file file_Output : text;

BEGIN
	--This is the main section of the SRAM model
	mem_process: PROCESS (clock)
	BEGIN
		--This is a cheap trick to initialize the SRAM in simulation
		IF(now < 1 ps)THEN
			For i in 0 to ram_size-1 LOOP
				ram_block(i) <= std_logic_vector(to_unsigned(i,32));
			END LOOP;
		end if;

		--This is the actual synthesizable SRAM block
		IF (clock'event AND clock = '1') THEN
			IF (0<=address AND address<=ram_size-1) THEN
				IF (memwrite = '1') THEN
					ram_block(address) <= writedata;
				END IF;
			END IF;
		--read_address_reg <= address;
		END IF;
	END PROCESS;
	readdata <= ram_block(address);


	--The waitrequest signal is used to vary response time in simulation
	--Read and write should never happen at the same time.
	--waitreq_w_proc: PROCESS (memwrite)
	--BEGIN
	--	IF(memwrite'event AND memwrite = '1')THEN
	--		write_waitreq_reg <= '0';
	--	END IF;
	--END PROCESS;

	--waitreq_r_proc: PROCESS (memread)
	--BEGIN
	--	IF(memread'event AND memread = '1')THEN
	--		read_waitreq_reg <= '0';
	--	END IF;
	--END PROCESS;
	--waitrequest <= write_waitreq_reg and read_waitreq_reg;
	waitrequest <= '0';

	write_file: PROCESS (write_to_file)
	variable i: integer := 0;
	variable v_OLINE: line;
	BEGIN
		--if write_to_file is true, loop through memory array and write all lines(even unused ones) in to the file
		IF(write_to_file = '1')THEN
			file_open(file_Output, "output_results.txt", write_mode);
			while i < ram_size loop
					write(v_OLINE, ram_block(i), right, 32);
					writeline(file_Output, v_OLINE);
					i := i + 1;

			end loop;
		end if;

	END PROCESS;


END rtl;
