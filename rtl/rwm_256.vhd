----------------------------------------------------------------------------------
-- Popis:				Synchronni operacni pamet o velikosti 512B (256 x 16 bitu).
--
-- Vyuzite moduly:	-
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity rwm_256 is
	port ( clk:			in  std_logic;								-- hodinovy signal pro synchronizaci
			 write_en:	in  std_logic;								-- signal pro povoleny zapis do pameti
			 addr:		in  std_logic_vector(7 downto 0);	-- adresa
			 data_in:	in  std_logic_vector(15 downto 0);	-- vstupni datova sbernice
			 data_out:	out  std_logic_vector(15 downto 0)	-- vystupni datova sbernice
			 );
end rwm_256;



architecture behavioral of rwm_256 is

	type ram_t is array (0 to 255) of std_logic_vector(15 downto 0);
	signal mem: ram_t := (
		0 => "1000011111101110",	--LI R6, 11111101b
		1 => "1001111111111110",	--LIH R6, 0xFF
		2 => "1000011111001101",	--LI R5, 11111001b
		3 => "1001111111111101",	--LIH R5, 0xFF
		4 => "0111100101110001",	--SL R1, R6, R5
		5 => "1010000011001000",	--JNE R1, +3 (8)
		6 => "0010101111110110",	--ADD R6, R6, -1
		7 => "1101111111101000",	--JWL R0, -3 (4)
		8 => "0000101001101101",	--ADD R5, R5, 9
		9 => "0111100110101001",	--SL R1, R5, R6
		10 => "1010000011001000",	--JNE R1, +3 (13)
		11 => "0000100001110110",	--ADD R6, R6, 1
		12 => "1101111111101000",	--JWL R0, -3 (9)
		13 => "1101111110011000",	--JWL R0, -13 (0)
		others => (others => 'X')
	);		-- operacni pamet, jeji inicializaci lze programovat procesor Limen ve strojovem kodu

begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(write_en = '1') then
				mem(to_integer(unsigned(addr))) <= data_in;
			end if;
			data_out <= mem(to_integer(unsigned(addr)));
		end if;
	end process;		-- proces pro synchronni zapis a cteni

end behavioral;