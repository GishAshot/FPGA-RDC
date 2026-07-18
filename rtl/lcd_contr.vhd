library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity lcd_contr is
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
			LCD_EN : out  STD_LOGIC;
			test : out STD_LOGIC
			);
end lcd_contr;

architecture imp of lcd_contr is

component rom_lcd_init is
	port (
	a: IN std_logic_VECTOR(2 downto 0);
	spo: OUT std_logic_VECTOR(7 downto 0));
end component;

component rom_hex is
	port (
	a: IN std_logic_VECTOR(3 downto 0);
	spo: OUT std_logic_VECTOR(7 downto 0));
end component;

	signal gnd_bus                 : std_logic_vector(15 downto 0);
	signal CNT_razv                : std_logic_vector(11 downto 0) :=(others => '0');
	signal CNT_EN_p                : std_logic_vector(4 downto 0) :=(others => '0');
	signal CNT_init                : std_logic_vector(10 downto 0);
	signal CNT_5ms                 : std_logic_vector(2 downto 0);
	signal CNT_ram                 : std_logic_vector(6 downto 0);
	signal D_A                     : std_logic_vector(15 downto 0);
	signal D_B                     : std_logic_vector(15 downto 0);
	signal D_C                     : std_logic_vector(15 downto 0);
	signal D_D                     : std_logic_vector(15 downto 0);
	signal D_E                     : std_logic_vector(15 downto 0);
	signal D_F                     : std_logic_vector(15 downto 0);
	signal D                       : std_logic_vector(3 downto 0);
	signal HEX                     : std_logic_VECTOR(7 downto 0);
	signal LCD_work_data           : std_logic_VECTOR(7 downto 0);
	signal LCD_init_data           : std_logic_VECTOR(7 downto 0);
	
	signal LD_EN_p                 : std_logic;
	signal EN_p                    : std_logic;
	signal STR_5ms                 : std_logic;
	signal EN_5ms                  : std_logic;
	signal MX_EN_p                 : std_logic;
	signal EN_p_out                : std_logic;
	signal MX_init                 : std_logic;
	signal RS_mx                   : std_logic;
	signal z1                      : std_logic;
	signal z2                      : std_logic;
	signal z3                      : std_logic;

begin

gnd_bus(15 downto 0) <= (others => '0');

test <= not MX_EN_p; 

LCD_RW <= '0';--vsegda zapis
LCD_EN <= EN_p_out;

LCD_data(7 downto 0)  <=  LCD_init_data(7 downto 0) when MX_init = '0' else LCD_work_data(7 downto 0);
LCD_RS <= '0' when MX_init = '0' else  RS_mx;

imp_IN_lch : process(CLK_50MHZ)
begin
	if rising_edge(CLK_50MHZ) then
		if LD_EN_p = '1' and CNT_ram(6) = '1' then
			D_A(15 downto 0) <= DATA_A(15 downto 0);
			D_B(15 downto 0) <= DATA_B(15 downto 0);
			D_C(15 downto 0) <= DATA_C(15 downto 0);
			D_D(15 downto 0) <= DATA_D(15 downto 0);
			D_E(15 downto 0) <= DATA_E(15 downto 0);
			D_F(15 downto 0) <= DATA_F(15 downto 0);
		end if;
	end if;
end process;


imp_CNT_razv : process(CLK_50MHZ)
begin
	if rising_edge(CLK_50MHZ) then
		if CNT_razv(11) = '1' then
			CNT_razv(11 downto 0) <= CONV_STD_LOGIC_VECTOR(0, 12);
		else
			CNT_razv <= CNT_razv + 1;
		end if;
	end if;
end process;

LD_EN_p <= CNT_razv(11);


imp_CNT_init : process(CLK_50MHZ)
begin
	if rising_edge(CLK_50MHZ) then
		if CNT_init(10) = '0' then
			if LD_EN_p = '1' then
				CNT_init <= CNT_init + 1;
			end if;
		end if;
		if CNT_5ms(2 downto 0) > CONV_STD_LOGIC_VECTOR(1, 3) then
			EN_5ms <= '1';
		else
			EN_5ms <= '0';
		end if;
		if CNT_init(6 downto 0) = CONV_STD_LOGIC_VECTOR(126, 7) then
			STR_5ms <= '1';
		else
			STR_5ms <= '0';
		end if;
		MX_EN_p <= CNT_init(10);
		EN_p <= (not MX_EN_p and LD_EN_p and EN_5ms and STR_5ms) or (MX_EN_p and LD_EN_p);
	end if;
end process;

MX_init <= CNT_init(10);
CNT_5ms(2 downto 0) <= CNT_init(9 downto 7);


imp_CNT_EN_p : process(CLK_50MHZ)
begin
	if rising_edge(CLK_50MHZ) then
		if EN_p = '1' then
			CNT_EN_p(4 downto 0) <= (others => '1');
		elsif CNT_EN_p(4) = '1' then
			CNT_EN_p <= CNT_EN_p - 1;
		end if;
		z1 <= CNT_EN_p(4);
		z2 <= z1;
		z3 <= z2;
	end if;
end process;


EN_p_out <= z3;

imp_rom_lcd_init: rom_lcd_init
	port map(
	a => CNT_5ms(2 downto 0),--: IN std_logic_VECTOR(2 downto 0);
	spo => LCD_init_data(7 downto 0)--: OUT std_logic_VECTOR(7 downto 0)
	);

