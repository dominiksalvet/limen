library ieee;
use ieee.std_logic_1164.all;



entity bit_width_extender is
	port ( extend_type: 	in  std_logic_vector(1 downto 0);
          input_data: 	in  std_logic_vector(15 downto 0);
          output_data:	out  std_logic_vector(15 downto 0)
			 );
end bit_width_extender;



architecture behavioral of bit_width_extender is

	constant ET_IN:			std_logic_vector(1 downto 0) := "00";
	constant ET_NOT_IN:		std_logic_vector(1 downto 0) := "01";
	constant ET_7_SIGN:		std_logic_vector(1 downto 0) := "10";
	constant ET_10_SIGN:		std_logic_vector(1 downto 0) := "11";

begin

	with extend_type select output_data <=
		input_data when ET_IN,
		not input_data when ET_NOT_IN,
		(15 downto 7 => input_data(6)) & input_data(6 downto 0) when ET_7_SIGN,
		(15 downto 10 => input_data(9)) & input_data(9 downto 0) when ET_10_SIGN,
		(others => '-') when others;

end behavioral;