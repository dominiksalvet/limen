----------------------------------------------------------------------------------
-- Popis:				Aritmeticko logicka jednotka podporujici 16 ruznych operaci,
--							ktere jsou skrze hardware z instrukcniho slova volany a
--							provedeny.
--
-- Vyuzite moduly:	add_sub_16.vhd, shifter_16.vhd
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



entity alu is
	port ( opcode: 		in  std_logic_vector(3 downto 0);		-- operacni kod udava typ provadene operace
          operand_l: 	in  std_logic_vector(15 downto 0);		-- 1. vstupni operand (levy operand)
          operand_r: 	in  std_logic_vector(15 downto 0);		-- 2. vstupni operand (pravy operand)
          result: 		out  std_logic_vector(15 downto 0)		-- vysledek
			 );
end alu;



architecture behavioral of alu is

	constant O_OR: 	std_logic_vector(3 downto 0) := "0000";
	constant O_NOR: 	std_logic_vector(3 downto 0) := "0001";
	constant O_AND: 	std_logic_vector(3 downto 0) := "0010";
	constant O_NAND: 	std_logic_vector(3 downto 0) := "0011";
	constant O_XOR: 	std_logic_vector(3 downto 0) := "0100";
	constant O_SLL: 	std_logic_vector(3 downto 0) := "0101";
	constant O_SRL: 	std_logic_vector(3 downto 0) := "0110";
	constant O_SRA: 	std_logic_vector(3 downto 0) := "0111";
	constant O_ADD: 	std_logic_vector(3 downto 0) := "1000";
	constant O_LR: 	std_logic_vector(3 downto 0) := "1001";
	constant O_RL: 	std_logic_vector(3 downto 0) := "1010";
	constant O_SUB:	std_logic_vector(3 downto 0) := "1011";
	constant O_SL: 	std_logic_vector(3 downto 0) := "1100";
	constant O_SLU:	std_logic_vector(3 downto 0) := "1101";
	constant O_L: 		std_logic_vector(3 downto 0) := "1110";
	constant O_R: 		std_logic_vector(3 downto 0) := "1111";		-- konstanty pro operacni kod z duvodu prehlednosti
	
	
	component add_sub_16 is
		port ( sel_sub_add:	in  std_logic;
				 operand_a:		in  std_logic_vector(15 downto 0);
				 operand_b:		in  std_logic_vector(15 downto 0);
				 c_out:			out  std_logic;
				 result:			out  std_logic_vector(15 downto 0)
				 );
	end component;						-- definice add_sub_16 komponenty
	
	signal a_s_16_sel_sub_add:		std_logic;
	signal a_s_16_result:			std_logic_vector(15 downto 0);
	signal a_s_16_c_out:				std_logic;			-- pomocne signaly pro nektere vstupy a vystupy modulu add_sub_16
	
	
	component shifter_16 is
		port ( sel_right_left: 		in  std_logic;
				 sel_arith_logic: 	in  std_logic;
				 operand_a: 			in  std_logic_vector(15 downto 0);
				 operand_b: 			in  std_logic_vector(3 downto 0);
				 result: 				out  std_logic_vector(15 downto 0)
				 );
	end component;						-- definice shifter_16 komponenty
	
	signal sh_16_sel_right_left:		std_logic;
	signal sh_16_sel_arith_logic:		std_logic;
	signal sh_16_result:					std_logic_vector(15 downto 0);		-- pomocne signaly pro nektere vstupy a vystupy modulu shifter_16
	
	
	signal lr_less:	std_logic;			-- priznak, ktery odpovida lr_less = levy operand < pravy operand

begin

	add_sub_16_0: add_sub_16
	port map ( sel_sub_add =>	a_s_16_sel_sub_add,
				  operand_a =>		operand_l,
				  operand_b =>		operand_r,
				  c_out =>			a_s_16_c_out,
				  result =>			a_s_16_result
				  );				-- pouzity modul add_sub_16
				  
	a_s_16_sel_sub_add <=	opcode(3) and ((opcode(2) and not opcode(1)) or
									(not opcode(2) and opcode(1) and opcode(0)));			-- popis prirazeni, ktery zarucuje spravne pouzitou operaci (soucet/rozdil)
	
				   
	shifter_16_0: shifter_16
	port map ( sel_right_left =>		sh_16_sel_right_left,
				  sel_arith_logic =>		sh_16_sel_arith_logic,
				  operand_a =>				operand_l,
				  operand_b =>				operand_r(3 downto 0),
				  result =>					sh_16_result
				  );				-- pouzity modul shifter_16
	
	sh_16_sel_right_left <= not (not opcode(3) and opcode(2) and
									not opcode(1) and opcode(0));			-- funkce pro zvoleni smeru posunu
								
	sh_16_sel_arith_logic <=	not opcode(3) and opcode(2) and
										opcode(1) and opcode(0);			-- funkce pro zvoleni typu posunu
						
	lr_less <= 	(operand_l(15) and not operand_r(15)) or
					(not operand_l(15) and a_s_16_result(15)) or
					(operand_l(15) and not a_s_16_c_out)
					when opcode = O_SL
					else not a_s_16_c_out;			-- funcke pro urceni porovnani hodnot leveho a praveho operandu

					
	with opcode select result <=
		operand_l or operand_r when O_OR,
		not (operand_l or operand_r) when O_NOR,
		operand_l and operand_r when O_AND,
		not (operand_l and operand_r) when O_NAND,
		operand_l xor operand_r when O_XOR,
		sh_16_result when O_SLL,
		sh_16_result when O_SRL,
		sh_16_result when O_SRA,
		a_s_16_result when O_ADD,
		operand_l(15 downto 8) & operand_r(7 downto 0) when O_LR,
		operand_r(15 downto 8) & operand_l(7 downto 0) when O_RL,
		a_s_16_result when O_SUB,
		(0 => lr_less, others => '0') when O_SL,
		(0 => lr_less, others => '0') when O_SLU,
		operand_l when O_L,
		operand_r when others;			-- popis implementace vykonani operace mezi operandy v zavislosti na operacnim kodu

end behavioral;