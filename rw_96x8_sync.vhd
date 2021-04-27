library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity rw_96x8_sync is
	port (clock	: in std_logic;
		address	: in std_logic_vector(7 downto 0);
		data_in : in std_logic_vector(7 downto 0);
		we   : in std_logic;
		data_out	: out std_logic_vector(7 downto 0));
end entity; 



architecture rw_96x8_sync_arch of  rw_96x8_sync is

	signal en : std_logic;
	
	type rw_type is array (128 to 223) of std_logic_vector(7 downto 0);
	signal RW : rw_type;
				
	begin

	ENABLE : process (address) 
		begin
		if ((to_integer(unsigned(address)) >= 128) and (to_integer(unsigned(address)) <= 223)) then
			en <= '1';
		else
			en <= '0';
		end if;
	end process;
	
	MEMORY : process (clock)
		begin
		if (clock'event and clock='1') then
			if (en='1' and we = '1') then
				RW(to_integer(unsigned(address))) <= data_in;
			elsif (en='1' and we = '0') then
				data_out <= RW(to_integer(unsigned(address)));
			end if;
		end if;
	end process;

end architecture;
