library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity WIDTH_LUT is
	port (
	WIDTH_LUT_D_IN: IN std_logic_VECTOR(5 downto 0);
	WIDTH_LUT_D_OUT: OUT std_logic_VECTOR(7 downto 0)
	);
end WIDTH_LUT;


architecture syn of WIDTH_LUT is
    type rom_type is array (0 to 63) of std_logic_vector (7 downto 0);                 
    signal ROM : rom_type:= (
X"00",
X"03",
X"06",
X"08",
X"0B",
X"0E",
X"11",
X"13",
X"16",
X"19",
X"1C",
X"1E",
X"21",
X"24",
X"26",
X"29",
X"2C",
X"2E",
X"31",
X"33",
X"36",
X"38",
X"3A",
X"3D",
X"3F",
X"41",
X"44",
X"46",
X"48",
X"4A",
X"4C",
X"4E",
X"50",
X"52",
X"54",
X"56",
X"58",
X"59",
X"5B",
X"5D",
X"5E",
X"60",
X"61",
X"62",
X"64",
X"65",
X"66",
X"67",
X"68",
X"69",
X"6A",
X"6B",
X"6C",
X"6D",
X"6D",
X"6E",
X"6E",
X"6F",
X"6F",
X"6F",
X"70",
X"70",
X"70",
X"70"
						);                        


begin

    WIDTH_LUT_D_OUT <= ROM(conv_integer(WIDTH_LUT_D_IN));

end syn;

	