library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALUctrl is
    Port ( 
        opcode : in  STD_LOGIC_VECTOR (5 downto 0);
        ALUcalc_operationcode : out  STD_LOGIC_VECTOR (3 downto 0)
		);
end ALUctrl;

architecture Behavior of ALUctrl is


begin
--Codes from: https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats
    ALUcalc_operationcode <=
		"0000" when(opcode = "100000" or opcode = "001000" or opcode = "100011" or opcode = "101011") else  -- Add
		"0001" when(opcode = "100010") else 						-- Subtract
		"0010" when(opcode = "011000" or opcode = "011001") else  	-- Multiply
		"0011" when(opcode = "011010" or opcode = "011011") else  	-- Divide
		"0100" when(opcode = "101010" or opcode = "001010") else  	-- Set Less Than
		"0101" when(opcode = "100100" or opcode = "001100") else  	-- AND
		"0110" when(opcode = "100101" or opcode = "001101") else  	-- OR
		"0111" when(opcode = "100111") else						  	-- NOR
		"1000" when(opcode = "100110" or opcode = "001110") else  	-- XOR
		"1001" when(opcode = "010000") else						  	-- Move From HI
		"1010" when(opcode = "010010") else						  	-- Move From LO
		"1011" when(opcode = "001111") else						  	-- Load Upper Immediate
		"1100" when(opcode = "000000") else							-- Shift Left Logical
		"1101" when(opcode = "000010") else							-- Shift Right Logical
		"1110" when(opcode = "000011") else							-- Shift Right Arithmetic
		"1111" when(opcode = "000100" or opcode = "000101") else	-- Branch on Equal
		"0000"; -- default to add
		
end Behavior;