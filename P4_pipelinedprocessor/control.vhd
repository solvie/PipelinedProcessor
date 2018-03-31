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
variable comb : std_logic_vector(11 downto 0);
begin
	--PLA style,https://cs.nyu.edu/courses/fall00/V22.0436-001/class-notes.html
	--parsed operation control for ALU
	-- PLA style control parse.JPG
	if(rising_edge(clock)) then
	   comb := opcode & funct;
	   case comb is
	       when "000000100000" => ALUcalc_operationcode <= "0000"; --add
	       when "000000100010" => ALUcalc_operationcode <= "0001"; --subtract
	       when "000000011000" => ALUcalc_operationcode <= "0010"; --MULT
	       when "000000011010" => ALUcalc_operationcode <= "0011"; --div
	       when "000000100100" => ALUcalc_operationcode <= "0101"; --and
	       when "000000100101" => ALUcalc_operationcode <= "0110"; --OR
	       when "000000100111" => ALUcalc_operationcode <= "0111"; --NOR
	       when "000000100110" => ALUcalc_operationcode <= "1000"; --XOR
	       when "000000010000" => ALUcalc_operationcode <= "1001"; --MOVE from HI
	       when "000000010010" => ALUcalc_operationcode <= "1010"; --MOVE from LO
         when "001111XXXXXX" => ALUcalc_operationcode <= "1011"; --Load Upper Immediate
         when "000000000000" => ALUcalc_operationcode <= "1100"; --Shift Left Logical
         when "000000000010" => ALUcalc_operationcode <= "1101"; --Shift right Logical
         when "000000000011" => ALUcalc_operationcode <= "1110"; --Shift Right Arithmetic
         when "000000101010" => ALUcalc_operationcode <= "0100"; --Set to 1 if Less Than
	       when "000100XXXXXX" => ALUcalc_operationcode <= "1111"; --Branch if Equal
 	       when others => ALUcalc_operationcode <= "0000"; --add
	   end case;
		 if(opcode = "001010") THEN
		 	 ALUcalc_operationcode <= "0100";
		 end if;
--
--
-- 		if(opcode = "100000" or opcode = "001000" or opcode = "100011" or opcode = "101011") then
-- 		  ALUcalc_operationcode <="0000";
-- 		elsif(opcode = "100010") then
-- 		  ALUcalc_operationcode <="0001";
-- 		elsif(opcode = "011000" or opcode = "011001") then
-- 		  ALUcalc_operationcode <="0010";
--
-- 		elsif(opcode = "011010" or opcode = "011011") then
-- 		  ALUcalc_operationcode <="0011";

-- 		elsif(opcode = "101010" or opcode = "001010") then
-- 		  ALUcalc_operationcode <="0100";

-- 		elsif(opcode = "100100" or opcode = "001100") then
-- 		  ALUcalc_operationcode <="0101";

-- 		elsif(opcode = "100101" or opcode = "001101") then
-- 		  ALUcalc_operationcode <="0110";

-- 		elsif(opcode = "100111") then
-- 		  ALUcalc_operationcode <="0111";

-- 		elsif(opcode = "100110" or opcode = "001110") then
-- 		  ALUcalc_operationcode <="1000";

-- 		elsif(opcode = "010000") then
-- 		  ALUcalc_operationcode <="1001";
-- 		elsif(opcode = "010010") then
-- 		  ALUcalc_operationcode <="1010";
-- 		elsif(opcode = "001111") then
-- 		  ALUcalc_operationcode <="1011";
-- 		elsif(opcode = "000000") then
-- 		  ALUcalc_operationcode <="1100";
-- 		elsif(opcode = "000010") then
-- 		  ALUcalc_operationcode <="1101";
-- 		elsif(opcode = "000011") then
-- 		  ALUcalc_operationcode <="1110";
-- 		elsif(opcode = "000100" or opcode = "000101") then
-- 		  ALUcalc_operationcode <="1111";
-- 		else
-- 		  ALUcalc_operationcode <="0000";
-- 		end if;

--	RegDst <= not opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and not opcode(1) and not opcode(0);
--	ALUSrc <= (opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and opcode(1) and opcode(0)) or (opcode(5) and not opcode(4) and opcode(3) and not opcode(2) and opcode(1) and opcode(0));
--	MemtoReg <= opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and opcode(1) and opcode(0);
--	RegWrite <= (not opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and not opcode(1) and not opcode(0)) or (opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and opcode(1) and opcode(0));
--	MemRead <= opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and opcode(1) and opcode(0);
--	MemWrite <=opcode(5) and not opcode(4) and opcode(3) and not opcode(2) and opcode(1) and opcode(0);
--	Branch <= not opcode(5) and not opcode(4) and not opcode(3) and opcode(2) and not opcode(1) and not opcode(0);
--	ALUOp1 <= not opcode(5) and not opcode(4) and not opcode(3) and not opcode(2) and not opcode(1) and not opcode(0);
--	ALUOp0<=not opcode(5) and not opcode(4) and not opcode(3) and opcode(2) and not opcode(1) and not opcode(0);

	if(opcode = "000000")then
		RegDst <= '1';
		if(funct ="100000" or funct="100010" or funct = "000000" or funct ="000010" or funct ="000011" or funct ="010000" or funct="010010") then
			ALUOp1 <= '1';
			RegWrite <= '0';
		else
			ALUOp1 <= '1';
			RegWrite <= '1';
		end if;
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
