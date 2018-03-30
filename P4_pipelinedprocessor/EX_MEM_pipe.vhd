library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_MEM_pipe is
  port(
  reset : IN std_logic;
	clock : IN std_logic;

	ALUOuput :	in STD_LOGIC_VECTOR (31 downto 0);
	zeroOut :	in STD_LOGIC;
	mux3_control : in std_logic;
	MemRead : in std_logic;
	MemWrite : in std_logic;
	address : in std_logic_vector(31 downto 0);
	pseudo_address : in std_logic_vector(25 downto 0);
	MemToReg : in std_logic;
	mem_writedata: out STD_LOGIC_VECTOR (31 DOWNTO 0);
	mem_address: out INTEGER range 0 to 8191; -- RANGE 0 TO ram_size-1
	mem_memwrite: out STD_LOGIC;
	mem_memread: out STD_LOGIC;
	mux3_control_out : out std_logic;
    zeroOut_out: out std_logic;
	mem_write_to_file: out STD_LOGIC;
	pseudo_address_converted : out std_logic_vector(31 downto 0);
	out_MemToReg : out std_logic;
	r_s_in : in std_logic_vector(4 downto 0);
	r_s_out: out std_logic_vector(4 downto 0);
	
	test: out std_logic_vector(31 downto 0):="00000000000000000000000000000000"
 );
end EX_MEM_pipe;

architecture behavior of EX_MEM_pipe is
begin

process(reset, clock)
    begin
        if reset = '1' then
            mem_writedata <="00000000000000000000000000000000";
            mem_address<=0;
            mem_memwrite<='0';
            mem_memread<='0';
            mux3_control_out <= '0';
            zeroOut_out <= '0';
            pseudo_address_converted <="00000000000000000000000000000000";
            r_s_out <= (others => '0');
			test <= "00000000000000000000000000000000";
        elsif rising_edge(clock) then
			out_MemToReg<= MemToReg;
			mem_writedata <=ALUOuput;
			mem_address<= to_integer(unsigned(address(12 downto 0)));
			mem_memwrite<=MemWrite;
			mem_memread<=MemRead;
			mux3_control_out <= mux3_control;
		    zeroOut_out <= zeroOut;
			pseudo_address_converted <= (31 downto pseudo_address'length => '0') & pseudo_address;
			test <= (31 downto pseudo_address'length => '0') & pseudo_address;
			r_s_out <= r_s_in;
        end if;
    end process;
end;
