library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memory is 
	port (clock : in std_logic;
		reset : in std_logic;
		address : in std_logic_vector(7 downto 0);
		data_in : in std_logic_vector(7 downto 0);
		writeE  : in std_logic;
		data_out : out std_logic_vector(7 downto 0);

		port_in_00 : in std_logic_vector(7 downto 0);
		port_in_01 : in std_logic_vector(7 downto 0);
		port_in_02 : in std_logic_vector(7 downto 0);
		port_in_03 : in std_logic_vector(7 downto 0);
		port_in_04 : in std_logic_vector(7 downto 0);
		port_in_05 : in std_logic_vector(7 downto 0);
		port_in_06 : in std_logic_vector(7 downto 0);
		port_in_07 : in std_logic_vector(7 downto 0);
		port_in_08 : in std_logic_vector(7 downto 0);
		port_in_09 : in std_logic_vector(7 downto 0);
		port_in_10 : in std_logic_vector(7 downto 0);
		port_in_11 : in std_logic_vector(7 downto 0);
		port_in_12 : in std_logic_vector(7 downto 0);
		port_in_13 : in std_logic_vector(7 downto 0);
		port_in_14 : in std_logic_vector(7 downto 0);
		port_in_15 : in std_logic_vector(7 downto 0);
		
		port_out_00 : out std_logic_vector(7 downto 0);
		port_out_01 : out std_logic_vector(7 downto 0);
		port_out_02 : out std_logic_vector(7 downto 0);	
		port_out_03 : out std_logic_vector(7 downto 0);
		port_out_04 : out std_logic_vector(7 downto 0);	
		port_out_05 : out std_logic_vector(7 downto 0);
		port_out_06 : out std_logic_vector(7 downto 0);
		port_out_07 : out std_logic_vector(7 downto 0);
		port_out_08 : out std_logic_vector(7 downto 0);
		port_out_09 : out std_logic_vector(7 downto 0);
		port_out_10 : out std_logic_vector(7 downto 0);
		port_out_11 : out std_logic_vector(7 downto 0);
		port_out_12 : out std_logic_vector(7 downto 0);
		port_out_13 : out std_logic_vector(7 downto 0);
		port_out_14 : out std_logic_vector(7 downto 0);
		port_out_15 : out std_logic_vector(7 downto 0));
end entity;



architecture memory_arch of memory is

	signal rom_data_out : std_logic_vector(7 downto 0);
	signal rw_data_out : std_logic_vector(7 downto 0);


	component rom_128x8_sync is
	port (clock	: in std_logic;
		address	: in std_logic_vector(7 downto 0);
		data_out	: out std_logic_vector(7 downto 0));
	end component;

	component rw_96x8_sync is
	port (clock	: in std_logic;
		address	: in std_logic_vector(7 downto 0);
		data_in : in std_logic_vector(7 downto 0);
		we   : in std_logic;
		data_out	: out std_logic_vector(7 downto 0));
	end component;

	begin

	ROM : rom_128x8_sync port map (clock => clock, address => address, data_out => rom_data_out);

	RW : rw_96x8_sync port map (clock => clock, address => address, data_in => data_in, we => writeE, data_out => rw_data_out);

	MUX1 : process (address, rom_data_out, rw_data_out,
		port_in_00, port_in_01, port_in_02, port_in_03,
		port_in_04, port_in_05, port_in_06, port_in_07,
		port_in_08, port_in_09, port_in_10, port_in_11,
		port_in_12, port_in_13, port_in_14, port_in_15)

		begin
		if ( (to_integer(unsigned(address)) >= 0) and (to_integer(unsigned(address)) <= 127)) then
			data_out <= rom_data_out;
		elsif ( (to_integer(unsigned(address)) >= 128) and (to_integer(unsigned(address)) <= 223)) then
			data_out <= rw_data_out;
		elsif (address = x"F0") then data_out <= port_in_00;
		elsif (address = x"F1") then data_out <= port_in_01;
		elsif (address = x"F2") then data_out <= port_in_02;
		elsif (address = x"F3") then data_out <= port_in_03;
		elsif (address = x"F4") then data_out <= port_in_04;
		elsif (address = x"F5") then data_out <= port_in_05;
		elsif (address = x"F6") then data_out <= port_in_06;
		elsif (address = x"F7") then data_out <= port_in_07;
		elsif (address = x"F8") then data_out <= port_in_08;
		elsif (address = x"F9") then data_out <= port_in_09;
		elsif (address = x"FA") then data_out <= port_in_10;
		elsif (address = x"FB") then data_out <= port_in_11;
		elsif (address = x"FC") then data_out <= port_in_12;
		elsif (address = x"FD") then data_out <= port_in_13;
		elsif (address = x"FE") then data_out <= port_in_14;
		elsif (address = x"FF") then data_out <= port_in_15;
		else data_out <= x"00";
		end if;
	end process;

	-- port_out_00 description : ADDRESS x"E0"
	U00 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_00 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"E0" and writeE = '1') then
				port_out_00 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_01 description : ADDRESS x"E1"
	U01 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_01 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"E1" and writeE = '1') then
				port_out_01 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_02 description : ADDRESS x"E2"
	U02 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_02 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"E2" and writeE = '1') then
				port_out_02 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_03 description : ADDRESS x"E3"
	U03 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_03 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"E3" and writeE = '1') then
				port_out_03 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_04 description : ADDRESS x"E4"
	U04 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_04 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"E4" and writeE = '1') then
				port_out_04 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_05 description : ADDRESS x"E5"
	U05 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_05 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"E5" and writeE = '1') then
				port_out_05 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_06 description : ADDRESS x"E6"
	U06 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_06 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"E6" and writeE = '1') then
				port_out_06 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_07 description : ADDRESS x"E7"
	U07 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_07 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"E7" and writeE = '1') then
				port_out_07 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_08 description : ADDRESS x"E8"
	U08 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_08 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"E8" and writeE = '1') then
				port_out_08 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_09 description : ADDRESS x"E9"
	U09 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_09 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"E9" and writeE = '1') then
				port_out_09 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_10 description : ADDRESS x"EA"
	U10 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_10 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"EA" and writeE = '1') then
				port_out_10 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_11 description : ADDRESS x"EB"
	U11 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_11 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"EB" and writeE = '1') then
				port_out_11 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_12 description : ADDRESS x"EC"
	U12 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_12 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"EC" and writeE = '1') then
				port_out_12 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_13 description : ADDRESS x"ED"
	U13 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_13 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"ED" and writeE = '1') then
				port_out_13 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_14 description : ADDRESS x"EE"
	U14 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_14 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"EE" and writeE = '1') then
				port_out_14 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_15 description : ADDRESS x"EF"
	U15 : process (clock, reset)
		begin
		if (reset = '0') then
			port_out_15 <= x"00";
		elsif (clock'event and clock='1') then
			if (address = x"EF" and writeE = '1') then
				port_out_15 <= data_in;
			end if;
		end if;
	end process;

end architecture;
