library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;

entity cache is
generic(
  	ram_size : INTEGER := 32768;
 	word_size : INTEGER := 32;
	cache_size : INTEGER := 32;
	block_size : INTEGER := 128
);
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic; 
    
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is

type state_type is (
	idle_state, -- No commands have been given to cache
	ca2cpu_state, -- State in which we attempt to read from cache to CPU
	load_mem_state, -- State in which data is being loaded from memory
	mem2ca_state, -- State in which we write a block from memory to cache
	store_mem_state, -- State in which we write a block to memory
	cpu2ca_state -- State in which we attempt to write to the cache
);
-- declare signals here
signal s: state_type;

signal latched_s_read : std_logic;
signal latched_s_write : std_logic;

signal input_tag : std_logic_vector(14 downto 0);
signal input_index : Integer;
signal input_byteoffset : Integer;

signal write_counter : Integer;
signal read_counter : Integer;

signal data_to_read : std_logic;
signal data_to_write : std_logic;

signal loaded_block : std_logic_vector(127 downto 0);

-- cache block declaration
-- |1 valid|1 dirty|15 tag|128 block bits| = 145 bits total per row
type cache_body is array(0 to 31) of std_logic_vector(144 downto 0);
signal cache : cache_body;

begin
process(clock)
begin
	if rising_edge(clock) then
		if (reset = '1') then -- on reset, go to the Idle state
			s <= idle_state;
		else 
			case s is
				-- in the idle_state wait to receive orders for write or read to cache
				when idle_state=> 
					-- reset write and read counters, and commands
					write_counter<=0;
					read_counter<=0;
					m_read<='0';
					m_write<='0';

					-- latch values from here so that we dont detect changes in them until we return to idle.
					input_tag<=s_addr(21 downto 7); -- we only care about the lowest 15 bits of tag
					input_index<=conv_integer(s_addr(6 downto 2)); -- 5 bit index field
					input_byteoffset<=conv_integer(s_addr(1 downto 0)); --2 bit offset field
					latched_s_read<=s_read;
					latched_s_write<=s_write;

					if (s_read = '1' AND s_write='0') then
						s<= ca2cpu_state;
					elsif (s_read = '0' AND s_write='1') then
						s<= cpu2ca_state;
					end if;
					s_waitrequest<='1';

				-- in the ca2cpu_state, check if we have a cache hit or miss, and go to the appropriate state
				when ca2cpu_state=>
					-- valid bit is set and tag matches
					if cache(input_index)(144)='1' and cache(input_index)(142 downto 128) = input_tag then
						-- cache hit
						s_readdata <=cache(input_index)(127- input_byteoffset*32 downto 128- (input_byteoffset+1)*32);
						s_waitrequest<='0';
						s<= idle_state;
					else  
						-- cache miss, and we need to evict a block
						s<=load_mem_state;
						s_waitrequest<='1';
					end if;
				-- in the cpu2ca_state, check if we have a cache hit or miss. Write to cache if hit, else go to load_mem_state
				when cpu2ca_state=>
					-- valid bit is set and tag matches
					if cache(input_index)(144)='1' and cache(input_index)(142 downto 128) = input_tag then
						-- cache hit, write 
						cache(input_index)(127- input_byteoffset*32 downto 128- (input_byteoffset+1)*32)<= s_writedata;
						cache(input_index)(143)<='1'; --set dirty
						s_waitrequest<='0';
						s<= idle_state;
					else  -- else go to load_mem_state
						s<=load_mem_state;
						s_waitrequest<='1';
					end if;

				-- in the mem2ca_state, we check if we need to evict anything from the cache. If we do need to, go to store_mem_state. Otherwise go to 
				when mem2ca_state=>
					-- if dirty, we go to write to mem state after which it will become clean 
					if cache(input_index)(143)='1' then
						s<=store_mem_state;
						s_waitrequest<='1';
					else
						-- if clean, put the loaded stuff into cache
						cache(input_index)(127 downto 0)<=loaded_block;
						cache(input_index)(143)<='0'; --set clean
						cache(input_index)(144)<='1'; --set valid
						cache(input_index)(142 downto 128)<=input_tag;
						-- if we are here from a read op, give it to s_read then go to idle
						if (latched_s_read = '1' AND latched_s_write='0') then
       							s_readdata <=cache(input_index)(127- input_byteoffset*32 downto 128- (input_byteoffset+1)*32);
							s_waitrequest<='0';
							s<= idle_state;
						elsif (latched_s_read = '0' AND latched_s_write='1') then 
							--we are here from a write op, go to cpu2ca_state, from which we'll do the cache hit action
							s<=cpu2ca_state;
							s_waitrequest<='1';
						end if;
					end if;
				when load_mem_state=>
					m_read<='1'; -- tell memory we want to read
					m_addr<=conv_integer(input_tag)+read_counter; -- from this address
					if(m_waitrequest = '0') then
					  data_to_read<='1';
					end if;
					if (data_to_read='1' and read_counter < 16) then
						loaded_block(block_size- read_counter*8-1 downto block_size- read_counter*8-8)<=m_readdata; -- get the data from mem
						read_counter<=read_counter+1;
						--TODO: check ordering
					end if;
					if (read_counter = 16) then
						s<=mem2ca_state;
						data_to_read<='0';
					end if;
					s_waitrequest<='1';
				when store_mem_state=>
					m_write<='1'; -- tell memory we want to write
					m_addr<=conv_integer(input_tag)+write_counter; -- to this address
					if(m_waitrequest = '0') then
					  data_to_write<='1';
					end if;
					if (data_to_write = '1' and write_counter < 16) then
						m_writedata<=cache(input_index)(block_size- write_counter*8-1 downto block_size- write_counter*8-8); -- write data 
						write_counter<=write_counter+1;
					end if;
					if (write_counter=16) then
					  	data_to_write <='0';
						s<=mem2ca_state;
						cache(input_index)(143)<='0';
					end if;
					s_waitrequest<='1';
			end case;
		end if;
	end if;
end process;

end arch;