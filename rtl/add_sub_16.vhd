----------------------------------------------------------------------------------
-- Popis:				16bitova scitacka s volbou scitani/odecitani.
--
-- Vyuzite moduly:	full_adder.vhd
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



entity add_sub_16 is
	port ( sel_sub_add:	in  std_logic;								-- soucet/rozdil (0 - soucet)
          operand_a:		in  std_logic_vector(15 downto 0);	-- 1. operand
          operand_b:		in  std_logic_vector(15 downto 0);	-- 2. operand
          c_out:			out  std_logic;							-- aritmeticke preteceni (vysledek mimo rozsah 16 bitu)
          result:			out  std_logic_vector(15 downto 0)	-- vysledek
			 );
end add_sub_16;



architecture behavioral of add_sub_16 is


	component full_adder is
		port ( a:		in  std_logic;
				 b:		in  std_logic;
				 c_in:	in  std_logic;
				 s:		out  std_logic;
				 c_out:	out  std_logic
				 );
	end component;									-- definice modulu full_adder
	

	signal sub_add_mask:			std_logic_vector(15 downto 0);		-- signal je pouzit pouze pro rozsireni vstupu sel_sub_add do 16 bitu pro vytvoreni masky
	signal sub_add_xor_b:		std_logic_vector(15 downto 0);		-- signal se pouziva pro realizaci souctu/rozdilu
	signal local_c_outs:			std_logic_vector(14 downto 0);		-- mistni preteceni, pouzivaji se pro mapovani signalu mezi jednotlivymi moduly full_adder

begin
	  
	sub_add_mask <= (others => sel_sub_add);				-- rozsireni bitu sel_sub_add to 16 bitu
	sub_add_xor_b <= operand_b xor sub_add_mask;			-- maskovani pro realizaci souctu a rozdilu v jednom obvodu


	full_adder_0: full_adder
	port map ( a =>		operand_a(0),
				  b =>		sub_add_xor_b(0),
				  c_in =>	sel_sub_add,
				  c_out =>	local_c_outs(0),
				  s =>		result(0)
				  );

	full_adder_1: full_adder
	port map ( a =>		operand_a(1),
				  b =>		sub_add_xor_b(1),
				  c_in =>	local_c_outs(0),
				  c_out =>	local_c_outs(1),
				  s =>		result(1)
				  );
				  
	full_adder_2: full_adder
	port map ( a =>		operand_a(2),
				  b =>		sub_add_xor_b(2),
				  c_in =>	local_c_outs(1),
				  c_out =>	local_c_outs(2),
				  s =>		result(2)
				  );
				  
	full_adder_3: full_adder
	port map ( a =>		operand_a(3),
				  b =>		sub_add_xor_b(3),
				  c_in =>	local_c_outs(2),
				  c_out =>	local_c_outs(3),
				  s =>		result(3)
				  );
				  
	full_adder_4: full_adder
	port map ( a =>		operand_a(4),
				  b =>		sub_add_xor_b(4),
				  c_in =>	local_c_outs(3),
				  c_out =>	local_c_outs(4),
				  s =>		result(4)
				  );
				  
	full_adder_5: full_adder
	port map ( a =>		operand_a(5),
				  b =>		sub_add_xor_b(5),
				  c_in =>	local_c_outs(4),
				  c_out =>	local_c_outs(5),
				  s =>		result(5)
				  );
	
	full_adder_6: full_adder
	port map ( a =>		operand_a(6),
				  b =>		sub_add_xor_b(6),
				  c_in =>	local_c_outs(5),
				  c_out =>	local_c_outs(6),
				  s =>		result(6)
				  );
	
	full_adder_7: full_adder
	port map ( a =>		operand_a(7),
				  b =>		sub_add_xor_b(7),
				  c_in =>	local_c_outs(6),
				  c_out =>	local_c_outs(7),
				  s =>		result(7)
				  );
				  
	full_adder_8: full_adder
	port map ( a =>		operand_a(8),
				  b =>		sub_add_xor_b(8),
				  c_in =>	local_c_outs(7),
				  c_out =>	local_c_outs(8),
				  s =>		result(8)
				  );
	
	full_adder_9: full_adder
	port map ( a =>		operand_a(9),
				  b => 		sub_add_xor_b(9),
				  c_in =>	local_c_outs(8),
				  c_out =>	local_c_outs(9),
				  s =>		result(9)
				  );
				  
	full_adder_10: full_adder
	port map ( a =>		operand_a(10),
				  b =>		sub_add_xor_b(10),
				  c_in =>	local_c_outs(9),
				  c_out =>	local_c_outs(10),
				  s =>		result(10)
				  );
	
	full_adder_11: full_adder
	port map ( a =>		operand_a(11),
				  b =>		sub_add_xor_b(11),
				  c_in =>	local_c_outs(10),
				  c_out =>	local_c_outs(11),
				  s =>		result(11)
				  );
				  
	full_adder_12: full_adder
	port map ( a =>		operand_a(12),
				  b =>		sub_add_xor_b(12),
				  c_in =>	local_c_outs(11),
				  c_out =>	local_c_outs(12),
				  s =>		result(12)
				  );
	
	full_adder_13: full_adder
	port map ( a =>		operand_a(13),
				  b =>		sub_add_xor_b(13),
				  c_in =>	local_c_outs(12),
				  c_out =>	local_c_outs(13),
				  s =>		result(13)
				  );
				  
	full_adder_14: full_adder
	port map ( a =>		operand_a(14),
				  b =>		sub_add_xor_b(14),
				  c_in =>	local_c_outs(13),
				  c_out =>	local_c_outs(14),
				  s =>		result(14)
				  );
	
	full_adder_15: full_adder
	port map ( a =>		operand_a(15),
				  b =>		sub_add_xor_b(15),
				  c_in =>	local_c_outs(14),
				  c_out =>	c_out,
				  s =>		result(15)
				  );										-- 16 pouzitych modulu full_adder pro realizaci 16bitoveho souctu/rozdilu
				  

end behavioral;