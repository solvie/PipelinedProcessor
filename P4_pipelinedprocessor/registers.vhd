library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity registers is
port(
	clock : in std_logic;
	reset : in std_logic;

	-- Avalon interface --
  instruction : in std_logic_vector(31 downto 0);

	wb_signal : in std_logic;
	wb_addr : in std_logic_vector (4 downto 0);
	wb_data : in std_logic_vector (31 downto 0);
	jumping : out std_logic;
	data_out_left: out std_logic_vector (31 downto 0) :="00000000000000000000000000000000";
	data_out_right: out std_logic_vector (31 downto 0):="00000000000000000000000000000000";
	data_out_imm: out std_logic_vector (31 downto 0):="00000000000000000000000000000000"; -- sign/zero extended value will come out
	shamt : out std_logic_vector(4 downto 0):="00000";
	funct : out std_logic_vector(5 downto 0):="000000";
	r_s: out std_logic_vector (4 downto 0):="00000";
	opcode: out std_logic_vector(5 downto 0):="000000";
	pseudo_address : out std_logic_vector(25 downto 0):="00000000000000000000000000";
	n_pseudo_address : out std_logic_vector(31 downto 0):="00000000000000000000000000000000";
	write_to_file : in std_logic;
	data_memory_data : out std_logic_vector (31 downto 0):="00000000000000000000000000000000";
	data_memory_address: out std_logic_vector (31 downto 0):= "00000000000000000000000000000000"
);
end registers;

architecture arch of registers is
type registers_body is array(0 to 31) of std_logic_vector(31 downto 0);
signal register_block : registers_body :=(others=>"00000000000000000000000000000000");
signal s_jumping : std_logic;
signal stall_r : integer := 0;

