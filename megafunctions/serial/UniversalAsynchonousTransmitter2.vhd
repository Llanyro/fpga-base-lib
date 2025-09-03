library ieee;
library llanylib;

use ieee.std_logic_1164.ALL;
use llanylib.LlanySettings.all;
use llanylib.LlanyUniversalReceiverTransmitterSettings.all;

entity UniversalAsynchonousTransmitter is
	generic(
		MAX_BUS_SIZE			: NAT									:= 8;						-- Size range that bus can send data
		TICKS_PER_BIT			: NAT									:= 16						-- Number of clock ticks that is needed to complete 1 baud
	);
	port(
		--sys_clk					: in	SL;														-- Any speed xTimes baud
		baud_clk				: in	SL;															-- 115200 bits second
		rst						: in	SL;															-- Module reset

		data					: in	SLV (MAX_BUS_SIZE - 1 downto 0);							-- Data to send
		bits_to_send			: in	NAT range 1 to MAX_BUS_SIZE - 1;							-- Number of bits to send
		data_valid				: in	SL;															-- If data to send is valid and prepared to be sent

		has_parity_bit			: in	SL;															-- If there is a parity bit
		extra_stop_bit			: in	SL;															-- If there is an extra stop bit

		data_out				: out	SL								:= '0';						-- Channel to export bits
		data_sent				: out	SL								:= '0';						-- Data is sent correctly
		active					: out	SL								:= '0'						-- In use, working, sending message
	);
end entity UniversalAsynchonousTransmitter;

architecture UniversalAsynchonousTransmitterArch of UniversalAsynchonousTransmitter is
	constant MAX_BUS_SIZE_L		: NAT									:= MAX_BUS_SIZE		- 1;	-- 
	constant TICKS_PER_BIT_L	: NAT									:= TICKS_PER_BIT	- 1;	-- 

	signal mode				: URTMode									:= URT_Idle;
	signal index			: NAT range 0 to MAX_BUS_SIZE_L				:= 0;						-- Position of bit to get
	signal counter			: NAT range 0 to TICKS_PER_BIT_L			:= 0;
	signal parity_mode		: SL										:= '0';

begin
	process(baud_clk, rst, data, data_valid, max_data_size, has_parity_bit, extra_stop_bit, data_out, data_sent, active)

	begin
		if rst = '1' then
			active					<= '0';				-- Set to inactive
			status					<= URT_Idle;		-- Reset uart status
			index					<= 0;				-- Reset index
			counter					<= 0;				-- Reset counter
			parity					<= '0';				-- Reset parity
			data_out				<= '1';				-- Set signal to high
			data_sent				<= '0';				-- Tell data is not set

		elsif rising_edge(baud_clk) then
			case status is
				when URT_Idle =>
					active			<= '0';				-- Emit we are not working
					data_out		<= '1';				-- Set signal to high

					if data_valid = '1' then			-- If data is prepared to be sent
						counter		<= 0;				-- Set counter to 0 prev next action
						status		<= URT_Start;
					end if;

				when URT_Start =>
					active			<= '1';				-- Emit to all that we are working
					counter			<= counter + 1;		-- Advancce to next tick
					data_out		<= '0';				-- Send 0 to emit an start bit

					if counter = TICKS_PER_BIT_L then	-- If we already wait for N ticks, we can continue
						counter		<= 0;				-- Reset counter
						index		<= 0;				-- Reset index
						parity		<= '0';				-- Reset parity
						status		<= URT_Data;		-- Update status to send bits next tick (next baud)
					end if;

				when URT_Data =>
					counter			<= counter + 1;		-- Advancce to next tick
					data_out		<= data(index);		-- Send bit in index position
					if counter = 0 then					-- Process this only one time
						if data(index) = '1' then		-- If data is a 1
							parity	<= not parity;		-- Negate parity to set number of 1
						end if;
					elsif counter = TICKS_PER_BIT_L then-- If we already wait for N ticks, we can continue
						index		<= index + 1;		-- Advance to next bit
						counter		<= 0;				-- Reset counter
						if index = bits_to_send - 1 then-- There is no more bits to send
							status	<= tern_uart(has_parity_bit, URT_Parity, URT_Stop);	-- Select check send parity or stop by user definition
						end if;
					end if;
					
				when URT_Parity =>
					data_out		<= parity;						-- Send stored parity
					counter			<= counter + 1;					-- Advancce to next tick
					if counter = TICKS_PER_BIT_L then				-- If we already wait for N ticks, we can continue
						index		<= 0;							-- Advance to next bit
						counter		<= 0;							-- Reset counter
						status		<= URT_Stop;					-- Jump to send stop bits
					end if;

				when URT_Stop =>
					data_out		<= '0';							-- Send stop bit
					counter			<= counter + 1;					-- Advancce to next tick
					if counter = 0 then								-- If its first tick
						index		<= index + 1;					-- Store number of stop bits sent
					elsif counter = TICKS_PER_BIT_L then			-- If we already wait for N ticks, we can continue
						if extra_stop_bit = '0' or index = 2 then	-- If we dont want an extra stop bit, or we already sent it
							status		<= URT_Cleanup;
						else
							counter		<= 0;						-- Restart counter to send next bit
						end if;
					end if;
				
				when URT_Cleanup =>
					data_sent			<= '1';						-- Tell user, data was sent correctly
					status				<= URT_Idle;				-- Reset to default status
				
				when others =>
					status				<= URT_Idle;				-- Reset to default status

			end case;
		end if;
	end process;
end architecture UniversalAsynchonousTransmitterArch;
