----------------------------------------------------------------------------------
-- Popis:				System (lze si predstavit jako zakladni desku) zalozeny na
--							procesoru Limen. Implementuje pamet a deleni hodinoveho
--							signalu, jehoz rychlost muze byt pouzita pro debug ucely.
--							Pro debug je vyvedeno 8 spodnich bitu IP registru z modulu
--							limen_core.
--
-- Vyuzite moduly:	limen_core.vhd, rwm_256.vhd
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; 



entity limen_system is
	port ( reset:	in  std_logic;								-- reset, vyveden na vyvojovy kit
			 clk:		in  std_logic;								-- hodinovy signal z krystalu na vyvojovem kitu
			 leds:	out  std_logic_vector(7 downto 0)	-- vystup, vyveden na ledky vyvojoveho kitu
			 );
end limen_system;



architecture behavioral of limen_system is


	component limen_core is
		port ( ip_debug:			out  std_logic_vector(15 downto 0);
				 reset:				in  std_logic;
				 clk:					in  std_logic;
				 mem_clk:			out  std_logic;
				 mem_write_en:		out  std_logic;
				 mem_addr:			out  std_logic_vector(15 downto 0);
				 mem_data_out:		out  std_logic_vector(15 downto 0);
				 mem_data_in:		in  std_logic_vector(15 downto 0)
				 );
	end component;			-- incializace modulu limen_core
	
	signal lc_clk:					std_logic;
	signal lc_mem_clk:			std_logic;
	signal lc_mem_write_en:		std_logic;
	signal lc_mem_addr:			std_logic_vector(15 downto 0);
	signal lc_mem_data_out:		std_logic_vector(15 downto 0);
	signal lc_mem_data_in:		std_logic_vector(15 downto 0);			-- pomocne signaly pro nektere vstupy a vystupy modulu limen_core
	
	signal lc_ip_debug:	std_logic_vector(15 downto 0);			-- pomocny signal pro debug
	
	
	component rwm_256 is
		port ( clk:			in  std_logic;
				 write_en:	in  std_logic;
				 addr:		in  std_logic_vector(7 downto 0);
				 data_in:	in  std_logic_vector(15 downto 0);
				 data_out:	out  std_logic_vector(15 downto 0)
				 );
	end component;			-- incializace modulu rwm_256
	
	
	signal clk_div:	std_logic_vector(21 downto 0);				-- v teto konfiguraci plne vyuzita 22 bitova delicka signalu

begin


	limen_core_0: limen_core
	port map ( ip_debug =>			lc_ip_debug,
				  reset => 				reset,
				  clk => 				lc_clk,
				  mem_clk =>			lc_mem_clk,
				  mem_write_en =>		lc_mem_write_en,
				  mem_addr =>			lc_mem_addr,
				  mem_data_out =>		lc_mem_data_out,
				  mem_data_in =>		lc_mem_data_in
				  );		-- pouziti modulu limen_core
				  
	
	rwm_256_0: rwm_256
	port map ( clk =>			lc_mem_clk,
				  write_en => 	lc_mem_write_en,
				  addr =>		lc_mem_addr(7 downto 0),
				  data_in =>	lc_mem_data_out,
				  data_out =>	lc_mem_data_in
				  );		-- pouziti modulu rwm_256 (na adresni sbernici je privedeno jen 8 spodnich bitu adresacni sbernice samotneho jadra procesoru Limen)
				  
				  
	process(clk, reset)
	begin
		if(reset = '1') then
			lc_clk <= '0';
			clk_div <= (others => '0');
		elsif(rising_edge(clk)) then
			clk_div <= clk_div + 1;
			if(clk_div = (21 => '1', 20 downto 0 => '0')) then
				lc_clk <= '1';
			else
				lc_clk <= '0';
			end if;
		end if;
	end process;		-- delicka
	
	
	leds <= lc_ip_debug(7 downto 0);		-- prirazeni spodni osmice bitu ip_reg modulu limen_core na vystupni ledky
	
	
end behavioral;