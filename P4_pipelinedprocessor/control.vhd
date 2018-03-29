library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
use ieee.std_logic_misc.all;
entity control is
port(
	clock : in std_logic;
	reset : in std_logic;

  opcode : in std_logic_vector(5 downto 0);

	RegDst   : out std_logic;
	ALUSrc   : out std_logic;
	MemtoReg : out std_logic;
	RegWrite : out std_logic;
	MemRead  : out std_logic;
	MemWrite : out std_logic;
	Branch   : out std_logic;

	ALUcalc_operationcode : out  STD_LOGIC_VECTOR (3 downto 0)

);
end control;

architecture arch of control is
--https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats
signal 	ALUOp1   :  std_logic;
signal	ALUOp0   :  std_logic;

begin
process(clock)
begin
	--PLA style,https://cs.nyu.edu/courses/fall00/V22.0436-001/class-notes.html
	--parsed operation control for ALU
	-- PLA style control parse.JPG
	if rising_edge(clock) then

    if(opcode = "100000" or opcode = "001000" or opcode = "100011" or opcode = "101011") then
      ALUcalc_operationcode <="0000";
    elsif(opcode = "100010") then
      ALUcalc_operationcode <="0001";
    elsif(opcode = "011000" or opcode = "011001") then
      ALUcalc_operationcode <="0010";

    elsif(opcode = "011010" or opcode = "011011") then
      ALUcalc_operationcode <="0011";

    elsif(opcode = "101010" or opcode = "001010") then
      ALUcalc_operationcode <="0100";

    elsif(opcode = "100100" or opcode = "001100") then
      ALUcalc_operationcode <="0101";

    elsif(opcode = "100101" or opcode = "001101") then
      ALUcalc_operationcode <="0110";

    elsif(opcode = "100111") then
      ALUcalc_operationcode <="0111";

    elsif(opcode = "100110" or opcode = "001110") then
      ALUcalc_operationcode <="1000";

    elsif(opcode = "010000") then
      ALUcalc_operationcode <="1001";
    elsif(opcode = "010010") then
      ALUcalc_operationcode <="1010";
    elsif(opcode = "001111") then
      ALUcalc_operationcode <="1011";
    elsif(opcode = "000000") then
      ALUcalc_operationcode <="1100";
    elsif(opcode = "000010") then
      ALUcalc_operationcode <="1101";
    elsif(opcode = "000011") then
      ALUcalc_operationcode <="1110";
    elsif(opcode = "000100" or opcode = "000101") then
      ALUcalc_operationcode <="1111";
    else
      ALUcalc_operationcode <="0000";
    end if;
		if(opcode = "000000")then
			RegDst <= '1';
			ALUOp1 <= '1';
			RegWrite <= '1';
		else
			if opcode = "100011" then
				RegWrite <= '1';
			else
				RegWrite <= '0';
			end if;
			RegDst <= '0';
			ALUOp1 <= '0';
		end if;

		if(opcode = "100011")then
			MemtoReg <= '1';
			MemRead <= '1';
			ALUSrc <= '1';
		else
			if opcode = "101011" then
				ALUSrc <= '1';
			else
				ALUSrc <= '0';
			end if;
			MemtoReg <= '0';
			MemRead <= '0';
		end if;

		if(opcode = "101011")then
			MemWrite <= '1';
			ALUSrc <= '1';
		else
			if opcode = "100011" then
			else
				ALUSrc <= '0';
			end if;
			MemWrite <= '0';
		end if;

		if(opcode = "000100")then
			Branch <= '1';
			MemWrite <= '1';
			ALUOp0<='1';
		else
			Branch <= '0';
			MemWrite <= '0';
			ALUOp0<='0';
		end if;

	end if;

end process;
end arch;
