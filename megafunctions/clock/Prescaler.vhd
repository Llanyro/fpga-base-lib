library ieee;
library llanylib;

use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.ALL;
use llanylib.LlanySettings.all;


entity ClockPrescaler is
	generic (
		INPUT_FREQ_HZ	: NAT	:= 100_000_000;  -- Default: 100 MHz
		OUTPUT_FREQ_HZ	: NAT	:= 1_000;        -- Default: 1 kHz
		DUTY_CYCLE		: FLOAT	:= 0.5           -- Range 0.0 to 1.0 (50%)
	);
	port (
		clk_in			: in  std_logic;
		rst				: in  std_logic;
		clk_out			: out std_logic
	);
end entity ClockPrescaler;

architecture behavioral of ClockPrescaler is
	-- Calculate number of clock cycles per output period
	constant CLK_DIVIDER : integer := INPUT_FREQ_HZ / OUTPUT_FREQ_HZ;
	-- Calculate number of cycles for high phase
	constant HIGH_CYCLES : integer := integer(round(real(CLK_DIVIDER) * DUTY_CYCLE));
	constant LOW_CYCLES  : integer := CLK_DIVIDER - HIGH_CYCLES;
	
	signal counter : integer range 0 to CLK_DIVIDER-1 := 0;
	signal output_reg : std_logic := '0';
begin
	assert (OUTPUT_FREQ_HZ <= INPUT_FREQ_HZ)
		report "Output frequency must be less than or equal to input frequency"
		severity failure;
	assert (DUTY_CYCLE >= 0.0 and DUTY_CYCLE <= 1.0)
		report "Duty cycle must be between 0.0 and 1.0"
		severity failure;

	process(clk_in, rst)
	begin
		if rst = '1' then
			counter <= 0;
			output_reg <= '0';
		elsif rising_edge(clk_in) then
			if counter < CLK_DIVIDER-1 then
				counter <= counter + 1;
			else
				counter <= 0;
			end if;
			
			-- Control duty cycle
			if counter < HIGH_CYCLES then
				output_reg <= '1';
			else
				output_reg <= '0';
			end if;
		end if;
	end process;

	clk_out <= output_reg;
end architecture behavioral;