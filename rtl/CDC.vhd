LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CDC_SYNC IS
 PORT ( 
    CLK_50MHZ : IN STD_LOGIC;
    RES       : IN STD_LOGIC;
    SIG_IN    : IN STD_LOGIC;
    SIG_OUT   : OUT STD_LOGIC
 );
end CDC_SYNC;

ARCHITECTURE SCHEMATIC OF CDC_SYNC IS

SIGNAL SYNC_REG : STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');

BEGIN

imp_CDC_SYNC : process (CLK_50MHZ) is
begin
    if rising_edge(CLK_50MHZ) then
        if RES = '1' then
            SYNC_REG <= (others => '0');
        else
            SYNC_REG(0) <= SIG_IN;
            SYNC_REG(1) <= SYNC_REG(0);
        end if;
    end if;
end process;

SIG_OUT <= SYNC_REG(1);

END SCHEMATIC;