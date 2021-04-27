library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is 
	port (A : in std_logic_vector(7 downto 0);
		B : in std_logic_vector(7 downto 0);
		ALU_Sel : in std_logic_vector(2 downto 0);
		NZVC : out std_logic_vector(3 downto 0);
		Result : out std_logic_vector(7 downto 0));
end entity;

architecture alu_arch of alu is

	constant one : std_logic_vector (7 downto 0) := "00000001";

	begin
	
	-- "000"=ADD, "100"=SUB, "010"=INCA, "011"=INCB, "110"=DECA, "111"=DECB, "001"=AND, "101"=OR; all reductions begin with '1'; all operations on B end with '1'

	ALU_PROCESS : process (A, B, ALU_Sel)
	
		variable Sum_uns : unsigned(8 downto 0);

		begin

		if (ALU_Sel = "000") then --ADDITION

			--- Sum Calculation ---------------------------------?
			Sum_uns := unsigned('0' & A) + unsigned('0' & B);
			Result <= std_logic_vector(Sum_uns(7 downto 0));

			--- Negative Flag (N) -------------------------------
				NZVC(3) <= Sum_uns(7);
	
			--- Zero Flag (Z) ---------------------------------?
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			--- Overflow Flag (V) -------------------------------
			if ((A(7)='0' and B(7)='0' and Sum_uns(7)='1') or (A(7)='1' and B(7)='1' and Sum_uns(7)='1')) then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;

			--- Carry Flag (C) ------------------------------------
			NZVC(0) <= Sum_uns(8);
			
		elsif (ALU_Sel = "100") then --SUBTRACTION
		
			--- Sum Calculation ---------------------------------?
			Sum_uns := unsigned('0' & A) - unsigned('0' & B);
			Result <= std_logic_vector(Sum_uns(7 downto 0));

			--- Negative Flag (N) -------------------------------
				NZVC(3) <= Sum_uns(7);
	
			--- Zero Flag (Z) ---------------------------------?
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			--- Overflow Flag (V) -------------------------------
			if ((A(7)='0' and B(7)='0' and Sum_uns(7)='1') or (A(7)='1' and B(7)='1' and Sum_uns(7)='1')) then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;
			
		--elsif (ALU_Sel = "001") then --AND
		--elsif (ALU_Sel = "101") then --OR
		elsif (ALU_Sel = "010") then --INCREMENT A
		
			--- Sum Calculation ---------------------------------?
			Sum_uns := unsigned('0' & A) + unsigned('0' & one);
			Result <= std_logic_vector(Sum_uns(7 downto 0));

			--- Negative Flag (N) -------------------------------
				NZVC(3) <= Sum_uns(7);
	
			--- Zero Flag (Z) ---------------------------------?
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			--- Overflow Flag (V) -------------------------------
			if ((A(7)='0' and Sum_uns(7)='1')) then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;
			
		elsif (ALU_Sel = "011") then --INCREMENT B
		
			--- Sum Calculation ---------------------------------?
			Sum_uns := unsigned('0' & B) + unsigned('0' & one);
			Result <= std_logic_vector(Sum_uns(7 downto 0));

			--- Negative Flag (N) -------------------------------
				NZVC(3) <= Sum_uns(7);
	
			--- Zero Flag (Z) ---------------------------------?
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			--- Overflow Flag (V) -------------------------------
			if ((B(7)='0' and Sum_uns(7)='1')) then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;
			
		elsif (ALU_Sel = "110") then --DECREMENT A
		
			--- Sum Calculation ---------------------------------?
			Sum_uns := unsigned('0' & A) - unsigned('0' & one);
			Result <= std_logic_vector(Sum_uns(7 downto 0));

			--- Negative Flag (N) -------------------------------
				NZVC(3) <= Sum_uns(7);
	
			--- Zero Flag (Z) ---------------------------------?
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			--- Overflow Flag (V) -------------------------------
			if ((A(7)='0' and Sum_uns(7)='1') or (A(7)='1' and Sum_uns(7)='1')) then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;
			
		elsif (ALU_Sel = "111") then --DECREMENT B
		
			--- Sum Calculation ---------------------------------?
			Sum_uns := unsigned('0' & B) - unsigned('0' & one);
			Result <= std_logic_vector(Sum_uns(7 downto 0));

			--- Negative Flag (N) -------------------------------
				NZVC(3) <= Sum_uns(7);
	
			--- Zero Flag (Z) ---------------------------------?
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			--- Overflow Flag (V) -------------------------------
			if ((B(7)='0' and Sum_uns(7)='1') or (B(7)='1' and Sum_uns(7)='1')) then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;
			
		--elsif (ALU_Sel = . . .: ?other ALU functionality goes here?
		else
			Result <= x"00";
			NZVC <= "0000";
		end if;

	end process;

end architecture;