file file_Output : text;
--https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats
begin
process(clock)
begin
	if(rising_edge(clock)) then
				IF(now < 1 ps)THEN
			For i in 0 to 31 LOOP
				register_block(i) <= std_logic_vector(to_unsigned(0,32));
			END LOOP;
			END IF;
    --normal operation for instruction parse
		if(wb_signal ='1' and (not (wb_addr="00000")))then
    		register_block(to_integer(unsigned(wb_addr)))<= wb_data;
    		data_out_left<="00000000000000000000000000000000";
      data_out_right<="00000000000000000000000000000000";
		end if;
	if (reset = '1') then
	    --reset all registers
			register_block<=(others=>"00000000000000000000000000000000");
				jumping <='0';
				data_out_left<="00000000000000000000000000000000";
	      data_out_right<="00000000000000000000000000000000";
       	data_out_imm<="00000000000000000000000000000000";
       	shamt <="00000";
       	funct <="000000";
       	r_s<="00000";
       	opcode<="000000";
       	pseudo_address <="00000000000000000000000000";

    elsif(stall_r = 0) then


		if( instruction(31 downto 27) ="00001") THEN
			jumping <='1';
			data_out_left<="00000000000000000000000000000000";
			data_out_right<="00000000000000000000000000000000";
			data_out_imm<="00000000000000000000000000000000";
			shamt <="00000";
			funct <="000000";
			r_s<="00000";
			opcode<="000000";
			pseudo_address<= instruction(25 downto 0);
		    n_pseudo_address<= std_logic_vector(resize(unsigned(instruction(25 downto 0)),32));
		    stall_r <= 3;
		elsif (instruction(31 downto 26) = "000100") THEN
			if(instruction(25 downto 21) = instruction(20 downto 16)) then
				jumping <='1';
				data_out_left<="00000000000000000000000000000000";
				data_out_right<="00000000000000000000000000000000";
				data_out_imm<="00000000000000000000000000000000";
				shamt <="00000";
				funct <="000000";
				r_s<="00000";
				opcode<="000000";
				pseudo_address<=std_logic_vector(to_unsigned(13,26));
				-- std_logic_vector(unsigned(("0000000000" & instruction(15 downto 0))) + 7);
			    n_pseudo_address<= std_logic_vector(to_unsigned(13,32));
			    --std_logic_vector(resize(unsigned(instruction(15 downto 0)),32));
			    stall_r <= 3;
			else
				jumping <='0';
				data_out_left<="00000000000000000000000000000000";
				data_out_right<="00000000000000000000000000000000";
				data_out_imm<="00000000000000000000000000000000";
				shamt <="00000";
				funct <="000000";
				r_s<="00000";
				opcode<="000000";
				pseudo_address <="00000000000000000000000000";
			end if;

		elsif ( instruction ="UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU") THEN
			jumping <='0';
			data_out_left<="00000000000000000000000000000000";
			data_out_right<="00000000000000000000000000000000";
			data_out_imm<="00000000000000000000000000000000";
			shamt <="00000";
			funct <="000000";
			r_s<="00000";
			opcode<="000000";
			pseudo_address <="00000000000000000000000000";
		else
			jumping <='0';
		  	opcode <=instruction(31 downto 26);
		  	if(instruction(31 downto 26)="000000") then
				--R type
				data_out_left<=register_block(to_integer(unsigned(instruction(25 downto 21))));
				data_out_right<=register_block(to_integer(unsigned(instruction(20 downto 16))));
				r_s<=instruction(15 downto 11);
			elsif( (instruction(31 downto 26) = "101011")--sw
		   	) then
		  		data_out_left<="00000000000000000000000000000000";
		  		data_out_right<="00000000000000000000000000000000";
		  		data_memory_data <= register_block(to_integer(unsigned(instruction(20 downto 16))) + to_integer(unsigned(instruction(15 downto 0))));
		  		data_memory_address <= std_logic_vector(resize(unsigned(instruction(25 downto 21)),32));
		  		r_s<="00000";
		  	elsif( (instruction(31 downto 26) = "100011")--lw
		   	) then
		  		data_out_left<="00000000000000000000000000000000";
		  		data_out_right<="00000000000000000000000000000000";
		  		data_memory_address <= std_logic_vector(resize(unsigned(instruction(25 downto 21)),32));
		  		r_s<=instruction(15 downto 11);
		  	else
			--Itype
		    data_out_left<=register_block(to_integer(unsigned(instruction(25 downto 21))));
		    data_out_right<=register_block(to_integer(unsigned(instruction(15 downto 11))));
		    r_s<=instruction(20 downto 16);
		  	end if;

		  	shamt<=instruction(10 downto 6);
		  	funct<=instruction(5 downto 0);
			pseudo_address<= instruction(25 downto 0);
		  	n_pseudo_address<= std_logic_vector(resize(unsigned(instruction(25 downto 0)),32));
		  	if(
        		(instruction(31 downto 26) = "001100")or --andi
        		instruction(31 downto 26) = "001101" --ori
      		) then
      		--zero extension
	      data_out_imm <= std_logic_vector(resize(unsigned(instruction(15 downto 0)),32));--zero extend
	      elsif((instruction(31 downto 26) = "101011")) then 
	      data_out_imm <= "00000000000000000000000000000000";
	      elsif((instruction(31 downto 26) = "100011")) then 
	      data_out_imm <= "00000000000000000000000000000000";
	      else
	      data_out_imm <= std_logic_vector(resize(signed(instruction(15 downto 0)),32));--sign extend
	      end if;
    	end if;
    else
    	
    	stall_r <= stall_r - 1;
    end if;
end if;
end process;

	write_file: PROCESS (write_to_file)
	variable i: integer := 0;
	variable v_OLINE: line;
	BEGIN
		--if write_to_file is true, loop through memory array and write all lines(even unused ones) in to the file
		IF(write_to_file = '1')THEN
			file_open(file_Output, "output_results_reg.txt", write_mode);
			while i < 32 loop
					write(v_OLINE, register_block(i), right, 32);
					writeline(file_Output, v_OLINE);
					i := i + 1;
			end loop;
			file_close(file_Output);
		end if;

	END PROCESS;
end arch;
