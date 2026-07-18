LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;


ENTITY CORDIC IS
   PORT ( 
          CLK_50MHZ	:	IN	STD_LOGIC; 
			 X_IN : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			 Y_IN: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			 START : IN STD_LOGIC;
			 UGOL_OUT : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			 TEST_SIG : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
          );

end CORDIC;

ARCHITECTURE SCHEMATIC OF CORDIC IS
	
		component ROM_ARCTAN is
  port (

		CNT_ITERATION_IN: IN std_logic_VECTOR(3 downto 0);
		ROM_ARCTAN_OUT: OUT std_logic_VECTOR(15 downto 0)
	);
	end component;
--------------------------------------------------------------------------------------
-- SIGNAL
--------------------------------------------------------------------------------------
	SIGNAL CORDIC_EN:	STD_LOGIC;
	SIGNAL CNT_ITERATION : INTEGER range 0 to 15 := 0;
	SIGNAL ATAN_VAL : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL ATAN_VAL_S : signed (15 DOWNTO 0);
	SIGNAL X_REG : signed (15 DOWNTO 0) := (others => '0');
	SIGNAL Y_REG : signed (15 DOWNTO 0) := (others => '0');
	SIGNAL Z_REG : signed (15 DOWNTO 0) := (others => '0');
	SIGNAL X_START : signed (15 DOWNTO 0);
	SIGNAL Y_START : signed (15 DOWNTO 0);
	SIGNAL Z_START : signed (15 DOWNTO 0);
	SIGNAL x_shift : signed (15 DOWNTO 0);
	SIGNAL y_shift : signed (15 DOWNTO 0);
	SIGNAL x_next : signed (15 DOWNTO 0);
	SIGNAL y_next : signed (15 DOWNTO 0);
	SIGNAL z_next : signed (15 DOWNTO 0);
	SIGNAL rom_addr_vec : STD_LOGIC_VECTOR(3 DOWNTO 0);	
	SIGNAL UGOL_BUFF : signed (15 DOWNTO 0) := (others => '0');
	SIGNAL TEST_LCD : signed (15 DOWNTO 0) := (others => '0');
	
BEGIN

rom_addr_vec <= std_logic_vector(to_unsigned(CNT_ITERATION,4));

	imp_ROM_ARCTAN:ROM_ARCTAN
  port map(

		 CNT_ITERATION_IN => rom_addr_vec, --: IN std_logic_VECTOR(3 downto 0);
		 ROM_ARCTAN_OUT => ATAN_VAL --: OUT std_logic_VECTOR(15 downto 0)
	);

TEST_SIG(31 DOWNTO 21) <= (others => '0');
TEST_SIG(0) <= START;
TEST_SIG(1) <= CORDIC_EN;
TEST_SIG(2) <= rom_addr_vec(0);
TEST_SIG(3) <= rom_addr_vec(3);
TEST_SIG(4) <= Z_REG(15);
TEST_SIG(20 DOWNTO 5) <= std_logic_vector(TEST_LCD);

ATAN_VAL_S <= signed(ATAN_VAL);
UGOL_OUT <= (not UGOL_BUFF(15)) & std_logic_vector(UGOL_BUFF(14 downto 0));

X_START <= -signed(X_IN) when signed(X_IN) < 0 
else signed(X_IN);
Y_START <= -signed(Y_IN) when signed(X_IN) < 0 
else signed(Y_IN);
Z_START <= to_signed(32767,16) when (signed(X_IN) < 0 and signed(Y_IN) >= 0) 
else to_signed(-32768, 16) when (signed(X_IN) < 0 and signed(Y_IN) < 0) 
else (others => '0');

x_shift <= shift_right(X_REG, CNT_ITERATION);
y_shift <= shift_right(y_REG, CNT_ITERATION);

x_next <= X_REG + y_shift when Y_REG(15) = '0'
else X_REG - y_shift;
y_next <= Y_REG - x_shift when Y_REG(15) = '0'
else Y_REG + x_shift;
z_next <= Z_REG + ATAN_VAL_S when Y_REG(15) = '0'
else Z_REG - ATAN_VAL_S;

imp_CORDIC_EN : process (CLK_50MHZ) is
begin  -- process CORDIC ENABLE 
	if rising_edge(CLK_50MHZ) then     -- rising clock edge
		if CNT_ITERATION = 15  then
			CORDIC_EN <= '0';
		elsif  START = '1' then
			CORDIC_EN <= '1';
		end if;
	end if;
end process;

imp_CNT_ITERATION : process (CLK_50MHZ) is
begin  -- process COUNTER OF CORDIC ITERATION
	if rising_edge(CLK_50MHZ) then     -- rising clock edge
		if CORDIC_EN = '0' then
			CNT_ITERATION <= 0;
		else 
				CNT_ITERATION <= CNT_ITERATION + 1;
		end if;
	end if;
end process;

imp_X_REG : process (CLK_50MHZ) is
begin  -- process X REGISTER
	if rising_edge(CLK_50MHZ) then     -- rising clock edge
		if START = '1' then
			X_REG <= X_START;
		elsif CORDIC_EN = '1' then
			X_REG <= x_next;
		end if;
	end if;
end process;

imp_Y_REG : process (CLK_50MHZ) is
begin  -- process Y REGISTER 
	if rising_edge(CLK_50MHZ) then     -- rising clock edge
		if START = '1' then
			Y_REG <= Y_START;
		elsif CORDIC_EN = '1' then
			Y_REG <= y_next;
		end if;
	end if;
end process;

imp_Z_REG : process (CLK_50MHZ) is
begin  -- process Z REGISTER
	if rising_edge(CLK_50MHZ) then     -- rising clock edge
		if START = '1' then
			Z_REG <= Z_START;	
		elsif CORDIC_EN = '1' then
			Z_REG <= z_next;
		end if;
	end if;
end process;

imp_UGOL_BUFF : process (CLK_50MHZ) is
begin  -- process Z REGISTER
	if rising_edge(CLK_50MHZ) then     -- rising clock edge
		if CNT_ITERATION = 15 then
			UGOL_BUFF <= z_next;
			TEST_LCD <= x_next;
		end if;
	end if;
end process;

END SCHEMATIC;