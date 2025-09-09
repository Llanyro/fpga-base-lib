library ieee;
library llanylib;

use ieee.std_logic_1164.ALL;
use llanylib.LlanySettings.all;

entity UniversalAsynchonousTransmitter3 is
	generic(
		MAX_BUS_SIZE			: NAT									:= 10;	-- Size range that bus can send data (1 start + 7 data + 1 parity + 2 stop)
		TICKS_PER_BIT			: NAT									:= 15	-- Number of clock ticks that is needed to complete 1 baud
	);
	port(
		tick_source				: in	SL;										-- Baudrate (multiplied by TICKS_PER_BIT)
		rst						: in	SL;										-- Module reset
		data					: in	SLV (MAX_BUS_SIZE - 1 downto 0);		-- Data to send
		bits_to_send			: in	NAT range 1 to MAX_BUS_SIZE - 1;		-- Number of bits to send
		data_valid				: in	SL;										-- If data to send is valid and prepared to be sent
		data_out				: out	SL								:= '0';	-- Channel to export bits
		is_active				: out	SL								:= '0'	-- In use, working, sending message
	);
end entity UniversalAsynchonousTransmitter3;

architecture UniversalAsynchonousTransmitter3Arch of UniversalAsynchonousTransmitter3 is
	constant TICKS_PER_BIT_L	: NAT									:= TICKS_PER_BIT	- 1;
	constant MAX_BUS_SIZE_L		: NAT									:= MAX_BUS_SIZE		- 1;
	signal counter				: NAT range 0 to TICKS_PER_BIT_L		:= 0;	-- Current tick
begin
	process(tick_source)
		variable index			: NAT range 0 to MAX_BUS_SIZE_L			:= 0;	-- Position of bit to get
	begin
		if rst = '1' then							-- Reset all
			index			:= 0;					-- Reset to default use
			counter			<= 0;					-- Reset to default use
			is_active			<= '0';				-- Tell module is inactive
			data_out		<= '1';					-- Set bus to high to contrast start bit
		elsif rising_edge(tick_source) then			-- Cycle function
			if data_valid = '0' then				-- No data to send, nothing to do (reset all)
				index		:= 0;					-- Reset to default use
				counter		<= 0;					-- Reset to default use
				is_active		<= '0';				-- Tell module is inactive
				data_out	<= '1';					-- Set bus to high to contrast start bit
			elsif counter = 0 then					-- First tick
				is_active		<= '1';				-- Tell user we are working
				data_out	<= data(index);			-- Send data
				counter		<= counter + 1;			-- Continue doing ticks
				index		:= index + 1;			-- Advance index
			elsif counter = TICKS_PER_BIT_L then	-- Max ticks reached
				counter		<= 0;					-- Reset counter
				if index = bits_to_send then		-- This bit was the last one to send
					is_active	<= '0';				-- Tell user we are no longer working
				end if;
			else counter	<= counter + 1;			-- Continue doing ticks
			end if;
		end if;
	end process;
end architecture UniversalAsynchonousTransmitter3Arch;
