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
	if (operationcode = "0010") then
		hi <= long(63 downto 32);	  						-- Multiply
	elsif(operationcode = "0011") then
		hi <= STD_LOGIC_VECTOR(signed(A) rem signed(B));		-- Divide
	end if;
	
	if (operationcode = "0010") then
	lo <= long(31 downto 0);								-- Multiply
	elsif(operationcode = "0011") then
	lo <= STD_LOGIC_VECTOR(signed(A) rem signed(B));		-- Divide
	end if;

--Codes from: https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats
	if (operationcode = "0000") then
	alucalcresult <=STD_LOGIC_VECTOR(signed(A)+signed(B)); 		-- Add
	elsif(operationcode = "0001") then
	alucalcresult <=STD_LOGIC_VECTOR(signed(A)-signed(B)); 		-- Subract
	elsif(operationcode = "0010") then
	alucalcresult <=lo;		-- Multiply
	elsif(operationcode = "0011") then
	alucalcresult <=lo;		-- Multiply
	elsif (operationcode = "0101") then
	alucalcresult <=A AND B;   									-- And
	elsif (operationcode = "0110") then
	alucalcresult <=A OR B ;  									-- OR
	elsif (operationcode = "0111") then
	alucalcresult <=A NOR B ;  									-- NOR
	elsif (operationcode = "1000") then
	alucalcresult <=A XOR B ;  									-- XOR
	elsif (operationcode = "1001") then
	alucalcresult <=hi;  										-- Move From Hi
	elsif (operationcode = "1010") then 
	alucalcresult <=lo; 											-- Move From Lo
	elsif (operationcode = "1011") then
	alucalcresult <=STD_LOGIC_VECTOR(shift_left(signed(A), 16)); -- Load Upper Immediate
	elsif (operationcode = "1100") then
	alucalcresult <= STD_LOGIC_VECTOR(shift_left(signed(A), to_integer(signed(B)))); 	-- Shift Left Logical
	elsif (operationcode = "1101") then
	alucalcresult <=STD_LOGIC_VECTOR(shift_right(signed(A), to_integer(signed(B))));   	-- Shift Right Logical
	elsif (operationcode = "1110") then
	alucalcresult <=to_stdlogicvector(to_bitvector(A) sra to_integer(signed(B))); 	 	-- Shift Right Arithmetic
	elsif (operationcode = "0100" and A<B) then
	alucalcresult <="00000000000000000000000000000001";  	-- Set Less Than
	else
	alucalcresult <="00000000000000000000000000000000"; -- Default to 0
	end if;
	
	if (operationcode = "1111" and A=B) then
	zero <='1'; 	-- Branch on Equal
	else
	zero <='0';
  end if;
	
end if;
end process;
end Behavior;