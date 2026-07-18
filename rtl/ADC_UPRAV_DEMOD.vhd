LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


ENTITY ADC_UPRAV_DEMOD IS
   PORT ( 
				CLK_50MHZ	:	IN	STD_LOGIC;
				DDS_POLAR_SHIFTED: IN STD_LOGIC;
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

end ADC_UPRAV_DEMOD;

ARCHITECTURE SCHEMATIC OF ADC_UPRAV_DEMOD IS
--------------------------------------------------------------------------------------
-- SIGNAL
--------------------------------------------------------------------------------------
	SIGNAL CNT_ADC_tCLK : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL CNT_ADC_tCLK_Z:	STD_LOGIC;
	SIGNAL CNT_CLB : STD_LOGIC_VECTOR(7 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 8);
	SIGNAL ADC0_OUTCLK_SIG:	STD_LOGIC;
	SIGNAL ADC0_OUTCLK_SIG_Z:	STD_LOGIC;
	SIGNAL SIN_DAT_IN: STD_LOGIC_VECTOR (13 DOWNTO 0);
	SIGNAL SIN_DAT_IN_BUFF: STD_LOGIC_VECTOR (13 DOWNTO 0);
	SIGNAL ADC1_OUTCLK_SIG:	STD_LOGIC;
	SIGNAL ADC1_OUTCLK_SIG_Z:	STD_LOGIC;
	SIGNAL COS_DAT_IN: STD_LOGIC_VECTOR (13 DOWNTO 0);
	SIGNAL COS_DAT_IN_BUFF: STD_LOGIC_VECTOR (13 DOWNTO 0);
	SIGNAL DDS_ZNAK_Z : STD_LOGIC;
	SIGNAL CNT_ADC_LATCH_DELAY_EN : STD_LOGIC;
	SIGNAL CNT_ADC_LATCH_DELAY: STD_LOGIC_VECTOR (12 DOWNTO 0);
	SIGNAL ADC_DATA_LATCH: STD_LOGIC;
	SIGNAL ADC_SIN_SIGNED: SIGNED (13 DOWNTO 0);
	SIGNAL DEMODULATED_SIN_DATA: SIGNED (13 DOWNTO 0);
	SIGNAL ADC_SIN_DATA_ACCUM_REG: SIGNED (31 DOWNTO 0) := (others => '0');
	SIGNAL DISPLAY_SIN_VALUE: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL ADC_SIN_BUFF: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL ADC_COS_SIGNED: SIGNED (13 DOWNTO 0);
	SIGNAL DEMODULATED_COS_DATA: SIGNED (13 DOWNTO 0);
	SIGNAL ADC_COS_DATA_ACCUM_REG: SIGNED (31 DOWNTO 0) := (others => '0');
	SIGNAL DISPLAY_COS_VALUE: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL ADC_COS_BUFF: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL DDS_POLAR_SHIFTED_Z: STD_LOGIC;
	SIGNAL ADC_SIN_MIN_SIG :  STD_LOGIC_VECTOR (13 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(8191, 14);
	SIGNAL ADC_SIN_MAX_SIG :  STD_LOGIC_VECTOR (13 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(8192, 14);
	SIGNAL ADC_COS_MIN_SIG :  STD_LOGIC_VECTOR (13 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(8191, 14);
	SIGNAL ADC_COS_MAX_SIG : STD_LOGIC_VECTOR (13 DOWNTO 0)  := CONV_STD_LOGIC_VECTOR(8192, 14);	
	SIGNAL CNT_ZDAT : STD_LOGIC_VECTOR (26 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 27);
	SIGNAL CNT_ZDAT_Z : STD_LOGIC;
	SIGNAL CNT_ZDAT_RDY : STD_LOGIC := '0';
	
BEGIN

TEST_SIG(11 DOWNTO 5) <= CONV_STD_LOGIC_VECTOR(0, 7);
TEST_SIG(0) <= COS_DAT_IN_BUFF(13);
TEST_SIG(1) <= DDS_POLAR_SHIFTED;
TEST_SIG(2) <= SIN_DAT_IN_BUFF(13);
TEST_SIG(3) <= SIN_DAT_IN_BUFF(1);
TEST_SIG(4) <= SIN_DAT_IN_BUFF(0);

ADC_SIN_SIGNED <= SIGNED(SIN_DAT_IN_BUFF(13 DOWNTO 0));
ADC_SIN <= ADC_SIN_BUFF;
ADC_COS_SIGNED <= SIGNED(COS_DAT_IN_BUFF(13 DOWNTO 0));
ADC_COS <= ADC_COS_BUFF;
ADC_CLB <= CNT_CLB(6);
ADC_tCLK <= CNT_ADC_tCLK(2);
SIN_DAT_IN <= ADC0_SIN_DATA;
COS_DAT_IN <= ADC1_COS_DATA;
START_CORDIC <= NOT DDS_POLAR_SHIFTED_Z AND DDS_POLAR_SHIFTED;
ADC_SIN_MIN <= '0' & '0' & ADC_SIN_MIN_SIG;
ADC_SIN_MAX <= '0' & '0' & ADC_SIN_MAX_SIG;
ADC_COS_MIN <= '0' & '0' & ADC_COS_MIN_SIG;
ADC_COS_MAX <= '0' & '0' & ADC_COS_MAX_SIG;

imp_CNT_ADC_tCLK : process (CLK_50MHZ) is
begin  -- process counter for adc sync 
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
			CNT_ADC_tCLK_Z <= CNT_ADC_tCLK(2);
			CNT_ADC_tCLK <= CNT_ADC_tCLK + 1;
	end if;
end process;

imp_CNT_ZDAT_RDY : process (CLK_50MHZ) is
begin  -- process counter for adc sync 
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
			CNT_ZDAT_Z <= CNT_ZDAT(26);
			CNT_ZDAT <= CNT_ZDAT + 1;
			IF (CNT_ZDAT_Z = '1') AND CNT_ZDAT(26) = '0' THEN
				CNT_ZDAT_RDY <= '1';
			END IF;
	end if;
end process;

imp_CNT_CLB : process (CLK_50MHZ) is
begin  -- process counter for adc calibration
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge 
		if CNT_CLB(7) = '0' then
			if (CNT_ADC_tCLK_Z = '0') and (CNT_ADC_tCLK(2) = '1') then
				CNT_CLB <= CNT_CLB + 1;
			end if;
		end if;
	end if;
end process;
		
	imp_DDS_POLAR_SHIFTED_Z : process (CLK_50MHZ) is
begin  -- process DDS_POLAR_SHIFTED_Z
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		DDS_POLAR_SHIFTED_Z <= DDS_POLAR_SHIFTED;
	end if;
end process;
		
imp_SIN_DAT_IN_BUFF : process (CLK_50MHZ) is
begin  -- process sin data catch 
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		ADC0_OUTCLK_SIG <= ADC0_OUTCLK;
		ADC0_OUTCLK_SIG_Z <= ADC0_OUTCLK_SIG;
		if (ADC0_OUTCLK_SIG_Z = '1') and (ADC0_OUTCLK_SIG = '0') then
			SIN_DAT_IN_BUFF <= SIN_DAT_IN;
			IF CNT_ZDAT_RDY = '1' THEN
				if signed(SIN_DAT_IN_BUFF) < signed(ADC_SIN_MIN_SIG) then
					ADC_SIN_MIN_SIG <= SIN_DAT_IN_BUFF;
				end if;
				if signed(SIN_DAT_IN_BUFF) > signed(ADC_SIN_MAX_SIG) then
					ADC_SIN_MAX_SIG <= SIN_DAT_IN_BUFF;
			end if;
			END IF;
		end if;
	end if;
end process;
	
imp_COS_DAT_IN_BUFF : process (CLK_50MHZ) is
begin  -- process cos data catch 
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		ADC1_OUTCLK_SIG <= ADC1_OUTCLK;
		ADC1_OUTCLK_SIG_Z <= ADC1_OUTCLK_SIG;
		if (ADC1_OUTCLK_SIG = '0') and (ADC1_OUTCLK_SIG_Z = '1') then
			COS_DAT_IN_BUFF <= COS_DAT_IN;
			IF CNT_ZDAT_RDY = '1' THEN
				if signed(COS_DAT_IN_BUFF) < signed(ADC_COS_MIN_SIG) then
					ADC_COS_MIN_SIG <= COS_DAT_IN_BUFF;
				end if;
				if signed(COS_DAT_IN_BUFF) > signed(ADC_COS_MAX_SIG) then
					ADC_COS_MAX_SIG <= COS_DAT_IN_BUFF;
				end if;
			END IF;
		end if;
	end if;
end process;

	imp_DEMODULATED_SIN_DATA : process (CLK_50MHZ) is
begin  -- process adc SIN data demodulation
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		if DDS_POLAR_SHIFTED = '0' then
			DEMODULATED_SIN_DATA <= ADC_SIN_SIGNED;
		else 
			DEMODULATED_SIN_DATA <= -ADC_SIN_SIGNED;
		end if;
	end if;
end process;

	imp_ADC_SIN_DATA_ACCUM_REG : process (CLK_50MHZ) is
begin  -- process adc SIN data filter
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		if (DDS_POLAR_SHIFTED_Z = '0') AND (DDS_POLAR_SHIFTED = '1') then
			DISPLAY_SIN_VALUE <= STD_LOGIC_VECTOR(ADC_SIN_DATA_ACCUM_REG(26 DOWNTO 11));
			ADC_SIN_DATA_ACCUM_REG <= (OTHERS => '0');
		elsif (ADC0_OUTCLK_SIG_Z = '0') and (ADC0_OUTCLK_SIG = '1') then
			ADC_SIN_DATA_ACCUM_REG <= ADC_SIN_DATA_ACCUM_REG + resize(DEMODULATED_SIN_DATA,32);
		end if;
	end if;
end process;

imp_ADC_SIN_BUFF : process (CLK_50MHZ) is
begin  -- process ADC SIN DATA DELAY FOR LCD
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		if (DDS_POLAR_SHIFTED_Z = '0') AND (DDS_POLAR_SHIFTED = '1') then
			ADC_SIN_BUFF <= DISPLAY_SIN_VALUE;
		end if;
	end if;
end process;

	imp_DEMODULATED_COS_DATA : process (CLK_50MHZ) is
begin  -- process adc COS data demodulation
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		if DDS_POLAR_SHIFTED = '0' then
			DEMODULATED_COS_DATA <= ADC_COS_SIGNED;
		else 
			DEMODULATED_COS_DATA <= -ADC_COS_SIGNED;
		end if;
	end if;
end process;

	imp_ADC_COS_DATA_ACCUM_REG : process (CLK_50MHZ) is
begin  -- process adc COS data filter
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		if (DDS_POLAR_SHIFTED_Z = '0') AND (DDS_POLAR_SHIFTED = '1') then
			DISPLAY_COS_VALUE <= STD_LOGIC_VECTOR(ADC_COS_DATA_ACCUM_REG(26 DOWNTO 11));
			ADC_COS_DATA_ACCUM_REG <= (OTHERS => '0');
		elsif (ADC1_OUTCLK_SIG_Z = '0') and (ADC1_OUTCLK_SIG = '1') then
			ADC_COS_DATA_ACCUM_REG <= ADC_COS_DATA_ACCUM_REG + resize(DEMODULATED_COS_DATA,32);
		end if;
	end if;
end process;

imp_ADC_COS_BUFF : process (CLK_50MHZ) is
begin  -- process ADC COS DATA DELAY FOR LCD
	if CLK_50MHZ'event and CLK_50MHZ = '1' then     -- rising clock edge
		if (DDS_POLAR_SHIFTED_Z = '0') AND (DDS_POLAR_SHIFTED = '1') then
			ADC_COS_BUFF <= DISPLAY_COS_VALUE;
		end if;
	end if;
end process;

END SCHEMATIC;