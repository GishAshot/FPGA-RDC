LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;


ENTITY DDS IS
   PORT ( 
          CLK_50MHZ	:	IN	STD_LOGIC; 
			 RES : IN STD_LOGIC;
			 DDS_OUT : OUT STD_LOGIC;
			 DDS_POLAR_SHIFTED : OUT STD_LOGIC;
			 DDS_POLAR : OUT STD_LOGIC;
			 TEST_SIG : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
          );

end DDS;

ARCHITECTURE SCHEMATIC OF DDS IS
	
		component WIDTH_LUT is
  port (

		WIDTH_LUT_D_IN: IN std_logic_VECTOR(5 downto 0);
		WIDTH_LUT_D_OUT: OUT std_logic_VECTOR(7 downto 0)
	);
	end component;
--------------------------------------------------------------------------------------
-- SIGNAL
--------------------------------------------------------------------------------------
	SIGNAL CNT : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL PWM_IMP:	STD_LOGIC;
	SIGNAL CNT_DDS : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL ADDR_REG : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL WIDTH_COMP : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL PHASE_DELAYED : STD_LOGIC_VECTOR(15 DOWNTO 0);
	CONSTANT PHASE_SHIFT : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"09E0";
	
BEGIN

	imp_WIDTH_LUT:WIDTH_LUT
  port map(

		 WIDTH_LUT_D_IN => ADDR_REG, --: IN std_logic_VECTOR(1 downto 0);
		 WIDTH_LUT_D_OUT => WIDTH_COMP --: OUT std_logic_VECTOR(7 downto 0)
	);

TEST_SIG(11 DOWNTO 5) <= CONV_STD_LOGIC_VECTOR(0, 7);
TEST_SIG(0) <= WIDTH_COMP(7);
TEST_SIG(1) <= PWM_IMP;
TEST_SIG(2) <= PWM_IMP;
TEST_SIG(3) <= PWM_IMP;
TEST_SIG(4) <= PWM_IMP;


DDS_OUT <= PWM_IMP;
DDS_POLAR <= CNT_DDS(15);

imp_CNT_DDS : process (CLK_50MHZ) is
begin  -- process counter 
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge 
			CNT_DDS <= CNT_DDS + 1;
	end if;
end process;


imp_PWM_IMP : process (CLK_50MHZ) is
begin  -- process PWM control
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge 
		if CNT_DDS(7 DOWNTO 0) <=  WIDTH_COMP then
			PWM_IMP <= '1';
		else
			PWM_IMP <= '0';
		end if;
	end if;
end process;
	
imp_ADDR_REG : process (CLK_50MHZ) is
begin  -- process convertion of adress for WIDTH_LUT
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge 
		if CNT_DDS(14)  = '0' then
			ADDR_REG <= CNT_DDS(13 DOWNTO 8);
		else 
			ADDR_REG <= not CNT_DDS(13 DOWNTO 8);
		end if;
	end if;
end process;	
	
	imp_DDS_POLAR_SHIFTED : process (CLK_50MHZ) is
begin  -- process PHASE OF PWM DELAY
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge 
		PHASE_DELAYED <= CNT_DDS + PHASE_SHIFT;
		DDS_POLAR_SHIFTED <= PHASE_DELAYED(15);
	end if;
end process;
	
END SCHEMATIC;

