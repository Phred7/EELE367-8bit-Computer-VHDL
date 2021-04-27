library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_path is 
	port (clock : in std_logic;
		reset : in std_logic;
		address : out std_logic_vector(7 downto 0);
		from_memory : in std_logic_vector(7 downto 0);
		to_memory : out std_logic_vector(7 downto 0);
		ir_load : in std_logic;
		ir : out std_logic_vector(7 downto 0);
		mar_load : in std_logic;
		pc_load : in std_logic;
		pc_inc : in std_logic;
		a_load : in std_logic;
		b_load : in std_logic;
		alu_sel : in std_logic_vector(2 downto 0);
		ccr_result : out std_logic_vector(3 downto 0);
		ccr_load : in std_logic;
		bus2_sel : in std_logic_vector(1 downto 0);
		bus1_sel : in std_logic_vector(1 downto 0));
end entity;



architecture data_path_arch of data_path is

	signal BUS1 : std_logic_vector(7 downto 0);
	signal BUS2 : std_logic_vector(7 downto 0);
	signal MAR : std_logic_vector(7 downto 0);
	signal PC : std_logic_vector(7 downto 0);
	signal PC_uns : unsigned(7 downto 0);
	signal A : std_logic_vector(7 downto 0);
	signal B : std_logic_vector(7 downto 0);
	signal ALU_RESULT : std_logic_vector(7 downto 0);
	signal NZVC : std_logic_vector(3 downto 0);

	component alu is 
		port (A : in std_logic_vector(7 downto 0);
			B : in std_logic_vector(7 downto 0);
			ALU_Sel : in std_logic_vector(2 downto 0);
			NZVC : out std_logic_vector(3 downto 0);
			Result : out std_logic_vector(7 downto 0));
	end component;

	begin

	ALU_comp : alu port map (A => B, B => BUS1, ALU_Sel => alu_sel, NZVC => NZVC, Result => ALU_RESULT);

	MUX_BUS1 : process (bus1_sel, PC, A, B)
		begin
		case (bus1_sel) is
			when "00" => BUS1 <= PC;
			when "01" => BUS1 <= A;
			when "10" => BUS1 <= B;
			when others => BUS1 <= x"00";
		end case;
	end process;

	MUX_BUS2 : process (bus2_sel, ALU_RESULT, BUS1, from_memory)
		begin
		case (bus2_sel) is
			when "00" => BUS2 <= ALU_RESULT;
			when "01" => BUS2 <= BUS1;
			when "10" => BUS2 <= from_memory;
			when others => BUS2 <= x"00";
		end case;
	end process;

	

	INSTRUCTION_REGISTER : process (clock, reset)
		begin
		if (reset = '0') then
			ir <= x"00";
		elsif (clock'event and clock = '1') then
			if (ir_load = '1') then
				ir <= BUS2;
			end if;
		end if;
	end process;

	MEMORY_ADDRESS_REGISTER : process (clock, reset)
		begin
		if (reset = '0') then
			MAR <= x"00";
		elsif (clock'event and clock = '1') then
			if (mar_load = '1') then
				MAR <= BUS2;
			end if;
		end if;
	end process;

	PROGRAM_COUNTER : process (clock, reset)
		begin
		if (reset = '0') then
			PC_uns <= x"00";
		elsif (clock'event and clock = '1') then
			if (pc_load = '1') then
				PC_uns <= unsigned(BUS2);
			elsif (pc_inc = '1') then
				PC_uns <= PC_uns + 1;
			end if;
		end if;
	end process;

	

	A_REGISTER : process (clock, reset)
		begin
		if (reset = '0') then
			A <= x"00";
		elsif (clock'event and clock = '1') then
			if (a_load = '1') then
				A <= BUS2;
			end if;
		end if;
	end process;

	B_REGISTER : process (clock, reset)
		begin
		if (reset = '0') then
			B <= x"00";
		elsif (clock'event and clock = '1') then
			if (b_load = '1') then
				B <= BUS2;
			end if;
		end if;
	end process;

	CONDITION_CODE_REGISTER : process (clock, reset)
		begin
		if (reset = '0') then
			ccr_result <= x"0";
		elsif (clock'event and clock = '1') then
			if (ccr_load = '1') then
				ccr_result <= NZVC;
			end if;
		end if;
	end process;

	address <= MAR;
	to_memory <= BUS1;
	PC <= std_logic_vector(PC_uns);

end architecture;