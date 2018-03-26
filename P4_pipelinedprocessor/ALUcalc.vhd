library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALUcalc is
    Port ( 
    clock : in STD_LOGIC;
		A : in  STD_LOGIC_VECTOR (31 downto 0);
    B : in  STD_LOGIC_VECTOR (31 downto 0);
		operationcode : in STD_LOGIC_VECTOR (3 downto 0);
		zero : out STD_LOGIC := '0';
		alucalcresult : out STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000"
    );
end ALUcalc;

architecture Behavior of ALUcalc is

	signal long : STD_LOGIC_VECTOR (63 downto 0);
	signal hi : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
	signal lo : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
	
begin
  process(clock)
begin
  if rising_edge(clock) then
    long <= STD_LOGIC_VECTOR(signed(A)*signed(B));
	
	hi <= 
		long(63 downto 32) when(operationcode = "0010") 						-- Multiply
		STD_LOGIC_VECTOR(signed(A) rem signed(B)) when(operationcode = "0011");		-- Divide
	
	lo <=
		long(31 downto 0) when(operationcode = "0010");						-- Multiply
		STD_LOGIC_VECTOR(signed(A) rem signed(B)) when(operationcode = "0011");		-- Divide
	

--Codes from: https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats
	alucalcresult <=STD_LOGIC_VECTOR(signed(A)+signed(B)) when(operationcode = "0000"); 		-- Add
		STD_LOGIC_VECTOR(signed(A)-signed(B)) when(operationcode = "0001") 		-- Subract
		A AND B when(operationcode = "0101")  									-- And
		A OR B when(operationcode = "0110")  									-- OR
		A NOR B when(operationcode = "0111")  									-- NOR
		A XOR B when(operationcode = "1000")  									-- XOR
		hi when(operationcode = "1001") 										-- Move From Hi
		lo when(operationcode = "1010") 										-- Move From Lo
		STD_LOGIC_VECTOR(shift_left(signed(A), 16)) when(operationcode = "1011")  	-- Load Upper Immediate
		STD_LOGIC_VECTOR(shift_left(signed(A), to_integer(signed(B)))) when(operationcode = "1100")  	-- Shift Left Logical
		STD_LOGIC_VECTOR(shift_right(signed(A), to_integer(signed(B)))) when(operationcode = "1101")  	-- Shift Right Logical
		to_stdlogicvector(to_bitvector(A) sra to_integer(signed(B))) when(operationcode = "1110") 	-- Shift Right Arithmetic
		"00000000000000000000000000000001" when (operationcode = "0100" and A<B) 	-- Set Less Than
		"00000000000000000000000000000000"; -- Default to 0
		
	zero <=
		'1' when(operationcode = "1111" and A=B) 	-- Branch on Equal
		'0';
  end if;
	

end Behavior;