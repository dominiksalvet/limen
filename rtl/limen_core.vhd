----------------------------------------------------------------------------------
-- Popis:				Jadro procesoru Limen popisujici propojeni mezi hlavnimi
--							moduly a praci vnejsiho rozhranni procesoru. Vystupem modulu
--							jadra je taky hodnota registru IP pro ucely odladeni.
--
-- Vyuzite moduly:	alu.vhd, register_file.vhd, condition_tester.vhd,
--							incrementator_16.vhd
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



entity limen_core is
	port ( ip_debug:			out  std_logic_vector(15 downto 0);		-- vystup IP registru
	
			 reset:				in  std_logic;									-- reset signal
          clk:					in  std_logic;									-- vstupni hodinovy signal
			 mem_clk:			out  std_logic;								-- vystupni hodinovy signal pro rizeni taktu pameti
          mem_write_en:		out  std_logic;								-- signal pro povoleni zapisu do operacni pameti
          mem_addr:			out  std_logic_vector(15 downto 0);		-- 16 bitovy vystup pro adresovani pameti
          mem_data_out:		out  std_logic_vector(15 downto 0);		-- 16 bitova vystupni datova sbernice pameti
          mem_data_in:		in  std_logic_vector(15 downto 0)		-- 16 bitova vstupni datova sbernice pameti
			 );
end limen_core;



architecture behavioral of limen_core is
	
	constant CLK_PHASE_0:	std_logic_vector(3 downto 0) := "0001";
	constant CLK_PHASE_1:	std_logic_vector(3 downto 0) := "0010";
	constant CLK_PHASE_2:	std_logic_vector(3 downto 0) := "0100";
	constant CLK_PHASE_3:	std_logic_vector(3 downto 0) := "1000";		-- konstanty pro taktovani jednotlivych casti procesoru

	constant IF_AZIMM:	std_logic_vector(2 downto 0) := "000";
	constant IF_AOIMM:	std_logic_vector(2 downto 0) := "001";
	constant IF_LIMM:		std_logic_vector(2 downto 0) := "010";
	constant IF_ALREG:	std_logic_vector(2 downto 0) := "011";
	constant IF_LDIMM:	std_logic_vector(2 downto 0) := "100";
	constant IF_CJDISP:	std_logic_vector(2 downto 0) := "101";
	constant IF_JDISP:	std_logic_vector(2 downto 0) := "110";
	constant IF_JREG:		std_logic_vector(2 downto 0) := "111";				-- konstatny pro instrukcni formaty
	

	component alu is
		port ( opcode: 		in  std_logic_vector(3 downto 0);
				 operand_l:		in  std_logic_vector(15 downto 0);
				 operand_r: 	in  std_logic_vector(15 downto 0);
				 result: 		out  std_logic_vector(15 downto 0)
				 );
	end component;			-- incializace modulu alu
	
	signal alu_opcode:		std_logic_vector(3 downto 0);
	signal alu_operand_l:	std_logic_vector(15 downto 0);
	signal alu_operand_r:	std_logic_vector(15 downto 0);
	signal alu_result:		std_logic_vector(15 downto 0);			-- pomocne signaly pro vstupy a vystupy modulu alu
	
	
	component register_file is
		port ( write_en: 			in  std_logic;
				 write_index: 		in  std_logic_vector(2 downto 0);
				 write_data: 		in  std_logic_vector(15 downto 0);
				 read_y_index: 	in  std_logic_vector(2 downto 0);
				 read_y_data: 		out  std_logic_vector(15 downto 0);
				 read_x_index: 	in  std_logic_vector(2 downto 0);
				 read_x_data: 		out  std_logic_vector(15 downto 0)
				 );
	end component;			-- incializace modulu register_file
	
	signal reg_write_en:			std_logic;
	signal reg_write_index:		std_logic_vector(2 downto 0);
	signal reg_write_data:		std_logic_vector(15 downto 0);
	signal reg_read_y_index:	std_logic_vector(2 downto 0);
	signal reg_read_y_data:		std_logic_vector(15 downto 0);
	signal reg_read_x_index:	std_logic_vector(2 downto 0);
	signal reg_read_x_data:		std_logic_vector(15 downto 0);			-- pomocne signaly pro vstupy a vystupy modulu register_file
	
	
	component condition_tester is
		port ( cond_type:		in  std_logic_vector(2 downto 0);
				 input_data:	in  std_logic_vector(15 downto 0);
				 jump_ack:		out  std_logic
				 );
	end component;			-- incializace modulu condition_tester
	
	signal con_cond_type:	std_logic_vector(2 downto 0);
	signal con_jump_ack:		std_logic;			-- pomocne signaly pro nektere vstupy a vystupy modulu condition_tester
	
	
	component incrementator_16 is
		port ( operand: 	in  std_logic_vector(15 downto 0);
				 result: 	out  std_logic_vector(15 downto 0)
				 );
	end component;			-- incializace modulu incrementator_16
	
	signal inc_16_result:	std_logic_vector(15 downto 0);
	signal ip_reg_input:		std_logic_vector(15 downto 0);			-- pomocne signaly pro vstup a vystup modulu incrementator_16
	
	
	signal clk_phase:				std_logic_vector(3 downto 0);			-- registr aktualni faze casovani procesoru
	signal mem_write_phase:		std_logic;									-- registr povoleni zapisu do RWM
	
	signal inst_format:			std_logic_vector(2 downto 0);			-- identifikator instrukcniho formatu
	signal ext_imm_data:			std_logic_vector(15 downto 0);		-- identifikator rozsirenych hodnot, ktere jsou obsazeny primo v instrukcnim slove
	signal st_inst_active:		std_logic;									-- aktivni instrukce ST
	signal ld_inst_active:		std_logic;									-- aktivni instrukce LD
	signal aimm_inst_active:	std_logic;									-- aktivni aritmeticke instrukce s primou hodnotou
	
	signal ir_reg:		std_logic_vector(15 downto 0);					-- registr aktualne provadene instrukce
	signal ip_reg:		std_logic_vector(15 downto 0);					-- registr adresy aktualne provadene instrukce
	
	signal sel_ip_reg_l_to_alu_l:			std_logic;								-- vstup do leveho operandu alu (0 - registr s y indexem, 1 - ip_reg)
	signal sel_imm_reg_r_to_alu_r:		std_logic;								-- vstup do praveho operandu alu (0 - registr s x indexem, 1 - prima hodnota)
	signal sel_alu_ip_to_mem_addr:		std_logic;								-- sbernice pro adresaci RWM (0 - ip_reg, 1 - vysledek alu)
	signal sel_inc_mem_in_alu_to_reg:		std_logic_vector(1 downto 0);
	-- zapis do registroveho souboru (00 - inkrementovany ip_reg, 01 - vstupni datova sbernice z RWM, ostatni - vysledek alu)

