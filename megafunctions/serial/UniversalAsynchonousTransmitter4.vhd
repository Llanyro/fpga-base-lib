library ieee;
library llanylib;

use ieee.std_logic_1164.ALL;
use llanylib.LlanySettings.all;

-- Update it to send at same time to diffeerent TX and different data vectors
-- Add a new generic number to indicate the matrix (MAX_BUS_SIZE * NUMBER_OF_TX)
-- Send all serial ports at same time
entity UniversalAsynchonousTransmitter4 is
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
end entity UniversalAsynchonousTransmitter4;

architecture UniversalAsynchonousTransmitter4Arch of UniversalAsynchonousTransmitter4 is
	constant TICKS_PER_BIT_L	: NAT									:= TICKS_PER_BIT	- 1;
	constant MAX_BUS_SIZE_L		: NAT									:= MAX_BUS_SIZE		- 1;
	signal activate_counter		: SL									:= '0';
	signal counter_completed	: SL									:= '0';
begin
	internal_timer	: llanylib.Timer
		generic map(
			TICKS_CYCLE	=> TICKS_PER_BIT_L
		)
		port map(
			clk			=> tick_source,
			rst			=> rst,
			activate	=> activate_counter,
			completed	=> counter_completed
		);

	process(tick_source)
		variable index			: NAT range 0 to MAX_BUS_SIZE_L			:= 0;	-- Position of bit to get
	begin
		if rst = '1' then								-- Reset all
			index						:= 0;			-- Reset to default use
			is_active					<= '0';			-- Tell module is inactive
			data_out					<= '1';			-- Set bus to high to contrast start bit
			activate_counter			<= '0';			-- Counter is not active

		elsif rising_edge(tick_source) then				-- Cycle function
			if data_valid = '0' then					-- No data to send, nothing to do (reset all)
				index					:= 0;			-- Reset to default use
				is_active				<= '0';			-- Tell module is inactive
				data_out				<= '1';			-- Set bus to high to contrast start bit
				activate_counter		<= '0';			-- Counter is not active
			else activate_counter = '1' then			-- We activated counter
				if counter_completed = '1' then			-- Counter has finished counting ticks
					activate_counter	<= '0';			-- Stop counter (it has finished)
					if index = bits_to_send then		-- Number of bits sent is same as requested to send
						is_active		<= '0';			-- Tell user module is no longer sending bits (it has finished sending it ans waiting last bit)
					end if;
				end if;
			else
				is_active				<= '1';			-- Tell user we are working
				data_out				<= data(index);	-- Send data
				index					:= index + 1;	-- Advance index
				activate_counter		<= '1';			-- Activate and wait counter to end its operation
			end if;
		end if;
	end process;
end architecture UniversalAsynchonousTransmitter4Arch;
