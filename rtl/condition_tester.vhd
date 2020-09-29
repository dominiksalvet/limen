----------------------------------------------------------------------------------
-- Popis:				Tester podminek je vyuzivan pro podminene skoky. Podminka je
--							je vzdy porovni mezi vstupnimi daty a nulou
--
-- Vyuzite moduly:	-
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



entity condition_tester is
	port ( cond_type:		in  std_logic_vector(2 downto 0);		-- typ podminky ke splneni
			 input_data:	in  std_logic_vector(15 downto 0);		-- data, ktera maji splnovat podminku
          jump_ack:		out  std_logic									-- podminka splnena/nesplnena (0 - nesplnena)
			 );
end condition_tester;



architecture behavioral of condition_tester is

	constant CT_NE:		std_logic_vector(2 downto 0) := "000";
	constant CT_E:			std_logic_vector(2 downto 0) := "001";
	constant CT_L:			std_logic_vector(2 downto 0) := "010";
	constant CT_LE:		std_logic_vector(2 downto 0) := "011";
	constant CT_G:			std_logic_vector(2 downto 0) := "100";
	constant CT_GE:		std_logic_vector(2 downto 0) := "101";
	constant CT_NEVER:	std_logic_vector(2 downto 0) := "110";
	constant CT_ALWAYS:	std_logic_vector(2 downto 0) := "111";		-- konstanty, ktere jsou vyuzity k rychlejsi synteze a snazsimu nalezeni souvislosti popisu, ovsem pouzivaji se zejmena z duvodu prehlednosti
	
	signal equal_flag:	std_logic;		-- priznak rovnosti nule
	signal less_flag:		std_logic;		-- priznak mensi nez nula

begin
	
	equal_flag <= 	'1' when input_data = (15 downto 0 => '0')
						else '0';			-- rovnost nule
						
	less_flag <= input_data(15);		-- mensi nez nula je primo rovno znamenkovemu bitu
	
	with cond_type select jump_ack <=
		not equal_flag when CT_NE,
		equal_flag when CT_E,
		less_flag when CT_L,
		less_flag or equal_flag when CT_LE,
		not less_flag and not equal_flag when CT_G,
		not less_flag when CT_GE,
		'0' when CT_NEVER,
		'1' when others;			-- vyhodnoceni splneni podminky v zavislosti na priznacich, ktere vychazi z vlastnosti vstupnich dat
		
end behavioral;