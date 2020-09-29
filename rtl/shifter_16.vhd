----------------------------------------------------------------------------------
-- Popis:				Modul, ktery je pouzit v procesoru k realizaci strojovych
--							instrukci SLL, SRL a SRA. Vstupy primo definuji typ
--							provadene operace.
--
-- Vyuzite moduly:	-
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



entity shifter_16 is
	port ( sel_right_left: 		in  std_logic;								-- bitovy posun doprava/doleva (0 - doleva)
          sel_arith_logic: 	in  std_logic;								-- bitovy posun aritmeticky/logicky (0 - logicky)
          operand_a: 			in  std_logic_vector(15 downto 0);	-- operand, jehoz bity budou posouvany
          operand_b: 			in  std_logic_vector(3 downto 0);	-- operand, ktery urcuje hodnotu, o kterou se bude posunovat
          result: 				out  std_logic_vector(15 downto 0)	-- vysledek zvolene operace
			 );
end shifter_16;



architecture behavioral of shifter_16 is

	signal extend_bit:	std_logic;											-- identifikator, ktery je pouzit pro aritmeticky posun (rozliseni kladneho a zaporneho cisla)
	
	signal shift_left_result:		std_logic_vector(15 downto 0);	-- identifikator vysledku posunu doleva
	signal shift_right_result:		std_logic_vector(15 downto 0);	-- identifikator vysledku posunu doprava

begin

	extend_bit <=	operand_a(15) when sel_arith_logic = '1'
						else '0';													-- prirazeni znamenka vstupniho operandu na vodic s identifikatorem extend_bit
	
	with operand_b select shift_left_result <=
		operand_a when "0000",
		operand_a(14 downto 0) & '0' when "0001",
		operand_a(13 downto 0) & (1 downto 0 => '0') when "0010",
		operand_a(12 downto 0) & (2 downto 0 => '0') when "0011",
		operand_a(11 downto 0) & (3 downto 0 => '0') when "0100",
		operand_a(10 downto 0) & (4 downto 0 => '0') when "0101",
		operand_a(9 downto 0) & (5 downto 0 => '0') when "0110",
		operand_a(8 downto 0) & (6 downto 0 => '0') when "0111",
		operand_a(7 downto 0) & (7 downto 0 => '0') when "1000",
		operand_a(6 downto 0) & (8 downto 0 => '0') when "1001",
		operand_a(5 downto 0) & (9 downto 0 => '0') when "1010",
		operand_a(4 downto 0) & (10 downto 0 => '0') when "1011",
		operand_a(3 downto 0) & (11 downto 0 => '0') when "1100",
		operand_a(2 downto 0) & (12 downto 0 => '0') when "1101",
		operand_a(1 downto 0) & (13 downto 0 => '0') when "1110",
		operand_a(0) & (14 downto 0 => '0') when others;				-- popis implementace posunu doleva
		
	with operand_b select shift_right_result <=
		operand_a when "0000",
		extend_bit & operand_a(15 downto 1) when "0001",
		(1 downto 0 => extend_bit) & operand_a(15 downto 2) when "0010",
		(2 downto 0 => extend_bit) & operand_a(15 downto 3) when "0011",
		(3 downto 0 => extend_bit) & operand_a(15 downto 4) when "0100",
		(4 downto 0 => extend_bit) & operand_a(15 downto 5) when "0101",
		(5 downto 0 => extend_bit) & operand_a(15 downto 6) when "0110",
		(6 downto 0 => extend_bit) & operand_a(15 downto 7) when "0111",
		(7 downto 0 => extend_bit) & operand_a(15 downto 8) when "1000",
		(8 downto 0 => extend_bit) & operand_a(15 downto 9) when "1001",
		(9 downto 0 => extend_bit) & operand_a(15 downto 10) when "1010",
		(10 downto 0 => extend_bit) & operand_a(15 downto 11) when "1011",
		(11 downto 0 => extend_bit) & operand_a(15 downto 12) when "1100",
		(12 downto 0 => extend_bit) & operand_a(15 downto 13) when "1101",
		(13 downto 0 => extend_bit) & operand_a(15 downto 14) when "1110",
		(14 downto 0 => extend_bit) & operand_a(15) when others;					-- popis implementace posunu doprava
		
	with sel_right_left select result <=
		shift_left_result when '0',
		shift_right_result when others;			-- vyber vysledku v zavislosti na zvolenem posunu (doprava/doleva)
					
end behavioral;