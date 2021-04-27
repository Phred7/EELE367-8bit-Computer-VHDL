library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu is 
	port (clock : in std_logic;
		reset : in std_logic;
		writeE : out std_logic;
		from_memory : in std_logic_vector(7 downto 0);
		to_memory : out std_logic_vector(7 downto 0);
		address : out std_logic_vector(7 downto 0));
end entity;

architecture cpu_arch of cpu is

	signal IR : std_logic_vector(7 downto 0);
	signal IR_LOAD : std_logic;
	signal MAR_LOAD : std_logic;
	signal PC_LOAD : std_logic;
	signal PC_INC : std_logic;
	signal A_LOAD : std_logic;
	signal B_LOAD : std_logic;
	signal ALU_SEL : std_logic_vector(2 downto 0);
	signal CCR_RESULT : std_logic_vector(3 downto 0);
	signal CCR_LOAD : std_logic;
	signal BUS2_SEL : std_logic_vector(1 downto 0);
	signal BUS1_SEL : std_logic_vector(1 downto 0);

	component control_unit is 
		port (clock : in std_logic;
			reset : in std_logic;
			writeE : out std_logic;
			ir_load : out std_logic;
			ir : in std_logic_vector(7 downto 0);
			mar_load : out std_logic;
			pc_load : out std_logic;
			pc_inc : out std_logic;
			a_load : out std_logic;
			b_load : out std_logic;
			alu_sel : out std_logic_vector(2 downto 0);
			ccr_result : in std_logic_vector(3 downto 0);
			ccr_load : out std_logic;
			bus2_sel : out std_logic_vector(1 downto 0);
			bus1_sel : out std_logic_vector(1 downto 0));
	end component;

	component data_path is 
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
	end component;

	begin

	CONTROL_UNIT_M : control_unit port map (clock => clock, reset => reset, writeE => writeE, ir_load => IR_LOAD, ir => IR, mar_load => MAR_LOAD, pc_load => PC_LOAD, pc_inc => PC_INC, a_load => A_LOAD, b_load => B_LOAD, alu_sel => ALU_SEL, ccr_result => CCR_RESULT, ccr_load => CCR_LOAD, bus2_sel => BUS2_SEL, bus1_sel => BUS1_SEL);
	DATA_PATH_M : data_path port map (clock => clock, reset => reset, address => address, from_memory => from_memory, to_memory => to_memory, ir_load => IR_LOAD, ir => IR, mar_load => MAR_LOAD, pc_load => PC_LOAD, pc_inc => PC_INC, a_load => A_LOAD, b_load => B_LOAD, alu_sel => ALU_SEL, ccr_result => CCR_RESULT, ccr_load => CCR_LOAD, bus2_sel => BUS2_SEL, bus1_sel => BUS1_SEL);
	

end architecture;
