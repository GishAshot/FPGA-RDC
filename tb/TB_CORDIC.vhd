LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY TB_CORDIC IS
end TB_CORDIC;

ARCHITECTURE SCHEMATIC OF TB_CORDIC IS

SIGNAL CLK_50MHZ : STD_LOGIC := '0';
SIGNAL X_IN      : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
SIGNAL Y_IN      : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
SIGNAL START     : STD_LOGIC := '0';
SIGNAL UGOL_OUT  : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
SIGNAL TEST_SIG  : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');

CONSTANT CLK_PERIOD : time := 20 ns;

BEGIN

uut: entity work.CORDIC
 PORT MAP (
    CLK_50MHZ => CLK_50MHZ,
    X_IN      => X_IN,
    Y_IN      => Y_IN,
    START     => START,
    UGOL_OUT  => UGOL_OUT,
    TEST_SIG  => TEST_SIG
 );

imp_CLK_GEN : process
begin
    CLK_50MHZ <= '0'; wait for CLK_PERIOD/2;
    CLK_50MHZ <= '1'; wait for CLK_PERIOD/2;
end process;

imp_STIMUL : process is
begin
    wait for 100 ns;

    X_IN  <= x"4000"; 
    Y_IN  <= (others => '0');
    START <= '1'; wait for CLK_PERIOD; START <= '0';
    wait for 500 ns;
    assert (signed(UGOL_OUT) < -32700) report "FAIL: 0 deg check" severity error;

    X_IN  <= x"4000"; 
    Y_IN  <= x"0200"; 
    START <= '1'; wait for CLK_PERIOD; START <= '0';
    wait for 500 ns;
    
    assert (signed(UGOL_OUT) > -32700) 
        report "FAIL: Small angle sensitivity check" severity error;

    report "TESTS COMPLETED" severity note;
    wait;
end process;

END SCHEMATIC;