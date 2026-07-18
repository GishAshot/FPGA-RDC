library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rom_lcd_init is
	port (
	a: IN std_logic_VECTOR(2 downto 0);
	spo: OUT std_logic_VECTOR(7 downto 0));
end rom_lcd_init;


architecture syn of rom_lcd_init is
    type rom_type is array (0 to 7) of std_logic_vector (7 downto 0);                 
    signal ROM : rom_type:= (
							X"30",
							X"30",
							X"30",
							X"30",
							X"30",
							X"38",--regim 8 bit, stranica 0
							X"06",--left, no shift
							X"0C" --on, kursora net
							
							);                        


begin

    spo <= ROM(conv_integer(a));

end syn;

	