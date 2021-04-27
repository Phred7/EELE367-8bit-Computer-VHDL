library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_unit is 
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
end entity;



architecture control_unit_arch of control_unit is 

	type state_type is
		(S_FETCH_0, S_FETCH_1, S_FETCH_2,
		S_DECODE_3,
		S_LDA_IMM_4, S_LDA_IMM_5, S_LDA_IMM_6,
		S_LDB_IMM_4, S_LDB_IMM_5, S_LDB_IMM_6,
		S_LDA_Dir_4, S_LDA_Dir_5, S_LDA_Dir_6, S_LDA_Dir_7, S_LDA_Dir_8,
		S_LDB_Dir_4, S_LDB_Dir_5, S_LDB_Dir_6, S_LDB_Dir_7, S_LDB_Dir_8,
		S_STA_Dir_4, S_STA_Dir_5, S_STA_Dir_6, S_STA_Dir_7,
		S_STB_Dir_4, S_STB_Dir_5, S_STB_Dir_6, S_STB_Dir_7,
		S_ADD_AB_4,
		S_SUB_AB_4,
		S_INCA_4,
		S_INCB_4,
		S_DECA_4,
		S_DECB_4,
		S_BRA_4, S_BRA_5, S_BRA_6,
		S_BEQ_4, S_BEQ_5, S_BEQ_6, S_BEQ_7);

	signal current_state, next_state : state_type;

	constant LDA_IMM : std_logic_vector (7 downto 0) := x"86";
	constant LDA_DIR : std_logic_vector (7 downto 0) := x"87";
	constant LDB_IMM : std_logic_vector (7 downto 0) := x"88";
	constant LDB_DIR : std_logic_vector (7 downto 0) := x"89";
	constant STA_DIR : std_logic_vector (7 downto 0) := x"96";
	constant STB_DIR : std_logic_vector (7 downto 0) := x"97";
	constant ADD_AB : std_logic_vector (7 downto 0) := x"42";
	constant SUB_AB : std_logic_vector (7 downto 0) := x"43";
	constant AND_AB : std_logic_vector (7 downto 0) := x"44";
	constant OR_AB : std_logic_vector (7 downto 0) := x"45";
	constant INCA : std_logic_vector (7 downto 0) := x"46";
	constant INCB : std_logic_vector (7 downto 0) := x"47";
	constant DECA : std_logic_vector (7 downto 0) := x"48";
	constant DECB : std_logic_vector (7 downto 0) := x"49";
	constant BRA : std_logic_vector (7 downto 0) := x"20";
	constant BMI : std_logic_vector (7 downto 0) := x"21";
	constant BPL : std_logic_vector (7 downto 0) := x"22";
	constant BEQ : std_logic_vector (7 downto 0) := x"23";
	constant BNE : std_logic_vector (7 downto 0) := x"24";
	constant BVS : std_logic_vector (7 downto 0) := x"25";
	constant BVC : std_logic_vector (7 downto 0) := x"26";
	constant BCS : std_logic_vector (7 downto 0) := x"27";
	constant BCC : std_logic_vector (7 downto 0) := x"28";

	begin

	STATE_MEMORY : process (clock, reset)
		begin
		if (reset = '0') then
			current_state <= S_FETCH_0;
		elsif (clock'event and clock = '1') then
			current_state <= next_state;
		end if;
	end process;

	NEXT_STATE_LOGIC : process (current_state, ir, ccr_result)
		begin
		if (current_state = S_FETCH_0) then
			next_state <= S_FETCH_1;
		elsif (current_state = S_FETCH_1) then
			next_state <= S_FETCH_2;
		elsif (current_state = S_FETCH_2) then
			next_state <= S_DECODE_3;
		elsif (current_state = S_DECODE_3) then -- select execution path
			if (ir = LDA_IMM) then -- Load A Immediate
				next_state <= S_LDA_IMM_4;
			elsif (ir = LDA_Dir) then -- Load A Direct
				next_state <= S_LDA_Dir_4;
			elsif (ir = STA_Dir) then -- Store A Direct
				next_state <= S_STA_Dir_4;
			elsif (ir = LDB_IMM) then -- Load B Immediate
				next_state <= S_LDB_IMM_4;
			elsif (ir = LDB_Dir) then -- Load B Direct
				next_state <= S_LDB_Dir_4;
			elsif (ir = STB_Dir) then -- Store B Direct
				next_state <= S_STB_Dir_4;
			elsif (ir = ADD_AB) then -- Add A and B
				next_state <= S_ADD_AB_4;
			elsif (ir = INCA) then -- Increment A
				next_state <= S_INCA_4;
			elsif (ir = INCB) then -- Increment B
				next_state <= S_INCB_4;
			elsif (ir = DECA) then -- Decrement A
				next_state <= S_DECA_4;
			elsif (ir = DECB) then -- Decrement B
				next_state <= S_DECB_4;
			elsif (ir = BRA) then -- Branch Always
				next_state <= S_BRA_4;
			elsif (ir=BEQ and ccr_result(2)='1') then -- BEQ and Z=1
				next_state <= S_BEQ_4;
			elsif (ir=BEQ and ccr_result(2)='0') then -- BEQ and Z=0
				next_state <= S_BEQ_7;
			else
				next_state <= S_FETCH_0;
			end if;
------------------------------------------ LDA_IMM ------------------------------------------
		elsif (current_state = S_LDA_IMM_4) then
			next_state <= S_LDA_IMM_5;
		elsif (current_state = S_LDA_IMM_5) then
			next_state <= S_LDA_IMM_6;
		elsif (current_state = S_LDA_IMM_6) then
			next_state <= S_FETCH_0;
------------------------------------------ LDB_IMM ------------------------------------------
		elsif (current_state = S_LDB_IMM_4) then
			next_state <= S_LDB_IMM_5;
		elsif (current_state = S_LDB_IMM_5) then
			next_state <= S_LDB_IMM_6;
		elsif (current_state = S_LDB_IMM_6) then
			next_state <= S_FETCH_0;
------------------------------------------ LDA_DIR ------------------------------------------
		elsif (current_state = S_LDA_DIR_4) then
			next_state <= S_LDA_DIR_5;
		elsif (current_state = S_LDA_DIR_5) then
			next_state <= S_LDA_DIR_6;
		elsif (current_state = S_LDA_DIR_6) then
			next_state <= S_LDA_DIR_7;
		elsif (current_state = S_LDA_DIR_7) then
			next_state <= S_LDA_DIR_8;
		elsif (current_state = S_LDA_DIR_8) then
			next_state <= S_FETCH_0;
------------------------------------------ LDB_DIR ------------------------------------------
		elsif (current_state = S_LDB_DIR_4) then
			next_state <= S_LDB_DIR_5;
		elsif (current_state = S_LDB_DIR_5) then
			next_state <= S_LDB_DIR_6;
		elsif (current_state = S_LDB_DIR_6) then
			next_state <= S_LDB_DIR_7;
		elsif (current_state = S_LDB_DIR_7) then
			next_state <= S_LDB_DIR_8;
		elsif (current_state = S_LDB_DIR_8) then
			next_state <= S_FETCH_0;			
------------------------------------------ STA_DIR ------------------------------------------
		elsif (current_state = S_STA_DIR_4) then
			next_state <= S_STA_DIR_5;
		elsif (current_state = S_STA_DIR_5) then
			next_state <= S_STA_DIR_6;
		elsif (current_state = S_STA_DIR_6) then
			next_state <= S_STA_DIR_7;
		elsif (current_state = S_STA_DIR_7) then
			next_state <= S_FETCH_0;			
------------------------------------------ STB_DIR ------------------------------------------
		elsif (current_state = S_STB_DIR_4) then
			next_state <= S_STB_DIR_5;
		elsif (current_state = S_STB_DIR_5) then
			next_state <= S_STA_DIR_6;
		elsif (current_state = S_STB_DIR_6) then
			next_state <= S_STB_DIR_7;
		elsif (current_state = S_STB_DIR_7) then
			next_state <= S_FETCH_0;					
-------------------------------------------- BRA --------------------------------------------
		elsif (current_state = S_BRA_4) then
			next_state <= S_BRA_5;
		elsif (current_state = S_BRA_5) then
			next_state <= S_BRA_6;
		elsif (current_state = S_BRA_6) then
			next_state <= S_FETCH_0;	
-------------------------------------------- BEQ --------------------------------------------
		elsif (current_state = S_BRA_4) then
			next_state <= S_BRA_5;
		elsif (current_state = S_BRA_5) then
			next_state <= S_BRA_6;
		elsif (current_state = S_BRA_6) then
			next_state <= S_FETCH_0;
		elsif (current_state = S_BEQ_7) then
			next_state <= S_FETCH_0;
------------------------------------------ ADD_AB -------------------------------------------
		elsif (current_state = S_ADD_AB_4) then
			next_state <= S_FETCH_0;
------------------------------------------ SUB_AB -------------------------------------------			
		elsif (current_state = S_SUB_AB_4) then
			next_state <= S_FETCH_0;
------------------------------------------- INCA --------------------------------------------			
		elsif (current_state = S_INCA_4) then
			next_state <= S_FETCH_0;
------------------------------------------- INCB --------------------------------------------
		elsif (current_state = S_INCB_4) then
			next_state <= S_FETCH_0;
------------------------------------------- DECA --------------------------------------------			
		elsif (current_state = S_DECA_4) then
			next_state <= S_FETCH_0;
------------------------------------------- DECB --------------------------------------------
		elsif (current_state = S_DECB_4) then
			next_state <= S_FETCH_0;			

			
--		elsif (current_state = S_) then
--			next_state <= S_;

		--elsif. . .
		--:
		--?paths for each instruction go here. . .?
		--:
		end if;
	end process;


	OUTPUT_LOGIC : process (current_state)
		begin
		case(current_state) is
			when S_FETCH_0 => -- Put PC onto MAR to read Opcode
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "01"; -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
				writeE <= '0';
			when S_FETCH_1 => -- Increment PC
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '1';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
			when S_FETCH_2 => -- BUS2 <- from_mem, IR_LOAD
				ir_load <= '1';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
			when S_DECODE_3 => -- Decode
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
				

------------------------------------------ LDA_IMM ------------------------------------------

			when S_LDA_IMM_4 => -- BUS1 <- PC, BUS2 <- BUS1, MAR_LOAD
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDA_IMM_5 => -- PC_inc
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '1';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDA_IMM_6 => -- BUS2 <- from_mem, A_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '1';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
				
------------------------------------------ LDB_IMM ------------------------------------------

			when S_LDB_IMM_4 => -- BUS1 <- PC, BUS2 <- BUS1, MAR_LOAD
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDB_IMM_5 => -- PC_inc
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '1';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDB_IMM_6 => -- BUS2 <- from_mem, B_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '1';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';


------------------------------------------ LDA_DIR ------------------------------------------

			when S_LDA_DIR_4 => -- BUS1 <- PC, BUS2 <- BUS1, MAR_LOAD
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDA_DIR_5 => -- PC_inc
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '1';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDA_DIR_6 => -- BUS2 <- from_mem, MAR_Load
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDA_DIR_7 => -- Wait for clock
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDA_DIR_8 => -- BUS2 <- from_mem, A_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '1';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
				
------------------------------------------ LDB_DIR ------------------------------------------

			when S_LDB_DIR_4 => -- BUS1 <- PC, BUS2 <- BUS1, MAR_LOAD
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDB_DIR_5 => -- PC_inc
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '1';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDB_DIR_6 => -- BUS2 <- from_mem, MAR_Load
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDB_DIR_7 => -- Wait for clock
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_LDB_DIR_8 => -- BUS2 <- from_mem, B_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '1';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';				

------------------------------------------ STA_DIR ------------------------------------------
			when S_STA_DIR_4 => -- BUS1 <- PC, BUS2 <- BUS1, MAR_LOAD
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_STA_DIR_5 => -- PC_inc
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '1';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_STA_DIR_6 => -- BUS2 <- from_mem, MAR_Load
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_STA_DIR_7 => -- BUS1 <- A, Write <- 1
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '1';
				
------------------------------------------ STB_DIR ------------------------------------------
			when S_STB_DIR_4 => -- BUS1 <- PC, BUS2 <- BUS1, MAR_LOAD
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_STB_DIR_5 => -- PC_inc
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '1';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_STB_DIR_6 => -- BUS2 <- from_mem, MAR_Load
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_STB_DIR_7 => -- BUS1 <- B, Write <- 1
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "10"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '1';				


-------------------------------------------- BRA --------------------------------------------
			when S_BRA_4 => -- BUS1 <- PC, BUS2 <- BUS1, MAR_LOAD
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_BRA_5 => -- wait state
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_BRA_6 => -- BUS2 <- from_mem, PC_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '1';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
				
-------------------------------------------- BEQ --------------------------------------------
			when S_BEQ_4 => -- BUS1 <- PC, BUS2 <- BUS1, MAR_LOAD
				ir_load <= '0';
				mar_load <= '1';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_BEQ_5 => -- wait state
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

			when S_BEQ_6 => -- BUS2 <- from_mem, PC_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '1';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
				
			when S_BEQ_7 => -- PC_Inc
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '1';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';

------------------------------------------ ADD_AB -------------------------------------------
			when S_ADD_AB_4 => -- Bus1 <= A, Bus2 <= ALU, ALU <= Add, A_Load, CCR_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '1';
				b_load <= '0';
				alu_sel <= "000";	-- "000"=ADD, "100"=SUB, "010"=INCA, "011"=INCB, "110"=DECA, "111"=DECB, "001"=AND, "101"=OR
				ccr_load <= '1';
				bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
				
------------------------------------------ SUB_AB -------------------------------------------			
			when S_SUB_AB_4 => -- Bus1 <= A, Bus2 <= ALU, ALU <= Subtract, A_Load, CCR_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '1';
				b_load <= '0';
				alu_sel <= "100";	-- "000"=ADD, "100"=SUB, "010"=INCA, "011"=INCB, "110"=DECA, "111"=DECB, "001"=AND, "101"=OR
				ccr_load <= '1';
				bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
				
------------------------------------------- INCA --------------------------------------------			
			when S_INCA_4 => -- Bus1 <= A, Bus2 <= ALU, ALU <= INCA, A_Load, CCR_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '1';
				b_load <= '0';
				alu_sel <= "010";	-- "000"=ADD, "100"=SUB, "010"=INCA, "011"=INCB, "110"=DECA, "111"=DECB, "001"=AND, "101"=OR
				ccr_load <= '1';
				bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
				
------------------------------------------- INCB --------------------------------------------
			when S_INCB_4 => -- Bus2 <= ALU, ALU <= INCB, B_Load, CCR_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '1';
				alu_sel <= "011";	-- "000"=ADD, "100"=SUB, "010"=INCA, "011"=INCB, "110"=DECA, "111"=DECB, "001"=AND, "101"=OR
				ccr_load <= '1';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
				
------------------------------------------- DECA --------------------------------------------			
			when S_DECA_4 => -- Bus1 <= A, Bus2 <= ALU, ALU <= DECA, A_Load, CCR_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '1';
				b_load <= '0';
				alu_sel <= "110";	-- "000"=ADD, "100"=SUB, "010"=INCA, "011"=INCB, "110"=DECA, "111"=DECB, "001"=AND, "101"=OR
				ccr_load <= '1';
				bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
				
------------------------------------------- DECB --------------------------------------------
			when S_DECB_4 => -- Bus2 <= ALU, ALU <= DECB, B_Load, CCR_Load
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '1';
				alu_sel <= "111";	-- "000"=ADD, "100"=SUB, "010"=INCA, "011"=INCB, "110"=DECA, "111"=DECB, "001"=AND, "101"=OR
				ccr_load <= '1';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';				


				--:
				--?output assignments for all other states go here. . .?
				--:

			when others =>
				ir_load <= '0';
				mar_load <= '0';
				pc_load <= '0';
				pc_inc <= '0';
				a_load <= '0';
				b_load <= '0';
				alu_sel <= "000";  -- "000"=ADD, "100"=SUB, "010"=INCA, "011"=INCB, "110"=DECA, "111"=DECB, "001"=AND, "101"=OR
				ccr_load <= '0';
				bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
				bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
				writeE <= '0';
		end case;
	end process;

end architecture;