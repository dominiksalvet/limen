----------------------------------------------------------------------------------
-- Popis:				Uplna scitacka.
--
-- Vyuzite moduly:	half_adder.vhd
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



entity full_adder is
	port ( a:		in  std_logic;
          b:		in  std_logic;
          c_in:	in  std_logic;
          s:		out  std_logic;
          c_out:	out  std_logic
			 );
end full_adder;



architecture behavioral of full_adder is


	component half_adder is
		port ( a:	in  std_logic;
				 b:	in  std_logic;
				 s:	out  std_logic;
				 c:	out  std_logic
				 );
	end component;

	signal half_adder_0_s:	std_logic;
	signal half_adder_0_c:	std_logic;
	signal half_adder_1_c:	std_logic;
	

begin


	half_adder_0: half_adder
	port map ( a =>	a,
				  b =>	b,
				  s =>	half_adder_0_s,
				  c =>	half_adder_0_c
				  );		  
				  
	half_adder_1: half_adder
	port map ( a =>	c_in,
				  b =>	half_adder_0_s,
				  s =>	s,
				  c =>	half_adder_1_c
				  );				  
				  
	c_out <= half_adder_0_c or half_adder_1_c;

end behavioral;