imp_CNT_ram : process(CLK_50MHZ)
begin
	if rising_edge(CLK_50MHZ) then
		if LD_EN_p = '1' and CNT_ram(6) = '1' then
			CNT_ram(5 downto 0) <= CONV_STD_LOGIC_VECTOR(32, 6);
			CNT_ram(6) <= '0';
		elsif LD_EN_p = '1' then
			CNT_ram <= CNT_ram - 1;
		end if;
	end if;
end process;

imp_MX_nimb :process
begin
   case CNT_ram(5 downto 0) is
      when CONV_STD_LOGIC_VECTOR(32, 6) => D(3 downto 0) <= D_B(15 downto 12);
      when CONV_STD_LOGIC_VECTOR(31, 6) => D(3 downto 0) <= D_B(11 downto 8);
      when CONV_STD_LOGIC_VECTOR(30, 6) => D(3 downto 0) <= D_B(7 downto 4);
      when CONV_STD_LOGIC_VECTOR(29, 6) => D(3 downto 0) <= D_B(3 downto 0);
      when CONV_STD_LOGIC_VECTOR(26, 6) => D(3 downto 0) <= D_F(15 downto 12);
      when CONV_STD_LOGIC_VECTOR(25, 6) => D(3 downto 0) <= D_F(11 downto 8);
      when CONV_STD_LOGIC_VECTOR(24, 6) => D(3 downto 0) <= D_F(7 downto 4);
      when CONV_STD_LOGIC_VECTOR(23, 6) => D(3 downto 0) <= D_F(3 downto 0);
      when CONV_STD_LOGIC_VECTOR(20, 6) => D(3 downto 0) <= D_D(15 downto 12);
      when CONV_STD_LOGIC_VECTOR(19, 6) => D(3 downto 0) <= D_D(11 downto 8);
      when CONV_STD_LOGIC_VECTOR(18, 6) => D(3 downto 0) <= D_D(7 downto 4);
      when CONV_STD_LOGIC_VECTOR(17, 6) => D(3 downto 0) <= D_D(3 downto 0);
      when CONV_STD_LOGIC_VECTOR(15, 6) => D(3 downto 0) <= D_A(15 downto 12);
      when CONV_STD_LOGIC_VECTOR(14, 6) => D(3 downto 0) <= D_A(11 downto 8);
      when CONV_STD_LOGIC_VECTOR(13, 6) => D(3 downto 0) <= D_A(7 downto 4);
      when CONV_STD_LOGIC_VECTOR(12, 6) => D(3 downto 0) <= D_A(3 downto 0);
      when CONV_STD_LOGIC_VECTOR(9, 6)  => D(3 downto 0) <= D_E(15 downto 12);
      when CONV_STD_LOGIC_VECTOR(8, 6)  => D(3 downto 0) <= D_E(11 downto 8);
      when CONV_STD_LOGIC_VECTOR(7, 6)  => D(3 downto 0) <= D_E(7 downto 4);
      when CONV_STD_LOGIC_VECTOR(6, 6)  => D(3 downto 0) <= D_E(3 downto 0);
      when CONV_STD_LOGIC_VECTOR(3, 6)  => D(3 downto 0) <= D_C(15 downto 12);
      when CONV_STD_LOGIC_VECTOR(2, 6)  => D(3 downto 0) <= D_C(11 downto 8);
      when CONV_STD_LOGIC_VECTOR(1, 6)  => D(3 downto 0) <= D_C(7 downto 4);
      when CONV_STD_LOGIC_VECTOR(0, 6)  => D(3 downto 0) <= D_C(3 downto 0);
      when others => D(3 downto 0) <= (others => '0');
   end case;
end process;

imp_rom_hex: rom_hex
	port map(
	a => D(3 downto 0),--: IN std_logic_VECTOR(3 downto 0);
	spo => HEX(7 downto 0)--: OUT std_logic_VECTOR(7 downto 0)
	);

imp_MX_out_data :process
begin
   case CNT_ram(5 downto 0) is
      when CONV_STD_LOGIC_VECTOR(32, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(31, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(30, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(29, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(26, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(25, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(24, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(23, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(20, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(19, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(18, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(17, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(15, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(14, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(13, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(12, 6) => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(9, 6)  => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(8, 6)  => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(7, 6)  => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(6, 6)  => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(3, 6)  => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(2, 6)  => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(1, 6)  => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(0, 6)  => LCD_work_data(7 downto 0) <= HEX(7 downto 0);
      when CONV_STD_LOGIC_VECTOR(63, 6) => LCD_work_data(7 downto 0) <= "10000000";--' '(0x80) 1stroka
      when CONV_STD_LOGIC_VECTOR(16, 6) => LCD_work_data(7 downto 0) <= "11000000";--' '(0xC0) 2stroka
      when others => LCD_work_data(7 downto 0) <= "00100000";--' '(0x20)
   end case;
end process;



imp_RS_mx :process
begin
   case CNT_ram(5 downto 0) is
      when CONV_STD_LOGIC_VECTOR(32, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(31, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(30, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(29, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(28, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(27, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(26, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(25, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(24, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(23, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(22, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(29, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(21, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(20, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(19, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(18, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(17, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(16, 6) => RS_mx <= '0';--com
      when CONV_STD_LOGIC_VECTOR(15, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(14, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(13, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(12, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(11, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(10, 6) => RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(9, 6) =>  RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(8, 6) =>  RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(7, 6) =>  RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(6, 6) =>  RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(5, 6) =>  RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(4, 6) =>  RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(3, 6) =>  RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(2, 6) =>  RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(1, 6) =>  RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(0, 6) =>  RS_mx <= '1';
      when CONV_STD_LOGIC_VECTOR(63, 6) => RS_mx <= '0';--com
      when others => RS_mx <= '0';
   end case;
end process;
  
end imp;
