LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



ENTITY MAGIST IS
   PORT ( 
          CLK	:	IN	STD_LOGIC;  
			 ---------ram_cs----------------------------------
			 CE1 : OUT  STD_LOGIC;
			 CE2 : OUT  STD_LOGIC;
			 ---------PWM_SIN-------------------------------------
			 SIN_P: OUT STD_LOGIC;
			 SIN_N: OUT STD_LOGIC;
			 ---------ADC-------------------------------------
			 ADC0_OUTCLK : IN STD_LOGIC;
			 ADC0_SIN_DATA : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
			 ADC1_OUTCLK : IN STD_LOGIC;
			 ADC1_COS_DATA : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
			 ADC_CLB : OUT STD_LOGIC;
			 ADC_tCLK : OUT STD_LOGIC;
			 --------LCD contr----------------------------------
			 LCD_data  : out  STD_LOGIC_VECTOR(7 downto 0);
			 LCD_RS    : out  STD_LOGIC;
			 LCD_EN    : out  STD_LOGIC;
			 ---------test-------------------------------------
			 TEST_1 : OUT STD_LOGIC;
			 TEST_2 : OUT STD_LOGIC;
			 TEST_3 : OUT STD_LOGIC;
			 TEST_4 : OUT STD_LOGIC;
			 TEST_5 : OUT STD_LOGIC
          );

end MAGIST;

