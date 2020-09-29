----------------------------------------------------------------------------------
-- Popis:				Registrovy soubor, R0 je vzdy rovno 0.
--
-- Vyuzite moduly:	-
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity register_file is
	port ( write_en: 			in  std_logic;									-- signal, pri jehoz nastupne hrane se zapise do registroveho souboru
			 write_index:		in  std_logic_vector(2 downto 0);		-- index pro zapis do registroveho souboru
			 write_data:		in  std_logic_vector(15 downto 0);		-- data pro zapis do registroveho souboru
			 read_y_index: 	in  std_logic_vector(2 downto 0);		-- index pro cteni 1. registroveho operandu
			 read_y_data: 		out  std_logic_vector(15 downto 0);		-- prectena data 1. registroveho operandu
			 read_x_index: 	in  std_logic_vector(2 downto 0);		-- index pro cteni 2. registroveho operandu
			 read_x_data: 		out  std_logic_vector(15 downto 0)		-- prectena data 2. registroveho operandu
			 );
end register_file;



architecture behavioral of register_file is
	
	type mem_array is array(7 downto 0) of std_logic_vector(15 downto 0);
	signal register_array:  mem_array := (0 => (others => '0'), others => (others => 'X'));		-- inicializace registru R0 do nuly

begin

	process(write_en)
	begin
		if(rising_edge(write_en)) then
			if(write_index /= "000") then
				register_array(to_integer(unsigned(write_index))) <= write_data;
			end if;
		end if;
	end process;			-- proces pro zapis do registroveho souboru reagujici na nastupnou hranu signalu write_en, v pripade zapisovane indexu 000, se neprovede zapis
		
read_y_data <= register_array(to_integer(unsigned(read_y_index)));		-- asynchronne ctena data 1. registroveho operandu
read_x_data <= register_array(to_integer(unsigned(read_x_index)));		-- asynchronne ctena data 2. registroveho operandu

end behavioral;