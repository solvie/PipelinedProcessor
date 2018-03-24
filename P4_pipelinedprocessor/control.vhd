library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
use ieee.std_logic_misc.all;
entity control is
port(
	clock : in std_logic;
	reset : in std_logic;
	-- Avalon interface --
    op_code : in std_logic_vector(5 downto 0);
	funct_code : in std_logic_vector(5 downto 0);
	
	RegDst   : out std_logic;
	ALUSrc   : out std_logic;
	MemtoReg : out std_logic;
	RegWrite : out std_logic;
	MemRead  : out std_logic;
	MemWrite : out std_logic;
	Branch   : out std_logic;
	ALUctrl  : out std_logic_vector(2 downto 0)
  
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
	  if(op_code = "000000")then
      RegDst <= '1';
      ALUOp1 <= '1';
      RegWrite <= '1';
    else
      if op_code = "100011" then
        RegWrite <= '1';
      else
        RegWrite <= '0';
      end if;
      RegDst <= '0';
      ALUOp1 <= '0';
    end if;
        
    if(op_code = "100011")then
      MemtoReg <= '1';
      MemRead <= '1';
      ALUSrc <= '1';
    else
      if op_code = "101011" then
        ALUSrc <= '1';
      else
        ALUSrc <= '0';
      end if;
      MemtoReg <= '0';
      MemRead <= '0';
    end if;
    
    if(op_code = "101011")then
      MemWrite <= '1';
      ALUSrc <= '1';
    else
      if op_code = "100011" then
        ALUSrc <= '1';
      else
        ALUSrc <= '0';
      end if;
      MemWrite <= '0';
    end if;
    
    if(op_code = "000100")then
      Branch <= '1';
      MemWrite <= '1';
      ALUOp0<='1';
    else
      Branch <= '0';
      MemWrite <= '0';
      ALUOp0<='0';
    end if;
    
    -- ALU operation decoding from opcode and control parsed
    -- ALU operation truth table.JPG
 	  if(ALUOp1 = '0' and ALUOp0 = '0') then
 	    ALUctrl<="010";
 	  elsif(ALUOp1 = '0' and ALUOp0 = '1') then
 	    ALUctrl<="110";
 	  elsif(ALUOp1 = '1' and ALUOp0 = '0') then
 	    case funct_code is
 	      when "100000"=>ALUctrl<="010";
 	      when "100010"=>ALUctrl<="110";
 	      when "100100"=>ALUctrl<="000";
 	      when "100101"=>ALUctrl<="001";
 	      when "101010"=>ALUctrl<="111"; 
 	      when others=> ALUctrl <="010";   	       	        
      end case; 
    end if;
	end if;
	
end process;
end arch;
