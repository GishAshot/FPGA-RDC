library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rom_hex is
	port (
	a: IN std_logic_VECTOR(3 downto 0);
	spo: OUT std_logic_VECTOR(7 downto 0));
end rom_hex;


architecture syn of rom_hex is
    type rom_type is array (0 to 15) of std_logic_vector (7 downto 0);                 
    signal ROM : rom_type:= (
							X"30",--0
							X"31",--1
							X"32",--2
							X"33",--3
							X"34",--4
							X"35",--5
							X"36",--6
							X"37",--7
							X"38",--8
							X"39",--9
							X"41",--A
							X"42",--B
							X"43",--C
							X"44",--D
							X"45",--E
							X"46" --F 
							
							);                        


begin

    spo <= ROM(conv_integer(a));

end syn;

	