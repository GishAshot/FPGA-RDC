library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ROM_ARCTAN is
	port (
	CNT_ITERATION_IN: IN std_logic_VECTOR(3 downto 0);
	ROM_ARCTAN_OUT: OUT std_logic_VECTOR(15 downto 0)
	);
end ROM_ARCTAN;


architecture syn of ROM_ARCTAN is
    type rom_type is array (0 to 15) of std_logic_vector (15 downto 0);                 
    signal ROM : rom_type:= (
X"2000",
X"12E4",
X"09FB",
X"0511",
X"028B",
X"0146",
X"00A3",
X"0051",
X"0029",
X"0014",
X"000A",
X"0005",
X"0003",
X"0001",
X"0001",
X"0000"
						);                        


begin

    ROM_ARCTAN_OUT <= ROM(conv_integer(CNT_ITERATION_IN));

end syn;

	