library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all; 

library UNISIM;
use UNISIM.VComponents.all;


entity dcm_pitanie is
  port (

	Clk_in : in  std_logic;
	
	Clk_out   : out  std_logic;
	Clk2x_out : out  std_logic

    );

end entity dcm_pitanie;



architecture IMP of dcm_pitanie is


--------------------------------------------------------------------------------------
-- signal
--------------------------------------------------------------------------------------
signal dcm_pitanie_CLK0: std_logic;
signal dcm_pitanie_CLK2X: std_logic;
signal dcm_pitanie_LOCKED: std_logic;
signal dcm_pitanie_CLKFB: std_logic;
signal dcm_pitanie_CLKIN: std_logic;
signal sys_clk: std_logic;




--signal gnd_bus                           : std_logic_vector(31 downto 0) := (others => '0');

begin  

--gnd_bus <= "00000000000000000000000000000000";

---------------------------------------------------------------------------
----------------clock section for pitanie----------------------------------------------
---------------------------------------------------------------------------
	
DCM_pitanie : DCM
generic map (
CLKDV_DIVIDE => 2.0, -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
-- 7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
CLKFX_DIVIDE => 1, -- Can be any interger from 1 to 32
CLKFX_MULTIPLY => 4, -- Can be any integer from 1 to 32
CLKIN_DIVIDE_BY_2 => FALSE, -- TRUE/FALSE to enable CLKIN divide by two feature
CLKIN_PERIOD => 20.0, -- Specify period of input clock
CLKOUT_PHASE_SHIFT => "NONE", -- Specify phase shift of NONE, FIXED or VARIABLE
CLK_FEEDBACK => "1X", -- Specify clock feedback of NONE, 1X or 2X
DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
-- an integer from 0 to 15
DFS_FREQUENCY_MODE => "LOW", -- HIGH or LOW frequency mode for frequency synthesis
DLL_FREQUENCY_MODE => "LOW", -- HIGH or LOW frequency mode for DLL
DUTY_CYCLE_CORRECTION => TRUE, -- Duty cycle correction, TRUE or FALSE
FACTORY_JF => X"C080", -- FACTORY JF Values
PHASE_SHIFT => 0, -- Amount of fixed phase shift from -255 to 255
STARTUP_WAIT => FALSE) -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
port map (
CLK0 => dcm_pitanie_CLK0, -- 0 degree DCM CLK ouptput
--CLK180 => CLK180, -- 180 degree DCM CLK output
--CLK270 => CLK270, -- 270 degree DCM CLK output
CLK2X => dcm_pitanie_CLK2X, -- 2X DCM CLK output
--CLK2X180 => CLK2X180, -- 2X, 180 degree DCM CLK out
--CLK90 => CLK90, -- 90 degree DCM CLK output
--CLKDV => CLKDV, -- Divided DCM CLK out (CLKDV_DIVIDE)
--CLKFX => CLKFX, -- DCM CLK synthesis out (M/D)
--CLKFX180 => CLKFX180, -- 180 degree CLK synthesis out
--LOCKED => dcm_pitanie_LOCKED, -- DCM LOCK status output
--PSDONE => PSDONE, -- Dynamic phase adjust done output
--STATUS => STATUS, -- 8-bit DCM status bits output
CLKFB => dcm_pitanie_CLKFB, -- DCM clock feedback
CLKIN => dcm_pitanie_CLKIN, -- Clock input (from IBUFG, BUFG or DCM)
PSCLK => '0',--PSCLK, -- Dynamic phase adjust clock input
PSEN => '0',--PSEN, -- Dynamic phase adjust enable input
PSINCDEC => '0',--PSINCDEC, -- Dynamic phase adjust increment/decrement
RST => '0' -- DCM asynchronous reset input
);	

dcm_pitanie_CLKFB <= sys_clk;
Clk_out <= sys_clk;


BUFG_sys_clk : BUFG
port map (
O => sys_clk, -- Clock buffer output
I => dcm_pitanie_CLK0 -- Clock buffer input
);

-- IBUFG: Single-ended global clock input buffer
-- All FPGA
-- Xilinx HDL Libraries Guide Version 8.1i
IBUFG_CLK : IBUFG
generic map (
IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-only)
IOSTANDARD => "DEFAULT")
port map (
O => dcm_pitanie_CLKIN, -- Clock buffer output
I => Clk_in -- Clock buffer input (connect directly to top-level port)
);


----fast uart clk--
BUFG_fast_clk : BUFG
port map (
O => Clk2x_out, -- Clock buffer output
I => dcm_pitanie_CLK2X -- Clock buffer input
);



end architecture IMP;

