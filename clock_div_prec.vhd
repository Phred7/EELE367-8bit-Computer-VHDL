library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_div_prec is
	port (Clock_in : in std_logic;
			Reset	: in std_logic;
			Sel	: in std_logic_vector(1 downto 0);
			Clock_out	: out std_logic);
end entity;

architecture clock_div_prec_arch of clock_div_prec is

	signal clk : std_logic;
	signal CNT_int : integer;
	signal max : integer := 24999;

	begin
	
	COUNTER : process (Clock_in, Reset)
		begin
		if(Reset = '0') then
			CNT_int <= 0;
			clk <= '0';
		elsif(Clock_in'event and Clock_in = '1') then 
			if(CNT_int > max) then
				CNT_int <= 0;
				clk <= not clk;
			else
				CNT_int <= CNT_int + 1;	
			end if;
		end if;
	end process;
	
	
		
	SEL_DELTA : process (Clock_in, Sel)
	
		begin
		
		if(Sel = "00") then --1 Hz
			--CNT_int <= 0;
			max <= 24999999;				
		elsif(Sel = "01") then --10 Hz
			--CNT_int <= 0;
			max <= 2499999;
		elsif(Sel = "10") then --100 Hz
			--CNT_int <= 0;
			max <= 249999;
		elsif(Sel = "11") then --1 kHz
			--CNT_int <= 0;
			max <= 24999;
		end if;
		
	end process;
	
	Clock_out <= clk;

end architecture;