ARCHITECTURE SCHEMATIC OF MAGIST IS
	
	component dcm_pitanie is
	  port (

		Clk_in : in  std_logic;
		
		Clk_out   : out  std_logic;
		Clk2x_out : out  std_logic

	    );
		 
	end component;
	
	component DDS is
  port (

      CLK_50MHZ	:	IN	STD_LOGIC; 
		RES : IN STD_LOGIC;
		DDS_OUT : OUT STD_LOGIC;
		DDS_POLAR_SHIFTED : OUT STD_LOGIC;
		DDS_POLAR : OUT STD_LOGIC;
		TEST_SIG : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
	end component;
	
		component ADC_UPRAV_DEMOD is
  port (
		
		CLK_50MHZ	:	IN	STD_LOGIC;
		DDS_POLAR_SHIFTED : IN STD_LOGIC;
		ADC0_OUTCLK : IN STD_LOGIC;
		ADC0_SIN_DATA : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
		ADC1_OUTCLK : IN STD_LOGIC;
		ADC1_COS_DATA : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
		ADC_CLB : OUT STD_LOGIC;
		ADC_tCLK : OUT STD_LOGIC;
		ADC_SIN : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		ADC_COS : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		START_CORDIC : OUT STD_LOGIC;
		ADC_SIN_MIN : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		ADC_SIN_MAX : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		ADC_COS_MIN : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		ADC_COS_MAX : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		TEST_SIG : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
	end component;
	
		component CORDIC is
  port (

          CLK_50MHZ	:	IN	STD_LOGIC; 
			 X_IN : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			 Y_IN: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			 START : IN STD_LOGIC;
			 UGOL_OUT : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			 TEST_SIG : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	end component;
	
	component lcd_contr
    Port ( 
			CLK_50MHZ : in  STD_LOGIC;
			DATA_A : in STD_LOGIC_VECTOR(15 downto 0);
			DATA_B : in STD_LOGIC_VECTOR(15 downto 0);
			DATA_C : in STD_LOGIC_VECTOR(15 downto 0);
			DATA_D : in STD_LOGIC_VECTOR(15 downto 0);
			DATA_E : in STD_LOGIC_VECTOR(15 downto 0);
			DATA_F : in STD_LOGIC_VECTOR(15 downto 0);
			LCD_data : out  STD_LOGIC_VECTOR(7 downto 0);
			LCD_RS : out  STD_LOGIC;
			LCD_RW : out  STD_LOGIC;
			LCD_EN : out  STD_LOGIC
			);
end component;
	
--------------------------------------------------------------------------------------
-- SIGNAL
--------------------------------------------------------------------------------------
	SIGNAL CLK_50MHZ	:	STD_LOGIC;
	SIGNAL CNT_R	:	STD_LOGIC_VECTOR (8 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 9);
	SIGNAL RES	:	STD_LOGIC;
	SIGNAL DIG_SIN	:	STD_LOGIC;
	SIGNAL DDS_POLAR_SHIFTED : STD_LOGIC;
	SIGNAL DDS_POLAR	:	STD_LOGIC;
	SIGNAL ADC_SIN	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL ADC_COS	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL LCD_D_A	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL LCD_D_B	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL LCD_D_C	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL LCD_D_D	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL LCD_D_E	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL LCD_D_F	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL START_CORDIC	:	STD_LOGIC;
	SIGNAL UGOL	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL TEST_SIG_CORDIC	:	STD_LOGIC_VECTOR (31 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 12);
	SIGNAL TEST_SIG_DDS	:	STD_LOGIC_VECTOR (11 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 12);
	SIGNAL TEST_SIG_ADC	:	STD_LOGIC_VECTOR (11 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 12);
	SIGNAL GND_BUS : std_logic_vector(15 downto 0);
	SIGNAL CNT_LCD_DELAY : STD_LOGIC_VECTOR(24 DOWNTO 0);
	SIGNAL CNT_LCD_DELAY_Z : STD_LOGIC;	
	SIGNAL LCD_SIN	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL LCD_COS	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL LCD_UGOL	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL LCD_TEST_CORDIC	:	STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ADC_SIN_MIN	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL ADC_SIN_MAX	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL ADC_COS_MIN	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL ADC_COS_MAX	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	
BEGIN

	imp_dcm_pitanie:dcm_pitanie
  port map(

	Clk_in => CLK,-- : in  std_logic;
	Clk_out => CLK_50MHZ,--   : out  std_logic;
	Clk2x_out => open-- : out  std_logic
	--Clk2x_out => clk100MHz-- : out  std_logic
	);
	
	imp_DDS:DDS
  port map(

      CLK_50MHZ => CLK_50MHZ, --:	IN	STD_LOGIC; 
		RES => RES, --: IN STD_LOGIC;
		DDS_OUT => DIG_SIN, --: OUT STD_LOGIC;
		DDS_POLAR_SHIFTED => DDS_POLAR_SHIFTED, --: OUT STD_LOGIC;
		DDS_POLAR => DDS_POLAR, --: OUT STD_LOGIC;
		TEST_SIG => TEST_SIG_DDS --: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
	
		imp_CORDIC:CORDIC
  port map(

          CLK_50MHZ => CLK_50MHZ,	--:	IN	STD_LOGIC; 
			 X_IN => ADC_COS, --: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			 Y_IN => ADC_SIN,--: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			 START => START_CORDIC, --: IN STD_LOGIC;
			 UGOL_OUT => UGOL, --: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			 TEST_SIG => TEST_SIG_CORDIC --: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
	
	imp_ADC_UPRAV_DEMOD:ADC_UPRAV_DEMOD
  port map (
  
		CLK_50MHZ => CLK_50MHZ,	--:	IN	STD_LOGIC;
		DDS_POLAR_SHIFTED => DDS_POLAR_SHIFTED, --: IN STD_LOGIC;
		ADC0_OUTCLK => ADC0_OUTCLK, --: IN STD_LOGIC;
		ADC0_SIN_DATA => ADC0_SIN_DATA, --: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
		ADC1_OUTCLK => ADC1_OUTCLK, --: IN STD_LOGIC;
		ADC1_COS_DATA => ADC1_COS_DATA, --: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
		ADC_CLB => ADC_CLB, -- : OUT STD_LOGIC;
		ADC_tCLK => ADC_tCLK, -- : OUT STD_LOGIC;
		ADC_SIN => ADC_SIN, --: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		ADC_COS => ADC_COS, --: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		START_CORDIC => START_CORDIC, --: OUT STD_LOGIC;
		ADC_SIN_MIN => ADC_SIN_MIN, --: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		ADC_SIN_MAX => ADC_SIN_MAX, --: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		ADC_COS_MIN => ADC_COS_MIN, --: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		ADC_COS_MAX => ADC_COS_MAX, --: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		TEST_SIG => TEST_SIG_ADC -- : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);

	imp_lcd_contr: lcd_contr
    Port map( 
		CLK_50MHZ => CLK_50MHZ,-- : in  STD_LOGIC;
		DATA_A => LCD_D_A,-- : in STD_LOGIC_VECTOR(15 downto 0);
		DATA_B => LCD_D_B,-- : in STD_LOGIC_VECTOR(15 downto 0);
		DATA_C => LCD_D_C,-- : in STD_LOGIC_VECTOR(15 downto 0);
		DATA_D => LCD_D_D,-- : in STD_LOGIC_VECTOR(15 downto 0);
		DATA_E => LCD_D_E,-- : in STD_LOGIC_VECTOR(15 downto 0);
		DATA_F => LCD_D_F,-- : in STD_LOGIC_VECTOR(15 downto 0);
		LCD_data => LCD_data,-- : out  STD_LOGIC_VECTOR(7 downto 0)
		LCD_RS => LCD_RS,-- : out  STD_LOGIC;
		LCD_RW => open,--LCD_RW,-- : out  STD_LOGIC;
		LCD_EN => LCD_EN-- : out  STD_LOGIC;
	);

	LCD_D_C(15 downto 0) <=  GND_BUS;
	LCD_D_D(15 downto 0) <=  GND_BUS;
	LCD_D_E(15 downto 0) <=  GND_BUS;
	LCD_D_F(15 downto 0) <=  UGOL;
	LCD_D_A(15 downto 0) <=  LCD_SIN;
	LCD_D_B(15 downto 0) <=  LCD_COS;
	
	CE1 <= '1';
	CE2 <= '1';
	
	SIN_P <= DIG_SIN and not DDS_POLAR;
	SIN_N <= DIG_SIN and DDS_POLAR;
	
	TEST_1 <= DDS_POLAR;
	TEST_2 <= DDS_POLAR_SHIFTED;
	TEST_3 <= TEST_SIG_ADC(0);
	TEST_4 <= TEST_SIG_ADC(2);
	TEST_5 <= TEST_SIG_CORDIC(4);
	
	RES <= CNT_R(8);
	
	
	imp_RES : process (CLK_50MHZ) is
begin  -- process Reset
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		if CNT_R(8) = '0' then
			CNT_R <= CNT_R + 1;
		end if;
	end if;
end process;


imp_CNT_LCD_DELAY : process (CLK_50MHZ) is
begin  -- process counter for LCD DELAY
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
			CNT_LCD_DELAY_Z <= CNT_LCD_DELAY(21);
			CNT_LCD_DELAY <= CNT_LCD_DELAY + 1;
	end if;
end process;
	

imp_LCD_DATA : process (CLK_50MHZ) is
begin  -- process counter for LCD DELAY
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		if (CNT_LCD_DELAY_Z = '1') and (CNT_LCD_DELAY(21) = '0') then
			LCD_SIN <= ADC_SIN;
			LCD_COS<= ADC_COS;
			LCD_UGOL <= UGOL;
			LCD_TEST_CORDIC <= TEST_SIG_CORDIC;
		end if;
	end if;
end process;

END SCHEMATIC;
