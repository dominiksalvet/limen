----------------------------------------------------------------------------------
-- Popis:				Modul slouzici k inkrementaci vstupni hodnoty.
--
-- Vyuzite moduly:	half_adder.vhd
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



entity incrementator_16 is
	port ( operand: 	in  std_logic_vector(15 downto 0);		-- operand
			 result: 	out  std_logic_vector(15 downto 0)		-- vysledek
			 );
end incrementator_16;



architecture behavioral of incrementator_16 is
	
	
	component half_adder is
		port ( a:	in  std_logic;
				 b:	in  std_logic;
				 s:	out  std_logic;
				 c:	out  std_logic
				 );
	end component;			-- definice modulu half_adder
	
	
	signal local_c_outs:	std_logic_vector(14 downto 0);	-- mistni preteceni, pouzivaji se pro mapovani signalu mezi jednotlivymi moduly half_adder
	
begin

	half_adder_0: half_adder
	port map ( a =>	operand(0),
				  b =>	'1',
				  s =>	result(0),
				  c =>	local_c_outs(0)
				  );

	half_adder_1: half_adder
	port map ( a =>	operand(1),
				  b =>	local_c_outs(0),
				  s =>	result(1),
				  c =>	local_c_outs(1)
				  );
	
	half_adder_2: half_adder
	port map ( a =>	operand(2),
				  b =>	local_c_outs(1),
				  s =>	result(2),
				  c =>	local_c_outs(2)
				  );
	
	half_adder_3: half_adder
	port map ( a =>	operand(3),
				  b =>	local_c_outs(2),
				  s =>	result(3),
				  c =>	local_c_outs(3)
				  );
	
	half_adder_4: half_adder
	port map ( a =>	operand(4),
				  b =>	local_c_outs(3),
				  s =>	result(4),
				  c =>	local_c_outs(4)
				  );
	
	half_adder_5: half_adder
	port map ( a =>	operand(5),
				  b =>	local_c_outs(4),
				  s =>	result(5),
				  c =>	local_c_outs(5)
				  );
	
	half_adder_6: half_adder
	port map ( a =>	operand(6),
				  b =>	local_c_outs(5),
				  s =>	result(6),
				  c =>	local_c_outs(6)
				  );
	
	half_adder_7: half_adder
	port map ( a =>	operand(7),
				  b =>	local_c_outs(6),
				  s =>	result(7),
				  c =>	local_c_outs(7)
				  );
	
	half_adder_8: half_adder
	port map ( a =>	operand(8),
				  b =>	local_c_outs(7),
				  s =>	result(8),
				  c =>	local_c_outs(8)
				  );
	
	half_adder_9: half_adder
	port map ( a =>	operand(9),
				  b =>	local_c_outs(8),
				  s =>	result(9),
				  c =>	local_c_outs(9)
				  );
	
	half_adder_10: half_adder
	port map ( a =>	operand(10),
				  b =>	local_c_outs(9),
				  s =>	result(10),
				  c =>	local_c_outs(10)
				  );
	
	half_adder_11: half_adder
	port map ( a =>	operand(11),
				  b =>	local_c_outs(10),
				  s =>	result(11),
				  c =>	local_c_outs(11)
				  );
	
	half_adder_12: half_adder
	port map ( a =>	operand(12),
				  b =>	local_c_outs(11),
				  s =>	result(12),
				  c =>	local_c_outs(12)
				  );
	
	half_adder_13: half_adder
	port map ( a =>	operand(13),
				  b =>	local_c_outs(12),
				  s =>	result(13),
				  c =>	local_c_outs(13)
				  );
	
	half_adder_14: half_adder
	port map ( a =>	operand(14),
				  b =>	local_c_outs(13),
				  s =>	result(14),
				  c =>	local_c_outs(14)
				  );										-- 15 pouzitych modulu half_adder pro realizaci 15bitoveho souctu s pretecenim
				  
				  
	result(15) <= operand(15) xor local_c_outs(14);		-- modul nepotrebuje indikator preteceni, proto je posledni modul half_adder nahrazen jen casti polovicni scitacky

end behavioral;