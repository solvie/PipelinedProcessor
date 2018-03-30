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
  funct : in std_logic_vector(5 downto 0);
	RegDst   : out std_logic;
	ALUSrc   : out std_logic;
	MemtoReg : out std_logic;
	RegWrite : out std_logic;
	MemRead  : out std_logic;
	MemWrite : out std_logic;
	Branch   : out std_logic;

	ALUcalc_operationcode : out  STD_LOGIC_VECTOR (3 downto 0) :="0000"

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
else
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

	RegDst <= not opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and not opcode(1) and not opcode(0);
	ALUSrc <= (opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and opcode(1) and opcode(0)) or (opcode(5) and not opcode(4) and opcode(3) and not opcode(2) and opcode(1) and opcode(0));
	MemtoReg <= opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and opcode(1) and opcode(0);
	RegWrite <= (not opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and not opcode(1) and not opcode(0)) or (opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and opcode(1) and opcode(0));
	MemRead <= opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and opcode(1) and opcode(0);
	MemWrite <=opcode(5) and not opcode(4) and opcode(3) and not opcode(2) and opcode(1) and opcode(0);
	Branch <= not opcode(5) and not opcode(4) and not opcode(3) and opcode(2) and not opcode(1) and not opcode(0);
	ALUOp1 <= not opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and not opcode(1) and not opcode(0);
	ALUOp0<=not opcode(5) and not opcode(4) and not opcode(3) and opcode(2) and not opcode(1) and not opcode(0);
	
	end if;

end process;
end arch;
