LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY memory IS 
	GENERIC(
		ram_size : INTEGER := 8192;
		mem_delay : time := 10 ns;
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
END memory;

ARCHITECTURE behaviour OF memory IS

	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal mem_block: mem;
	SIGNAL read_address_reg: INTEGER RANGE 0 to ram_size-1;
	SIGNAL write_waitreq_reg: STD_LOGIC := '1';
	SIGNAL read_waitreq_reg: STD_LOGIC := '1';
	
BEGIN

	mem_process: PROCESS (clock)
	BEGIN
	
	IF(now<1ps)THEN 
		For i in 0 to ram_size-1 LOOP
			mem_block(i) <= std_logic_vector(to_unsigned(i,32));
		END LOOP;
	end if;
	
	IF (clock'event AND clock = '1') THEN
			IF (memwrite = '1') THEN
				mem_block(address) <= writedata;
			END IF;
		read_address_reg <= address;
		END IF;
	END PROCESS;
	readdata <= mem_block(read_address_reg);
	
	waitreq_w_proc: PROCESS (memwrite)
	BEGIN
		IF(memwrite'event AND memwrite = '1')THEN
			write_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;

		END IF;
	END PROCESS;

	waitreq_r_proc: PROCESS (memread)
	BEGIN
		IF(memread'event AND memread = '1')THEN
			read_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;
		END IF;
	END PROCESS;
	waitrequest <= write_waitreq_reg and read_waitreq_reg;


END rtl;
		
		
		
	 
	

 