begin

	inst_format <= ir_reg(15 downto 13);			-- maskovani instrukcniho formatu z instrukcniho slova
	
	aimm_inst_active <=	'1' when inst_format = IF_AZIMM or inst_format = IF_AOIMM
								else '0';					-- aktivni aritmeticka instrukce s primou hodnotou
								
	mem_write_en <=	'1' when st_inst_active = '1' and mem_write_phase = '1'
							else '0';						-- pokud je faze zapisu (rizeno procesem, ktery casuje procesor) a aktivni instrukce ST, zapis je povolen
		
	mem_addr <= ip_reg when sel_alu_ip_to_mem_addr = '0'
					else alu_result;						-- adresace pameti (v procesu, ktery casuje procesor se prepina)
					
	mem_data_out <= reg_read_x_data;					-- pro zapis do pameti RWM se vzdy pouziva registr indexovany x


	alu_0: alu
	port map ( opcode =>			alu_opcode,
				  operand_l =>		alu_operand_l,
				  operand_r =>		alu_operand_r,
				  result =>			alu_result
				  );			-- pouziti modulu alu
	
	sel_ip_reg_l_to_alu_l <=	'1' when inst_format = IF_CJDISP or inst_format = IF_JDISP
										else '0';
										-- pokud se provadi jakykoli skok s odsazenim, je hodnota ip_reg pouzita jako levy operand (pro soucet s primou hodnotou z instrukcniho slova)
				  
	sel_imm_reg_r_to_alu_r <=	'0' when inst_format = IF_ALREG
										else '1';		-- registr indexovany x se pouziva pouze pokud je instrukcni format aritmeticky s registry
										
	ext_imm_data <=	(15 downto 4 => '0') & ir_reg(9 downto 6) when inst_format = IF_AZIMM else
							(15 downto 4 => '1') & ir_reg(9 downto 6) when inst_format = IF_AOIMM else
							(15 downto 4 => '0') & ir_reg(9 downto 6) when inst_format = IF_LIMM else
							(15 downto 8 => '0') & ir_reg(10 downto 3) when inst_format = IF_LDIMM and ir_reg(11) = '0' else
							ir_reg(10 downto 3) & (7 downto 0 => '0') when inst_format = IF_LDIMM and ir_reg(11) = '1' else
							(15 downto 7 => ir_reg(12)) & ir_reg(12 downto 6) when inst_format = IF_CJDISP else
							(15 downto 10 => ir_reg(12)) & ir_reg(12 downto 3);
							-- rozsirovani a doplnovani primych hodnot z instrukcniho slova
				  
	alu_opcode <=	'0' & ir_reg(12 downto 10) when inst_format = IF_LIMM else
						'0' & ir_reg(11 downto 9) when inst_format = IF_ALREG and ir_reg(12) = '0' else
						"1001" when inst_format = IF_LDIMM and ir_reg(12 downto 11) = "10" else
						"1010" when inst_format = IF_LDIMM and ir_reg(12 downto 11) = "11" else
						"1011" when inst_format = IF_ALREG and ir_reg(12 downto 9) = "1011" else
						"1100" when (aimm_inst_active = '1' and ir_reg(12 downto 10) = "100") or
						(inst_format = IF_ALREG and ir_reg(12 downto 9) = "1100") else
						"1101" when (aimm_inst_active = '1' and ir_reg(12 downto 10) = "101") or
						(inst_format = IF_ALREG and ir_reg(12 downto 9) = "1101") else
						"1110" when inst_format = IF_JREG else
						"1111" when inst_format = IF_LDIMM and ir_reg(12) = '0'
						else "1000";
						-- dekodovani pouziteho operacniho kodu alu v zavislosti na pouzite instrukci
				  
	alu_operand_l <=	reg_read_y_data when sel_ip_reg_l_to_alu_l = '0'
							else ip_reg;		-- viz sel_ip_reg_l_to_alu_l
	
	alu_operand_r <=	reg_read_x_data when sel_imm_reg_r_to_alu_r = '0'
							else ext_imm_data;		-- viz sel_imm_reg_r_to_alu_r
							
	
	register_file_0: register_file
	port map ( write_en =>			reg_write_en,
				  write_index =>		reg_write_index,
				  write_data =>		reg_write_data,
				  read_y_index =>		reg_read_y_index,
				  read_y_data =>		reg_read_y_data,
				  read_x_index =>		reg_read_x_index,
				  read_x_data =>		reg_read_x_data
				  );			-- pouziti modulu register_file
				  
	st_inst_active <=	'1' when aimm_inst_active = '1' and ir_reg(12 downto 10) = "000"
							else '0';		-- indikace aktivni instrukce ST
	
	ld_inst_active <=	'1' when aimm_inst_active = '1' and ir_reg(12 downto 10) = "001"
							else '0';		-- indikace aktivni instrukce LD
				  
	sel_inc_mem_in_alu_to_reg <=	"00" when inst_format = IF_JDISP or inst_format = IF_JREG else
											"01" when ld_inst_active = '1'
											else "11";
											-- viz signal sel_inc_mem_in_alu_to_reg
				  
	with sel_inc_mem_in_alu_to_reg select reg_write_data <=
		inc_16_result when "00",
		mem_data_in when "01",
		alu_result when others;
		-- viz signal sel_inc_mem_in_alu_to_reg
	
	reg_write_index <=	"000" when st_inst_active = '1' or inst_format = IF_CJDISP
								else ir_reg(2 downto 0);
								-- zapisovany index registru,
								-- pokud je aktivni instrukce ST nebo podmineny skok, zapis probehne do registru R0 (nic se nestane),
								-- jinak je index ve 3 spodnich bitech kazde instrukce
								
	reg_read_y_index <= 	ir_reg(2 downto 0) when ir_reg(15 downto 12) = "1001"
								else ir_reg(5 downto 3);
								-- instrukce LIL, LIH pro maskovani vrchni/spodni osmici bitu nacist index ze 3 spodnich bitu instrukcniho slova,
								-- u vsech ostatnich instrukci jsou pouzity bity 3 az 5
	
	reg_read_x_index <= 	ir_reg(2 downto 0) when st_inst_active = '1'
								else ir_reg(8 downto 6);
								-- instrukce pro zapis do pameti (ST) potrebuje operand pro zapis dostat na sbernici x
								
	
	condition_tester_0: condition_tester
	port map ( cond_type =>		con_cond_type,
				  input_data =>	reg_read_y_data,
				  jump_ack =>		con_jump_ack
				  );			-- pouziti modulu condition_tester
	
	con_cond_type <=	ir_reg(2 downto 0) when inst_format = IF_CJDISP else
							"111" when inst_format = IF_JDISP or inst_format = IF_JREG
							else "110";
							-- u instrukci instrukcniho fomartu podminene skoky s odsazenim je podminka ke
							-- splneni ulozna ve 3 spodnich bitech,
							-- instrukce, ktere provadi nepodmineny skok, maji vzdy podminku pro skok na vystupni hodnotu alu povolenou,
							-- ostatni instrukce tuto podminku nemaji povolenou nikdy (tj. pouzije se inkrementovana hodnota ip_reg)

	
	incrementator_16_0: incrementator_16
	port map ( operand =>	ip_reg,
				  result =>		inc_16_result
				  );			-- pouziti modulu incrementator_16
	
	ip_reg_input <=	alu_result when con_jump_ack = '1'
							else inc_16_result;		-- pokud je splnena podminka pro skok, nasledujici adresa je vystupem z alu, jinak inkrementovana hodnota ip_reg


	process(reset, clk)
	begin
		if(reset = '1') then
			ip_reg <= (others => '1');
			ir_reg <= (others => '0');
			clk_phase <= CLK_PHASE_0;
			reg_write_en <= '0';
			mem_clk <= '0';
			mem_write_phase <= '0';			-- reset hodnoty
		elsif(rising_edge(clk)) then		
			case clk_phase is
				when CLK_PHASE_0 => clk_phase <= CLK_PHASE_1;
				when CLK_PHASE_1 => clk_phase <= CLK_PHASE_2;
				when CLK_PHASE_2 => clk_phase <= CLK_PHASE_3;
				when CLK_PHASE_3 => clk_phase <= CLK_PHASE_0;		-- kruhovy registr pro casovani casti procesoru
				when others => null;
			end case;
			
			if(clk_phase = CLK_PHASE_1 or clk_phase = CLK_PHASE_3) then
				mem_clk <= '1';
			else
				mem_clk <= '0';
			end if;		-- taktovani pameti
			
			if(clk_phase = CLK_PHASE_2 or clk_phase = CLK_PHASE_3) then
				mem_write_phase <= '1';
			else
				mem_write_phase <= '0';
			end if;		-- faze zapisu do pameti (3 faze taktovani pameti provede nastupnou hranu potrebnou pro zapis)
			
			if(clk_phase = CLK_PHASE_0) then
				reg_write_en <= '1';
				ip_reg <= ip_reg_input;
				sel_alu_ip_to_mem_addr <= '0';
			else
				reg_write_en <= '0';
			end if;			-- zapis do registroveho souboru, zapis dalsi adresy instrukce, prepnuti ip_reg na adresovou sbernici
			
			if(clk_phase = CLK_PHASE_2) then
				ir_reg <= mem_data_in;
				sel_alu_ip_to_mem_addr <= '1';
			end if;			-- zapis vystupu operacni pameti do instrukcniho registru (ir_reg), prepnuti vysledku alu na adresovou sbernici
			
		end if;
	end process;
	
								
	ip_debug <= ip_reg;		--debug


end behavioral;