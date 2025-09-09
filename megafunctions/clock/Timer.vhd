library ieee;
library llanylib;

use ieee.std_logic_1164.ALL;
use llanylib.LlanySettings.all;

entity Timer is
	generic(
		TICKS_CYCLE	: NAT							:= 15	-- Number of clock ticks that is needed to complete
	);
	port(
		clk			: in	SL;								-- Baudrate (multiplied by TICKS_PER_BIT)
		rst			: in	SL;								-- Module reset
		activate	: in	SL;								-- Activates counter
		completed	: out	SL					:= '0'		-- Tells if number of ticks has passed
	);
end entity Timer;

architecture TimerArch of Timer is
	signal counter	: NAT range 0 to TICKS_CYCLE	:= 0;	-- Current tick
begin
	process(clk, rst)
	begin
		if rst = '1' then									-- Reset all
			counter			<= 0;							-- Reset to default use
			completed		<= '0';							-- Tell that cycle is not completed
		elsif rising_edge(tick_source) then					-- Cycle function
			if activate = '1' then							-- If user activates this module
				counter		<= counter + 1;					-- Increment counter
				if counter	= TICKS_CYCLE then				-- If desired ticks has passed
					completed	<= '1';						-- Notify user
					counter		<= 0;						-- Reset counter
				end if;
			else
				completed	<= '0';
				counter		<= 0;
			end if;
		end if;
	end process;
end architecture TimerArch;
