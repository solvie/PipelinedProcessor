library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_WB_pipe is
port( 
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
end MEM_WB_pipe;

architecture behavior of MEM_WB_pipe is

begin

process(reset, clock)
    begin
        if reset = '1' then
            mem_out <= (others => '0'); 
            ALU_out <= (others => '0');
            --instruction_out <= (others => '0');
            pseudo_address_out <= (others => '0');
            mux3_control_out <= '0';
            r_s_out <= (others => '0');
        elsif rising_edge(clock) then
            mem_out	<= mem_in;
            ALU_out	<= ALU_in;
            --instruction_out <= instruction_in;
            --sel_sig_out <= sel_sig_in;
            pseudo_address_out <= pseudo_address_in;
            mux3_control_out <= mux3_control_in;
            r_s_out <=  r_s_in;
        end if;
    end process;
end;