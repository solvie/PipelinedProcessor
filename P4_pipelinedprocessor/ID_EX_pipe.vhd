library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_EX_pipe is
port( 
	clock : IN std_logic;
	reset : IN std_logic;
	--id output
	instruction_loc_in : in std_logic_vector(31 downto 0);
	instruction_loc_out: out std_logic_vector(31 downto 0);

	d_data_out_left: in std_logic_vector (31 downto 0);
	d_data_out_right: in std_logic_vector (31 downto 0);
	d_data_out_imm: in std_logic_vector (31 downto 0); -- sign/zero extended value will come out
	d_funct : in std_logic_vector(5 downto 0);
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
	funct : out std_logic_vector(5 downto 0);
	shamt : out std_logic_vector(4 downto 0);
	r_s: out std_logic_vector (4 downto 0);
	pseudo_address : out std_logic_vector(25 downto 0);
	
	
	mux1_control : out std_logic;
	mux2_control : out std_logic;
	mux3_control : out std_logic;
	MemRead : out std_logic;
	MemWrite : out std_logic
 );
end ID_EX_pipe;

architecture behavior of ID_EX_pipe is

begin

process(reset, clock)
    begin
        if reset = '1' then
            
        elsif rising_edge(clock) then
            ALUcalc_operationcode<=d_ALUcalc_operationcode;
            data_out_left <=d_data_out_left;
            data_out_right<=d_data_out_right;
            data_out_imm<=d_data_out_imm;
            funct<=d_funct;
            shamt<=d_shamt;
            r_s<=d_r_s;
            pseudo_address<=d_pseudo_address;
            -- from control

            mux1_control <= d_Branch;
			mux2_control <= d_RegDst;
			mux3_control <= d_MemtoReg;
			MemRead <=d_MemRead;
			MemWrite <=d_MemWrite;
	        instruction_loc_out<=instruction_loc_in;

	     
        end if;
    end process;
end;
